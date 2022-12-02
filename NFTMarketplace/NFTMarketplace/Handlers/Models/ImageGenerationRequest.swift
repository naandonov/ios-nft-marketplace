//
//  ImageGenerationRequest.swift
//  NFTMarketplace
//
//  Created by Nikolay Andonov on 2.12.22.
//

import Foundation

struct ImageGenerationRequest: Encodable {
    enum Size: String, Encodable {
        case x256 = "256x256"
        case x512 = "512x512"
        case x1024 = "1024x1024"
    }
    
    let content: String
    let number: Int
    let size: Size
    
    enum CodingKeys: String, CodingKey {
        case content = "prompt"
        case number = "n"
        case size
    }
}
