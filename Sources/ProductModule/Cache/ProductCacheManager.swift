//
//  ProductCacheManager.swift
//  ProductModule
//
//  Created by sanaz on 11/6/25.
//
import Foundation

final class ProductCacheManager {
    private let cacheURL: URL

    init(filename: String = "cachedProducts.json") {
        let directory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        cacheURL = directory.appendingPathComponent(filename)
    }

    func save(_ products: [Product]) {
        do {
            let data = try JSONEncoder().encode(products)
            try data.write(to: cacheURL, options: [.atomic])
        } catch {
            print("Failed to save cache:", error)
        }
    }

    func load() -> [Product] {
        do {
            let data = try Data(contentsOf: cacheURL)
            return try JSONDecoder().decode([Product].self, from: data)
        } catch {
            return []
        }
    }

    func clear() {
        try? FileManager.default.removeItem(at: cacheURL)
    }
}
