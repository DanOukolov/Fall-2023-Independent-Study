//
//  MarketplaceItem.swift
//  WildcatExchange
//
//  Created by Oukolov, Daniel on 11/15/23.
//

import Foundation

struct MarketplaceItem: Codable {
    let id: String
    let title: String
    let description: String
    let price: String
    let category: String
    let imageUrl: String
    let seller: Seller
}

struct Seller: Codable {
    let name: String
    let contact: String
}
