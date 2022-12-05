//
//  InventoryViewController.swift
//  NFTMarketplace
//
//  Created by Nikolay Andonov on 4.12.22.
//

import UIKit
import Kingfisher
import BigInt

protocol InventoryViewControllerDelegate: AnyObject {
    func didListItem(with tokenID: Int, price: BigUInt, collectionID: Int)
    func requestDataSourceRefresh()
}

class InventoryViewController: UIViewController, Web3DataSourceUpdatable {
    @IBOutlet weak var tableView: UITableView!
    private var tokens: [Token] = [] {
        didSet {
            tableView?.reloadData()
        }
    }
    
    private var collections: [NFTCollection] = []
    
    weak var delegate: InventoryViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.roundAllCorners()
        tableView.dataSource = self
        tableView.tableFooterView = .init(frame: .zero)
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
    }
    
    func didUpdateWeb3DataSource(_ dataSource: Web3DataSource) {
        tokens = dataSource.ownedTokens.filter({ !$0.wasListed })
        collections = dataSource.collections
    }
    
    @IBAction func didTapRefreshInventory(_ sender: Any) {
        delegate?.requestDataSourceRefresh()
    }
}

extension InventoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? InventoryTableViewCell else {
            return UITableViewCell()
        }
        
        cell.tokenImageView.backgroundColor = .white
        cell.tokenImageView.roundAllCorners()
        cell.selectionStyle = .none
        cell.sellButton.tag = indexPath.row
        cell.sellButton.addTarget(self, action: #selector(didTapSell), for: .touchUpInside)
        
        let token = tokens[indexPath.row]
        if let url = URL(string: token.tokenURI) {
            cell.tokenImageView.kf.setImage(with: url)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tokens.count
    }
}

extension InventoryViewController {
    @objc func didTapSell(sender: UIButton) {
        let item = tokens[sender.tag]
        let alertController = UIAlertController(title: "Sell NFT", message: "Enther desired price in ethers (ETH)", preferredStyle: .alert)

        alertController.addTextField { (textField) in
            textField.placeholder = "0.00"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let sellAction = UIAlertAction(title: "Sell", style: .default) { [weak self] _ in
            let inputName = alertController.textFields?[0].text ?? ""
            if let number = Double(inputName) {
                let price = BigUInt(number * pow(10, 18))
                self?.selectCollection(for: item.tokenID, price: price)
            }
        }

        alertController.addAction(cancelAction)
        alertController.addAction(sellAction)

        present(alertController, animated: true, completion: nil)
    }
    
    func selectCollection(for tokenID: Int, price: BigUInt) {
        let alertController = UIAlertController(title: "Select Collection", message: "Choose the listing collection for your token", preferredStyle: .actionSheet)
        
        for collection in collections {
            alertController.addAction(.init(title: collection.name, style: .default, handler: { [weak self] _ in
                self?.delegate?.didListItem(with: tokenID, price: price, collectionID: collection.collectionID)
            }))
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)

    }
}
