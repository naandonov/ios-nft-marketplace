//
//  Web3Coordinator.swift
//  NFTMarketplace
//
//  Created by Nikolay Andonov on 3.12.22.
//

import Foundation
import WalletConnectSwift
import Web3
import Web3ContractABI

protocol Web3CoordinatorDelegate: AnyObject {
    func shoundInteractWithExternalWallet(with pairingURI: String)
    func didConnect()
    func didDisconnect()
    func didFailToConnect(error: Error)
}

final class Web3Coordinator {
    enum CustomError: Error {
        case general
        case invalidData
        case noConnectionWasEstablished
        case parsingError
    }
    
    static let sharedInstance: Web3Coordinator = .init()
    
    private let walletConnectHandler: WalletConnectHandler
    private let dataComposer: Web3DataComposer?
    private let transactionHandler: Web3TransactionsHandler
    
    weak var delegate: Web3CoordinatorDelegate?
    
    private init() {
        walletConnectHandler = WalletConnectHandler()
        dataComposer = .init()
        transactionHandler = .init()
        walletConnectHandler.delegate = self
    }
    
    var isWalletConnected: Bool {
        return walletConnectHandler.sessionExists
    }
    
    func initiateConnection() {
        guard let pairingURI = try? walletConnectHandler.connect() else {
            delegate?.didFailToConnect(error: CustomError.invalidData)
            return
        }
        
        if !walletConnectHandler.sessionExists {
            delegate?.shoundInteractWithExternalWallet(with: pairingURI)
        }
    }
}

// MARK: - Web3 WalletConnectDelegate

extension Web3Coordinator: WalletConnectDelegate {
    func didFailToConnect() {
        delegate?.didFailToConnect(error: CustomError.general)
    }
    
    func didConnect(with client: Client) {
        transactionHandler.setClient(client)
        delegate?.didConnect()
    }

    func didDisconnect() {
        transactionHandler.invalidateClient()
        delegate?.didDisconnect()
    }
}


// MARK: - Web3 API

extension Web3Coordinator {
    func createNFTCollection(name: String, completion: @escaping (Result<String, Error>) -> Void) {
        let functionMethod = Web3DataComposer.FunctionMethod.createNFTCollection(name: name)
        guard let data = dataComposer?.generateSendTransactionRequestHexData(for: functionMethod),
              // TODO: Introduce custom logic when multiple accounts are present
              let walletAddress = walletConnectHandler.walletAccounts.first,
              let pairingURI = walletConnectHandler.pairingURI else {
            completion(.failure(CustomError.invalidData))
            return
        }
        let transation = Web3TransactionsHandler.SendTransactionRequest(data: data,
                                                                        fromAddress: walletAddress,
                                                                        toAddress: functionMethod.contract.address,
                                                                        value: nil)
        transactionHandler.sendTransaction(with: transation,
                                           pairingURI: pairingURI,
                                           completion: { (response: Result<String, Error>) in
            completion(response)
        })
        delegate?.shoundInteractWithExternalWallet(with: pairingURI.absoluteString)
    }
    
    func createToken(tokenURI: String, completion: @escaping (Result<String, Error>) -> Void) {
        let functionMethod = Web3DataComposer.FunctionMethod.createToken(tokenURI: tokenURI)
        guard let data = dataComposer?.generateSendTransactionRequestHexData(for: functionMethod),
              // TODO: Introduce custom logic when multiple accounts are present
              let walletAddress = walletConnectHandler.walletAccounts.first,
              let pairingURI = walletConnectHandler.pairingURI else {
            completion(.failure(CustomError.invalidData))
            return
        }
        let transation = Web3TransactionsHandler.SendTransactionRequest(data: data,
                                                                        fromAddress: walletAddress,
                                                                        toAddress: functionMethod.contract.address,
                                                                        value: nil)
        transactionHandler.sendTransaction(with: transation,
                                           pairingURI: pairingURI,
                                           completion: { (response: Result<String, Error>) in
            completion(response)
        })
        delegate?.shoundInteractWithExternalWallet(with: pairingURI.absoluteString)
    }
    
