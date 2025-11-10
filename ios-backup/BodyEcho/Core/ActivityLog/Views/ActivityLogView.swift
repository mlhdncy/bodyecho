//
//  ActivityLogView.swift
//  BodyEcho
//
//  Created on 2025-11-10
//

import SwiftUI

struct ActivityLogView: View {
    @State private var selectedTab = 0
    @State private var activityDuration = ""
    @State private var activityDistance = ""

    private let tabs = ["Beslenme", "Aktivite", "Uyku", "Mod"]

    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundNeutral
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button(action: {
                            // Go back
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.primaryTeal)
                                .font(.system(size: 20))
                        }

                        Spacer()

                        HStack(spacing: 8) {
                            Image(systemName: "leaf.fill")
                                .foregroundColor(.primaryTeal)
                            Text("Yeni Giriş Yap")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.textPrimary)
                        }

                        Spacer()

                        Color.clear.frame(width: 44) // Spacer for balance
                    }
                    .padding()
                    .background(Color.white)

                    // Tab Selector
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(0..<tabs.count, id: \.self) { index in
                                tabButton(title: tabs[index], index: index)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 16)

                    // Content based on selected tab
                    ScrollView {
                        VStack(spacing: 20) {
                            if selectedTab == 1 { // Aktivite tab
                                activityContent
                            } else {
                                Text("Yakında...")
                                    .font(.system(size: 16))
                                    .foregroundColor(.textSecondary)
                                    .padding(.top, 40)
                            }
                        }
                        .padding()
                    }

                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
    }

    // MARK: - Tab Button
    private func tabButton(title: String, index: Int) -> some View {
        Button(action: {
            selectedTab = index
        }) {
            VStack(spacing: 4) {
                Image(systemName: iconForTab(index))
                    .font(.system(size: 24))

                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(selectedTab == index ? .primaryTeal : .textSecondary)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(
                selectedTab == index ?
                Color.primaryTeal.opacity(0.1) :
                Color.clear
            )
            .cornerRadius(12)
        }
    }

    // MARK: - Activity Content
    private var activityContent: some View {
        VStack(spacing: 24) {
            Text("Aktiviteyi Kaydet")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Activity type cards
            HStack(spacing: 16) {
                activityTypeCard(icon: "figure.walk", title: "Yürüyüş", color: .primaryTeal)
                activityTypeCard(icon: "figure.run", title: "Koşu", color: .primaryTealLight)
                activityTypeCard(icon: "bicycle", title: "Bisiklet", color: .alertOrangeLight)
            }

            // Duration and distance inputs
            VStack(alignment: .leading, spacing: 16) {
                Text("Süre (Dakika)")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.textPrimary)

                HStack {
                    TextField("30", text: $activityDuration)
                        .keyboardType(.numberPad)
                        .font(.system(size: 16))
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                }

                Text("Mesafe (KM)")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.textPrimary)

                HStack {
                    TextField("2.5 KM", text: $activityDistance)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 16))
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .cardShadow()

            // Motivation message
            HStack(spacing: 8) {
                Image(systemName: "leaf.fill")
                    .foregroundColor(.primaryTeal)
                Text("30 dakika aktivite ile 250 kalori yakabilirsin!")
                    .font(.system(size: 14))
                    .foregroundColor(.textPrimary)
            }
            .padding()
            .background(Color.primaryTeal.opacity(0.1))
            .cornerRadius(12)

            // Save button
            CustomButton(
                title: "Veriyi Kaydet",
                action: {
                    // TODO: Save activity
                },
                style: .primary
            )
        }
    }

    // MARK: - Activity Type Card
    private func activityTypeCard(icon: String, title: String, color: Color) -> some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(color.opacity(0.2))
                    .frame(height: 100)

                Image(systemName: icon)
                    .font(.system(size: 36))
                    .foregroundColor(color)
            }

            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.textPrimary)

            Button(action: {
                // Select activity
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.primaryTeal)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func iconForTab(_ index: Int) -> String {
        switch index {
        case 0: return "fork.knife"
        case 1: return "figure.walk"
        case 2: return "moon.zzz"
        case 3: return "face.smiling"
        default: return "questionmark"
        }
    }
}

#Preview {
    ActivityLogView()
}
