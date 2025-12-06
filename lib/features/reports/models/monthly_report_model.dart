import 'package:cloud_firestore/cloud_firestore.dart';

class MonthlyReportModel {
  final String userId;
  final DateTime monthStartDate;
  final DateTime monthEndDate;
  final DateTime lastUpdated;

  // 30 günlük ortalamalar
  final double avgSteps;
  final double avgWaterIntake;
  final double avgCalories;
  final double avgSleepQuality;

  // Toplam metrikler
  final int totalSteps;
  final double totalWaterIntake;
  final int totalCalories;

  // Sağlık kayıtları ortalamaları
  final double? avgBloodGlucose;
  final double? avgSystolicBP;
  final double? avgDiastolicBP;
  final double? avgHeartRate;
  final double? avgTemperature;

  // ML risk skorları (aylık ortalama veri ile)
  final double? diabetesRisk;
  final double? heartDiseaseRisk;
  final double? obesityRisk;
  final double? cancerRisk;
  final double? highCholesterolRisk;
  final double? lowActivityRisk;

  // Önceki ayla karşılaştırma
  final double? stepsChangeVsPreviousMonth;
  final double? waterChangeVsPreviousMonth;
  final double? caloriesChangeVsPreviousMonth;
  final double? sleepChangeVsPreviousMonth;

  // Risk skoru değişimleri (uzun vadeli)
  final double? diabetesRiskChange;
  final double? heartDiseaseRiskChange;
  final double? obesityRiskChange;
  final double? cancerRiskChange;
  final double? cholesterolRiskChange;

  // Aylık başarı metrikleri
  final int totalDays; // 30
  final int daysGoalAchieved; // Kaç gün hedefe ulaşıldı
  final double monthlyGoalAchievement; // %
  final DateTime? bestDay; // En iyi gün
  final int? bestDaySteps;
  final DateTime? worstDay; // En kötü gün
  final int? worstDaySteps;

  // Uzun vadeli trend analizi
  final String stepsTrend; // 'improving', 'declining', 'stable'
  final String waterTrend;
  final String sleepTrend;
  final String overallHealthTrend;
  final String riskTrend; // Genel risk durumu

  // BMI değişimi (eğer varsa)
  final double? startBMI;
  final double? endBMI;
  final double? bmiChange;

  // Başarı rozetleri
  final List<Achievement> achievements;

  // Aylık öneriler ve hedefler
  final List<String> recommendations;
  final List<String> nextMonthGoals;

  // Haftalık breakdown (4 hafta)
  final List<WeeklyData> weeklyData;

