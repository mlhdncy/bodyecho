//
//  User.swift
//  BodyEcho
//
//  Created on 2025-11-10
//

import Foundation
import FirebaseFirestore

struct User: Codable, Identifiable {
    @DocumentID var id: String?
    let anonymousId: String // Anonimleştirilmiş user ID
    var fullName: String
    var email: String // Encrypted/anonymized
    var level: Int
    var points: Int
    var avatarType: String
    var createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case anonymousId
        case fullName
        case email
        case level
        case points
        case avatarType
        case createdAt
        case updatedAt
    }

    init(
        id: String? = nil,
        anonymousId: String,
        fullName: String,
        email: String,
        level: Int = 1,
        points: Int = 0,
        avatarType: String = "default",
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.anonymousId = anonymousId
        self.fullName = fullName
        self.email = email
        self.level = level
        self.points = points
        self.avatarType = avatarType
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var currentLevelProgress: Int {
        return points % Constants.Level.pointsPerLevel
    }

    var pointsForNextLevel: Int {
        return Constants.Level.pointsPerLevel - currentLevelProgress
    }
}
