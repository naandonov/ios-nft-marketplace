//
//  NetworkingManager.swift
//  NFTMarketplace
//
//  Created by Nikolay Andonov on 2.12.22.
//

import Foundation
import Alamofire

final class NetworkingManager {
    static let sharedInstance: NetworkingManager = .init()
    private init() {}

    func getRequest<Output: Decodable>(for url: String,
                                       completion: @escaping (Result<Output, Error>) -> Void) {
        AF.request(url, method: .get)
            .responseDecodable(of: Output.self, decoder: JSONDecoder()) { response in
                switch response.result {
                case .success(let result):
                    completion(.success(result))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    func postRequest<Input: Encodable, Output: Decodable>(for url: String,
                                                          input: Input,
                                                          headers: [String: String] = [:],
                                                          completion: @escaping (Result<Output, Error>) -> Void) {
        AF.request(url,
                   method: .post,
                   parameters: input,
                   encoder: .json,
                   headers: .init(headers)).responseDecodable(of: Output.self) { response in
            switch response.result {
            case .success(let result):
                completion(.success(result))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Files Management
    
    func uploadImage<Output: Decodable>(url: String,
                                        imageType: String,
                                        imageData: Data,
                                        imageName: String,
                                        headers: [String: String] = [:],
                                        completion: @escaping (Result<Output, Error>) -> Void) {
        AF.upload(multipartFormData: { multiPart in
            multiPart.append(imageData, withName: "key", fileName: imageName, mimeType: "image/*")
        }, to: url, headers: .init(headers)).responseDecodable(of: Output.self) { response in
            switch response.result {
            case .success(let result):
                completion(.success(result))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func downloadData(url: String,
                      completion: @escaping (Result<Data?, Error>) -> Void) {
        AF.request(url, method: .get).response { response in
            switch response.result {
            case .success(let result):
                completion(.success(result))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
