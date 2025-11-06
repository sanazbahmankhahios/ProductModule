//
//  ProductDetailView.swift
//  ProductModule
//
//  Created by sanaz on 11/5/25.
//
import SwiftUI
import Kingfisher
import ProductKit

public struct ProductDetailView: View {
    @ObservedObject private var viewModel: ProductDetailViewModel
    static let imageHeight: CGFloat = 300
    
    init(viewModel: ProductDetailViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading) {
                ImageSlider(images: viewModel.product.images)
                    .frame(height: imageHeight)

                VStack(alignment: .leading, spacing: 16) {
                    HeaderView(
                        title: viewModel.product.title,
                        description: viewModel.product.description
                    )

                    HStack(alignment: .top) {
                        TagsView(tags: viewModel.product.tags)
                        Spacer()
                        VStack(alignment: .trailing, spacing: 8) {
                            RateView(rate: viewModel.product.rating)
                            StockView(stock: viewModel.product.stock)
                        }
                    }

                    PriceView(
                        price: viewModel.product.price,
                        discountedPrice: viewModel.product.discountPercentage
                    )
                }
                .padding(20)
            }
        }
        .background(Color.gray.opacity(0.08).ignoresSafeArea())
        .onAppear {
            viewModel.getProductDetail()
        }
    }
}

struct HeaderView: View {
    var title: String
    var description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title.bold())
            Text(description)
                .font(.body)
        }
    }
}

struct TagsView: View {
    var tags: [String]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(tags, id: \.self) { tag in
                    Text(tag)
                        .foregroundColor(.black)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(RoundedRectangle(cornerRadius: 6).fill(Color.cyan))
                }
            }
        }
        .frame(height: 30)
    }
}

struct StockView: View {
    var stock: Int

    var body: some View {
        Label(
            title: { Text("In stock: \(stock)") },
            icon: { Image(systemName: "digitalcrown.arrow.counterclockwise.fill") }
        )
        .foregroundColor(stock > 2 ? .orange : .red)
    }
}

struct PriceView: View {
    var price: Double
   var discountedPrice: Double
    
    var body: some View {
        HStack {
            Text(price.currencyValue)
                .font(.body)
                .strikethrough()
            Text(discountedPrice.currencyValue)
                .foregroundColor(.orange)
                .font(.title.bold())
        }
    }
}