  MonthlyReportModel({
    required this.userId,
    required this.monthStartDate,
    required this.monthEndDate,
    required this.lastUpdated,
    this.avgSteps = 0.0,
    this.avgWaterIntake = 0.0,
    this.avgCalories = 0.0,
    this.avgSleepQuality = 0.0,
    this.totalSteps = 0,
    this.totalWaterIntake = 0.0,
    this.totalCalories = 0,
    this.avgBloodGlucose,
    this.avgSystolicBP,
    this.avgDiastolicBP,
    this.avgHeartRate,
    this.avgTemperature,
    this.diabetesRisk,
    this.heartDiseaseRisk,
    this.obesityRisk,
    this.cancerRisk,
    this.highCholesterolRisk,
    this.lowActivityRisk,
    this.stepsChangeVsPreviousMonth,
    this.waterChangeVsPreviousMonth,
    this.caloriesChangeVsPreviousMonth,
    this.sleepChangeVsPreviousMonth,
    this.diabetesRiskChange,
    this.heartDiseaseRiskChange,
    this.obesityRiskChange,
    this.cancerRiskChange,
    this.cholesterolRiskChange,
    this.totalDays = 30,
    this.daysGoalAchieved = 0,
    this.monthlyGoalAchievement = 0.0,
    this.bestDay,
    this.bestDaySteps,
    this.worstDay,
    this.worstDaySteps,
    this.stepsTrend = 'stable',
    this.waterTrend = 'stable',
    this.sleepTrend = 'stable',
    this.overallHealthTrend = 'stable',
    this.riskTrend = 'stable',
    this.startBMI,
    this.endBMI,
    this.bmiChange,
    this.achievements = const [],
    this.recommendations = const [],
    this.nextMonthGoals = const [],
    this.weeklyData = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'monthStartDate': Timestamp.fromDate(monthStartDate),
      'monthEndDate': Timestamp.fromDate(monthEndDate),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'avgSteps': avgSteps,
      'avgWaterIntake': avgWaterIntake,
      'avgCalories': avgCalories,
      'avgSleepQuality': avgSleepQuality,
      'totalSteps': totalSteps,
      'totalWaterIntake': totalWaterIntake,
      'totalCalories': totalCalories,
      'avgBloodGlucose': avgBloodGlucose,
      'avgSystolicBP': avgSystolicBP,
      'avgDiastolicBP': avgDiastolicBP,
      'avgHeartRate': avgHeartRate,
      'avgTemperature': avgTemperature,
      'diabetesRisk': diabetesRisk,
      'heartDiseaseRisk': heartDiseaseRisk,
      'obesityRisk': obesityRisk,
      'cancerRisk': cancerRisk,
      'highCholesterolRisk': highCholesterolRisk,
      'lowActivityRisk': lowActivityRisk,
      'stepsChangeVsPreviousMonth': stepsChangeVsPreviousMonth,
      'waterChangeVsPreviousMonth': waterChangeVsPreviousMonth,
      'caloriesChangeVsPreviousMonth': caloriesChangeVsPreviousMonth,
      'sleepChangeVsPreviousMonth': sleepChangeVsPreviousMonth,
      'diabetesRiskChange': diabetesRiskChange,
      'heartDiseaseRiskChange': heartDiseaseRiskChange,
      'obesityRiskChange': obesityRiskChange,
      'cancerRiskChange': cancerRiskChange,
      'cholesterolRiskChange': cholesterolRiskChange,
      'totalDays': totalDays,
      'daysGoalAchieved': daysGoalAchieved,
      'monthlyGoalAchievement': monthlyGoalAchievement,
      'bestDay': bestDay != null ? Timestamp.fromDate(bestDay!) : null,
      'bestDaySteps': bestDaySteps,
      'worstDay': worstDay != null ? Timestamp.fromDate(worstDay!) : null,
      'worstDaySteps': worstDaySteps,
      'stepsTrend': stepsTrend,
      'waterTrend': waterTrend,
      'sleepTrend': sleepTrend,
      'overallHealthTrend': overallHealthTrend,
      'riskTrend': riskTrend,
      'startBMI': startBMI,
      'endBMI': endBMI,
      'bmiChange': bmiChange,
      'achievements': achievements.map((a) => a.toMap()).toList(),
      'recommendations': recommendations,
      'nextMonthGoals': nextMonthGoals,
      'weeklyData': weeklyData.map((w) => w.toMap()).toList(),
    };
  }

