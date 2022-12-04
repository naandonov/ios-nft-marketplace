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

struct NFTComposedItem: Decodable {
    let itemID: Int
    let nftContractAddress: String
    let tokenID: Int
    let seller: String
    let owner: String
    let price: Int
    let collectionID: Int
    let isSold: Bool
    let tokenURI: String
    
    init(item: NFTItem, tokenURI: String) {
        self.itemID = item.itemID
        self.nftContractAddress = item.nftContractAddress
        self.tokenID = item.tokenID
        self.seller = item.seller
        self.owner = item.owner
        self.price = item.price
        self.collectionID = item.collectionID
        self.isSold = item.isSold
        self.tokenURI = tokenURI
    }
}
