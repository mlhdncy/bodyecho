//
//  TrendsView.swift
//  BodyEcho
//
//  Created on 2025-11-10
//

import SwiftUI

struct TrendsView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundNeutral
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header
                        HStack {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .foregroundColor(.primaryTeal)
                            Text("Trendler & İçgörüler")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.textPrimary)
                        }
                        .padding(.horizontal)

                        // Health Metrics Section
                        Text("Sağlık Metrikleri Trendleri")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.textPrimary)
                            .padding(.horizontal)

                        // Placeholder cards for metrics
                        VStack(spacing: 16) {
                            metricCard(title: "Fiziksel Aktivite", icon: "figure.walk", color: .primaryTeal)
                            metricCard(title: "Uyku Süresi", icon: "moon.zzz.fill", color: .primaryTealLight)
                            metricCard(title: "Beslenme Kalitesi", icon: "fork.knife", color: .alertOrangeLight)
                        }
                        .padding(.horizontal)

                        // TODO: Implement actual charts and trend analysis
                    }
                    .padding(.vertical)
                }
            }
            .navigationBarHidden(true)
        }
    }

    private func metricCard(title: String, icon: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 40)

            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.textPrimary)

            Spacer()

            Text("📈")
                .font(.system(size: 24))
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .cardShadow()
    }
}

#Preview {
    TrendsView()
}
