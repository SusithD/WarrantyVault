//
//  GlassCard.swift
//  WarrantyVault
//
//  Frosted-glass card container used throughout the app.
//

import SwiftUI

struct GlassCard<Content: View>: View {
    var padding: CGFloat = 20
    var cornerRadius: CGFloat = 24
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.06), radius: 20, x: 0, y: 8)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(AppColors.border, lineWidth: 1)
            )
    }
}

#Preview {
    ZStack {
        GradientBackground()
        GlassCard {
            Text("Hello, World!")
                .font(AppTypography.body)
        }
        .padding()
    }
}
