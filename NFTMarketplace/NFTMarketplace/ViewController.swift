//
//  ViewController.swift
//  NFTMarketplace
//
//  Created by Nikolay Andonov on 1.12.22.
//

import UIKit
import CryptoSwift
import BigInt

class ViewController: UIViewController {

//    let wc = WalletConnectHandler(delegate: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        Web3Coordinator.sharedInstance.initiateConnection()
        Web3Coordinator.sharedInstance.delegate = self
        
//        let urlCon = try? wc.connect()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: { [weak self] in
//            if !(self?.wc.sessionExists ?? true) {
//                let url = URL(string: urlCon!)!
//                if UIApplication.shared.canOpenURL(url) {
//                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
//                }
//            }
//        })
        
        
        
    }


}

extension ViewController: Web3CoordinatorDelegate {
    func shoundInteractWithExternalWallet(with pairingURI: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: { [weak self] in
            let url = URL(string: pairingURI)!
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        })
    }
    
    func didConnect() {
//        Web3Coordinator.sharedInstance.createNFTCollection(name: "Beeple", completion: { response in
//            switch response {
//            case .success(let value):
//                print(value)
//            case .failure(let error):
//                print(error)
//            }
//        })
        
//        Web3Coordinator.sharedInstance.getListingFee(completion: { response in
//            switch response {
//            case .success(let value):
//                print(value)
//            case .failure(let error):
//                print(error)
//            }
//
//        })
        
//        Web3Coordinator.sharedInstance.createToken(tokenURI: "wc:test-uri2", completion: { response in
//            switch response {
//            case .success(let value):
//                print(value)
//            case .failure(let error):
//                print(error)
//            }
//        })
        
//        Web3Coordinator.sharedInstance.getTokenURI(tokenID: 1, completion: { response in
//            switch response {
//            case .success(let value):
//                print(value)
//            case .failure(let error):
//                print(error)
//            }
//        })
        let val = try! BigUInt("1000000000000")
        let fee = BigUInt("10000000000000000")
        
//        Web3Coordinator.sharedInstance.listNFTForSale(tokenID: 1, price:  val, collectionID: 1, value: fee, completion: { response in
//            switch response {
//            case .success(let value):
//                print(value)
//            case .failure(let error):
//                print(error)
//            }
//        })
     
//        Web3Coordinator.sharedInstance.buyNFT(tokenID: 1, value: val, completion: { response in
//            print(response)
//
//        })
        
//        Web3Coordinator.sharedInstance.getNFTItems(collectionID: 1) { response in
//            switch response {
//            case .success(let value):
//                print(value)
//            case .failure(let error):
//                print(error)
//            }
//        }
    }
    
    func didDisconnect() {
        
    }
    
    func didFailToConnect(error: Error) {
        
    }
    
    
}

