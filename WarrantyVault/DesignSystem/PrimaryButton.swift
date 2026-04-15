//
//  PrimaryButton.swift
//  WarrantyVault
//
//  Full-width rounded primary + secondary button styles.
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    var icon: String? = nil
    var isEnabled: Bool = true
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title)
                    .font(AppTypography.button)
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .foregroundStyle(.white)
            .background(
                LinearGradient(
                    colors: [
                        AppColors.brandBlue,
                        AppColors.brandBlue.opacity(0.85)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            .shadow(color: AppColors.brandBlue.opacity(0.25), radius: 12, x: 0, y: 6)
            .opacity(isEnabled ? 1 : 0.5)
        }
        .disabled(!isEnabled)
        .buttonStyle(.plain)
    }
}

struct SecondaryTextButton: View {
    let title: String
    var color: Color = AppColors.textSecondary
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTypography.bodyStrong)
                .foregroundStyle(color)
                .tracking(1.0)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 16) {
        PrimaryButton(title: "Get Started", icon: "arrow.right") { }
        PrimaryButton(title: "Next") { }
        SecondaryTextButton(title: "SKIP") { }
    }
    .padding()
    .background(GradientBackground())
}
