//
//  DailyGoalsWidget.swift
//  BodyEcho
//
//  Created on 2025-11-10
//

import SwiftUI

struct DailyGoalsWidget: View {
    let metric: DailyMetric

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Günlük Hedefler & İlerleme")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.textPrimary)

            // Circular progress indicators
            HStack(spacing: 24) {
                CircularProgressWithText(
                    currentValue: metric.steps,
                    maxValue: Constants.Goals.defaultStepsGoal,
                    unit: "",
                    color: .primaryTeal,
                    title: "Adım Sayısı"
                )

                CircularProgressWithDecimal(
                    currentValue: metric.waterIntake,
                    maxValue: Constants.Goals.defaultWaterGoal,
                    unit: "Litre",
                    color: .primaryTealLight,
                    title: "Su Tüketimi",
                    decimalPlaces: 1
                )
            }
            .frame(maxWidth: .infinity, alignment: .center)

            // Linear progress bars
            VStack(spacing: 16) {
                ProgressBarWithLabel(
                    icon: "flame.fill",
                    title: "Kalori (Tahmin)",
                    currentValue: metric.calorieEstimate,
                    maxValue: Constants.Goals.defaultCalorieGoal,
                    color: .alertOrange,
                    unit: nil
                )

                ProgressBarWithPercentage(
                    icon: "moon.zzz.fill",
                    title: "Uyku Kalitesi",
                    percentage: metric.sleepQuality,
                    color: .buttonPrimary
                )
            }
        }
        .padding(Constants.UI.cardPadding)
        .background(Color.white)
        .cornerRadius(16)
        .cardShadow()
    }
}

#Preview {
    DailyGoalsWidget(
        metric: DailyMetric(
            userId: "test",
            steps: 8500,
            waterIntake: 2.0,
            calorieEstimate: 1625,
            sleepQuality: 88
        )
    )
    .padding()
    .background(Color.backgroundNeutral)
}
