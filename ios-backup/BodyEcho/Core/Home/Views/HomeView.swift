//
//  HomeView.swift
//  BodyEcho
//
//  Created on 2025-11-10
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundNeutral
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Header with user info
                        headerView

                        // Avatar with message
                        if let user = viewModel.currentUser {
                            avatarMessageCard(user: user)
                        }

                        // Daily Goals Widget
                        if let metric = viewModel.todayMetric {
                            DailyGoalsWidget(metric: metric)
                                .padding(.horizontal)
                        }

                        // AI Insights Section
                        if !viewModel.aiInsights.isEmpty {
                            aiInsightsSection
                        }

                        // New Entry Button
                        newEntryButton
                    }
                    .padding(.vertical)
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            Task {
                await viewModel.loadData()
            }
        }
    }

    // MARK: - Header View
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(viewModel.greetingMessage), \(viewModel.currentUser?.fullName.components(separatedBy: " ").first ?? "Kullanıcı")")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.textPrimary)
            }

            Spacer()

            if let user = viewModel.currentUser {
                AvatarWithLevel(
                    size: 60,
                    avatarType: user.avatarType,
                    level: user.level,
                    points: user.points
                )
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Avatar Message Card
    private func avatarMessageCard(user: User) -> some View {
        HStack(spacing: 12) {
            AvatarView(size: 50, avatarType: user.avatarType)

            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.dailyMotivation)
                    .font(.system(size: 14))
                    .foregroundColor(.textPrimary)
            }

            Spacer()
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .cardShadow()
        .padding(.horizontal)
    }

    // MARK: - AI Insights Section
    private var aiInsightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.primaryTeal)
                Text("AI Asistanından Öneriler")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.textPrimary)
            }
            .padding(.horizontal)

            ForEach(viewModel.aiInsights) { insight in
                AIRecommendationCard(insight: insight)
                    .padding(.horizontal)
            }
        }
    }

    // MARK: - New Entry Button
    private var newEntryButton: some View {
        CustomButton(
            title: "Yeni Giriş Yap + Görevler (3 Tamamlandı)",
            action: {
                // TODO: Navigate to activity log
            },
            style: .primary
        )
        .padding(.horizontal)
    }
}

#Preview {
    HomeView()
}
