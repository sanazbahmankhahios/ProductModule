//
//  ProductListViewModel.swift
//  ProductModule
//
//  Created by sanaz on 11/5/25.
//

import Foundation
import Combine
import ProductKit

@MainActor
public class ProductListViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var searchText: String = ""
    @Published var filteredProducts: [Product] = []
    @Published var loading: Bool = false
    @Published var isRequestFailed = false
    private var cancellables = Set<AnyCancellable>()
    private var currentPage: Int = 0
    private var limit: Int = 10
    private var totalItems: Int = 0

    var shouldShowLoading: Bool {
        products.isEmpty || products.count != totalItems
    }
    
    init() {
        setupSearch()
    }
    
    func getProducts() {
        loading = true
        isRequestFailed = false
        
        let serverClient = ProductClientDependency(client: ProductClientServer())
        
        serverClient.products(request: ProductRequest(limit: limit, skip: currentPage))
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.loading = false
                if case .failure = completion {
                    self.isRequestFailed = true
                }
            } receiveValue: { [weak self] response in
                guard let self = self else { return }
                self.products.append(contentsOf: response.products)
                self.totalItems = response.total
                if self.products.count < self.totalItems {
                    self.currentPage += self.limit
                }
                
                self.filteredProducts = self.filtered(for: self.searchText)
            }
            .store(in: &cancellables)
    }
    
    private func setupSearch() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .map { [unowned self] text in
                filtered(for: text)
            }
            .assign(to: &$filteredProducts)
    }
    
    private func filtered(for text: String) -> [Product] {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return products
        }
        return products.filter { matches(product: $0, text: text) }
    }
    
    private func matches(product: Product, text: String) -> Bool {
        let normalizedQuery = text.folding(options: .diacriticInsensitive, locale: .current).lowercased()
        let queryWords = normalizedQuery.split(separator: " ")
        
        let searchableText = (product.title + " " + product.description)
            .folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()
        let searchableWords = searchableText.components(separatedBy: CharacterSet.alphanumerics.inverted)
        
        return queryWords.allSatisfy { queryWord in
            searchableWords.contains { $0.hasPrefix(queryWord) }
        }
    }
}
