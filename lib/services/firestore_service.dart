import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/daily_metric_model.dart';
import '../models/activity_model.dart';
import '../models/health_record_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // DAILY METRICS

  Future<DailyMetricModel?> getTodayMetric(String userId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    final querySnapshot = await _firestore
        .collection('dailyMetrics')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) return null;

    final doc = querySnapshot.docs.first;
    return DailyMetricModel.fromMap(doc.data(), doc.id);
  }

  Future<void> updateDailyMetric(DailyMetricModel metric) async {
    if (metric.id != null) {
      await _firestore
          .collection('dailyMetrics')
          .doc(metric.id)
          .set(metric.toMap(), SetOptions(merge: true));
    } else {
      await _firestore.collection('dailyMetrics').add(metric.toMap());
    }
  }

  Future<void> createOrUpdateTodayMetric({
    required String userId,
    int? steps,
    double? water,
    int? calories,
    int? sleep,
  }) async {
    var metric = await getTodayMetric(userId);

    if (metric != null) {
      metric = metric.copyWith(
        steps: steps ?? metric.steps,
        waterIntake: water ?? metric.waterIntake,
        calorieEstimate: calories ?? metric.calorieEstimate,
        sleepQuality: sleep ?? metric.sleepQuality,
        updatedAt: DateTime.now(),
      );
      await updateDailyMetric(metric);
    } else {
      final newMetric = DailyMetricModel(
        userId: userId,
        steps: steps ?? 0,
        waterIntake: water ?? 0,
        calorieEstimate: calories ?? 0,
        sleepQuality: sleep ?? 0,
      );
      await _firestore.collection('dailyMetrics').add(newMetric.toMap());
    }
  }

  // STREAM FOR LIVE UPDATES
  Stream<DailyMetricModel?> getTodayMetricStream(String userId) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    return _firestore
        .collection('dailyMetrics')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      return DailyMetricModel.fromMap(doc.data(), doc.id);
    });
  }

  // HISTORY FOR TRENDS
  Future<List<DailyMetricModel>> getDailyMetricsHistory(String userId,
      {int days = 7}) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));

    final querySnapshot = await _firestore
        .collection('dailyMetrics')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .orderBy('date', descending: false) // Eskiden yeniye
        .get();

    return querySnapshot.docs
        .map((doc) => DailyMetricModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // ACTIVITIES

  Future<void> addActivity(ActivityModel activity) async {
    await _firestore.collection('activities').add(activity.toMap());
  }

  Future<List<ActivityModel>> getActivities(String userId,
      {int limit = 20}) async {
    final querySnapshot = await _firestore
        .collection('activities')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .limit(limit)
        .get();

    return querySnapshot.docs
        .map((doc) => ActivityModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<ActivityModel>> getActivitiesForDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final querySnapshot = await _firestore
        .collection('activities')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('date', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => ActivityModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // HEALTH RECORDS

  Future<void> addHealthRecord(HealthRecordModel record) async {
    await _firestore.collection('healthRecords').add(record.toMap());
  }

  Future<List<HealthRecordModel>> getHealthRecords(String userId,
      {int limit = 10}) async {
    final querySnapshot = await _firestore
        .collection('healthRecords')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .limit(limit)
        .get();

    return querySnapshot.docs
        .map((doc) => HealthRecordModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // USER PROFILE UPDATE
  Future<void> updateUserProfile(
      String userId, Map<String, dynamic> data) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .set(data, SetOptions(merge: true));
  }
}
