//
//  ProductDetailViewModel.swift
//  ProductModule
//
//  Created by sanaz on 11/5/25.
//

import Foundation
import Combine
import ProductKit

@MainActor
public class ProductDetailViewModel: ObservableObject {
    @Published var product: Product
    @Published var isLoading: Bool = false
    @Published var error: Error?

    private var cancellables = Set<AnyCancellable>()

    init(product: Product) {
        self.product = product
    }

    func getProductDetail() {
        isLoading = true
        error = nil

        let serverClient = ProductClientDependency(client: ProductClientServer())

        serverClient.product(by: product.id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case let .failure(err) = completion {
                    self?.error = err
                    print(err.localizedDescription, #function)
                }
            } receiveValue: { [weak self] updatedProduct in
                self?.product = updatedProduct
            }
            .store(in: &cancellables)
    }
}
