//
//  ImageGenerationResult.swift
//  NFTMarketplace
//
//  Created by Nikolay Andonov on 2.12.22.
//

import Foundation

struct ImageGenerationResult: Decodable {
    struct Data: Decodable {
        let url: String
    }
    let created: TimeInterval
    let data: [Data]
}
