//
//  RateView.swift
//  ProductModule
//
//  Created by sanaz on 11/5/25.
//
import SwiftUI

public struct RateView: View {
    var rate: Double
    
    public var body: some View {
        Label {
            Text("\(rate.formatted(.number.precision(.fractionLength(1)))) / 5")
                .foregroundColor(.primary)
        } icon: {
            Image(systemName: iconName(for: rate))
                .foregroundColor(iconColor(for: rate))
        }
        .font(.caption)
    }
    
    private func iconName(for rating: Double) -> String {
        switch rating {
        case ..<3: return "hand.thumbsdown.fill"
        case 3..<4: return "hand.thumbsup"
        default: return "hand.thumbsup.fill"
        }
    }
    
    private func iconColor(for rating: Double) -> Color {
        switch rating {
        case ..<3: return .red
        case 3..<4: return .orange
        default: return .green
        }
    }
}

