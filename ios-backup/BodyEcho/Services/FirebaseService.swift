//
//  FirebaseService.swift
//  BodyEcho
//
//  Created on 2025-11-10
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class FirebaseService {
    static let shared = FirebaseService()
    private let db = Firestore.firestore()

    private init() {}

    // MARK: - Daily Metrics

    func getTodayMetric(for userId: String) async throws -> DailyMetric? {
        let today = Calendar.current.startOfDay(for: Date())

        let snapshot = try await db.collection("dailyMetrics")
            .whereField("userId", isEqualTo: userId)
            .whereField("date", isGreaterThanOrEqualTo: today)
            .limit(to: 1)
            .getDocuments()

        return try snapshot.documents.first?.data(as: DailyMetric.self)
    }

    func updateDailyMetric(_ metric: DailyMetric) async throws {
        guard let id = metric.id else {
            // Create new if doesn't exist
            try db.collection("dailyMetrics").addDocument(from: metric)
            return
        }

        try db.collection("dailyMetrics").document(id).setData(from: metric, merge: true)
    }

    func createOrUpdateTodayMetric(userId: String, steps: Int? = nil, water: Double? = nil, calories: Int? = nil, sleep: Int? = nil) async throws {
        if var metric = try await getTodayMetric(for: userId) {
            // Update existing
            if let steps = steps { metric.steps = steps }
            if let water = water { metric.waterIntake = water }
            if let calories = calories { metric.calorieEstimate = calories }
            if let sleep = sleep { metric.sleepQuality = sleep }
            metric.updatedAt = Date()

            try await updateDailyMetric(metric)
        } else {
            // Create new
            let metric = DailyMetric(
                userId: userId,
                date: Date(),
                steps: steps ?? 0,
                waterIntake: water ?? 0,
                calorieEstimate: calories ?? 0,
                sleepQuality: sleep ?? 0
            )
            try db.collection("dailyMetrics").addDocument(from: metric)
        }
    }

    // MARK: - Activities

    func addActivity(_ activity: Activity) async throws {
        try db.collection("activities").addDocument(from: activity)
    }

    func getActivities(for userId: String, limit: Int = 20) async throws -> [Activity] {
        let snapshot = try await db.collection("activities")
            .whereField("userId", isEqualTo: userId)
            .order(by: "date", descending: true)
            .limit(to: limit)
            .getDocuments()

        return snapshot.documents.compactMap { try? $0.data(as: Activity.self) }
    }

    func getActivitiesForDateRange(userId: String, from startDate: Date, to endDate: Date) async throws -> [Activity] {
        let snapshot = try await db.collection("activities")
            .whereField("userId", isEqualTo: userId)
            .whereField("date", isGreaterThanOrEqualTo: startDate)
            .whereField("date", isLessThanOrEqualTo: endDate)
            .order(by: "date", descending: true)
            .getDocuments()

        return snapshot.documents.compactMap { try? $0.data(as: Activity.self) }
    }

    // MARK: - Health Trends

    func getHealthTrends(for userId: String, days: Int = 30) async throws -> [HealthTrend] {
        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()

        let snapshot = try await db.collection("healthTrends")
            .whereField("userId", isEqualTo: userId)
            .whereField("date", isGreaterThanOrEqualTo: startDate)
            .order(by: "date", descending: false)
            .getDocuments()

        return snapshot.documents.compactMap { try? $0.data(as: HealthTrend.self) }
    }

    func addHealthTrend(_ trend: HealthTrend) async throws {
        try db.collection("healthTrends").addDocument(from: trend)
    }

    // MARK: - User

    func updateUser(_ user: User) async throws {
        guard let id = user.id else { return }
        try db.collection("users").document(id).setData(from: user, merge: true)
    }

    func addPointsToUser(userId: String, points: Int) async throws {
        let userRef = db.collection("users").document(userId)
        try await userRef.updateData([
            "points": FieldValue.increment(Int64(points)),
            "updatedAt": FieldValue.serverTimestamp()
        ])

        // Update level if needed
        let document = try await userRef.getDocument()
        if var user = try? document.data(as: User.self) {
            let newLevel = Constants.Level.calculateLevel(from: user.points)
            if newLevel != user.level {
                try await userRef.updateData(["level": newLevel])
            }
        }
    }
}
