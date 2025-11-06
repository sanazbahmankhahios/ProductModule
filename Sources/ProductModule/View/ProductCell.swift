//
//  ProductCell.swift
//  ProductModule
//
//  Created by sanaz on 11/5/25.
//
import SwiftUI
import ProductKit

struct ProductCell: View {
    private let imageHeight: CGFloat = 100
    let title: String
    let description: String
    let price: Double
    let discountPercentage: Double
    let discountedPrice: Double
    let icon: URL?
    let tags: [String]
    let rate: Double
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 16) {
                ProductIconView(icon: icon, size: imageHeight)
                VStack(alignment: .leading) {
                    headerView
                    
                    if !tags.isEmpty {
                        tagsView
                    }
                    priceView
                }
            }
        }
        .padding()
        .background {
            Color.white
                .shadow(radius: 0.5)
        }
    }
    
    private var headerView: some View {
        HStack(alignment: .top) {
            Text(title)
                .font(.body.bold())
                .lineLimit(2)
            Spacer()
            RateView(rate: rate)
        }
    }
    
    private var tagsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(tags, id: \.self) { tag in
                    Text(tag)
                        .foregroundStyle(.black)
                        .font(.caption)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.cyan)
                        }
                }
            }
        }
        .frame(height: 20)
    }
    
    private var priceView: some View {
        HStack {
            Text(price.currencyValue)
                .font(.callout)
                .strikethrough()
            
            Text(discountedPrice.currencyValue)
                .foregroundStyle(Color.orange)
                .font(.body)
        }
    }
}
