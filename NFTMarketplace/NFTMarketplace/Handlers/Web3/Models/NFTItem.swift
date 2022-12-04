//
//  NFTItem.swift
//  NFTMarketplace
//
//  Created by Nikolay Andonov on 4.12.22.
//

import Foundation
import BigInt

struct NFTItem: Decodable {
    let itemID: Int
    let nftContractAddress: String
    let tokenID: Int
    let seller: String
    let owner: String
    let price: Int
    let collectionID: Int
    let isSold: Bool
}
