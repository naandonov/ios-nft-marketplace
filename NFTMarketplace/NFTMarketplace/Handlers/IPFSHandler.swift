//
//  IPFSHandler.swift
//  NFTMarketplace
//
//  Created by Nikolay Andonov on 2.12.22.
//

import Foundation
import Alamofire

final class IPFSHandler {
    static let sharedInstance: IPFSHandler = .init()
    private init() {}
    
    private let networkingManager: NetworkingManager = .sharedInstance
    
    private lazy var authorizationHeaders: [String: String] = {
        var autorization = GlobalConstants.ipfsProjectID + ":" + GlobalConstants.ipfsSecret
        autorization = autorization.toBase64()
        return ["Authorization" : "Basic \(autorization)"]
    }()
    
    enum IPFSHandlerError: Error {
        case invalidAssetURL
        case invalidData
    }
    
    private enum Endpoint: String {
        case upload = "/api/v0/add"
        
        var url: String {
            GlobalConstants.ipfsAPIEndpoint + self.rawValue
        }
    }
    
    func uploadAsset(url: String, completion: @escaping (Result<IPFSResult, Error>) -> Void) {
        networkingManager.downloadData(url: url, completion: { [weak self] response in
            switch response {
            case .success(let data):
                if let data = data {
                    self?.uploadAsset(assetData: data, completion: completion)
                } else {
                    completion(.failure(IPFSHandlerError.invalidData))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    func uploadAsset(assetData: Data, completion: @escaping (Result<IPFSResult, Error>) -> Void) {
        networkingManager.uploadImage(url: Endpoint.upload.url,
                                      imageType: "png",
                                      imageData: assetData,
                                      imageName: UUID().uuidString,
                                      headers: authorizationHeaders,
                                      completion: { (result: Result<IPFSResult, Error>) in
            switch result {
            case .success(let value):
                completion(.success(value))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
}
