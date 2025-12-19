import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/daily_metric_model.dart';
import '../models/health_record_model.dart';
import 'ml_service.dart';
import 'health_standards_service.dart';

class Insight {
  final String title;
  final String message;
  final String type; // 'risk', 'warning', 'info', 'success'
  final String category; // 'obesity', 'disease', 'lifestyle'
  final String? source; // 'WHO', 'T.C. Sağlık Bakanlığı', etc.
  final String? referenceUrl; // Kaynak URL

  Insight({
    required this.title,
    required this.message,
    required this.type,
    required this.category,
    this.source,
    this.referenceUrl,
  });
}

class InsightsService {
  final MlService _mlService = MlService();
  final HealthStandardsService _healthStandards = HealthStandardsService();

  // Level 1: Profil Bazlı Analiz (BMI & Obezite) - WHO Standartlarına göre
  Future<List<Insight>> analyzeProfile(UserModel user) async {
    final insights = <Insight>[];

    if (user.height != null && user.weight != null && user.height! > 0) {
      final heightInMeters = user.height! / 100;
      final bmi = user.weight! / (heightInMeters * heightInMeters);

      // Use WHO standards for dynamic BMI assessment
      try {
        final bmiAssessment = await _healthStandards.evaluateBmi(
          bmi,
          user.age ?? 30,
          user.gender ?? 'Male',
        );

        insights.add(Insight(
          title: 'Body Mass Index (BMI)',
          message:
              'Your BMI is: ${bmi.toStringAsFixed(1)} (${bmiAssessment.description}). '
              '${bmiAssessment.recommendation}',
          type: bmiAssessment.insightType,
          category: 'obesity',
          source: bmiAssessment.source,
          referenceUrl: 'https://www.who.int/health-topics/obesity',
        ));
      } catch (e) {
        debugPrint('BMI assessment error: $e');
        // Fallback to basic evaluation
        insights.add(Insight(
          title: 'Body Mass Index (BMI)',
          message:
              'Your BMI is: ${bmi.toStringAsFixed(1)}. Loading standards for detailed assessment.',
          type: 'info',
          category: 'obesity',
        ));
      }
    } else {
      insights.add(Insight(
        title: 'Complete Your Profile',
        message:
            'Please add your height and weight to your profile for more accurate analysis.',
        type: 'info',
        category: 'obesity',
      ));
    }

    return insights;
  }

  // Level 2: İstatistiksel Hastalık Riski (ML Destekli)
  Future<List<Insight>> analyzeDiseaseRisks(
      UserModel user, HealthRecordModel? latestRecord) async {
    final insights = <Insight>[];

    // Yeterli veri yoksa analiz yapma
    if (latestRecord == null || latestRecord.bloodGlucoseLevel == null) {
      return insights;
    }

    // ML Servisine gönderilecek verileri hazırla
    // Eksik veriler için varsayılan değerler veya profil verileri kullanılır
    try {
      final mlResponse = await _mlService.getPredictions(
        age: user.age ?? 30,
        bmi: _calculateBmi(user.height, user.weight),
        bloodGlucoseLevel: latestRecord.bloodGlucoseLevel!,
        active: user.activityLevel == 'High' ? 1 : 0,
        // Diğer parametreler varsayılan veya kayıttan alınabilir
      );

      if (mlResponse.success) {
        final results = mlResponse.results;

        // Diabetes Risk
        if (results['diabetes_risk']?.prediction == 1) {
          insights.add(Insight(
            title: 'Diabetes Risk Warning',
            message:
                'Statistical models predict you may have diabetes risk based on your blood sugar and other data. Please consult a doctor.',
            type: 'risk',
            category: 'disease',
          ));
        }

        // Heart Risk
        if (results['heart_risk']?.prediction == 1) {
          insights.add(Insight(
            title: 'Heart Health Warning',
            message:
                'Your data may contain risk factors for heart health.',
            type: 'risk',
            category: 'disease',
          ));
        }

        // Other ML results can be added here
      }
    } catch (e) {
      debugPrint('ML Analysis Error: $e');
    }

    return insights;
  }

  double _calculateBmi(double? height, double? weight) {
    if (height == null || weight == null || height == 0)
      return 25.0; // Varsayılan
    return weight / ((height / 100) * (height / 100));
  }

