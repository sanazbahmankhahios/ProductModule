//
//  LoaderView.swift
//  ProductModule
//
//  Created by sanaz on 11/5/25.
//

import SwiftUI

public struct LoaderView: View {
    let failed: Bool
    public var body: some View {
        Text(failed ? "Failed! Tap to retry." : "Loading...")
            .foregroundColor(failed ? .red : .gray)
            .padding()
    }
}
