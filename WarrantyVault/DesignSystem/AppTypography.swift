//
//  AppTypography.swift
//  WarrantyVault
//
//  Typography tokens using the SF Pro system font.
//

import SwiftUI

enum AppTypography {
    static let largeTitle = Font.system(size: 32, weight: .bold)
    static let title      = Font.system(size: 28, weight: .bold)
    static let headline   = Font.system(size: 22, weight: .bold)
    static let subhead    = Font.system(size: 17, weight: .bold)          // brand bar
    static let body       = Font.system(size: 15, weight: .regular)
    static let bodyStrong = Font.system(size: 15, weight: .semibold)
    static let caption    = Font.system(size: 13, weight: .regular)
    static let captionStrong = Font.system(size: 13, weight: .semibold)
    static let overline   = Font.system(size: 11, weight: .semibold)      // ALL-CAPS labels
    static let chip       = Font.system(size: 12, weight: .medium)
    static let button     = Font.system(size: 16, weight: .semibold)
}

extension Text {
    /// Applies an ALL-CAPS overline style used throughout the app
    /// (e.g. "FILING A CLAIM", "ESTIMATED RESPONSE").
    func overlineStyle(color: Color = AppColors.textSecondary) -> some View {
        self
            .font(AppTypography.overline)
            .tracking(0.8)
            .foregroundStyle(color)
    }
}
