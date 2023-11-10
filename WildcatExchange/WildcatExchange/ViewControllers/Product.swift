//
//  Product.swift
//  WildcatExchange
//
//  Created by Oukolov, Daniel on 11/10/23.
//

import Foundation

struct Product: Identifiable {
    var id = UUID()
    var name: String
    var description: String
    var price: Double
    var imageName: String
}

