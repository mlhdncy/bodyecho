//
//  DailyMetric.swift
//  BodyEcho
//
//  Created on 2025-11-10
//

import Foundation
import FirebaseFirestore

struct DailyMetric: Codable, Identifiable {
    @DocumentID var id: String?
    let userId: String // Anonymous user ID
    let date: Date
    var steps: Int
    var waterIntake: Double // in liters
    var calorieEstimate: Int
    var sleepQuality: Int // percentage 0-100
    var createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case date
        case steps
        case waterIntake
        case calorieEstimate
        case sleepQuality
        case createdAt
        case updatedAt
    }

    init(
        id: String? = nil,
        userId: String,
        date: Date = Date(),
        steps: Int = 0,
        waterIntake: Double = 0.0,
        calorieEstimate: Int = 0,
        sleepQuality: Int = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.date = date
        self.steps = steps
        self.waterIntake = waterIntake
        self.calorieEstimate = calorieEstimate
        self.sleepQuality = sleepQuality
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // Helper computed properties
    var stepsProgress: Double {
        Double(steps) / Double(Constants.Goals.defaultStepsGoal)
    }

    var waterProgress: Double {
        waterIntake / Constants.Goals.defaultWaterGoal
    }

    var calorieProgress: Double {
        Double(calorieEstimate) / Double(Constants.Goals.defaultCalorieGoal)
    }

    var sleepQualityProgress: Double {
        Double(sleepQuality) / Double(Constants.Goals.defaultSleepQualityGoal)
    }
}
