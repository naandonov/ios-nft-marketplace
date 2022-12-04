//
//  UIView+Loading.swift
//  NFTMarketplace
//
//  Created by Nikolay Andonov on 4.12.22.
//

import UIKit

protocol Loadable {
    func startLoadingIndicator()
    func stopLoadingIndicator()
}

extension UIView: Loadable {
    func startLoadingIndicator() {
        guard !subviews.contains(where: { $0 is LoadingIndicatorView }) else {
            return
        }
        
        isUserInteractionEnabled = false
        let loadingIndicatorView = LoadingIndicatorView()
        loadingIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        loadingIndicatorView.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.5)
        addSubview(loadingIndicatorView)
        NSLayoutConstraint.activate([
            loadingIndicatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            loadingIndicatorView.topAnchor.constraint(equalTo: topAnchor),
            loadingIndicatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            loadingIndicatorView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        loadingIndicatorView.startLoading()
    }
    
    func stopLoadingIndicator() {
        guard let loadingIndicatorView = subviews.first(where: { $0 is LoadingIndicatorView }) as? LoadingIndicatorView else {
            return
        }
        
        isUserInteractionEnabled = true
        loadingIndicatorView.backgroundColor = .clear
        loadingIndicatorView.stopLoading()
        loadingIndicatorView.removeFromSuperview()
    }
}

private final class LoadingIndicatorView: UIView {
    lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        indicator.color = UIColor.primaryBlue
        
        return indicator
    }()
    
    override init(frame: CGRect) {
        super .init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    func startLoading() {
        loadingIndicator.startAnimating()
    }
    
    func stopLoading() {
        loadingIndicator.stopAnimating()
    }
}

private extension LoadingIndicatorView {
    func commonInit() {
        backgroundColor = .clear
        isUserInteractionEnabled = false
        addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

extension UIView {
    func roundCorners(maskedCorners: CACornerMask = [.layerMinXMinYCorner, .layerMaxXMinYCorner],
                      cornerRadius: CGFloat = 20) {
        layer.cornerRadius = cornerRadius
        layer.maskedCorners = maskedCorners
        layer.masksToBounds = true
    }
    
    func roundAllCorners(cornerRadius: CGFloat = 20) {
        layer.cornerRadius = cornerRadius
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        layer.masksToBounds = true
    }
}
