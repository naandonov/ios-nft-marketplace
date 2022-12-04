//
//  InventoryViewController.swift
//  NFTMarketplace
//
//  Created by Nikolay Andonov on 4.12.22.
//

import UIKit
import Kingfisher

class InventoryViewController: UIViewController, Web3DataSourceUpdatable {
    @IBOutlet weak var tableView: UITableView!
    private var tokens: [Token] = [] {
        didSet {
            tableView?.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.roundAllCorners()
        tableView.dataSource = self
        tableView.tableFooterView = .init(frame: .zero)
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
    }
    
    func didUpdateWeb3DataSource(_ dataSource: Web3DataSource) {
        tokens = dataSource.ownedTokens
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