  factory MonthlyReportModel.fromMap(Map<String, dynamic> map) {
    return MonthlyReportModel(
      userId: map['userId'] ?? '',
      monthStartDate: (map['monthStartDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      monthEndDate: (map['monthEndDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastUpdated: (map['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      avgSteps: (map['avgSteps'] ?? 0).toDouble(),
      avgWaterIntake: (map['avgWaterIntake'] ?? 0).toDouble(),
      avgCalories: (map['avgCalories'] ?? 0).toDouble(),
      avgSleepQuality: (map['avgSleepQuality'] ?? 0).toDouble(),
      totalSteps: map['totalSteps'] ?? 0,
      totalWaterIntake: (map['totalWaterIntake'] ?? 0).toDouble(),
      totalCalories: map['totalCalories'] ?? 0,
      avgBloodGlucose: (map['avgBloodGlucose'] as num?)?.toDouble(),
      avgSystolicBP: (map['avgSystolicBP'] as num?)?.toDouble(),
      avgDiastolicBP: (map['avgDiastolicBP'] as num?)?.toDouble(),
      avgHeartRate: (map['avgHeartRate'] as num?)?.toDouble(),
      avgTemperature: (map['avgTemperature'] as num?)?.toDouble(),
      diabetesRisk: (map['diabetesRisk'] as num?)?.toDouble(),
      heartDiseaseRisk: (map['heartDiseaseRisk'] as num?)?.toDouble(),
      obesityRisk: (map['obesityRisk'] as num?)?.toDouble(),
      cancerRisk: (map['cancerRisk'] as num?)?.toDouble(),
      highCholesterolRisk: (map['highCholesterolRisk'] as num?)?.toDouble(),
      lowActivityRisk: (map['lowActivityRisk'] as num?)?.toDouble(),
      stepsChangeVsPreviousMonth: (map['stepsChangeVsPreviousMonth'] as num?)?.toDouble(),
      waterChangeVsPreviousMonth: (map['waterChangeVsPreviousMonth'] as num?)?.toDouble(),
      caloriesChangeVsPreviousMonth: (map['caloriesChangeVsPreviousMonth'] as num?)?.toDouble(),
      sleepChangeVsPreviousMonth: (map['sleepChangeVsPreviousMonth'] as num?)?.toDouble(),
      diabetesRiskChange: (map['diabetesRiskChange'] as num?)?.toDouble(),
      heartDiseaseRiskChange: (map['heartDiseaseRiskChange'] as num?)?.toDouble(),
      obesityRiskChange: (map['obesityRiskChange'] as num?)?.toDouble(),
      cancerRiskChange: (map['cancerRiskChange'] as num?)?.toDouble(),
      cholesterolRiskChange: (map['cholesterolRiskChange'] as num?)?.toDouble(),
      totalDays: map['totalDays'] ?? 30,
      daysGoalAchieved: map['daysGoalAchieved'] ?? 0,
      monthlyGoalAchievement: (map['monthlyGoalAchievement'] ?? 0).toDouble(),
      bestDay: (map['bestDay'] as Timestamp?)?.toDate(),
      bestDaySteps: map['bestDaySteps'] as int?,
      worstDay: (map['worstDay'] as Timestamp?)?.toDate(),
      worstDaySteps: map['worstDaySteps'] as int?,
      stepsTrend: map['stepsTrend'] ?? 'stable',
      waterTrend: map['waterTrend'] ?? 'stable',
      sleepTrend: map['sleepTrend'] ?? 'stable',
      overallHealthTrend: map['overallHealthTrend'] ?? 'stable',
      riskTrend: map['riskTrend'] ?? 'stable',
      startBMI: (map['startBMI'] as num?)?.toDouble(),
      endBMI: (map['endBMI'] as num?)?.toDouble(),
      bmiChange: (map['bmiChange'] as num?)?.toDouble(),
      achievements: (map['achievements'] as List<dynamic>?)
              ?.map((a) => Achievement.fromMap(a as Map<String, dynamic>))
              .toList() ??
          [],
      recommendations: List<String>.from(map['recommendations'] ?? []),
      nextMonthGoals: List<String>.from(map['nextMonthGoals'] ?? []),
      weeklyData: (map['weeklyData'] as List<dynamic>?)
              ?.map((w) => WeeklyData.fromMap(w as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

// Haftalık veri özeti (aylık rapor için)
class WeeklyData {
  final int weekNumber; // 1-4
  final double avgSteps;
  final double avgWater;
  final double avgCalories;

  WeeklyData({
    required this.weekNumber,
    required this.avgSteps,
    required this.avgWater,
    required this.avgCalories,
  });

  Map<String, dynamic> toMap() {
    return {
      'weekNumber': weekNumber,
      'avgSteps': avgSteps,
      'avgWater': avgWater,
      'avgCalories': avgCalories,
    };
  }

  factory WeeklyData.fromMap(Map<String, dynamic> map) {
    return WeeklyData(
      weekNumber: map['weekNumber'] ?? 1,
      avgSteps: (map['avgSteps'] ?? 0).toDouble(),
      avgWater: (map['avgWater'] ?? 0).toDouble(),
      avgCalories: (map['avgCalories'] ?? 0).toDouble(),
    );
  }
}

// Başarı rozeti
class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon; // emoji veya icon adı
  final DateTime earnedDate;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.earnedDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'earnedDate': Timestamp.fromDate(earnedDate),
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      icon: map['icon'] ?? '🏆',
      earnedDate: (map['earnedDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
