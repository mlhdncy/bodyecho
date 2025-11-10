//
//  AuthService.swift
//  BodyEcho
//
//  Created on 2025-11-10
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthService {
    static let shared = AuthService()
    private let db = Firestore.firestore()
    private let anonymizer = AnonymizationService.shared

    private init() {}

    /// Sign up with email and password
    func signUp(fullName: String, email: String, password: String) async throws -> User {
        // Create Firebase Auth user
        let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
        let firebaseUid = authResult.user.uid

        // Generate anonymous ID
        let anonymousId = anonymizer.generateAnonymousId(from: firebaseUid)

        // Create user document
        let user = User(
            id: firebaseUid,
            anonymousId: anonymousId,
            fullName: fullName,
            email: anonymizer.anonymizeEmail(email),
            level: 1,
            points: 0,
            avatarType: "bunny_pink",
            createdAt: Date(),
            updatedAt: Date()
        )

        // Save to Firestore
        try db.collection("users").document(firebaseUid).setData(from: user)

        // Create initial daily metric
        let dailyMetric = DailyMetric(
            userId: anonymousId,
            date: Date()
        )
        try db.collection("dailyMetrics").addDocument(from: dailyMetric)

        return user
    }

    /// Sign in with email and password
    func signIn(email: String, password: String) async throws -> User {
        let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
        let firebaseUid = authResult.user.uid

        // Fetch user from Firestore
        let document = try await db.collection("users").document(firebaseUid).getDocument()
        guard let user = try? document.data(as: User.self) else {
            throw NSError(domain: "AuthService", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }

        return user
    }

    /// Sign out
    func signOut() throws {
        try Auth.auth().signOut()
    }

    /// Get current user
    func getCurrentUser() async throws -> User? {
        guard let firebaseUid = Auth.auth().currentUser?.uid else {
            return nil
        }

        let document = try await db.collection("users").document(firebaseUid).getDocument()
        return try? document.data(as: User.self)
    }

    /// Check if user is authenticated
    var isAuthenticated: Bool {
        Auth.auth().currentUser != nil
    }

    /// Get current Firebase UID
    var currentUserUid: String? {
        Auth.auth().currentUser?.uid
    }
}
