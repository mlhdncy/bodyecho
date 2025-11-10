//
//  ProgressBarView.swift
//  BodyEcho
//
//  Created on 2025-11-10
//

import SwiftUI

struct ProgressBarView: View {
    let progress: Double // 0.0 to 1.0
    let height: CGFloat
    let color: Color
    let backgroundColor: Color

    init(
        progress: Double,
        height: CGFloat = 10,
        color: Color = .primaryTeal,
        backgroundColor: Color = Color.gray.opacity(0.2)
    ) {
        self.progress = min(max(progress, 0), 1) // Clamp between 0 and 1
        self.height = height
        self.color = color
        self.backgroundColor = backgroundColor
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(backgroundColor)
                    .frame(width: geometry.size.width, height: height)

                // Progress
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(color)
                    .frame(width: geometry.size.width * progress, height: height)
                    .animation(.easeInOut(duration: 0.6), value: progress)
            }
        }
        .frame(height: height)
    }
}

struct ProgressBarWithLabel: View {
    let icon: String
    let title: String
    let currentValue: Int
    let maxValue: Int
    let color: Color
    let unit: String?

    var progress: Double {
        Double(currentValue) / Double(maxValue)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 16))

                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.textSecondary)

                Spacer()

                HStack(spacing: 4) {
                    Text("\(currentValue)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.textPrimary)

                    Text("/ \(maxValue)")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.textSecondary)

                    if let unit = unit {
                        Text(unit)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.textSecondary)
                    }
                }
            }

            ProgressBarView(
                progress: progress,
                height: 8,
                color: color
            )
        }
    }
}

struct ProgressBarWithPercentage: View {
    let icon: String
    let title: String
    let percentage: Int // 0-100
    let color: Color

    var progress: Double {
        Double(percentage) / 100.0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 16))

                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.textSecondary)

                Spacer()

                Text("\(percentage)%")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.textPrimary)
            }

            ProgressBarView(
                progress: progress,
                height: 8,
                color: color
            )
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        ProgressBarWithLabel(
            icon: "flame.fill",
            title: "Kalori (Tahmin)",
            currentValue: 1625,
            maxValue: 2500,
            color: .alertOrange,
            unit: nil
        )

        ProgressBarWithPercentage(
            icon: "moon.zzz.fill",
            title: "Uyku Kalitesi",
            percentage: 88,
            color: .buttonPrimary
        )

        // Simple progress bar
        VStack(alignment: .leading, spacing: 8) {
            Text("Simple Progress")
                .font(.caption)
            ProgressBarView(
                progress: 0.65,
                height: 12,
                color: .primaryTeal
            )
        }
    }
    .padding()
    .background(Color.backgroundNeutral)
}
