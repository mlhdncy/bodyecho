//
//  LoginView.swift
//  BodyEcho
//
//  Created on 2025-11-10
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showRegistration = false

    var body: some View {
        ZStack {
            Color.backgroundNeutral
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // Logo and Title
                VStack(spacing: 16) {
                    Image(systemName: "waveform.path.ecg")
                        .font(.system(size: 60))
                        .foregroundColor(.primaryTeal)

                    Text("Body Echo")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.textPrimary)
                }

                Spacer()

                // Login Card
                VStack(spacing: 20) {
                    Text("Giriş Yap")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .center)

                    CustomTextField(
                        placeholder: "E-posta Adresi",
                        text: $email,
                        keyboardType: .emailAddress
                    )

                    CustomTextField(
                        placeholder: "Şifre",
                        text: $password,
                        isSecure: true
                    )

                    if let errorMessage = authViewModel.errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundColor(.alertOrange)
                            .multilineTextAlignment(.center)
                    }

                    Button("Şifremi Unuttum?") {
                        // TODO: Implement password reset
                    }
                    .font(.system(size: 14))
                    .foregroundColor(.buttonPrimary)

                    CustomButton(
                        title: "GİRİŞ",
                        action: {
                            Task {
                                await authViewModel.signIn(email: email, password: password)
                            }
                        },
                        isLoading: authViewModel.isLoading,
                        isDisabled: email.isEmpty || password.isEmpty
                    )
                }
                .padding(24)
                .background(Color.white)
                .cornerRadius(20)
                .cardShadow()
                .padding(.horizontal, 24)

                // Sign Up Link
                HStack(spacing: 4) {
                    Text("Hesabın yok mu?")
                        .font(.system(size: 15))
                        .foregroundColor(.textSecondary)

                    Button("Kaydol") {
                        showRegistration = true
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.buttonPrimary)
                }

                Spacer()
            }
        }
        .sheet(isPresented: $showRegistration) {
            RegistrationView()
                .environmentObject(authViewModel)
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
