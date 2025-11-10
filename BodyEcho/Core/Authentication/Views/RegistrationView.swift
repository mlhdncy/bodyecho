//
//  RegistrationView.swift
//  BodyEcho
//
//  Created on 2025-11-10
//

import SwiftUI

struct RegistrationView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var acceptedTerms = false

    var body: some View {
        ZStack {
            Color.backgroundNeutral
                .ignoresSafeArea()

            VStack(spacing: 32) {
                // Logo and Title
                VStack(spacing: 16) {
                    Image(systemName: "waveform.path.ecg")
                        .font(.system(size: 50))
                        .foregroundColor(.primaryTeal)

                    Text("Body Echo")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.textPrimary)
                }
                .padding(.top, 40)

                // Registration Card
                VStack(spacing: 20) {
                    Text("Kaydol")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .center)

                    CustomTextField(
                        placeholder: "Ad Soyad",
                        text: $fullName
                    )

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

                    // Terms and Conditions
                    HStack(alignment: .top, spacing: 12) {
                        Button(action: {
                            acceptedTerms.toggle()
                        }) {
                            Image(systemName: acceptedTerms ? "checkmark.square.fill" : "square")
                                .foregroundColor(acceptedTerms ? .buttonPrimary : .textSecondary)
                                .font(.system(size: 24))
                        }

                        Text("Kullanım koşullarını ve gizlilik politikasını kabul ediyorum.")
                            .font(.system(size: 14))
                            .foregroundColor(.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    if let errorMessage = authViewModel.errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundColor(.alertOrange)
                            .multilineTextAlignment(.center)
                    }

                    CustomButton(
                        title: "HESAP OLUŞTUR",
                        action: {
                            Task {
                                await authViewModel.signUp(
                                    fullName: fullName,
                                    email: email,
                                    password: password
                                )
                                if authViewModel.isAuthenticated {
                                    dismiss()
                                }
                            }
                        },
                        isLoading: authViewModel.isLoading,
                        isDisabled: !isFormValid
                    )
                }
                .padding(24)
                .background(Color.white)
                .cornerRadius(20)
                .cardShadow()
                .padding(.horizontal, 24)

                // Sign In Link
                HStack(spacing: 4) {
                    Text("Zaten hesabın var mı?")
                        .font(.system(size: 15))
                        .foregroundColor(.textSecondary)

                    Button("Giriş Yap") {
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.buttonPrimary)
                }

                Spacer()
            }
        }
    }

    private var isFormValid: Bool {
        !fullName.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        password.count >= 6 &&
        acceptedTerms
    }
}

#Preview {
    RegistrationView()
        .environmentObject(AuthViewModel())
}
