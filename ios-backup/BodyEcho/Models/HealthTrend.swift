//
//  HealthTrend.swift
//  BodyEcho
//
//  Created on 2025-11-10
//

import Foundation
import FirebaseFirestore

struct HealthTrend: Codable, Identifiable {
    @DocumentID var id: String?
    let userId: String // Anonymous user ID
    let date: Date
    var physicalActivity: Double // 0-100 score
    var sleepDuration: Double // in hours
    var nutritionQuality: Double // 0-100 score
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case date
        case physicalActivity
        case sleepDuration
        case nutritionQuality
        case createdAt
    }

    init(
        id: String? = nil,
        userId: String,
        date: Date,
        physicalActivity: Double = 0.0,
        sleepDuration: Double = 0.0,
        nutritionQuality: Double = 0.0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.date = date
        self.physicalActivity = physicalActivity
        self.sleepDuration = sleepDuration
        self.nutritionQuality = nutritionQuality
        self.createdAt = createdAt
    }
}

// MARK: - AI Insight Model
struct AIInsight: Identifiable {
    let id: String
    let type: InsightType
    let title: String
    let message: String
    let actionable: String?
    let createdAt: Date

    enum InsightType: String {
        case warning
        case suggestion
        case achievement

        var icon: String {
            switch self {
            case .warning: return "exclamationmark.triangle.fill"
            case .suggestion: return "lightbulb.fill"
            case .achievement: return "star.fill"
            }
        }

        var color: String {
            switch self {
            case .warning: return "alertOrange"
            case .suggestion: return "primaryTeal"
            case .achievement: return "avatarPink"
            }
        }
    }

    init(
        id: String = UUID().uuidString,
        type: InsightType,
        title: String,
        message: String,
        actionable: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.message = message
        self.actionable = actionable
        self.createdAt = createdAt
    }
}
