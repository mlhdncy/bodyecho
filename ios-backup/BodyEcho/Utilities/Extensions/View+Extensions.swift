//
//  View+Extensions.swift
//  BodyEcho
//
//  Created on 2025-11-10
//

import SwiftUI

extension View {
    /// Adds rounded corners with specific corners
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }

    /// Adds a card-like shadow
    func cardShadow(radius: CGFloat = 8, y: CGFloat = 4) -> some View {
        self.shadow(color: Color.black.opacity(0.08), radius: radius, x: 0, y: y)
    }
}

// MARK: - Custom Shape for Specific Corner Radius
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
