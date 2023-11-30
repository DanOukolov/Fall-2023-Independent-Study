//
//  ProductDetailView.swift
//  WildcatExchange
//
//  Created by Vyas, Kishan on 11/5/23.
//

import SwiftUI

struct ProductDetailView: View {
    var product: Product

    var body: some View {
        VStack {
            Image(product.imageURL)
                .resizable()
                .aspectRatio(contentMode: .fit)
            Text(product.userProfileURL)
                .font(.headline)
            Text(product.description)
                .font(.subheadline)
            Spacer()
            Text("$\(product.price, specifier: "%.2f")")
                .font(.title)
        }
        .padding()
    }
}
