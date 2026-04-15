import SwiftUI

struct MainTabView: View {
    @Environment(AppStore.self) private var store
    @State private var presentingAdd = false
    @State private var presentingFileClaim = false

    var body: some View {
        @Bindable var store = store

        ZStack {
            GradientBackground()
                .ignoresSafeArea()

            VStack(spacing: 0) {
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

                BottomNavBar(
                    selected: $store.selectedTab,
                    onAddTapped: { presentingAdd = true }
                )
            }
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

    private let addSize: CGFloat = 56

    var body: some View {
        HStack(spacing: 0) {
            navItem(.dashboard, symbol: "square.grid.2x2.fill",    title: "Home")
            navItem(.claims,    symbol: "doc.text.magnifyingglass", title: "Claims")

            // Invisible spacer reserves width for the floating + button
            Color.clear
                .frame(width: addSize + 12, height: 1)

            navItem(.household, symbol: "person.2.fill",           title: "Family")
            navItem(.profile,   symbol: "person.crop.circle.fill", title: "Profile")
        }
        .padding(.horizontal, 8)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(
            Color.white
                .shadow(color: .black.opacity(0.06), radius: 12, y: -4)
                .ignoresSafeArea(edges: .bottom)
        )
        .overlay(alignment: .top) {
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
            VStack(spacing: 4) {
                Image(systemName: symbol)
                    .font(.system(size: 20, weight: isSelected ? .bold : .medium))
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
            Circle()
                .fill(
                    LinearGradient(
                        colors: [AppColors.brandBlue, Color(red: 0.02, green: 0.40, blue: 0.90)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: addSize, height: addSize)
                .shadow(color: AppColors.brandBlue.opacity(0.30), radius: 10, y: 4)
                .overlay(
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                )
        }
        .buttonStyle(.plain)
    }
}
