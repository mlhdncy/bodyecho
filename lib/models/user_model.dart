import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? id;
  final String anonymousId;
  final String fullName;
  final String email;
  final double? height; // cm
  final double? weight; // kg
  final int? age;
  final String? gender; // 'Male', 'Female'
  final String? activityLevel; // 'Low', 'Moderate', 'High'

  UserModel({
    this.id,
    required this.anonymousId,
    required this.fullName,
    required this.email,
    this.avatarType = 'default',
    this.height,
    this.weight,
    this.age,
    this.gender,
    this.activityLevel,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'anonymousId': anonymousId,
      'fullName': fullName,
      'email': email,
      'avatarType': avatarType,
      'height': height,
      'weight': weight,
      'age': age,
      'gender': gender,
      'activityLevel': activityLevel,
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
      avatarType: map['avatarType'] ?? 'default',
      height: (map['height'] as num?)?.toDouble(),
      weight: (map['weight'] as num?)?.toDouble(),
      age: map['age'] as int?,
      gender: map['gender'] as String?,
      activityLevel: map['activityLevel'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  UserModel copyWith({
    String? id,
    String? anonymousId,
    String? fullName,
    String? email,
    String? avatarType,
    double? height,
    double? weight,
    int? age,
    String? gender,
    String? activityLevel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      anonymousId: anonymousId ?? this.anonymousId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      avatarType: avatarType ?? this.avatarType,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      activityLevel: activityLevel ?? this.activityLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
