import 'package:cloud_firestore/cloud_firestore.dart';

class WeeklyReportModel {
  final String userId;
  final DateTime weekStartDate;
  final DateTime weekEndDate;
  final DateTime lastUpdated;

  // 7 günlük ortalamalar
  final double avgSteps;
  final double avgWaterIntake;
  final double avgCalories;
  final double avgSleepQuality;

  // Sağlık kayıtları ortalamaları
  final double? avgBloodGlucose;
  final double? avgSystolicBP;
  final double? avgDiastolicBP;
  final double? avgHeartRate;
  final double? avgTemperature;

  // ML risk skorları (haftalık ortalama veri ile)
  final double? diabetesRisk;
  final double? heartDiseaseRisk;
  final double? obesityRisk;
  final double? cancerRisk;
  final double? highCholesterolRisk;
  final double? lowActivityRisk;

  // Önceki haftayla karşılaştırma
  final double? stepsChangeVsPreviousWeek;
  final double? waterChangeVsPreviousWeek;
  final double? caloriesChangeVsPreviousWeek;
  final double? sleepChangeVsPreviousWeek;

  // Risk skoru değişimleri
  final double? diabetesRiskChange;
  final double? heartDiseaseRiskChange;
  final double? obesityRiskChange;

  // Haftalık başarı metrikleri
  final int totalDays; // 7
  final int daysGoalAchieved; // Kaç gün hedefe ulaşıldı
  final double weeklyGoalAchievement; // %
  final DateTime? bestDay; // En iyi gün
  final int? bestDaySteps;

  // Trend analizi
  final String stepsTrend; // 'improving', 'declining', 'stable'
  final String waterTrend;
  final String sleepTrend;
  final String overallHealthTrend;

  // Haftalık öneriler
  final List<String> recommendations;

  // Günlük veriler (grafik için)
  final List<DailyData> dailyData;

  WeeklyReportModel({
    required this.userId,
    required this.weekStartDate,
    required this.weekEndDate,
    required this.lastUpdated,
    this.avgSteps = 0.0,
    this.avgWaterIntake = 0.0,
    this.avgCalories = 0.0,
    this.avgSleepQuality = 0.0,
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
    this.stepsChangeVsPreviousWeek,
    this.waterChangeVsPreviousWeek,
    this.caloriesChangeVsPreviousWeek,
    this.sleepChangeVsPreviousWeek,
    this.diabetesRiskChange,
    this.heartDiseaseRiskChange,
    this.obesityRiskChange,
    this.totalDays = 7,
    this.daysGoalAchieved = 0,
    this.weeklyGoalAchievement = 0.0,
    this.bestDay,
    this.bestDaySteps,
    this.stepsTrend = 'stable',
    this.waterTrend = 'stable',
    this.sleepTrend = 'stable',
    this.overallHealthTrend = 'stable',
    this.recommendations = const [],
    this.dailyData = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'weekStartDate': Timestamp.fromDate(weekStartDate),
      'weekEndDate': Timestamp.fromDate(weekEndDate),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'avgSteps': avgSteps,
      'avgWaterIntake': avgWaterIntake,
      'avgCalories': avgCalories,
      'avgSleepQuality': avgSleepQuality,
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
      'stepsChangeVsPreviousWeek': stepsChangeVsPreviousWeek,
      'waterChangeVsPreviousWeek': waterChangeVsPreviousWeek,
      'caloriesChangeVsPreviousWeek': caloriesChangeVsPreviousWeek,
      'sleepChangeVsPreviousWeek': sleepChangeVsPreviousWeek,
      'diabetesRiskChange': diabetesRiskChange,
      'heartDiseaseRiskChange': heartDiseaseRiskChange,
      'obesityRiskChange': obesityRiskChange,
      'totalDays': totalDays,
      'daysGoalAchieved': daysGoalAchieved,
      'weeklyGoalAchievement': weeklyGoalAchievement,
      'bestDay': bestDay != null ? Timestamp.fromDate(bestDay!) : null,
      'bestDaySteps': bestDaySteps,
      'stepsTrend': stepsTrend,
      'waterTrend': waterTrend,
      'sleepTrend': sleepTrend,
      'overallHealthTrend': overallHealthTrend,
      'recommendations': recommendations,
      'dailyData': dailyData.map((d) => d.toMap()).toList(),
    };
  }

  factory WeeklyReportModel.fromMap(Map<String, dynamic> map) {
    return WeeklyReportModel(
      userId: map['userId'] ?? '',
      weekStartDate: (map['weekStartDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      weekEndDate: (map['weekEndDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastUpdated: (map['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      avgSteps: (map['avgSteps'] ?? 0).toDouble(),
      avgWaterIntake: (map['avgWaterIntake'] ?? 0).toDouble(),
      avgCalories: (map['avgCalories'] ?? 0).toDouble(),
      avgSleepQuality: (map['avgSleepQuality'] ?? 0).toDouble(),
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
      stepsChangeVsPreviousWeek: (map['stepsChangeVsPreviousWeek'] as num?)?.toDouble(),
      waterChangeVsPreviousWeek: (map['waterChangeVsPreviousWeek'] as num?)?.toDouble(),
      caloriesChangeVsPreviousWeek: (map['caloriesChangeVsPreviousWeek'] as num?)?.toDouble(),
      sleepChangeVsPreviousWeek: (map['sleepChangeVsPreviousWeek'] as num?)?.toDouble(),
      diabetesRiskChange: (map['diabetesRiskChange'] as num?)?.toDouble(),
      heartDiseaseRiskChange: (map['heartDiseaseRiskChange'] as num?)?.toDouble(),
      obesityRiskChange: (map['obesityRiskChange'] as num?)?.toDouble(),
      totalDays: map['totalDays'] ?? 7,
      daysGoalAchieved: map['daysGoalAchieved'] ?? 0,
      weeklyGoalAchievement: (map['weeklyGoalAchievement'] ?? 0).toDouble(),
      bestDay: (map['bestDay'] as Timestamp?)?.toDate(),
      bestDaySteps: map['bestDaySteps'] as int?,
      stepsTrend: map['stepsTrend'] ?? 'stable',
      waterTrend: map['waterTrend'] ?? 'stable',
      sleepTrend: map['sleepTrend'] ?? 'stable',
      overallHealthTrend: map['overallHealthTrend'] ?? 'stable',
      recommendations: List<String>.from(map['recommendations'] ?? []),
      dailyData: (map['dailyData'] as List<dynamic>?)
              ?.map((d) => DailyData.fromMap(d as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

// Günlük veri noktası (grafik için)
class DailyData {
  final DateTime date;
  final int steps;
  final double waterIntake;
  final int calories;
  final int sleepQuality;

  DailyData({
    required this.date,
    required this.steps,
    required this.waterIntake,
    required this.calories,
    required this.sleepQuality,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'steps': steps,
      'waterIntake': waterIntake,
      'calories': calories,
      'sleepQuality': sleepQuality,
    };
  }

  factory DailyData.fromMap(Map<String, dynamic> map) {
    return DailyData(
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      steps: map['steps'] ?? 0,
      waterIntake: (map['waterIntake'] ?? 0).toDouble(),
      calories: map['calories'] ?? 0,
      sleepQuality: map['sleepQuality'] ?? 0,
    );
  }
}
