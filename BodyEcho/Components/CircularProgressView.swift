//
//  CircularProgressView.swift
//  BodyEcho
//
//  Created on 2025-11-10
//

import SwiftUI

struct CircularProgressView: View {
    let progress: Double // 0.0 to 1.0
    let lineWidth: CGFloat
    let color: Color
    let backgroundColor: Color
    let size: CGFloat

    init(
        progress: Double,
        lineWidth: CGFloat = 8,
        color: Color = .primaryTeal,
        backgroundColor: Color = Color.gray.opacity(0.2),
        size: CGFloat = 100
    ) {
        self.progress = min(max(progress, 0), 1) // Clamp between 0 and 1
        self.lineWidth = lineWidth
        self.color = color
        self.backgroundColor = backgroundColor
        self.size = size
    }

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(backgroundColor, lineWidth: lineWidth)

            // Progress circle
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.8), value: progress)
        }
        .frame(width: size, height: size)
    }
}

struct CircularProgressWithText: View {
    let currentValue: Int
    let maxValue: Int
    let unit: String
    let color: Color
    let title: String

    var progress: Double {
        Double(currentValue) / Double(maxValue)
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                CircularProgressView(
                    progress: progress,
                    lineWidth: 8,
                    color: color,
                    size: 90
                )

                VStack(spacing: 2) {
                    Text("\(currentValue)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.textPrimary)

                    Text("/ \(maxValue)")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.textSecondary)
                }
            }

            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.textSecondary)
        }
    }
}

struct CircularProgressWithDecimal: View {
    let currentValue: Double
    let maxValue: Double
    let unit: String
    let color: Color
    let title: String
    let decimalPlaces: Int

    var progress: Double {
        currentValue / maxValue
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                CircularProgressView(
                    progress: progress,
                    lineWidth: 8,
                    color: color,
                    size: 90
                )

                VStack(spacing: 2) {
                    Text(String(format: "%.\(decimalPlaces)f", currentValue))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.textPrimary)

                    Text("/ \(String(format: "%.1f", maxValue)) \(unit)")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.textSecondary)
                }
            }

            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.textSecondary)
        }
    }
}

#Preview {
    HStack(spacing: 32) {
        CircularProgressWithText(
            currentValue: 8500,
            maxValue: 10000,
            unit: "",
            color: .primaryTeal,
            title: "Adım Sayısı"
        )

        CircularProgressWithDecimal(
            currentValue: 2.0,
            maxValue: 2.5,
            unit: "Litre",
            color: .primaryTealLight,
            title: "Su Tüketimi",
            decimalPlaces: 1
        )
    }
    .padding()
    .background(Color.backgroundNeutral)
}
