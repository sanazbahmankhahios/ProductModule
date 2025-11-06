//
//  ProductListView.swift
//  ProductModule
//
//  Created by sanaz on 11/5/25.
//
import SwiftUI
import ProductKit

public struct ProductList: View {
    @ObservedObject private var viewModel = ProductViewModel()
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchBar
                ScrollView {
                    LazyVStack(spacing: 0) {
                        if viewModel.filteredProducts.isEmpty && !viewModel.searchText.isEmpty {
                            emptyState
                        } else {
                            let products = viewModel.searchText.isEmpty ? viewModel.products : viewModel.filteredProducts
                            ForEach(products) { product in
                                NavigationLink {
                                    ProductDetailView(viewModel: ProductDetailViewModel(product: product))
                                } label: {
                                    ProductCell(
                                        title: product.title,
                                        description: product.description,
                                        price: product.price,
                                        discountPercentage: product.discountPercentage,
                                        discountedPrice: product.discountedPrice,
                                        icon: product.thumbnail,
                                        tags: product.tags,
                                        rate: product.rating
                                    )
                                }
                                .buttonStyle(.plain)
                                .onAppear {
                                    if products.last?.id == product.id {
                                        viewModel.getMoreProducts(currentItem: product)
                                    }
                                }
                                .onChange(of: viewModel.products.count) {
                                    // TODO: Check if search result is correct and get more if needed
                                }
                            }
                        }
                        
                        if viewModel.shouldShowLoading {
                            ProgressView("Loading...")
                        }
                    }
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Products")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    public var searchBar: some View {
        TextField("Search products...", text: $viewModel.searchText)
            .padding(10)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
            .padding(.horizontal)
    }
    
    public var emptyState: some View {
        Text("No products found")
            .font(.headline)
            .foregroundColor(.gray)
            .padding(.top, 50)
    }
}
