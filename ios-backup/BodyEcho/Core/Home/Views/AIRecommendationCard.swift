//
//  AIRecommendationCard.swift
//  BodyEcho
//
//  Created on 2025-11-10
//

import SwiftUI

struct AIRecommendationCard: View {
    let insight: AIInsight

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(iconBackgroundColor.opacity(0.2))
                        .frame(width: 40, height: 40)

                    Image(systemName: insight.type.icon)
                        .foregroundColor(iconColor)
                        .font(.system(size: 18))
                }

                VStack(alignment: .leading, spacing: 8) {
                    // Title
                    Text(insight.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.textPrimary)

                    // Message
                    Text(insight.message)
                        .font(.system(size: 14))
                        .foregroundColor(.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    // Actionable link
                    if let actionable = insight.actionable {
                        Button(action: {
                            // TODO: Navigate to detail
                        }) {
                            Text(actionable)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.buttonPrimary)
                        }
                    }
                }

                Spacer()
            }
        }
        .padding(16)
        .background(backgroundColor)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor, lineWidth: 1)
        )
    }

    private var iconColor: Color {
        switch insight.type {
        case .warning:
            return .alertOrange
        case .suggestion:
            return .primaryTeal
        case .achievement:
            return .avatarPink
        }
    }

    private var iconBackgroundColor: Color {
        iconColor
    }

    private var backgroundColor: Color {
        switch insight.type {
        case .warning:
            return Color.alertOrange.opacity(0.05)
        case .suggestion:
            return Color.primaryTeal.opacity(0.05)
        case .achievement:
            return Color.avatarPink.opacity(0.1)
        }
    }

    private var borderColor: Color {
        switch insight.type {
        case .warning:
            return Color.alertOrange.opacity(0.2)
        case .suggestion:
            return Color.primaryTeal.opacity(0.2)
        case .achievement:
            return Color.avatarPink.opacity(0.3)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        AIRecommendationCard(
            insight: AIInsight(
                type: .warning,
                title: "D Vitamini Eksikliği Riski",
                message: "Son haftalardaki düşük günlük güneş ışığı maruziyeti ve beslenme göre risk tespit edilmiştir. Güneş ışığı alımını artırmayı veya takviye kullanmayı düşünün.",
                actionable: "Bilgi için tıkla"
            )
        )

        AIRecommendationCard(
            insight: AIInsight(
                type: .suggestion,
                title: "Uyku Düzeninizi İyileştirin",
                message: "Son 7 günün uyku verileri, tutarlı bir uyku saatlerini gösteriyor.",
                actionable: "Daha fazla bilgi →"
            )
        )
    }
    .padding()
    .background(Color.backgroundNeutral)
}
