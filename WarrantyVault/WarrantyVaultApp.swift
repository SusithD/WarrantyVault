//
//  WarrantyVaultApp.swift
//  WarrantyVault
//
//  App entry point. Hosts the AppCoordinator and switches between
//  splash, onboarding, auth and main app based on current stage.
//

import SwiftUI

@main
struct WarrantyVaultApp: App {
    @State private var coordinator = AppCoordinator()
    @State private var store       = AppStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(coordinator)
                .environment(store)
                .preferredColorScheme(.light)
        }
    }
}

struct RootView: View {
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        ZStack {
            switch coordinator.stage {
            case .splash:
                SplashView(onFinish: { coordinator.advanceFromSplash() })
                    .transition(.opacity)

            case .onboarding:
                OnboardingContainerView(onComplete: { coordinator.completeOnboarding() })
                    .transition(.opacity)

            case .authentication:
                AuthenticationView(onAuthenticated: { coordinator.authenticated() })
                    .transition(.opacity)

            case .mainApp:
                MainTabView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: coordinator.stage)
    }
}

#Preview {
    RootView()
        .environment(AppCoordinator())
}
