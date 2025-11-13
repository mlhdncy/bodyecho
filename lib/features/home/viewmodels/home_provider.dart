import 'package:flutter/material.dart';
import '../../../models/daily_metric_model.dart';
import '../../../services/firestore_service.dart';

class HomeProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  DailyMetricModel? _todayMetric;
  bool _isLoading = false;
  String? _errorMessage;

  DailyMetricModel? get todayMetric => _todayMetric;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadTodayMetrics(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _todayMetric = await _firestoreService.getTodayMetric(userId);
      debugPrint('HomeProvider: Loaded metrics - Steps: ${_todayMetric?.steps}, Water: ${_todayMetric?.waterIntake}, Calories: ${_todayMetric?.calorieEstimate}, Sleep: ${_todayMetric?.sleepQuality}');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('HomeProvider: Error loading metrics - $e');
      _errorMessage = 'Metrikler yüklenemedi: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSteps(String userId, int steps) async {
    try {
      await _firestoreService.createOrUpdateTodayMetric(
        userId: userId,
        steps: steps,
      );
      await loadTodayMetrics(userId);
    } catch (e) {
      _errorMessage = 'Adım güncellenemedi: $e';
      notifyListeners();
    }
  }

  Future<void> addWater(String userId, double amount) async {
    try {
      final currentWater = _todayMetric?.waterIntake ?? 0.0;
      await _firestoreService.createOrUpdateTodayMetric(
        userId: userId,
        water: currentWater + amount,
      );
      await loadTodayMetrics(userId);
    } catch (e) {
      _errorMessage = 'Su eklenemedi: $e';
      notifyListeners();
    }
  }

  Future<void> updateCalories(String userId, int calories) async {
    try {
      await _firestoreService.createOrUpdateTodayMetric(
        userId: userId,
        calories: calories,
      );
      await loadTodayMetrics(userId);
    } catch (e) {
      _errorMessage = 'Kalori güncellenemedi: $e';
      notifyListeners();
    }
  }

  Future<void> updateSleep(String userId, int hours) async {
    try {
      await _firestoreService.createOrUpdateTodayMetric(
        userId: userId,
        sleep: hours,
      );
      await loadTodayMetrics(userId);
    } catch (e) {
      _errorMessage = 'Uyku güncellenemedi: $e';
      notifyListeners();
    }
  }
}
