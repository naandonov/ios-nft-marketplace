//
//  MainTabBarController.swift
//  NFTMarketplace
//
//  Created by Nikolay Andonov on 4.12.22.
//

import UIKit
import BigInt

protocol Web3DataSourceUpdatable {
    func didUpdateWeb3DataSource(_ dataSource: Web3DataSource)
}

struct Web3DataSource {
    let listingPrice: BigUInt
    let ownedTokens: [Token]
    let collections: [NFTCollection]
    let listedNFTItems: [NFTComposedItem]
}

class MainTabBarController: UITabBarController {
    private let web3Coordinator = Web3Coordinator.sharedInstance
    private let ipfsHandler = IPFSHandler.sharedInstance

    private lazy var authenticationViewController: AuthenticationViewController? = {
        return storyboard?.instantiateViewController(withIdentifier: "AuthenticationViewController") as? AuthenticationViewController
    }()
    private var createNFTViewController: CreateNFTViewController?
    private var inventoryViewController: InventoryViewController?
    private var marketViewController: MarketViewController?
    
    private var web3DataSource: Web3DataSource?
    private lazy var overlayView: UIView = {
        let view = UIView(frame: view.bounds)
        view.backgroundColor = UIColor.primaryBlue
        view.isHidden = true
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        web3Coordinator.delegate = self
        view.addSubview(overlayView)
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        web3Coordinator.initiateConnection()
        delegate = self
        
        for viewController in viewControllers ?? [] {
            if let createNFTViewController = viewController as? CreateNFTViewController {
                self.createNFTViewController = createNFTViewController
                self.createNFTViewController?.delegate = self
            } else if let inventoryViewController = viewController as? InventoryViewController {
                self.inventoryViewController = inventoryViewController
                self.inventoryViewController?.delegate = self
            } else if let marketViewController = viewController as? MarketViewController {
                self.marketViewController = marketViewController
                self.marketViewController?.delegate = self
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !web3Coordinator.isWalletConnected {
            presentAuthentication(shouldAnimate: false)
        }
    }
    
    func presentAuthentication(shouldAnimate: Bool = true) {
        guard let viewController = authenticationViewController else {
            return
        }
        viewController.delegate = self
        present(viewController, animated: shouldAnimate)
    }
    
    private func loadWeb3DataSource() {
        view.startLoadingIndicator()
        
        let group = DispatchGroup()
        
        var tokens: [Token] = []
        group.enter()
        web3Coordinator.getAllTokens(completion: { response in
            if case let .success(result) = response {
                tokens = result
            }
            group.leave()
        })
        
        var listingPrice = BigUInt.zero
        group.enter()
        web3Coordinator.getListingFee(completion: { response in
            if case let .success(result) = response {
                listingPrice = result
            }
            group.leave()
        })
        
        var collections: [NFTCollection] = []
        group.enter()
        web3Coordinator.getAllNFTCollections(completion: { response in
            if case let .success(result) = response {
                collections = result
            }
            group.leave()
        })
    
        group.notify(queue: .main) { [weak self] in
            self?.loadWeb3DataSourceItemsSegregation(tokens: tokens, collections: collections, listingPrice: listingPrice)
        }
    }
    
    private func loadWeb3DataSourceItemsSegregation(tokens: [Token], collections: [NFTCollection], listingPrice: BigUInt) {
        let group = DispatchGroup()
        let subGroup = DispatchGroup()

        var items: [NFTComposedItem] = []
        for collection in collections {
            group.enter()
            web3Coordinator.getNFTItems(collectionID: collection.collectionID, completion: { [weak self] response in
                guard case let .success(result) = response else {
                    group.leave()
                    return
                }
                
                for item in result {
                    subGroup.enter()
                    self?.web3Coordinator.getTokenURI(tokenID: item.tokenID, completion: { response in
                        if case let .success(result) = response {
                            let composedItem = NFTComposedItem(item: item, tokenURI: result)
                            items.append(composedItem)
                        }
                        subGroup.leave()
                    })
                }
                subGroup.notify(queue: .global()) {
                    group.leave()
                }
            })
        }
        
        group.notify(queue: .main) { [weak self] in
            let web3DataSource = Web3DataSource(listingPrice: listingPrice,
                                                ownedTokens: tokens,
                                                collections: collections,
                                                listedNFTItems: items)
            self?.web3DataSource = web3DataSource
            self?.view.stopLoadingIndicator()
            
            for viewController in self?.viewControllers?.compactMap({ $0 as? Web3DataSourceUpdatable }) ?? [] {
                viewController.didUpdateWeb3DataSource(web3DataSource)
            }
        }
    }
    
    private func triggerErrorAlert() {
        let alert = UIAlertController(title: "Error", message: "Something went wrong", preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default))
        present(alert, animated: true, completion: nil)
    }
    
    private func openSuccessAlert(title: String) {
        let alert = UIAlertController(title: "Success", message: title, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default))
        present(alert, animated: true, completion: nil)
    }
}

