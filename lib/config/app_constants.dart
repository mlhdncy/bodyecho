class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Body Echo';
  static const String appVersion = '1.0.0';

  // UI Constants
  static const double cornerRadius = 12.0;
  static const double buttonHeight = 52.0;
  static const double padding = 16.0;
  static const double cardPadding = 20.0;

  // Daily Goals
  static const int defaultStepsGoal = 10000;
  static const double defaultWaterGoal = 2.5; // liters
  static const int defaultCalorieGoal = 2500;
  static const int defaultSleepQualityGoal = 80; // percentage

  // Level System
  static const int pointsPerLevel = 500;

  // Activity Types
  static const Map<String, Map<String, dynamic>> activityTypes = {
    'walking': {
      'name': 'Yürüyüş',
      'icon': '🚶',
      'caloriesPerMinute': 4.0,
    },
    'running': {
      'name': 'Koşu',
      'icon': '🏃',
      'caloriesPerMinute': 10.0,
    },
    'cycling': {
      'name': 'Bisiklet',
      'icon': '🚴',
      'caloriesPerMinute': 8.0,
    },
  };

  // Helper Methods
  static int calculateLevel(int points) {
    return (points ~/ pointsPerLevel) + 1;
  }

  static int pointsForNextLevel(int currentPoints) {
    final currentLevel = calculateLevel(currentPoints);
    return (currentLevel * pointsPerLevel) - currentPoints;
  }

  static int calculateCalories(String activityType, int durationMinutes) {
    final activity = activityTypes[activityType];
    if (activity == null) return 0;
    return (activity['caloriesPerMinute'] * durationMinutes).round();
  }
}
