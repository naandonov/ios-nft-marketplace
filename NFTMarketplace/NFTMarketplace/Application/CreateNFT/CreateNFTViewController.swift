//
//  CreateNFTViewController.swift
//  NFTMarketplace
//
//  Created by Nikolay Andonov on 4.12.22.
//

import UIKit
import Kingfisher

protocol CreateNFTViewControllerDelegate: AnyObject {
    func requestTokenGeneration(with imageURL: URL)
}

class CreateNFTViewController: UIViewController, Web3DataSourceUpdatable {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var generateButton: UIButton!
    @IBOutlet weak var storeButton: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var collectionsSelectionView: UIView!
    
    weak var delegate: CreateNFTViewControllerDelegate?
    
    private var currentGenerationURL: URL? {
        didSet {
            storeButton.isEnabled = currentGenerationURL != nil
        }
    }
    
    private let emptyStateImage = UIImage(named: "emptyState")
    
    private var openAPIHandler = OpenAPIHandler.sharedInstance
    
    private var nftCollections: [NFTCollection] = [] {
        didSet {
            collectionsSelectionView?.isHidden = nftCollections.isEmpty
            invalidateSegmentedControl()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionsSelectionView.isHidden = nftCollections.isEmpty
        imageView.roundCorners()
        storeButton.isEnabled = false
        invalidateSegmentedControl()
    }
    
    private func invalidateSegmentedControl() {
        for (index, nftCollection) in nftCollections.enumerated() {
            segmentedControl?.setTitle(nftCollection.name, forSegmentAt: index)
        }
    }
    
    func invalidateContent() {
        imageView.image = emptyStateImage
        currentGenerationURL = nil
    }
    
    @IBAction func generateButtonAction(_ sender: Any) {
        view.startLoadingIndicator()
        let query = nftCollections[segmentedControl.selectedSegmentIndex].name + " art panda"
        openAPIHandler.requestImage(of: query, size: .x1024, completion: { [weak self] result in
            guard case let .success(item) = result else {
                return
            }
            
            if let stringURL = item?.url,
            let url = URL(string: stringURL) {
                self?.imageView.kf.setImage(with: url, placeholder: self?.emptyStateImage, completionHandler: { _ in
                    self?.view.stopLoadingIndicator()
                    self?.currentGenerationURL = url
                })
            }
        })
    }
    
    @IBAction func storeButtonAction(_ sender: Any) {
        if let currentGenerationURL = currentGenerationURL {
            delegate?.requestTokenGeneration(with: currentGenerationURL)
        }
    }
    
    func didUpdateWeb3DataSource(_ dataSource: Web3DataSource) {
        nftCollections = dataSource.collections
    }
}
