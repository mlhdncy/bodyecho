//
//  Activity.swift
//  BodyEcho
//
//  Created on 2025-11-10
//

import Foundation
import FirebaseFirestore

struct Activity: Codable, Identifiable {
    @DocumentID var id: String?
    let userId: String // Anonymous user ID
    var type: String // walking, running, cycling
    var duration: Int // in minutes
    var distance: Double // in kilometers
    var caloriesBurned: Int
    var date: Date
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case type
        case duration
        case distance
        case caloriesBurned
        case date
        case createdAt
    }

    init(
        id: String? = nil,
        userId: String,
        type: String,
        duration: Int,
        distance: Double,
        caloriesBurned: Int? = nil,
        date: Date = Date(),
        createdAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.type = type
        self.duration = duration
        self.distance = distance
        // Calculate calories if not provided
        if let calories = caloriesBurned {
            self.caloriesBurned = calories
        } else {
            self.caloriesBurned = Activity.calculateCalories(type: type, duration: duration)
        }
        self.date = date
        self.createdAt = createdAt
    }

    var activityType: Constants.ActivityType? {
        Constants.ActivityType(rawValue: type)
    }

    var displayName: String {
        activityType?.displayName ?? type
    }

    var icon: String {
        activityType?.icon ?? "figure.walk"
    }

    static func calculateCalories(type: String, duration: Int) -> Int {
        guard let activityType = Constants.ActivityType(rawValue: type) else {
            return 0
        }
        return Int(activityType.caloriesPerMinute * Double(duration))
    }
}
