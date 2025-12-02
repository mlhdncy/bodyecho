import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/app_constants.dart';

class DailyMetricModel {
  final String? id;
  final String userId;
  final DateTime date;
  final int steps;
  final double waterIntake;
  final int calorieEstimate;
  final int sleepQuality;
  final DateTime createdAt;
  final DateTime updatedAt;

  DailyMetricModel({
    this.id,
    required this.userId,
    DateTime? date,
    this.steps = 0,
    this.waterIntake = 0.0,
    this.calorieEstimate = 0,
    this.sleepQuality = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : date = date ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  double get stepsProgress => steps / AppConstants.defaultStepsGoal;
  double get waterProgress => waterIntake / AppConstants.defaultWaterGoal;
  double get calorieProgress =>
      calorieEstimate / AppConstants.defaultCalorieGoal;
  double get sleepQualityProgress =>
      sleepQuality / AppConstants.defaultSleepQualityGoal;
  double get sleepProgress =>
      sleepQuality / AppConstants.defaultSleepQualityGoal;

  // Overall Progress: Average of Steps, Water, and Sleep (capped at 1.0 each)
  double get overallProgress {
    final s = (stepsProgress > 1.0) ? 1.0 : stepsProgress;
    final w = (waterProgress > 1.0) ? 1.0 : waterProgress;
    final sl = (sleepProgress > 1.0) ? 1.0 : sleepProgress;
    return (s + w + sl) / 3.0;
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'steps': steps,
      'waterIntake': waterIntake,
      'calorieEstimate': calorieEstimate,
      'sleepQuality': sleepQuality,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory DailyMetricModel.fromMap(Map<String, dynamic> map, String id) {
    return DailyMetricModel(
      id: id,
      userId: map['userId'] ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      steps: map['steps'] ?? 0,
      waterIntake: (map['waterIntake'] ?? 0).toDouble(),
      calorieEstimate: map['calorieEstimate'] ?? 0,
      sleepQuality: map['sleepQuality'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  DailyMetricModel copyWith({
    String? id,
    String? userId,
    DateTime? date,
    int? steps,
    double? waterIntake,
    int? calorieEstimate,
    int? sleepQuality,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyMetricModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      steps: steps ?? this.steps,
      waterIntake: waterIntake ?? this.waterIntake,
      calorieEstimate: calorieEstimate ?? this.calorieEstimate,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
