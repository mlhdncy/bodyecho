import 'package:flutter/material.dart';
import '../../../models/activity_model.dart';
import '../../../services/firestore_service.dart';
import '../../../services/gamification_service.dart';

class ActivityProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final GamificationService _gamificationService = GamificationService();

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

      // Update daily calories
      await _updateDailyCalories(activity.userId, activity.caloriesBurned);

      // GAMIFICATION: Award points for activity
      final distanceKm = activity.distance;
      final activityHour = activity.date.hour;
      final isWeekend = activity.date.weekday == DateTime.saturday ||
                        activity.date.weekday == DateTime.sunday;

      // Award base activity points
      final result = await _gamificationService.awardPoints(
        userId: activity.userId,
        actionType: 'activity_logged',
        metadata: {
          'distance': distanceKm,
          'type': activity.type,
          'calories': activity.caloriesBurned,
          'hour': activityHour,
          'isWeekend': isWeekend,
        },
      );

      // Update gamification stats for badge checking
      await _gamificationService.updateGamificationStats(
        activity.userId,
        distanceKm: distanceKm,
        activityHour: activityHour,
        isWeekend: isWeekend,
      );

      // Update streak
      await _gamificationService.updateStreak(activity.userId, activity.date);

      // Check for new badges
      final newBadges = await _gamificationService.checkBadgeUnlocks(activity.userId);

      debugPrint('Activity added! Points: ${result.pointsAwarded}, New badges: ${newBadges.length}');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Aktivite eklenemedi: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _updateDailyCalories(String userId, int calories) async {
    try {
      // Get today's metric
      final todayMetric = await _firestoreService.getTodayMetric(userId);
      final currentCalories = todayMetric?.calorieEstimate ?? 0;

      // Add new calories to existing
      await _firestoreService.createOrUpdateTodayMetric(
        userId: userId,
        calories: currentCalories + calories,
      );
    } catch (e) {
      // Don't throw, just log - activity was already added
      debugPrint('Kalori güncellenemedi: $e');
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
