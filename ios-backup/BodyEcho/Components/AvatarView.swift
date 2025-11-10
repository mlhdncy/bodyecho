//
//  AvatarView.swift
//  BodyEcho
//
//  Created on 2025-11-10
//

import SwiftUI

struct AvatarView: View {
    let size: CGFloat
    let avatarType: String

    init(size: CGFloat = 60, avatarType: String = "bunny_pink") {
        self.size = size
        self.avatarType = avatarType
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.avatarPink.opacity(0.3))
                .frame(width: size, height: size)

            // Bunny emoji as placeholder
            Text("🐰")
                .font(.system(size: size * 0.6))
        }
    }
}

struct AvatarWithLevel: View {
    let size: CGFloat
    let avatarType: String
    let level: Int
    let points: Int

    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .topTrailing) {
                AvatarView(size: size, avatarType: avatarType)

                // Level badge
                ZStack {
                    Circle()
                        .fill(Color.primaryTeal)
                        .frame(width: size * 0.35, height: size * 0.35)

                    Text("Seviye \(level)")
                        .font(.system(size: size * 0.14, weight: .bold))
                        .foregroundColor(.white)
                }
                .offset(x: size * 0.1, y: -size * 0.05)
            }

            // Points badge
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.white)

                Text("\(points) Puan")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.primaryTeal)
            .cornerRadius(12)
        }
    }
}

#Preview {
    VStack(spacing: 32) {
        AvatarView(size: 80)

        AvatarWithLevel(size: 80, avatarType: "bunny_pink", level: 12, points: 450)
    }
    .padding()
    .background(Color.backgroundNeutral)
}
