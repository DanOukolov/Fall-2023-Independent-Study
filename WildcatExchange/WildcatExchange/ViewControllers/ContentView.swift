//
//  ContentView.swift
//  WildcatExchange
//
//  Created by Oukolov, Daniel on 11/10/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            List(sampleProducts) { product in // from firebase
                NavigationLink(destination: ProductDetailView(product: product)) {
                    ProductRow(product: product)
                }
            }
            .navigationBarTitle("Products")
        }
    }
}
