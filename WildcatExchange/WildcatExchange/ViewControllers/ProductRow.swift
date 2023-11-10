//
//  ProductRow.swift
//  WildcatExchange
//
//  Created by Oukolov, Daniel on 11/10/23.
//

import SwiftUI

struct ProductRow: View {
    var product: Product

    var body: some View {
        HStack {
            Image(product.imageName)
                .resizable()
                .frame(width: 50, height: 50)
            Text(product.name)
            Spacer()
            Text("$\(product.price, specifier: "%.2f")")
        }
    }
}
