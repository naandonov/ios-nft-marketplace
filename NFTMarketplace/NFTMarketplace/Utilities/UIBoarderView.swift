//
//  UIBoarderView.swift
//  NFTMarketplace
//
//  Created by Nikolay Andonov on 4.12.22.
//

import Foundation
import UIKit

class UIBoarderView: UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 20;
        layer.masksToBounds = false;
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = .zero
        layer.shadowRadius = 10
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
//        yourView.layer.shouldRasterize = true
    }
}
