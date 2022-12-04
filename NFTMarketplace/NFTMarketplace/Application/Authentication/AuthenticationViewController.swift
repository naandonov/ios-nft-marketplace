//
//  AuthenticationViewController.swift
//  NFTMarketplace
//
//  Created by Nikolay Andonov on 4.12.22.
//

import UIKit

protocol AuthenticationViewControllerDelegate: AnyObject {
    func didTapOnConnect()
}

class AuthenticationViewController: UIViewController {
    weak var delegate: AuthenticationViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presentationController?.delegate = self
    }
    
    @IBAction func connectButtonAction(_ sender: Any) {
        view.startLoadingIndicator()
        delegate?.didTapOnConnect()
    }
}

extension AuthenticationViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        false
    }
}

