//
//  ProductListViewModel.swift
//  ProductModule
//
//  Created by sanaz on 11/5/25.
//

import Foundation
import Combine
import ProductKit

import Foundation
import Combine
import ProductKit

@MainActor
public class ProductViewModel: ObservableObject {
   // private let client: ProductClientDependency
    
    @Published public var products: [Product] = []
    @Published public var filteredProducts: [Product] = []
    @Published public var searchText: String = ""
    @Published public var loading: Bool = false
    @Published public var isRequestFailed: Bool = false
    
    private var cancellable = Set<AnyCancellable>()
    private let cache = ProductCacheManager()
    private var currentPage: Int = 0
    private var limit: Int = 20
    private var totalItems: Int = 0

    // TODO: Check for redundancy ProductClientDependency(client: ProductClientServer()))
    public init() {
        // TODO: Single responsibility?
        loadCachedProducts()
        setupSearch()
        getProducts()
    }
    
    private func loadCachedProducts() {
          let cached = cache.load()
          if !cached.isEmpty {
              products = cached
              filteredProducts = cached
          }
      }
    private func getProductsIfNeeded() {
           guard products.isEmpty else { return }
           getProducts()
       }
    
    public var shouldShowLoading: Bool {
        products.count < totalItems
    }
    
    public func getProducts() {
        guard !loading else { return }
        loading = true
        isRequestFailed = false
        
        fetchProducts()
    }
    
    private func fetchProducts() {
        let request = ProductRequest(limit: limit, skip: currentPage)
        //TODO: DI
        let client = ProductClientDependency(client: ProductClientServer())
        client.products(request: request)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                self?.handleCompletion(completion)
            } receiveValue: { [weak self] response in
                self?.handleResponse(response)
            }
            .store(in: &cancellable)
    }

    private func handleCompletion(_ completion: Subscribers.Completion<Error>) {
        loading = false
        if case .failure = completion {
            isRequestFailed = true
        }
    }

    private func handleResponse(_ response: ProductResponse) {
        // Append only new products (avoid duplication)
        let uniqueProducts = response.products.filter { newProduct in
            !products.contains(where: { $0.id == newProduct.id })
        }
        products.append(contentsOf: uniqueProducts)
        
        totalItems = response.total
        if products.count < totalItems {
            currentPage += limit
        }
        
        filteredProducts = filtered(for: searchText)
        self.cache.save(self.products)
    }
    
    public func getMoreProducts() {
        guard !loading else { return }
        guard let lastItem = products.last else { return }
        guard shouldLoadNextPage(after: lastItem) else { return }

        getProducts()
    }

    private func shouldLoadNextPage(after item: Product) -> Bool {
        guard
            let index = products.firstIndex(where: { $0.id == item.id }),
            index == products.count - 1, // user reached the last item
            products.count < totalItems  // still more products available
        else {
            return false
        }
        return true
    }
    
    private func setupSearch() {
        //Note: Debounce is not essential for local search but added to demonstrate Combine operation usage as required by the challenge.
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

        return queryWords.allSatisfy { searchableText.contains($0) }
    }
}
