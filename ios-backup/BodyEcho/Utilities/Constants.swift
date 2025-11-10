//
//  Constants.swift
//  BodyEcho
//
//  Created on 2025-11-10
//

import Foundation

enum Constants {
    // MARK: - App Configuration
    enum App {
        static let name = "Body Echo"
        static let bundleIdentifier = "com.bodyecho.app"
    }

    // MARK: - UI Constants
    enum UI {
        static let cornerRadius: CGFloat = 12
        static let buttonHeight: CGFloat = 52
        static let padding: CGFloat = 16
        static let cardPadding: CGFloat = 20
    }

    // MARK: - Daily Goals
    enum Goals {
        static let defaultStepsGoal = 10000
        static let defaultWaterGoal: Double = 2.5 // liters
        static let defaultCalorieGoal = 2500
        static let defaultSleepQualityGoal = 80 // percentage
    }

    // MARK: - Activity Types
    enum ActivityType: String, CaseIterable {
        case walking = "walking"
        case running = "running"
        case cycling = "cycling"

        var displayName: String {
            switch self {
            case .walking: return "Yürüyüş"
            case .running: return "Koşu"
            case .cycling: return "Bisiklet"
            }
        }

        var icon: String {
            switch self {
            case .walking: return "figure.walk"
            case .running: return "figure.run"
            case .cycling: return "bicycle"
            }
        }

        var caloriesPerMinute: Double {
            switch self {
            case .walking: return 4.0
            case .running: return 10.0
            case .cycling: return 8.0
            }
        }
    }

    // MARK: - Level System
    enum Level {
        static let pointsPerLevel = 500

        static func calculateLevel(from points: Int) -> Int {
            return points / pointsPerLevel + 1
        }

        static func pointsForNextLevel(currentPoints: Int) -> Int {
            let currentLevel = calculateLevel(from: currentPoints)
            return (currentLevel * pointsPerLevel) - currentPoints
        }
    }
}
