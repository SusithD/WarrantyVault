//
//  MainAppPlaceholderView.swift
//  WarrantyVault
//
//  Placeholder for the main app — hit once authentication succeeds.
//  Will be replaced by the real Dashboard in a later sprint.
//

import SwiftUI

struct MainAppPlaceholderView: View {
    var body: some View {
        ZStack {
            GradientBackground()

            VStack(spacing: 16) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 56, weight: .bold))
                    .foregroundStyle(AppColors.success)

                Text("You're in!")
                    .font(AppTypography.title)

                Text("Dashboard coming next sprint.")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
    }
}

#Preview {
    MainAppPlaceholderView()
}
