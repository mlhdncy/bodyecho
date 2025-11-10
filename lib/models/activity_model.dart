import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/app_constants.dart';

class ActivityModel {
  final String? id;
  final String userId;
  final String type; // walking, running, cycling
  final int duration; // minutes
  final double distance; // km
  final int caloriesBurned;
  final DateTime date;
  final DateTime createdAt;

  ActivityModel({
    this.id,
    required this.userId,
    required this.type,
    required this.duration,
    required this.distance,
    int? caloriesBurned,
    DateTime? date,
    DateTime? createdAt,
  })  : caloriesBurned = caloriesBurned ?? AppConstants.calculateCalories(type, duration),
        date = date ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  String get displayName {
    return AppConstants.activityTypes[type]?['name'] ?? type;
  }

  String get icon {
    return AppConstants.activityTypes[type]?['icon'] ?? '🏃';
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type,
      'duration': duration,
      'distance': distance,
      'caloriesBurned': caloriesBurned,
      'date': Timestamp.fromDate(date),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ActivityModel.fromMap(Map<String, dynamic> map, String id) {
    return ActivityModel(
      id: id,
      userId: map['userId'] ?? '',
      type: map['type'] ?? '',
      duration: map['duration'] ?? 0,
      distance: (map['distance'] ?? 0).toDouble(),
      caloriesBurned: map['caloriesBurned'] ?? 0,
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
