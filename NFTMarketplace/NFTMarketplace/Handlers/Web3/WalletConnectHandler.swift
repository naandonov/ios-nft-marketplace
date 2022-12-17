//
//  WalletConnectHandler.swift
//  NFTMarketplace
//
//  Created by Nikolay Andonov on 2.12.22.
//

import Foundation
import WalletConnectSwift

protocol WalletConnectDelegate: AnyObject {
    func didFailToConnect()
    func didConnect(with client: Client)
    func didDisconnect()
}

final class WalletConnectHandler {
    enum WalletConnectError: Error {
        case invalidData
        case general
    }
    
    private enum Constants {
        static let bridgeURL = "https://bridge.walletconnect.org"
        static let dAppName = "Pandamonium"
        static let dAppDescription = "NFT Marketplace"
        static let dAppURL = "https://pandamonium.io"
        static let dAppIcons: [String] = []
        
        static let sessionStorageService = "wallet-connect-session"
        static let sessionStorageAccount = "pandamonium"
    }
    
    private var client: Client?
    private var session: Session?
    private(set) var pairingURI: WCURL?
    weak var delegate: WalletConnectDelegate?
    
    func connect() throws -> String?  {
        if let session = SecureStorageManager.sharedInstance.read(service: Constants.sessionStorageService,
                                                                  account: Constants.sessionStorageAccount,
                                                                  type: Session.self) {
            self.session = session
            try recconnect(with: session)
            pairingURI = session.url
            return pairingURI?.absoluteString
        }
        guard let dappURL = URL(string: Constants.dAppURL) else {
            throw WalletConnectError.invalidData
        }
        
        let metaData = Session.ClientMeta(name: Constants.dAppName,
                                          description: Constants.dAppDescription,
                                          icons: Constants.dAppIcons.compactMap({ .init(string: $0) }),
                                          url: dappURL)
        let dAppInfo = Session.DAppInfo(peerId: UUID().uuidString,
                                        peerMeta: metaData)
        pairingURI = try generatePairingURI()
        
        client = Client(delegate: self, dAppInfo: dAppInfo)
        if let pairingURI = pairingURI {
            try client?.connect(to: pairingURI)
            return pairingURI.absoluteString
        } else {
            return nil
        }
    }
    
    func disconnectIfPossible() {
        guard let session = session else {
            return
        }

        try? client?.disconnect(from: session)
    }
    
    var sessionExists: Bool {
        SecureStorageManager.sharedInstance.read(service: Constants.sessionStorageService,
                                                 account: Constants.sessionStorageAccount,
                                                 type: Session.self) != nil
    }
    
    var walletAccounts: [String] {
        session?.walletInfo?.accounts ?? []
    }
    
    private func recconnect(with session: Session) throws {
        client = Client(delegate: self, dAppInfo: session.dAppInfo)
        try client?.reconnect(to: session)
    }
}

// MARK: - Utilities

private extension WalletConnectHandler {
    private func generatePairingURI() throws -> WCURL {
        guard let bridgeURL = URL(string: Constants.bridgeURL) else {
            throw WalletConnectError.invalidData
        }
        let wcUrl =  WCURL(topic: UUID().uuidString,
                           bridgeURL: bridgeURL,
                           key: try generateSymKey())
        
        return wcUrl
    }
    
    private func generateSymKey() throws -> String {
        var bytes = [Int8](repeating: 0, count: 32)
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        if status == errSecSuccess {
            return Data(bytes: bytes, count: 32).toHexString()
        } else {
            throw WalletConnectError.general
        }
    }
}

// MARK: - ClientDelegate

extension WalletConnectHandler: ClientDelegate {
    func client(_ client: Client, didFailToConnect url: WCURL) {
        SecureStorageManager.sharedInstance.delete(service: Constants.sessionStorageService,
                                                   account: Constants.sessionStorageAccount)
        session = nil
        self.client = nil
        delegate?.didFailToConnect()
    }

    func client(_ client: Client, didConnect url: WCURL) {
        // No handling
    }

    func client(_ client: Client, didConnect session: Session) {
        guard let walletInfo = session.walletInfo,
              walletInfo.approved else {
            disconnectIfPossible()
            return
        }
        SecureStorageManager.sharedInstance.save(session,
                                                 service: Constants.sessionStorageService,
                                                 account: Constants.sessionStorageAccount)
        self.session = session
        self.client = client
        delegate?.didConnect(with: client)
    }

    func client(_ client: Client, didDisconnect session: Session) {
        SecureStorageManager.sharedInstance.delete(service: Constants.sessionStorageService,
                                                   account: Constants.sessionStorageAccount)
        self.session = nil
        self.client = nil
        delegate?.didDisconnect()
    }

    func client(_ client: Client, didUpdate session: Session) {
        // No handling
    }
}

