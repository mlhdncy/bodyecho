//
//  ProfileView.swift
//  BodyEcho
//
//  Created on 2025-11-10
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundNeutral
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Header
                        if let user = authViewModel.currentUser {
                            VStack(spacing: 16) {
                                AvatarView(size: 100, avatarType: user.avatarType)

                                Text(user.fullName)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.textPrimary)

                                HStack(spacing: 24) {
                                    VStack {
                                        Text("Seviye \(user.level)")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.primaryTeal)
                                        Text("Level")
                                            .font(.system(size: 12))
                                            .foregroundColor(.textSecondary)
                                    }

                                    Divider()
                                        .frame(height: 40)

                                    VStack {
                                        Text("\(user.points)")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.primaryTeal)
                                        Text("Puan")
                                            .font(.system(size: 12))
                                            .foregroundColor(.textSecondary)
                                    }
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                            .cardShadow()
                        }

                        // Settings Section
                        VStack(spacing: 0) {
                            settingRow(icon: "person.fill", title: "Profil Bilgileri")
                            Divider().padding(.leading, 52)
                            settingRow(icon: "bell.fill", title: "Bildirimler")
                            Divider().padding(.leading, 52)
                            settingRow(icon: "lock.fill", title: "Gizlilik")
                            Divider().padding(.leading, 52)
                            settingRow(icon: "questionmark.circle.fill", title: "Yardım & Destek")
                        }
                        .background(Color.white)
                        .cornerRadius(16)
                        .cardShadow()

                        // Sign Out Button
                        CustomButton(
                            title: "Çıkış Yap",
                            action: {
                                authViewModel.signOut()
                            },
                            style: .outline
                        )
                    }
                    .padding()
                }
            }
            .navigationTitle("Ayarlar")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func settingRow(icon: String, title: String) -> some View {
        Button(action: {
            // TODO: Navigate to setting detail
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.primaryTeal)
                    .frame(width: 28)

                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.textPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.textSecondary)
            }
            .padding()
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
