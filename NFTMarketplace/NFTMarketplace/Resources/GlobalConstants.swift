//
//  GlobalConstants.swift
//  NFTMarketplace
//
//  Created by Nikolay Andonov on 1.12.22.
//

import Foundation

enum GlobalConstants {
    static let walletConnectProjectID = "<ID>"
    
    static let ipfsProjectID = "<ID>"
    static let ipfsSecret = "<Secret>"
    static let ipfsAPIEndpoint = "https://ipfs.infura.io:5001"
    static let ipfsAccessHost = "https://nft-marketplace-ios.infura-ipfs.io/ipfs"
    
    static let nftContractAddress = "<Contract Address>"
    static let nftMarketplaceContractAddress = "<Contract Address>"
    
    static let contractOwnerPublicAddress = "<Address>"
    static let emptyAddress = "0x0000000000000000000000000000000000000000"
    
    static let openAPIHost = "https://api.openai.com"
    static let openAPIKey = "sk-<KEY>"
}
