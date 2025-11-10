//
//  Color+Theme.swift
//  BodyEcho
//
//  Created on 2025-11-10
//

import SwiftUI

extension Color {
    // MARK: - Primary Colors (Teal/Turkuaz/Soft Green)
    static let primaryTeal = Color(hex: "4CC9B0")
    static let primaryTealLight = Color(hex: "6ED1C8")

    // MARK: - Secondary Colors
    static let secondaryTeal = Color(hex: "A7D7C5")
    static let secondaryTealLight = Color(hex: "B8E1DD")

    // MARK: - Background Colors
    static let backgroundNeutral = Color(hex: "F5F7FA")
    static let backgroundWhite = Color.white

    // MARK: - Avatar/Positive Message Colors (Pink)
    static let avatarPink = Color(hex: "FADADD")
    static let accentPink = Color(hex: "F6C6C6")

    // MARK: - Alert/Warning Colors
    static let alertOrange = Color(hex: "F66A4B")
    static let alertOrangeLight = Color(hex: "FF9F68")

    // MARK: - Button Colors
    static let buttonPrimary = Color(hex: "2E9E9A")
    static let buttonPrimaryDark = Color(hex: "247A76")

    // MARK: - Text Colors
    static let textPrimary = Color(hex: "2D3142")
    static let textSecondary = Color(hex: "6B7280")
    static let textTertiary = Color(hex: "9CA3AF")

    // MARK: - Helper Initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
