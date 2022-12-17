//
//  GlobalConstants.swift
//  NFTMarketplace
//
//  Created by Nikolay Andonov on 1.12.22.
//

import Foundation

enum GlobalConstants {
    static let ipfsProjectID = UserDefaults.standard.object(forKey: "ipfsProjectID") as? String ?? ""
    static let ipfsSecret = UserDefaults.standard.object(forKey: "ipfsSecret") as? String ?? ""
    static let ipfsAPIEndpoint = "https://ipfs.infura.io:5001"
    static let ipfsAccessHost = "https://nft-marketplace-ios.infura-ipfs.io/ipfs"
    
    static let nftContractAddress = "0xF30070c5481974eE2B8BC6849cD2593D1cb83423"
    static let nftMarketplaceContractAddress = "0x5857f727998288a562b9c65f5E5198b9EbB75135"
    
    static let contractOwnerPublicAddress = "0x3D1bf2A5EFE4be1D0EFeD337eda3a90B925Ab163"
    static let emptyAddress = "0x0000000000000000000000000000000000000000"
    
    static let openAPIHost = "https://api.openai.com"
    static let openAPIKey = UserDefaults.standard.object(forKey: "openAPIKey") as? String ?? ""
}
