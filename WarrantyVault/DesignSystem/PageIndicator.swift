//
//  PageIndicator.swift
//  WarrantyVault
//
//  Small dash/dot indicator for paged content (splash, onboarding).
//

import SwiftUI

struct PageIndicator: View {
    let total: Int
    let current: Int
    var activeColor: Color = AppColors.brandBlue
    var inactiveColor: Color = AppColors.border

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<total, id: \.self) { index in
                Capsule()
                    .fill(index == current ? activeColor : inactiveColor)
                    .frame(
                        width: index == current ? 22 : 6,
                        height: 6
                    )
                    .animation(.easeInOut(duration: 0.25), value: current)
            }
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        PageIndicator(total: 3, current: 0)
        PageIndicator(total: 3, current: 1)
        PageIndicator(total: 3, current: 2)
    }
    .padding()
    .background(GradientBackground())
}
