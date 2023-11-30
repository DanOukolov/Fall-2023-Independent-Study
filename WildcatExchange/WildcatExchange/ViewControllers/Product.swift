//
//  Product.swift
//  WildcatExchange
//
//  Created by Oukolov, Daniel on 11/10/23.
//

import Foundation

struct Product {
    var id: String
    var userId: String
    var userName: String
    var userProfileURL: String
    var productName: String
    var description: String
    var price: Double
    var imageURL: String
    var date: Date

    //  initializer for creating new products
    init(userId: String, userName: String, userProfileURL: String, productName: String, description: String, price: Double, imageURL: String, date: Date) {
        self.id = UUID().uuidString
        self.userId = userId
        self.userName = userName
        self.userProfileURL = userProfileURL
        self.productName = productName
        self.description = description
        self.price = price
        self.imageURL = imageURL
        self.date = date
    }

    //  initializer for fetching products from Firestore
    init(id: String, userId: String, userName: String, userProfileURL: String, productName: String, description: String, price: Double, imageURL: String, date: Date) {
        self.id = id
        self.userId = userId
        self.userName = userName
        self.userProfileURL = userProfileURL
        self.productName = productName
        self.description = description
        self.price = price
        self.imageURL = imageURL
        self.date = date
    }
}


