import SwiftUI

/// Top-level main app shell with a custom 5-item bottom nav.
/// The middle "Add" slot is a floating circular button that presents the Add Warranty sheet.
struct MainTabView: View {
    @Environment(AppStore.self) private var store
    @State private var presentingAdd = false
    @State private var presentingFileClaim = false

    var body: some View {
        @Bindable var store = store

        ZStack(alignment: .bottom) {
            GradientBackground()
                .ignoresSafeArea()

            Group {
                switch store.selectedTab {
                case .dashboard:
                    NavigationStack { DashboardView() }
                case .claims:
                    NavigationStack { ClaimsListView(presentingFileClaim: $presentingFileClaim) }
                case .add:
                    EmptyView()
                case .household:
                    HouseholdHubView()
                case .profile:
                    NavigationStack { ProfileView() }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Color.clear.frame(height: 72)
            }

            BottomNavBar(
                selected: $store.selectedTab,
                onAddTapped: { presentingAdd = true }
            )
        }
        .ignoresSafeArea(edges: .bottom)
        .sheet(isPresented: $presentingAdd) {
            NavigationStack { AddWarrantyView() }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $presentingFileClaim) {
            NavigationStack { FileClaimView() }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Bottom navigation

struct BottomNavBar: View {
    @Binding var selected: MainTab
    var onAddTapped: () -> Void

    private let addSize: CGFloat = 56

    var body: some View {
        ZStack(alignment: .top) {
            // Tab items row
            HStack(spacing: 0) {
                navItem(.dashboard, symbol: "square.grid.2x2.fill",    title: "Home")
                navItem(.claims,    symbol: "doc.text.magnifyingglass", title: "Claims")

                // Spacer for the floating button
                Color.clear.frame(width: addSize + 16)

                navItem(.household, symbol: "person.2.fill",           title: "Family")
                navItem(.profile,   symbol: "person.crop.circle.fill", title: "Profile")
            }
            .padding(.horizontal, 8)
            .padding(.top, 14)
            .padding(.bottom, 34) // accounts for home indicator safe area
            .background(
                UnevenRoundedRectangle(
                    topLeadingRadius: 24,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 24
                )
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.06), radius: 12, y: -4)
            )

            // Floating add button — anchored above the bar
            addButton
                .offset(y: -(addSize / 2))
        }
    }

    @ViewBuilder
    private func navItem(_ tab: MainTab, symbol: String, title: String) -> some View {
        let isSelected = selected == tab

        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                selected = tab
            }
        } label: {
            VStack(spacing: 5) {
                Image(systemName: symbol)
                    .font(.system(size: 20, weight: isSelected ? .bold : .medium))
                    .symbolEffect(.bounce, value: isSelected)
                Text(title)
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundStyle(isSelected ? AppColors.brandBlue : AppColors.textSecondary)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    private var addButton: some View {
        Button(action: onAddTapped) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppColors.brandBlue, Color(red: 0.02, green: 0.40, blue: 0.90)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: addSize, height: addSize)
                    .shadow(color: AppColors.brandBlue.opacity(0.30), radius: 10, y: 6)

                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
    }
}
