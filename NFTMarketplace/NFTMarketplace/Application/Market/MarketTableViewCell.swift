//
//  MarketTableViewCell.swift
//  NFTMarketplace
//
//  Created by Nikolay Andonov on 5.12.22.
//

import UIKit

class MarketTableViewCell: UITableViewCell {
    @IBOutlet weak var tokenImageView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var actionsHolderView: UIVisualEffectView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        actionsHolderView.roundCorners(maskedCorners: [.layerMaxXMinYCorner, .layerMinXMaxYCorner])
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
