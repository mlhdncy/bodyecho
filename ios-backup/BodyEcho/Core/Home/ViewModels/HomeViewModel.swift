//
//  HomeViewModel.swift
//  BodyEcho
//
//  Created on 2025-11-10
//

import Foundation
import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var todayMetric: DailyMetric?
    @Published var aiInsights: [AIInsight] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let firebaseService = FirebaseService.shared
    private let authService = AuthService.shared

    init() {
        Task {
            await loadData()
        }
    }

    func loadData() async {
        isLoading = true

        do {
            // Load current user
            currentUser = try await authService.getCurrentUser()

            // Load today's metrics
            if let user = currentUser {
                todayMetric = try await firebaseService.getTodayMetric(for: user.anonymousId)

                // If no metric exists for today, create one
                if todayMetric == nil {
                    let newMetric = DailyMetric(
                        userId: user.anonymousId,
                        date: Date()
                    )
                    try await firebaseService.updateDailyMetric(newMetric)
                    todayMetric = newMetric
                }

                // Generate AI insights
                generateAIInsights()
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func updateSteps(_ steps: Int) async {
        guard let user = currentUser else { return }

        do {
            try await firebaseService.createOrUpdateTodayMetric(
                userId: user.anonymousId,
                steps: steps
            )
            await loadData()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func updateWaterIntake(_ liters: Double) async {
        guard let user = currentUser else { return }

        do {
            try await firebaseService.createOrUpdateTodayMetric(
                userId: user.anonymousId,
                water: liters
            )
            await loadData()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func generateAIInsights() {
        guard let metric = todayMetric else { return }

        aiInsights = []

        // Sleep quality insight
        if metric.sleepQuality < 70 {
            aiInsights.append(AIInsight(
                type: .suggestion,
                title: "Uyku Düzeninizi İyileştirin",
                message: "Son 7 günün uyku verileri, tutarlı bir uyku saatlerini gösteriyor. Her gün aynı saatlerde yatıp kalkmanız, uyku kalitenizi artırabilir.",
                actionable: "Bilgi için tıkla"
            ))
        }

        // Vitamin D warning (simulated)
        if metric.steps < 5000 {
            aiInsights.append(AIInsight(
                type: .warning,
                title: "D Vitamini Eksikliği Riski",
                message: "Son haftalardaki düşük günlük güneş ışığı maruziyeti ve beslenme göre risk tespit edilmiştir. Güneş ışığı alımını artırmayı veya takviye kullanmayı düşünün.",
                actionable: "Bilgi için tıkla"
            ))
        }

        // Achievement
        if metric.steps > 10000 {
            aiInsights.append(AIInsight(
                type: .achievement,
                title: "Harika Gidiyorsun!",
                message: "Bugün 10.000 adım hedefini aştın! Devam et!",
                actionable: nil
            ))
        }
    }

    var greetingMessage: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:
            return "Günaydın"
        case 12..<18:
            return "İyi günler"
        default:
            return "İyi akşamlar"
        }
    }

    var dailyMotivation: String {
        let messages = [
            "Bugün 7 saat uyudun.",
            "Harika bir gün olacak!",
            "Kendine iyi bak!",
            "Sağlıklı beslenmeyi unutma!"
        ]
        return messages.randomElement() ?? messages[0]
    }
}
