//
//  ImageSlider.swift
//  ProductModule
//
//  Created by sanaz on 11/5/25.
//

import SwiftUI

public struct ImageSlider: View {
    public let images: [URL]

    public init(images: [URL]) {
        self.images = images
    }
    
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 8) {
                ForEach(images, id: \.self) { url in
                    ProductIconView(icon: url, size: 300)
                }
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 8)
            .background(Color.white)
        }
    }
}

