import '../services/badge_definitions_service.dart';

/// Utility to initialize gamification system
/// Call this once when setting up the app for the first time
class GamificationInitializer {
  static Future<void> initialize() async {
    try {
      print('🎮 Initializing gamification system...');

      // Initialize badge definitions in Firestore
      final badgeService = BadgeDefinitionsService();
      await badgeService.initializeBadgeDefinitions();

      print('✅ Badge definitions uploaded to Firestore');
      print('✅ Gamification system initialized successfully!');
      print('📊 Total badges: 30+');
      print('');
      print('Badge categories:');
      print('  🏃 Activity badges: Distance & count milestones');
      print('  💧 Health badges: Water, sleep, steps goals');
      print('  🔥 Streak badges: Consecutive days active');
      print('  🎯 Goal badges: Perfect day completions');
      print('  ⭐ Special badges: Early bird, weekend warrior, etc.');
    } catch (e) {
      print('❌ Error initializing gamification: $e');
      rethrow;
    }
  }
}