extension MainTabBarController: Web3CoordinatorDelegate {
    func shoundInteractWithExternalWallet(with pairingURI: String) {
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            let url = URL(string: pairingURI)!
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        })
    }
    
    func didConnect() {
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: { [weak self] in
            self?.authenticationViewController?.dismiss(animated: true)
            self?.loadWeb3DataSource()
        })
    }
    
    func didDisconnect() {
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: { [weak self] in
            self?.presentAuthentication()
        })
    }
    
    func didFailToConnect(error: Error) {
        
    }
    
}

extension MainTabBarController: AuthenticationViewControllerDelegate {
    func didTapOnConnect() {
        web3Coordinator.initiateConnection()
    }
}

extension MainTabBarController: CreateNFTViewControllerDelegate {
    func requestTokenGeneration(with imageURL: URL) {
        view.startLoadingIndicator()
        ipfsHandler.uploadAsset(url: imageURL.absoluteString, completion: { [weak self] response in
            switch response {
            case .success(let result):
                self?.web3Coordinator.createToken(tokenURI: result.uri, completion: { response in
                    DispatchQueue.main.async {
                        if case .failure = response {
                            self?.triggerErrorAlert()
                            self?.view.stopLoadingIndicator()
                            return
                        }
                        
                        self?.view.stopLoadingIndicator()
                        self?.openSuccessAlert(title: "Token was successfully created")
                        self?.createNFTViewController?.invalidateContent()
                    }
                })
                
            case .failure:
                self?.triggerErrorAlert()
            }
        })
    }
    
    func requestCollectionCreation(with name: String) {
        view.startLoadingIndicator()
        web3Coordinator.createNFTCollection(name: name, completion: { [weak self] response in
            DispatchQueue.main.async {
                if case .failure = response {
                    self?.triggerErrorAlert()
                    self?.view.stopLoadingIndicator()
                }
                
                self?.view.stopLoadingIndicator()
                self?.openSuccessAlert(title: "NFT collection successfully created")
                self?.requestDataSourceRefresh()
            }
        })
    }
}

extension MainTabBarController: InventoryViewControllerDelegate {
    func requestDataSourceRefresh() {
        loadWeb3DataSource()
    }
    
    func didListItem(with tokenID: Int, price: BigUInt, collectionID: Int) {
        guard let listingPrice = web3DataSource?.listingPrice else {
            triggerErrorAlert()
            return
        }
        view.startLoadingIndicator()
        web3Coordinator.listNFTForSale(tokenID: tokenID,
                                       price: price,
                                       collectionID: collectionID,
                                       value: listingPrice, completion: { [weak self] response in
            DispatchQueue.main.async {
                if case .failure = response {
                    self?.triggerErrorAlert()
                    self?.view.stopLoadingIndicator()
                }
                
                self?.view.stopLoadingIndicator()
                self?.openSuccessAlert(title: "NFT listing successfully created")
            }
        })
    }
}

extension MainTabBarController: MarketViewControllerDelegate {
    func didRequestBuy(for item: NFTComposedItem) {
        view.startLoadingIndicator()
        web3Coordinator.buyNFT(tokenID: item.itemID,
                               value: BigUInt(item.price),
                               completion: { response in
            DispatchQueue.main.async { [weak self] in
                if case .failure = response {
                    self?.triggerErrorAlert()
                    self?.view.stopLoadingIndicator()
                }
                
                self?.view.stopLoadingIndicator()
                self?.openSuccessAlert(title: "Purchase completed")
            }
        })
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true
    }
}
