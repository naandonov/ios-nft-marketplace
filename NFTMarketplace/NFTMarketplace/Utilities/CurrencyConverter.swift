//
//  CurrencyConverter.swift
//  NFTMarketplace
//
//  Created by Nikolay Andonov on 5.12.22.
//

import Foundation
import BigInt

public typealias Ether = Decimal
public typealias Wei = BigUInt

public final class CurrencyConverter {
    private static let etherInWei = pow(Decimal(10), 18)
    
    public static func toEther(wei: Wei) -> Ether? {
        guard let decimalWei = Decimal(string: wei.description) else {
            return nil
        }
        return decimalWei / etherInWei
    }
    
    public static func toWei(ether: Ether) -> Wei? {
        guard let wei = Wei((ether * etherInWei).description) else {
            return nil
        }
        return wei
    }
    
    public static func toWei(ether: String) -> Wei? {
        guard let decimalEther = Decimal(string: ether) else {
            return nil
        }
        return toWei(ether: decimalEther)
    }
    
    public static func toWei(GWei: Int) -> Int {
        return GWei * 1000000000
    }
}
