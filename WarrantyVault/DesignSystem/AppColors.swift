//
//  AppColors.swift
//  WarrantyVault
//
//  Centralised color tokens matching the Figma design system.
//

import SwiftUI

enum AppColors {
    // Backgrounds
    static let bgGradientStart = Color(red: 0.933, green: 0.949, blue: 1.000) // #EEF2FF
    static let bgGradientEnd   = Color(red: 0.969, green: 0.976, blue: 0.988) // #F7F9FC
    static let surface         = Color.white
    static let surfaceMuted    = Color(red: 0.95, green: 0.95, blue: 0.97)    // card-muted / input

    // Text
    static let textPrimary     = Color(red: 0.110, green: 0.110, blue: 0.118) // #1C1C1E
    static let textSecondary   = Color(red: 0.557, green: 0.557, blue: 0.576) // #8E8E93
    static let textTertiary    = Color(red: 0.714, green: 0.722, blue: 0.749) // #B6B8BF

    // Borders
    static let border          = Color(red: 0.898, green: 0.898, blue: 0.918) // #E5E5EA

    // Accents
    static let brandBlue       = Color(red: 0.039, green: 0.518, blue: 1.000) // #0A84FF
    static let brandBlueSoft   = Color(red: 0.894, green: 0.937, blue: 1.000) // #E4EFFF
    static let success         = Color(red: 0.204, green: 0.780, blue: 0.349) // #34C759
    static let successSoft     = Color(red: 0.878, green: 0.965, blue: 0.894)
    static let warning         = Color(red: 1.000, green: 0.584, blue: 0.000) // #FF9500
    static let warningSoft     = Color(red: 1.000, green: 0.933, blue: 0.839)
    static let danger          = Color(red: 1.000, green: 0.231, blue: 0.188) // #FF3B30
    static let dangerSoft      = Color(red: 1.000, green: 0.898, blue: 0.886)
    static let purple          = Color(red: 0.388, green: 0.400, blue: 0.945) // #6366F1
    static let purpleSoft      = Color(red: 0.926, green: 0.929, blue: 1.000)
}
