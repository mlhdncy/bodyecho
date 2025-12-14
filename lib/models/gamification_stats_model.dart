import 'package:cloud_firestore/cloud_firestore.dart';

class GamificationStats {
  final String userId;

  // Cumulative stats for badge unlocking
  final double totalDistanceKm;
  final int totalActivities;
  final int waterGoalDaysCount;
  final int stepsGoalDaysCount;
  final int sleepGoalDaysCount;
  final int caloriesGoalDaysCount;
  final int perfectDaysCount; // All goals hit in one day

  // Activity-specific stats
  final double longestRunKm;
  final int earliestActivityHour; // For "Early Bird" badge
  final int weekendActivitiesCount;
  final int healthRecordsCount;

  final DateTime lastUpdated;

  GamificationStats({
    required this.userId,
    this.totalDistanceKm = 0.0,
    this.totalActivities = 0,
    this.waterGoalDaysCount = 0,
    this.stepsGoalDaysCount = 0,
    this.sleepGoalDaysCount = 0,
    this.caloriesGoalDaysCount = 0,
    this.perfectDaysCount = 0,
    this.longestRunKm = 0.0,
    this.earliestActivityHour = 24, // 24 means no activity yet
    this.weekendActivitiesCount = 0,
    this.healthRecordsCount = 0,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'totalDistanceKm': totalDistanceKm,
      'totalActivities': totalActivities,
      'waterGoalDaysCount': waterGoalDaysCount,
      'stepsGoalDaysCount': stepsGoalDaysCount,
      'sleepGoalDaysCount': sleepGoalDaysCount,
      'caloriesGoalDaysCount': caloriesGoalDaysCount,
      'perfectDaysCount': perfectDaysCount,
      'longestRunKm': longestRunKm,
      'earliestActivityHour': earliestActivityHour,
      'weekendActivitiesCount': weekendActivitiesCount,
      'healthRecordsCount': healthRecordsCount,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  factory GamificationStats.fromMap(Map<String, dynamic> map) {
    return GamificationStats(
      userId: map['userId'] ?? '',
      totalDistanceKm: (map['totalDistanceKm'] as num?)?.toDouble() ?? 0.0,
      totalActivities: map['totalActivities'] as int? ?? 0,
      waterGoalDaysCount: map['waterGoalDaysCount'] as int? ?? 0,
      stepsGoalDaysCount: map['stepsGoalDaysCount'] as int? ?? 0,
      sleepGoalDaysCount: map['sleepGoalDaysCount'] as int? ?? 0,
      caloriesGoalDaysCount: map['caloriesGoalDaysCount'] as int? ?? 0,
      perfectDaysCount: map['perfectDaysCount'] as int? ?? 0,
      longestRunKm: (map['longestRunKm'] as num?)?.toDouble() ?? 0.0,
      earliestActivityHour: map['earliestActivityHour'] as int? ?? 24,
      weekendActivitiesCount: map['weekendActivitiesCount'] as int? ?? 0,
      healthRecordsCount: map['healthRecordsCount'] as int? ?? 0,
      lastUpdated: (map['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  GamificationStats copyWith({
    String? userId,
    double? totalDistanceKm,
    int? totalActivities,
    int? waterGoalDaysCount,
    int? stepsGoalDaysCount,
    int? sleepGoalDaysCount,
    int? caloriesGoalDaysCount,
    int? perfectDaysCount,
    double? longestRunKm,
    int? earliestActivityHour,
    int? weekendActivitiesCount,
    int? healthRecordsCount,
    DateTime? lastUpdated,
  }) {
    return GamificationStats(
      userId: userId ?? this.userId,
      totalDistanceKm: totalDistanceKm ?? this.totalDistanceKm,
      totalActivities: totalActivities ?? this.totalActivities,
      waterGoalDaysCount: waterGoalDaysCount ?? this.waterGoalDaysCount,
      stepsGoalDaysCount: stepsGoalDaysCount ?? this.stepsGoalDaysCount,
      sleepGoalDaysCount: sleepGoalDaysCount ?? this.sleepGoalDaysCount,
      caloriesGoalDaysCount: caloriesGoalDaysCount ?? this.caloriesGoalDaysCount,
      perfectDaysCount: perfectDaysCount ?? this.perfectDaysCount,
      longestRunKm: longestRunKm ?? this.longestRunKm,
      earliestActivityHour: earliestActivityHour ?? this.earliestActivityHour,
      weekendActivitiesCount: weekendActivitiesCount ?? this.weekendActivitiesCount,
      healthRecordsCount: healthRecordsCount ?? this.healthRecordsCount,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
