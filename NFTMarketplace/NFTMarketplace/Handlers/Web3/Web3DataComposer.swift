//
//  Web3DataComposer.swift
//  NFTMarketplace
//
//  Created by Nikolay Andonov on 3.12.22.
//

import Foundation
import Web3
import Web3ContractABI

final class Web3DataComposer {
    enum Contract: String {
        case nft = "nftABI"
        case nftMarketplace = "nftMarketplaceABI"
        
        var extensionType: String {
            "json"
        }
        
        var address: String {
            switch self {
            case .nft:
                return GlobalConstants.nftContractAddress
            case .nftMarketplace:
                return GlobalConstants.nftMarketplaceContractAddress
            }
        }
    }
    
    enum FunctionMethod {
        case getAllNFTCollections
        case getListingFee
        case createNFTCollection(name: String)
        case listNFTItem(address: EthereumAddress, tokenID: Int, price: BigUInt, collectionID: Int)
        case buyNFT(address: EthereumAddress, tokenID: Int)
        case getNFTItems(collectionID: Int)
        
        case createToken(tokenURI: String)
        case getAllTokens
        case getTokenURI(tokenID: Int)
        
        var contract: Contract {
            switch self {
            case .getAllNFTCollections, .getListingFee, .createNFTCollection,
                    .listNFTItem, .buyNFT, .getNFTItems:
                return .nftMarketplace
            case .createToken, .getAllTokens, .getTokenURI:
                return .nft
            }
        }
        
        var name: String {
            switch self {
            case .getAllNFTCollections:
                return "getAllNFTCollectionsRaw"
            case .getListingFee:
                return "getListingFee"
            case .createNFTCollection:
                return "createNFTCollection"
            case .createToken:
                return "createToken"
            case .getAllTokens:
                return "getUnlistedNFTItemsRaw"
            case .getTokenURI:
                return "tokenURI"
            case .listNFTItem:
                return "createNFTItem"
            case .buyNFT:
                return "buyNFTItem"
            case .getNFTItems:
                return "getNFTItemsRaw"
            }
        }
        
        var parameters: [ABIEncodable] {
            switch self {
            case .getAllNFTCollections, .getListingFee, .getAllTokens:
                return []
            case .createNFTCollection(name: let value), .createToken(tokenURI: let value):
                return [value]
            case .getTokenURI(tokenID: let value), .getNFTItems(collectionID: let value):
                return [value]
            case .listNFTItem(address: let address, tokenID: let tokenID, price: let price, collectionID: let collectionID):
                return [address, tokenID, price, collectionID]
            case .buyNFT(address: let address, tokenID: let tokenID):
                return [address, tokenID]
            }
        }
    }
    
    private let nftContractData: Data
    private let nftMarketplaceContractData: Data
    private let web3 = Web3(rpcURL: "")
    private let ownerAddress: EthereumAddress
    
    init?() {
        guard let nftContractURL = Bundle.main.url(forResource: Contract.nft.rawValue,
                                                   withExtension: Contract.nft.extensionType),
              let nftMarketplaceContractURL = Bundle.main.url(forResource: Contract.nftMarketplace.rawValue,
                                                              withExtension: Contract.nftMarketplace.extensionType),
              let nftContractData = try? Data(contentsOf: nftContractURL),
              let nftMarketplaceContractData = try? Data(contentsOf: nftMarketplaceContractURL),
              let ownerAddress = try? EthereumAddress(hex: GlobalConstants.contractOwnerPublicAddress, eip55: true) else {
            return nil
        }
        self.nftContractData = nftContractData
        self.nftMarketplaceContractData = nftMarketplaceContractData
        self.ownerAddress = ownerAddress
    }
    
    // MARK: - Encoding
    
    func generateCallRequestHexData(for functionMethod: FunctionMethod) -> String? {
        let abiData = abiData(for: functionMethod.contract)
        guard let contract = try? web3.eth.Contract(json: abiData, abiKey: nil, address: ownerAddress),
              let functionInvocation = contract[name: functionMethod.name, isReadOnly: true] else {
            return nil
        }
        
        let transaction = functionInvocation(functionMethod.parameters).createCall()
        return transaction?.data?.hex()
    }
    
    func generateSendTransactionRequestHexData(for functionMethod: FunctionMethod) -> String? {
        let abiData = abiData(for: functionMethod.contract)
        guard let contract = try? web3.eth.Contract(json: abiData, abiKey: nil, address: ownerAddress),
              let functionInvocation = contract[name: functionMethod.name, isReadOnly: false] else {
            return nil
        }
        let transaction = functionInvocation(functionMethod.parameters).createTransaction(nonce: nil,
                                                                                          gasPrice: nil,
                                                                                          maxFeePerGas: nil,
                                                                                          maxPriorityFeePerGas: nil,
                                                                                          gasLimit: nil,
                                                                                          from: nil,
                                                                                          value: nil,
                                                                                          accessList: [:],
                                                                                          transactionType: .legacy)
        return transaction?.data.hex()
    }
    
    // MARK: - Decoding
    
    func decodeUInt256(from value: String) -> BigUInt? {
        return try? ABI.decodeParameter(type: .uint256, from: value) as? BigUInt
    }
    
    func decodeString(from value: String) -> String? {
        return try? ABI.decodeParameter(type: .string, from: value) as? String
    }
}

// MARK: - Utitlities

private extension Web3DataComposer {
    func abiData(for contract: Contract) -> Data {
        switch contract {
        case .nft:
            return nftContractData
        case .nftMarketplace:
            return nftMarketplaceContractData
        }
    }
}

// MARK: - Web3

fileprivate extension SolidityFunction {
    func invokeReadOnly(_ inputs: [ABIEncodable]) -> SolidityInvocation {
        return SolidityReadInvocation(method: self, parameters: inputs, handler: handler)
    }
    
    func invokeWrite(_ inputs: [ABIEncodable]) -> SolidityInvocation {
        return SolidityPayableInvocation(method: self, parameters: inputs, handler: handler)
    }
}

fileprivate extension DynamicContract {
    subscript(name name: String, isReadOnly isReadOnly: Bool) -> (([ABIEncodable]) -> SolidityInvocation)? {
        if isReadOnly {
            return methods[name]?.invokeReadOnly
        } else {
            return methods[name]?.invokeWrite
        }
    }
}
