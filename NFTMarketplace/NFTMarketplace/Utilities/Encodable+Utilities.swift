//
//  Encodable+Utilities.swift
//  NFTMarketplace
//
//  Created by Nikolay Andonov on 3.12.22.
//

import Foundation

extension Encodable {
  func asDictionary() throws -> [String: String] {
    let data = try JSONEncoder().encode(self)
    guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: String] else {
      throw NSError()
    }
    return dictionary
  }
}
