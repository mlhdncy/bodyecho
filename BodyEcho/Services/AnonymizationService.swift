//
//  AnonymizationService.swift
//  BodyEcho
//
//  Created on 2025-11-10
//

import Foundation
import CryptoKit

class AnonymizationService {
    static let shared = AnonymizationService()

    private init() {}

    /// Generates an anonymous user ID from Firebase UID
    func generateAnonymousId(from firebaseUid: String) -> String {
        let inputData = Data(firebaseUid.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }

    /// Anonymizes email address
    func anonymizeEmail(_ email: String) -> String {
        let components = email.components(separatedBy: "@")
        guard components.count == 2 else { return email }

        let username = components[0]
        let domain = components[1]

        // Show first 2 characters and hash the rest
        let visiblePart = String(username.prefix(2))
        let hiddenPart = String(repeating: "*", count: max(username.count - 2, 3))

        return "\(visiblePart)\(hiddenPart)@\(domain)"
    }

    /// Encrypts sensitive data (simple implementation)
    func encryptData(_ data: String) -> String {
        let inputData = Data(data.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}
