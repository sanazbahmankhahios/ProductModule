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
public class ProductViewModel: ObservableObject {
    @Published public var products: [Product] = []
    @Published public var filteredProducts: [Product] = []
    @Published public var searchText: String = ""
    @Published public var loading: Bool = false
    @Published public var isRequestFailed: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private var currentPage: Int = 0
    private var limit: Int = 20
    private var totalItems: Int = 0
    
    public init() {
        setupSearch()
        getProducts()
    }
        
    public var shouldShowLoading: Bool {
        products.isEmpty || products.count < totalItems
    }
    
    public func getProducts() {
        guard !loading else { return }
        loading = true
        isRequestFailed = false
        
        let client = ProductClientDependency(client: ProductClientServer())
        client.products(request: ProductRequest(limit: limit, skip: currentPage))
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
    
    public func getMoreProducts(currentItem item: Product) {
        guard !loading else { return }
        guard let index = products.firstIndex(where: { $0.id == item.id }),
              index + 1 == products.count,
              products.count < totalItems else { return }
        
        getProducts()
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
        let normalizedQuery = text
            .folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()
        let queryWords = normalizedQuery.split(separator: " ")

        let searchableText = (product.title + " " + product.description)
            .folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()
        let searchableWords = searchableText.components(separatedBy: CharacterSet.alphanumerics.inverted)

        return queryWords.allSatisfy { queryWord in
            searchableWords.contains { $0.contains(queryWord) }
        }
    }
}
