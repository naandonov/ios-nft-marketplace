//
//  MarketViewController.swift
//  NFTMarketplace
//
//  Created by Nikolay Andonov on 5.12.22.
//

import UIKit
import BigInt

protocol MarketViewControllerDelegate: AnyObject {
    func requestDataSourceRefresh()
    func didRequestBuy(for item: NFTComposedItem)
}

class MarketViewController: UIViewController, Web3DataSourceUpdatable {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    private var collections: [NFTCollection] = [] {
        didSet {
            segmentedControl?.isHidden = collections.isEmpty
            invalidateSegmentedControl()
        }
    }
    private var listedNFTItems: [NFTComposedItem] = []
    
    private var dataSource: [Int: [NFTComposedItem]] {
        var result: [Int: [NFTComposedItem]] = [:]
        for (index, collection) in collections.enumerated() {
            result[index] = listedNFTItems.filter({ $0.collectionID == collection.collectionID })
        }
        return result
    }
    
    private func invalidateSegmentedControl() {
        for (index, nftCollection) in collections.enumerated() {
            segmentedControl?.setTitle(nftCollection.name, forSegmentAt: index)
        }
    }
    
    weak var delegate: MarketViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentedControl.isHidden = collections.isEmpty
        tableView.roundAllCorners()
        tableView.dataSource = self
        tableView.tableFooterView = .init(frame: .zero)
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        segmentedControl.addTarget(self, action: #selector(indexChanged), for: .valueChanged)
    }
    
    @IBAction func didTapRefreshMarketplace(_ sender: Any) {
        delegate?.requestDataSourceRefresh()
    }
    
    func didUpdateWeb3DataSource(_ dataSource: Web3DataSource) {
        collections = dataSource.collections
        listedNFTItems = dataSource.listedNFTItems.filter({ !$0.isSold })
        tableView.reloadData()
    }
    
    @objc func indexChanged(_ sender: UISegmentedControl) {
        tableView.reloadData()
    }
}

extension MarketViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? MarketTableViewCell,
              let item = dataSource[segmentedControl.selectedSegmentIndex]?[indexPath.row] else {
            return UITableViewCell()
        }
        
        cell.tokenImageView.backgroundColor = .white
        cell.tokenImageView.roundAllCorners()
        cell.selectionStyle = .none
        cell.buyButton.tag = indexPath.row
        cell.buyButton.addTarget(self, action: #selector(didTapBuy), for: .touchUpInside)
        let etherValue = CurrencyConverter.toEther(wei: BigUInt(item.price))?.description ?? ""
        cell.priceLabel.text = etherValue + " ETH"

        if let url = URL(string: item.tokenURI) {
            cell.tokenImageView.kf.setImage(with: url)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource[segmentedControl.selectedSegmentIndex]?.count ?? 0
    }
}

extension MarketViewController {
    @objc func didTapBuy(sender: UIButton) {
        if let item = dataSource[segmentedControl.selectedSegmentIndex]?[sender.tag] {
            delegate?.didRequestBuy(for: item)
        }
    }
}
