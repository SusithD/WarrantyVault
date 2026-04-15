import SwiftUI

struct DashboardView: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        @Bindable var store = store

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header

                summaryStrip

                searchField

                categoryChips

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Your Warranties")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(AppColors.textPrimary)
                        Spacer()
                        Text("\(store.filteredWarranties.count)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(AppColors.textSecondary)
                    }

                    if store.filteredWarranties.isEmpty {
                        emptyState
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(store.filteredWarranties) { w in
                                NavigationLink(value: w) {
                                    WarrantyRow(warranty: w)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
        .safeAreaInset(edge: .top, spacing: 0) { navBar }
        .navigationDestination(for: Warranty.self) { w in
            WarrantyDetailView(warrantyID: w.id)
        }
    }

    // MARK: Subviews

    private var navBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Good morning")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(AppColors.textSecondary)
                Text("WarrantyVault")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(AppColors.textPrimary)
            }
            Spacer()
            Button {
                // placeholder notifications
            } label: {
                Image(systemName: "bell.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppColors.brandBlue)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(AppColors.brandBlueSoft))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(
            GradientBackground().opacity(0.95).ignoresSafeArea(edges: .top)
        )
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Jamie".uppercased())
                .overlineStyle(color: AppColors.brandBlue)
            Text("Welcome back,\nlet's keep things covered.")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(AppColors.textPrimary)
                .lineSpacing(2)
        }
        .padding(.top, 4)
    }

    private var summaryStrip: some View {
        HStack(spacing: 12) {
            summaryTile(title: "Active",       count: store.activeCount,        tint: AppColors.success,   symbol: "checkmark.seal.fill")
            summaryTile(title: "Expiring",     count: store.expiringSoonCount,  tint: AppColors.warning,   symbol: "clock.badge.exclamationmark.fill")
            summaryTile(title: "Open Claims",  count: store.openClaimsCount,    tint: AppColors.brandBlue, symbol: "doc.text.magnifyingglass")
        }
    }

    private func summaryTile(title: String, count: Int, tint: Color, symbol: String) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 8) {
                ZStack {
                    Circle().fill(tint.opacity(0.15)).frame(width: 34, height: 34)
                    Image(systemName: symbol)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(tint)
                }
                Text("\(count)")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(AppColors.textPrimary)
                Text(title.uppercased())
                    .overlineStyle()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var searchField: some View {
        @Bindable var store = store
        return HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppColors.textSecondary)
            TextField("Search warranties", text: $store.searchText)
                .font(.system(size: 15))
            if !store.searchText.isEmpty {
                Button { store.searchText = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(AppColors.textTertiary)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppColors.border, lineWidth: 1)
        )
    }

    private var categoryChips: some View {
        @Bindable var store = store
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip(title: "All", isSelected: store.categoryFilter == nil) {
                    store.categoryFilter = nil
                }
                ForEach(WarrantyCategory.allCases) { cat in
                    chip(title: cat.rawValue, isSelected: store.categoryFilter == cat) {
                        store.categoryFilter = (store.categoryFilter == cat) ? nil : cat
                    }
                }
            }
        }
    }

    private func chip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(isSelected ? .white : AppColors.textPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule().fill(isSelected ? AppColors.brandBlue : Color.white)
                )
                .overlay(
                    Capsule().stroke(isSelected ? .clear : AppColors.border, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private var emptyState: some View {
        GlassCard {
            VStack(spacing: 12) {
                Image(systemName: "tray")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(AppColors.textSecondary)
                Text("No warranties match your filters")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
        }
    }
}

// MARK: - Row

struct WarrantyRow: View {
    let warranty: Warranty

    var body: some View {
        GlassCard {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(warranty.category.tint.opacity(0.15))
                        .frame(width: 48, height: 48)
                    Image(systemName: warranty.category.symbolName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(warranty.category.tint)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(warranty.productName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(1)
                    Text("\(warranty.brand) · \(warranty.category.rawValue)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(1)
                    StatusChip(status: warranty.status, daysRemaining: warranty.daysRemaining)
                        .padding(.top, 2)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(AppColors.textTertiary)
            }
        }
    }
}

struct StatusChip: View {
    let status: WarrantyStatus
    let daysRemaining: Int

    var body: some View {
        HStack(spacing: 6) {
            Circle().fill(status.tint).frame(width: 6, height: 6)
            Text(label)
                .font(.system(size: 11, weight: .semibold))
        }
        .foregroundStyle(status.tint)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Capsule().fill(status.softTint))
    }

    private var label: String {
        switch status {
        case .active:       return "Active · \(daysRemaining)d left"
        case .expiringSoon: return "Expires in \(max(daysRemaining, 0))d"
        case .expired:      return "Expired \(abs(daysRemaining))d ago"
        }
    }
}

#Preview {
    NavigationStack {
        DashboardView()
            .environment(AppStore())
    }
}
