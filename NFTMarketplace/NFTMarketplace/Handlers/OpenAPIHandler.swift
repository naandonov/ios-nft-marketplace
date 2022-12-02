//
//  OpenAPIHandler.swift
//  NFTMarketplace
//
//  Created by Nikolay Andonov on 2.12.22.
//

import Foundation
import WalletConnectSwift

final class OpenAPIHandler {
    static let sharedInstance: OpenAPIHandler = .init()
    private init() {}
    
    private let networkingManager: NetworkingManager = .sharedInstance
    
    private lazy var authorizationHeaders: [String: String] = {
        return ["Authorization" : "Bearer \(GlobalConstants.openAPIKey)"]
    }()
    
    private enum Endpoint: String {
        case generateImage = "/v1/images/generations"
        
        var url: String {
            GlobalConstants.openAPIHost + self.rawValue
        }
    }
    
    func requestImage(of content: String,
                      size: ImageGenerationRequest.Size,
                      completion: @escaping (Result<ImageGenerationResult.Data?, Error>) -> Void ) {
        let request = ImageGenerationRequest(content: content,
                                             number: 1,
                                             size: size)
        networkingManager.postRequest(for: Endpoint.generateImage.url,
                                      input: request,
                                      headers: authorizationHeaders,
                                      completion: { (response: Result<ImageGenerationResult, Error>) in
            switch response {
            case .success(let result):
                completion(.success(result.data.first))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
}