    func getAllNFTCollections(completion: @escaping (Result<[NFTCollection], Error>) -> Void) {
        let functionMethod = Web3DataComposer.FunctionMethod.getAllNFTCollections
        guard let data = dataComposer?.generateCallRequestHexData(for: functionMethod),
              let pairingURI = walletConnectHandler.pairingURI else {
            completion(.failure(CustomError.invalidData))
            return
        }
        transactionHandler.call(with: .init(data: data,
                                            to: functionMethod.contract.address,
                                            from: nil),
                                pairingURI: pairingURI,
                                completion: { (response: Result<String, Error>) in
            switch response {
            case .success(let value):
                guard let json = try? ABI.decodeParameter(type: .string, from: value) as? String,
                      let jsonData = json.data(using: .utf8),
                      let deserializedData = try? JSONDecoder().decode([NFTCollection].self, from: jsonData) else {
                    completion(.failure(CustomError.parsingError))
                    return
                }
                completion(.success(deserializedData))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    func getListingFee(completion: @escaping (Result<BigUInt, Error>) -> Void) {
        let functionMethod = Web3DataComposer.FunctionMethod.getListingFee
        guard let data = dataComposer?.generateCallRequestHexData(for: functionMethod),
              let pairingURI = walletConnectHandler.pairingURI else {
            completion(.failure(CustomError.invalidData))
            return
        }
        transactionHandler.call(with: .init(data: data,
                                            to: functionMethod.contract.address,
                                            from: nil),
                                pairingURI: pairingURI,
                                completion: { [weak dataComposer] (response: Result<String, Error>) in
            switch response {
            case .success(let value):
                guard let result = dataComposer?.decodeUInt256(from: value) else {
                    completion(.failure(CustomError.parsingError))
                    return
                }
                completion(.success(result))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    func getAllTokens(completion: @escaping (Result<[Token], Error>) -> Void) {
        let functionMethod = Web3DataComposer.FunctionMethod.getAllTokens
        guard let data = dataComposer?.generateCallRequestHexData(for: functionMethod),
              let pairingURI = walletConnectHandler.pairingURI,
              // TODO: Introduce custom logic when multiple accounts are present
              let walletAddress = walletConnectHandler.walletAccounts.first else {
            completion(.failure(CustomError.invalidData))
            return
        }
        transactionHandler.call(with: .init(data: data,
                                            to: functionMethod.contract.address,
                                            from: walletAddress),
                                pairingURI: pairingURI,
                                completion: { [weak dataComposer] (response: Result<String, Error>) in
            switch response {
            case .success(let value):
                guard let json = dataComposer?.decodeString(from: value),
                      let jsonData = json.data(using: .utf8),
                      let deserializedData = try? JSONDecoder().decode([Token].self, from: jsonData) else {
                    completion(.failure(CustomError.parsingError))
                    return
                }
                completion(.success(deserializedData))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    func getTokenURI(tokenID: Int, completion: @escaping (Result<String, Error>) -> Void) {
        let functionMethod = Web3DataComposer.FunctionMethod.getTokenURI(tokenID: tokenID)
        guard let data = dataComposer?.generateCallRequestHexData(for: functionMethod),
              let pairingURI = walletConnectHandler.pairingURI else {
            completion(.failure(CustomError.invalidData))
            return
        }
        transactionHandler.call(with: .init(data: data,
                                            to: functionMethod.contract.address,
                                            from: nil),
                                pairingURI: pairingURI,
                                completion: { [weak dataComposer] (response: Result<String, Error>) in
            switch response {
            case .success(let value):
                guard let result = dataComposer?.decodeString(from: value) else {
                    completion(.failure(CustomError.parsingError))
                    return
                }
                completion(.success(result))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    func listNFTForSale(tokenID: Int,
                        price: BigUInt,
                        collectionID: Int,
                        value: BigUInt,
                        completion: @escaping (Result<String, Error>) -> Void) {
        guard let nftContractAddress = try? EthereumAddress(hex: GlobalConstants.nftContractAddress, eip55: true) else {
            completion(.failure(CustomError.invalidData))
            return
        }
        
        let functionMethod = Web3DataComposer.FunctionMethod.listNFTItem(address: nftContractAddress,
                                                                         tokenID: tokenID,
                                                                         price: price,
                                                                         collectionID: collectionID)
        guard let data = dataComposer?.generateSendTransactionRequestHexData(for: functionMethod),
              // TODO: Introduce custom logic when multiple accounts are present
              let walletAddress = walletConnectHandler.walletAccounts.first,
              let pairingURI = walletConnectHandler.pairingURI else {
            completion(.failure(CustomError.invalidData))
            return
        }
      
        
        let transation = Web3TransactionsHandler.SendTransactionRequest(data: data,
                                                                        fromAddress: walletAddress,
                                                                        toAddress: functionMethod.contract.address,
                                                                        value: value.hexRepresentation)
        transactionHandler.sendTransaction(with: transation,
                                           pairingURI: pairingURI,
                                           completion: { (response: Result<String, Error>) in
            completion(response)
        })
        delegate?.shoundInteractWithExternalWallet(with: pairingURI.absoluteString)
    }
    
    func buyNFT(tokenID: Int, value: BigUInt, completion: @escaping (Result<String, Error>) -> Void) {
        guard let nftContractAddress = try? EthereumAddress(hex: GlobalConstants.nftContractAddress, eip55: true) else {
            completion(.failure(CustomError.invalidData))
            return
        }
        let functionMethod = Web3DataComposer.FunctionMethod.buyNFT(address: nftContractAddress, tokenID: tokenID)
        guard let data = dataComposer?.generateSendTransactionRequestHexData(for: functionMethod),
              // TODO: Introduce custom logic when multiple accounts are present
              let walletAddress = walletConnectHandler.walletAccounts.first,
              let pairingURI = walletConnectHandler.pairingURI else {
            completion(.failure(CustomError.invalidData))
            return
        }
        let transation = Web3TransactionsHandler.SendTransactionRequest(data: data,
                                                                        fromAddress: walletAddress,
                                                                        toAddress: functionMethod.contract.address,
                                                                        value: value.hexRepresentation)
        transactionHandler.sendTransaction(with: transation,
                                           pairingURI: pairingURI,
                                           completion: { (response: Result<String, Error>) in
            completion(response)
        })
        delegate?.shoundInteractWithExternalWallet(with: pairingURI.absoluteString)
    }
    
    func getNFTItems(collectionID: Int, completion: @escaping (Result<[NFTItem], Error>) -> Void) {
        let functionMethod = Web3DataComposer.FunctionMethod.getNFTItems(collectionID: collectionID)
        guard let data = dataComposer?.generateCallRequestHexData(for: functionMethod),
              let pairingURI = walletConnectHandler.pairingURI,
              // TODO: Introduce custom logic when multiple accounts are present
              let walletAddress = walletConnectHandler.walletAccounts.first else {
            completion(.failure(CustomError.invalidData))
            return
        }
        transactionHandler.call(with: .init(data: data,
                                            to: functionMethod.contract.address,
                                            from: walletAddress),
                                pairingURI: pairingURI,
                                completion: { [weak dataComposer] (response: Result<String, Error>) in
            switch response {
            case .success(let value):
                guard let json = dataComposer?.decodeString(from: value),
                      let jsonData = json.data(using: .utf8),
                      let deserializedData = try? JSONDecoder().decode([NFTItem].self, from: jsonData) else {
                    completion(.failure(CustomError.parsingError))
                    return
                }
                completion(.success(deserializedData))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
}

// MARK: - Utilies

private extension BigUInt {
    var hexRepresentation: String? {
        var hexValue: String?
        if let encodedValue = abiEncode(dynamic: true)?.replacingOccurrences(of: "^0+", with: "", options: .regularExpression) {
            hexValue = "0x" + encodedValue
        }
        return hexValue
    }
}
