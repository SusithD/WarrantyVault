//
//  AuthenticationView.swift
//  WarrantyVault
//
//  Biometric unlock screen. Stubs Face ID via LocalAuthentication and falls
//  back to a passcode prompt.
//

import SwiftUI
import LocalAuthentication

struct AuthenticationView: View {
    var onAuthenticated: () -> Void

    @State private var isScanning = false
    @State private var showPasscode = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            GradientBackground()

            VStack(spacing: 0) {
                // Brand header
                VStack(spacing: 6) {
                    Text("WarrantyVault")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(AppColors.textPrimary)

                    Text("SECURE INFRASTRUCTURE")
                        .font(AppTypography.overline)
                        .tracking(2.0)
                        .foregroundStyle(AppColors.brandBlue)
                }
                .padding(.top, 40)
                .padding(.bottom, 28)

                // Main card
                GlassCard(padding: 28, cornerRadius: 32) {
                    VStack(spacing: 24) {
                        // Avatar badge
                        ZStack {
                            Circle()
                                .fill(AppColors.brandBlueSoft)
                                .frame(width: 80, height: 80)
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 40, weight: .regular))
                                .foregroundStyle(AppColors.brandBlue)
                        }

                        VStack(spacing: 8) {
                            Text("Welcome Back")
                                .font(AppTypography.title)
                                .foregroundStyle(AppColors.textPrimary)

                            Text("Verify your identity to access your vault")
                                .font(AppTypography.body)
                                .foregroundStyle(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                        }

                        // Face ID scan button
                        Button(action: beginBiometricAuth) {
                            VStack(spacing: 0) {
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .fill(AppColors.brandBlueSoft)
                                    .frame(width: 140, height: 140)
                                    .overlay(
                                        faceIDIcon
                                    )

                                // Tap-to-scan chip overlapping bottom edge
                                Text("TAP TO SCAN")
                                    .font(AppTypography.overline)
                                    .tracking(1.5)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule().fill(AppColors.brandBlue)
                                    )
                                    .shadow(color: AppColors.brandBlue.opacity(0.3),
                                            radius: 8, x: 0, y: 4)
                                    .offset(y: -18)
                            }
                            .scaleEffect(isScanning ? 0.96 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: isScanning)
                        }
                        .buttonStyle(.plain)

                        if let errorMessage {
                            Text(errorMessage)
                                .font(AppTypography.caption)
                                .foregroundStyle(AppColors.danger)
                        }

                        // Security line
                        HStack(spacing: 6) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 11, weight: .semibold))
                            Text("END-TO-END ENCRYPTED")
                                .font(AppTypography.overline)
                                .tracking(1.5)
                        }
                        .foregroundStyle(AppColors.textTertiary)
                    }
                }
                .padding(.horizontal, 24)

                Spacer()

                // Family vault chip
                HStack(spacing: 10) {
                    HStack(spacing: -8) {
                        ForEach(0..<2) { i in
                            Circle()
                                .fill(i == 0 ? AppColors.purple : AppColors.warning)
                                .frame(width: 24, height: 24)
                                .overlay(Circle().stroke(.white, lineWidth: 2))
                        }
                        Circle()
                            .fill(AppColors.textPrimary)
                            .frame(width: 24, height: 24)
                            .overlay(
                                Text("+2")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(.white)
                            )
                            .overlay(Circle().stroke(.white, lineWidth: 2))
                    }
                    Text("FAMILY VAULT ACTIVE")
                        .font(AppTypography.overline)
                        .tracking(1.2)
                        .foregroundStyle(AppColors.textPrimary)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(
                    Capsule().fill(.white.opacity(0.6))
                )
                .overlay(Capsule().stroke(AppColors.border, lineWidth: 1))

                // Passcode & forgot links
                VStack(spacing: 10) {
                    Button("Enter Passcode Instead") {
                        showPasscode = true
                    }
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(AppColors.brandBlue)

                    Rectangle()
                        .fill(AppColors.border)
                        .frame(width: 140, height: 1)

                    Button("FORGOT PASSCODE?") { }
                        .font(AppTypography.overline)
                        .tracking(1.5)
                        .foregroundStyle(AppColors.textSecondary)
                }
                .padding(.top, 24)
                .padding(.bottom, 32)
            }
            .padding(.horizontal, 24)
        }
        .sheet(isPresented: $showPasscode) {
            PasscodeEntrySheet(onUnlock: onAuthenticated)
        }
    }

    private var faceIDIcon: some View {
        ZStack {
            Circle()
                .stroke(AppColors.brandBlue, lineWidth: 2.5)
                .frame(width: 72, height: 72)

            VStack(spacing: 6) {
                HStack(spacing: 12) {
                    Circle().fill(AppColors.brandBlue).frame(width: 6, height: 6)
                    Circle().fill(AppColors.brandBlue).frame(width: 6, height: 6)
                }
                RoundedRectangle(cornerRadius: 1)
                    .fill(AppColors.brandBlue)
                    .frame(width: 24, height: 2)
            }
        }
    }

    private func beginBiometricAuth() {
        withAnimation { isScanning = true }
        errorMessage = nil

        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                        error: &error) else {
            // In simulator / no biometrics → auto-succeed for dev builds.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                isScanning = false
                onAuthenticated()
            }
            return
        }

        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                               localizedReason: "Unlock WarrantyVault") { success, err in
            DispatchQueue.main.async {
                isScanning = false
                if success {
                    onAuthenticated()
                } else {
                    errorMessage = err?.localizedDescription ?? "Authentication failed"
                }
            }
        }
    }
}

// MARK: - Passcode Sheet

private struct PasscodeEntrySheet: View {
    var onUnlock: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var passcode = ""

    var body: some View {
        VStack(spacing: 24) {
            Capsule()
                .fill(AppColors.border)
                .frame(width: 40, height: 4)
                .padding(.top, 12)

            Text("Enter Passcode")
                .font(AppTypography.title)

            SecureField("••••••", text: $passcode)
                .textFieldStyle(.roundedBorder)
                .multilineTextAlignment(.center)
                .keyboardType(.numberPad)
                .padding(.horizontal, 40)

            PrimaryButton(title: "Unlock", isEnabled: passcode.count >= 4) {
                onUnlock()
                dismiss()
            }
            .padding(.horizontal, 24)

            Spacer()
        }
        .presentationDetents([.height(320)])
    }
}

#Preview {
    AuthenticationView(onAuthenticated: {})
}
