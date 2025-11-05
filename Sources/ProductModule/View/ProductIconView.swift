//
//  ProductIconView.swift
//  ProductModule
//
//  Created by sanaz on 11/5/25.
//

import SwiftUI
import Kingfisher
import ProductKit

public struct ProductIconView: View {
    var icon: URL?
    let size: CGFloat
    
    public var body: some View {
        KFImage(icon)
            .placeholder {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .background(Color.gray.opacity(0.2))
            }
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
