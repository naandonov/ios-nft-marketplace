//
//  Web3Transactions.swift
//  NFTMarketplace
//
//  Created by Nikolay Andonov on 3.12.22.
//

import Foundation
import WalletConnectSwift
import Web3ContractABI
import BigInt

final class Web3TransactionsHandler {
    enum CustomError: Error {
        case invalidInput
    }
    struct CallRequest: Encodable {
        let data: String
        let to: String
        let from: String?
        
        var ethMethod: String {
            "eth_call"
        }
    }
    
    struct SendTransactionRequest: Encodable {
        let data: String
        let fromAddress: String
        let toAddress: String
        let value: String?
        
        var ethMethod: String {
            "eth_sendTransaction"
        }
    }
    
    private var client: Client?
    func setClient(_ client: Client) {
        self.client = client
    }
    
    func invalidateClient() {
        self.client = nil
    }
    
    func call<Output: Decodable>(with request: CallRequest,
                                 pairingURI: WCURL,
                                 completion: @escaping (Result<Output, Error>) -> Void) {
        guard let parameters = try? request.asDictionary(),
              let client = client,
              let request = try? Request(url: pairingURI,
                                         method: request.ethMethod,
                                         params: [parameters]) else {
            completion(.failure(CustomError.invalidInput))
            return
        }
        
        try? client.send(request, completion: { response in
            do {
                let result = try response.result(as: Output.self)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        })
    }
    
    func sendTransaction<Output: Decodable>(with request: SendTransactionRequest,
                                            pairingURI: WCURL,
                                            completion: @escaping (Result<Output, Error>) -> Void) {
        let transaction = Client.Transaction(from: request.fromAddress,
                                             to: request.toAddress,
                                             data: request.data,
                                             gas: nil,
                                             gasPrice: nil,
                                             value: request.value,
                                             nonce: nil,
                                             type: nil,
                                             accessList: nil,
                                             chainId: nil,
                                             maxPriorityFeePerGas: nil,
                                             maxFeePerGas: nil)
        try? client?.eth_sendTransaction(url: pairingURI,
                                         transaction: transaction,
                                         completion: { response in
            do {
                let result = try response.result(as: Output.self)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        })
    }
}