  // Level 3: Günlük Yaşam Tarzı (Daily Metrics) - WHO ve T.C. Sağlık Bakanlığı standartlarına göre
  Future<List<Insight>> analyzeLifestyle(
      DailyMetricModel? todayMetric, UserModel user) async {
    final insights = <Insight>[];

    if (todayMetric == null) return insights;

    // Water Intake - Dynamic standards (age, gender, pregnancy status)
    try {
      final waterRecommendation =
          await _healthStandards.getWaterIntakeRecommendation(
        user.gender ?? 'Male',
        user.age ?? 30,
        isPregnant: false,
        isBreastfeeding: false,
      );

      final currentWater = todayMetric.waterIntake;
      final recommendedWater = waterRecommendation.recommendedLiters;

      if (currentWater < recommendedWater * 0.5) {
        insights.add(Insight(
          title: 'Water Intake Very Low',
          message: waterRecommendation.getRecommendationText(currentWater),
          type: 'warning',
          category: 'lifestyle',
          source: waterRecommendation.source,
          referenceUrl: 'https://www.who.int/water_sanitation_health/dwq',
        ));
      } else if (currentWater >= recommendedWater) {
        insights.add(Insight(
          title: 'Great Hydration',
          message: waterRecommendation.getRecommendationText(currentWater),
          type: 'success',
          category: 'lifestyle',
          source: waterRecommendation.source,
        ));
      } else if (currentWater < recommendedWater * 0.8) {
        insights.add(Insight(
          title: 'Water Intake Low',
          message: waterRecommendation.getRecommendationText(currentWater),
          type: 'info',
          category: 'lifestyle',
          source: waterRecommendation.source,
        ));
      }
    } catch (e) {
      debugPrint('Water intake assessment error: $e');
    }

    // Steps - Dynamic standards (by age)
    try {
      final activityRecommendation =
          await _healthStandards.getPhysicalActivityRecommendation(
        user.age ?? 30,
      );

      final currentSteps = todayMetric.steps;
      final recommendedSteps = activityRecommendation.stepsPerDay;

      if (currentSteps < recommendedSteps * 0.3) {
        insights.add(Insight(
          title: 'Get Moving',
          message: activityRecommendation.getStepsRecommendation(currentSteps),
          type: 'warning',
          category: 'lifestyle',
          source: activityRecommendation.source,
          referenceUrl:
              'https://www.who.int/news-room/fact-sheets/detail/physical-activity',
        ));
      } else if (currentSteps >= recommendedSteps) {
        insights.add(Insight(
          title: 'Excellent Activity',
          message: activityRecommendation.getStepsRecommendation(currentSteps),
          type: 'success',
          category: 'lifestyle',
          source: activityRecommendation.source,
        ));
      } else if (currentSteps < recommendedSteps * 0.8) {
        insights.add(Insight(
          title: 'Move More',
          message: activityRecommendation.getStepsRecommendation(currentSteps),
          type: 'info',
          category: 'lifestyle',
          source: activityRecommendation.source,
        ));
      }
    } catch (e) {
      debugPrint('Activity assessment error: $e');
    }

    // Sleep - Dynamic standards (by age)
    if (todayMetric.sleepQuality > 0) {
      try {
        final sleepRecommendation =
            await _healthStandards.getSleepRecommendation(
          user.age ?? 30,
        );

        if (todayMetric.sleepQuality < 6) {
          insights.add(Insight(
            title: 'Low Sleep Quality',
            message: 'Your sleep quality appears to be low recently. '
                '${sleepRecommendation.getRecommendationText(null)} '
                'Try staying away from screens before bed.',
            type: 'warning',
            category: 'lifestyle',
            source: sleepRecommendation.source,
          ));
        } else if (todayMetric.sleepQuality >= 8) {
          insights.add(Insight(
            title: 'Excellent Sleep',
            message:
                'Your sleep quality is great! Keep it up. You are resting according to ${sleepRecommendation.source} standards.',
            type: 'success',
            category: 'lifestyle',
            source: sleepRecommendation.source,
          ));
        }
      } catch (e) {
        debugPrint('Sleep assessment error: $e');
      }
    }

    return insights;
  }
}
