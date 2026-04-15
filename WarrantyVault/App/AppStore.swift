import Foundation
import Observation

/// App-wide in-memory store that feeds every screen.
/// Backed by `MockData` on first launch; replace with real persistence later.
@Observable
final class AppStore {
    // Data
    var warranties: [Warranty]
    var claims:     [Claim]
    var household:  Household
    var activity:   [ActivityEntry]
    var messages:   [ChatMessage]

    // UI state
    var selectedTab: MainTab = .dashboard
    var searchText: String = ""
    var categoryFilter: WarrantyCategory? = nil

    init(
        warranties: [Warranty]    = MockData.warranties,
        claims:     [Claim]       = MockData.claims,
        household:  Household     = MockData.household,
        activity:   [ActivityEntry] = MockData.activity,
        messages:   [ChatMessage] = MockData.chatMessages
    ) {
        self.warranties = warranties
        self.claims     = claims
        self.household  = household
        self.activity   = activity
        self.messages   = messages
    }

    // MARK: Derived

    var filteredWarranties: [Warranty] {
        warranties
            .filter { w in
                guard let cat = categoryFilter else { return true }
                return w.category == cat
            }
            .filter { w in
                let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                guard !q.isEmpty else { return true }
                return w.productName.lowercased().contains(q)
                    || w.brand.lowercased().contains(q)
                    || w.retailer.lowercased().contains(q)
            }
            .sorted { $0.expiryDate < $1.expiryDate }
    }

    var expiringSoonCount: Int { warranties.filter { $0.status == .expiringSoon }.count }
    var activeCount:       Int { warranties.filter { $0.status == .active }.count }
    var expiredCount:      Int { warranties.filter { $0.status == .expired }.count }

    var openClaimsCount: Int {
        claims.filter { $0.status != .completed && $0.status != .rejected }.count
    }

    // MARK: Mutations

    func addWarranty(_ w: Warranty) {
        warranties.insert(w, at: 0)
        activity.insert(
            ActivityEntry(
                kind: .added,
                actorName: household.members.first?.name ?? "You",
                actorInitials: household.members.first?.avatarInitials ?? "ME",
                actorAccentHex: household.members.first?.accentHex ?? "#0A84FF",
                title: "Added \(w.productName)",
                detail: "\(w.category.rawValue) · \(w.brand)",
                occurredAt: Date()
            ),
            at: 0
        )
    }

    func updateWarranty(_ w: Warranty) {
        guard let idx = warranties.firstIndex(where: { $0.id == w.id }) else { return }
        warranties[idx] = w
    }

    func deleteWarranty(_ id: UUID) {
        warranties.removeAll { $0.id == id }
    }

    func addClaim(_ c: Claim) {
        claims.insert(c, at: 0)
        activity.insert(
            ActivityEntry(
                kind: .claimed,
                actorName: household.members.first?.name ?? "You",
                actorInitials: household.members.first?.avatarInitials ?? "ME",
                actorAccentHex: household.members.first?.accentHex ?? "#0A84FF",
                title: "Filed claim \(c.referenceCode)",
                detail: "\(c.productName) · \(c.status.rawValue)",
                occurredAt: Date()
            ),
            at: 0
        )
    }

    func appendMessage(_ text: String) {
        let msg = ChatMessage(text: text, isFromUser: true, sentAt: Date())
        messages.append(msg)
    }

    func addMember(_ m: HouseholdMember) {
        household.members.append(m)
    }

    func removeMember(_ id: UUID) {
        household.members.removeAll { $0.id == id }
    }

    func updateMemberRole(_ id: UUID, role: HouseholdRole) {
        guard let idx = household.members.firstIndex(where: { $0.id == id }) else { return }
        household.members[idx].role = role
    }
}

enum MainTab: Hashable {
    case dashboard, claims, add, household, profile
}
