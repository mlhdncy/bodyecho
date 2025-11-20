import 'package:cloud_firestore/cloud_firestore.dart';

class HealthRecordModel {
  final String? id;
  final String userId;
  final DateTime date;
  final int? bloodGlucoseLevel;
  final int? systolicBP; // Büyük tansiyon
  final int? diastolicBP; // Küçük tansiyon
  final int? heartRate;
  final double? temperature;
  final String? notes;
  final DateTime createdAt;

  HealthRecordModel({
    this.id,
    required this.userId,
    DateTime? date,
    this.bloodGlucoseLevel,
    this.systolicBP,
    this.diastolicBP,
    this.heartRate,
    this.temperature,
    this.notes,
    DateTime? createdAt,
  })  : date = date ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'bloodGlucoseLevel': bloodGlucoseLevel,
      'systolicBP': systolicBP,
      'diastolicBP': diastolicBP,
      'heartRate': heartRate,
      'temperature': temperature,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory HealthRecordModel.fromMap(Map<String, dynamic> map, String id) {
    return HealthRecordModel(
      id: id,
      userId: map['userId'] ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      bloodGlucoseLevel: map['bloodGlucoseLevel'] as int?,
      systolicBP: map['systolicBP'] as int?,
      diastolicBP: map['diastolicBP'] as int?,
      heartRate: map['heartRate'] as int?,
      temperature: (map['temperature'] as num?)?.toDouble(),
      notes: map['notes'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
