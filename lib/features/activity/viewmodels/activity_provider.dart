import 'package:flutter/material.dart';
import '../../../models/activity_model.dart';
import '../../../services/firestore_service.dart';

class ActivityProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<ActivityModel> _activities = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ActivityModel> get activities => _activities;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadActivities(String userId, {int limit = 20}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _activities = await _firestoreService.getActivities(userId, limit: limit);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Aktiviteler yüklenemedi: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addActivity(ActivityModel activity) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.addActivity(activity);

      // Add points to user (10 points per activity)
      await _firestoreService.addPointsToUser(activity.userId, 10);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Aktivite eklenemedi: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadActivitiesForDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _activities = await _firestoreService.getActivitiesForDateRange(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Aktiviteler yüklenemedi: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
}
