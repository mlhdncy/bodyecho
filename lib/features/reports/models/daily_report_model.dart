import 'package:cloud_firestore/cloud_firestore.dart';

class DailyReportModel {
  final String userId;
  final DateTime date;
  final DateTime lastUpdated;

  // Günlük metrikler
  final int steps;
  final double waterIntake;
  final int calorieEstimate;
  final int sleepQuality;

  // Sağlık kayıtları (ortalamalar)
  final double? avgBloodGlucose;
  final double? avgSystolicBP;
  final double? avgDiastolicBP;
  final double? avgHeartRate;
  final double? avgTemperature;

  // ML risk skorları (güncel)
  final double? diabetesRisk;
  final double? heartDiseaseRisk;
  final double? obesityRisk;
  final double? cancerRisk;
  final double? highCholesterolRisk;
  final double? lowActivityRisk;

  // Dünle karşılaştırma (% değişim)
  final double? stepsChange;
  final double? waterChange;
  final double? calorieChange;
  final double? sleepQualityChange;

  // Hedef başarı oranı
  final double dailyGoalAchievement;

  // Öneriler
  final List<String> recommendations;

  DailyReportModel({
    required this.userId,
    required this.date,
    required this.lastUpdated,
    this.steps = 0,
    this.waterIntake = 0.0,
    this.calorieEstimate = 0,
    this.sleepQuality = 0,
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
    this.stepsChange,
    this.waterChange,
    this.calorieChange,
    this.sleepQualityChange,
    this.dailyGoalAchievement = 0.0,
    this.recommendations = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'steps': steps,
      'waterIntake': waterIntake,
      'calorieEstimate': calorieEstimate,
      'sleepQuality': sleepQuality,
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
      'stepsChange': stepsChange,
      'waterChange': waterChange,
      'calorieChange': calorieChange,
      'sleepQualityChange': sleepQualityChange,
      'dailyGoalAchievement': dailyGoalAchievement,
      'recommendations': recommendations,
    };
  }

  factory DailyReportModel.fromMap(Map<String, dynamic> map) {
    return DailyReportModel(
      userId: map['userId'] ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastUpdated: (map['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      steps: map['steps'] ?? 0,
      waterIntake: (map['waterIntake'] ?? 0).toDouble(),
      calorieEstimate: map['calorieEstimate'] ?? 0,
      sleepQuality: map['sleepQuality'] ?? 0,
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
      stepsChange: (map['stepsChange'] as num?)?.toDouble(),
      waterChange: (map['waterChange'] as num?)?.toDouble(),
      calorieChange: (map['calorieChange'] as num?)?.toDouble(),
      sleepQualityChange: (map['sleepQualityChange'] as num?)?.toDouble(),
      dailyGoalAchievement: (map['dailyGoalAchievement'] ?? 0).toDouble(),
      recommendations: List<String>.from(map['recommendations'] ?? []),
    );
  }

  DailyReportModel copyWith({
    String? userId,
    DateTime? date,
    DateTime? lastUpdated,
    int? steps,
    double? waterIntake,
    int? calorieEstimate,
    int? sleepQuality,
    double? avgBloodGlucose,
    double? avgSystolicBP,
    double? avgDiastolicBP,
    double? avgHeartRate,
    double? avgTemperature,
    double? diabetesRisk,
    double? heartDiseaseRisk,
    double? obesityRisk,
    double? cancerRisk,
    double? highCholesterolRisk,
    double? lowActivityRisk,
    double? stepsChange,
    double? waterChange,
    double? calorieChange,
    double? sleepQualityChange,
    double? dailyGoalAchievement,
    List<String>? recommendations,
  }) {
    return DailyReportModel(
      userId: userId ?? this.userId,
      date: date ?? this.date,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      steps: steps ?? this.steps,
      waterIntake: waterIntake ?? this.waterIntake,
      calorieEstimate: calorieEstimate ?? this.calorieEstimate,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      avgBloodGlucose: avgBloodGlucose ?? this.avgBloodGlucose,
      avgSystolicBP: avgSystolicBP ?? this.avgSystolicBP,
      avgDiastolicBP: avgDiastolicBP ?? this.avgDiastolicBP,
      avgHeartRate: avgHeartRate ?? this.avgHeartRate,
      avgTemperature: avgTemperature ?? this.avgTemperature,
      diabetesRisk: diabetesRisk ?? this.diabetesRisk,
      heartDiseaseRisk: heartDiseaseRisk ?? this.heartDiseaseRisk,
      obesityRisk: obesityRisk ?? this.obesityRisk,
      cancerRisk: cancerRisk ?? this.cancerRisk,
      highCholesterolRisk: highCholesterolRisk ?? this.highCholesterolRisk,
      lowActivityRisk: lowActivityRisk ?? this.lowActivityRisk,
      stepsChange: stepsChange ?? this.stepsChange,
      waterChange: waterChange ?? this.waterChange,
      calorieChange: calorieChange ?? this.calorieChange,
      sleepQualityChange: sleepQualityChange ?? this.sleepQualityChange,
      dailyGoalAchievement: dailyGoalAchievement ?? this.dailyGoalAchievement,
      recommendations: recommendations ?? this.recommendations,
    );
  }
}
