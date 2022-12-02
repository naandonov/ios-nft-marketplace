//
//  IPFSResult.swift
//  NFTMarketplace
//
//  Created by Nikolay Andonov on 2.12.22.
//

import Foundation

struct IPFSResult: Decodable {
    let hash: String
    let name: String
    let size: String
    
    enum CodingKeys: String, CodingKey {
        case hash = "Hash"
        case name = "Name"
        case size = "Size"
    }
    
    var uri: String {
        GlobalConstants.ipfsAccessHost + "/\(hash)"
    }
}
