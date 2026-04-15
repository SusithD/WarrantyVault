//
//  AppCoordinator.swift
//  WarrantyVault
//
//  Drives the top-level flow: Splash → Onboarding → Authentication → MainApp.
//

import SwiftUI

enum AppFlowStage: Hashable {
    case splash
    case onboarding
    case authentication
    case mainApp
}

@Observable
final class AppCoordinator {
    var stage: AppFlowStage = .splash

    /// Has the user previously completed onboarding? Real app would persist this.
    var hasCompletedOnboarding: Bool = false

    func advanceFromSplash() {
        stage = hasCompletedOnboarding ? .authentication : .onboarding
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        stage = .authentication
    }

    func authenticated() {
        stage = .mainApp
    }
}
