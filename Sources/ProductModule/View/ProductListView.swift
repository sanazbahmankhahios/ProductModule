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
                            ForEach(viewModel.searchText.isEmpty ? viewModel.products : viewModel.filteredProducts) { product in
                                NavigationLink {
                                    ProductDetailView(viewModel: ProductDetailViewModel(product: product))
                                } label: {
                                    ProductCell(
                                        title: product.title,
                                        description: product.description,
                                        price: product.price,
                                        discountPercentage: product.discountPercentage,
                                        icon: product.thumbnail,
                                        tags: product.tags,
                                        rate: product.rating
                                    )
                                }
                                .buttonStyle(.plain)
                                .onAppear {
                                    if viewModel.searchText.isEmpty {
                                        viewModel.getMoreProducts(currentItem: product)
                                    }
                                }
                            }
                        }
                        
                        if viewModel.shouldShowLoading {
                            LoaderView(failed: viewModel.isRequestFailed)
                        }
                    }
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Products")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var searchBar: some View {
        TextField("Search products...", text: $viewModel.searchText)
            .padding(10)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
            .padding(.horizontal)
    }
    
    private var emptyState: some View {
        Text("No products found")
            .font(.headline)
            .foregroundColor(.gray)
            .padding(.top, 50)
    }
}
