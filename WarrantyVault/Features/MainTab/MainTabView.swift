import SwiftUI

/// Top-level main app shell with a custom 5-item bottom nav matching the Figma.
/// The middle "Add" slot is a floating circular button that presents the Add Warranty sheet.
struct MainTabView: View {
    @Environment(AppStore.self) private var store
    @State private var presentingAdd = false
    @State private var presentingFileClaim = false

    var body: some View {
        @Bindable var store = store

        ZStack(alignment: .bottom) {
            GradientBackground()

            Group {
                switch store.selectedTab {
                case .dashboard:
                    NavigationStack { DashboardView() }
                case .claims:
                    NavigationStack { ClaimsListView(presentingFileClaim: $presentingFileClaim) }
                case .add:
                    EmptyView() // handled via sheet
                case .household:
                    HouseholdHubView()
                case .profile:
                    NavigationStack { ProfileView() }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.bottom, 96)

            BottomNavBar(
                selected: $store.selectedTab,
                onAddTapped: { presentingAdd = true }
            )
        }
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

    var body: some View {
        HStack(spacing: 0) {
            navItem(.dashboard, symbol: "square.grid.2x2.fill",        title: "Home")
            navItem(.claims,    symbol: "doc.text.magnifyingglass",    title: "Claims")
            addButton
            navItem(.household, symbol: "person.2.fill",               title: "Family")
            navItem(.profile,   symbol: "person.crop.circle.fill",     title: "Profile")
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 22)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(AppColors.border, lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 10)
    }

    @ViewBuilder
    private func navItem(_ tab: MainTab, symbol: String, title: String) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                selected = tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: symbol)
                    .font(.system(size: 20, weight: .semibold))
                Text(title)
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundStyle(selected == tab ? AppColors.brandBlue : AppColors.textSecondary)
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
                            colors: [AppColors.brandBlue, AppColors.brandBlue.opacity(0.85)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 54, height: 54)
                    .shadow(color: AppColors.brandBlue.opacity(0.35), radius: 12, y: 8)
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
        .offset(y: -14)
        .frame(maxWidth: .infinity)
    }
}
