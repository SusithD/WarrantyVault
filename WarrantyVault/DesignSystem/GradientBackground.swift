//
//  GradientBackground.swift
//  WarrantyVault
//
//  The subtle top-left → bottom-right light gradient used on every screen.
//

import SwiftUI

struct GradientBackground: View {
    var body: some View {
        LinearGradient(
            colors: [AppColors.bgGradientStart, AppColors.bgGradientEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

#Preview {
    GradientBackground()
}
