//
//  Token.swift
//  NFTMarketplace
//
//  Created by Nikolay Andonov on 4.12.22.
//

import Foundation

struct Token: Decodable {
    let tokenURI: String
    let wasListed: Bool
}
