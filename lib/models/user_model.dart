import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/app_constants.dart';

class UserModel {
  final String? id;
  final String anonymousId;
  final String fullName;
  final String email;
  final int level;
  final int points;
  final String avatarType;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    this.id,
    required this.anonymousId,
    required this.fullName,
    required this.email,
    this.level = 1,
    this.points = 0,
    this.avatarType = 'default',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  int get currentLevelProgress => points % AppConstants.pointsPerLevel;
  int get pointsForNextLevel => AppConstants.pointsPerLevel - currentLevelProgress;

  Map<String, dynamic> toMap() {
    return {
      'anonymousId': anonymousId,
      'fullName': fullName,
      'email': email,
      'level': level,
      'points': points,
      'avatarType': avatarType,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      anonymousId: map['anonymousId'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      level: map['level'] ?? 1,
      points: map['points'] ?? 0,
      avatarType: map['avatarType'] ?? 'default',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  UserModel copyWith({
    String? id,
    String? anonymousId,
    String? fullName,
    String? email,
    int? level,
    int? points,
    String? avatarType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      anonymousId: anonymousId ?? this.anonymousId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      level: level ?? this.level,
      points: points ?? this.points,
      avatarType: avatarType ?? this.avatarType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
