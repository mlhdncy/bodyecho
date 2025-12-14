import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/app_constants.dart';
import '../models/gamification_stats_model.dart';
import '../models/badge_model.dart';

/// Result of awarding points to a user
class PointsResult {
  final int pointsAwarded;
  final List<String> newBadgesUnlocked;
  final int newLevel;
  final int previousLevel;
  final bool leveledUp;
  final String? streakBonus;

  PointsResult({
    required this.pointsAwarded,
    required this.newBadgesUnlocked,
    required this.newLevel,
    required this.previousLevel,
    this.streakBonus,
  }) : leveledUp = newLevel > previousLevel;
}

/// Gamification service for managing points, levels, streaks, and badges
class GamificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== POINTS MANAGEMENT ====================

  /// Award points to a user for an action
  Future<PointsResult> awardPoints({
    required String userId,
    required String actionType,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Calculate points for this action
      final points = _calculatePointsForAction(actionType, metadata: metadata);

      if (points == 0) {
        return PointsResult(
          pointsAwarded: 0,
          newBadgesUnlocked: [],
          newLevel: 1,
          previousLevel: 1,
        );
      }

      // Get current user data
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final currentPoints = userDoc.data()?['totalPoints'] as int? ?? 0;
      final previousLevel = AppConstants.calculateLevel(currentPoints);

      // Update user points
      final newPoints = currentPoints + points;
      final newLevel = AppConstants.calculateLevel(newPoints);

      await _firestore.collection('users').doc(userId).update({
        'totalPoints': newPoints,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Check for new badges
      final newBadges = await checkBadgeUnlocks(userId);
      final newBadgeIds = newBadges.map((b) => b.id).toList();

      return PointsResult(
        pointsAwarded: points,
        newBadgesUnlocked: newBadgeIds,
        newLevel: newLevel,
        previousLevel: previousLevel,
      );
    } catch (e) {
      print('Error awarding points: $e');
      rethrow;
    }
  }

  /// Calculate points for a specific action
  int _calculatePointsForAction(String actionType, {Map<String, dynamic>? metadata}) {
    switch (actionType) {
      // Base activities
      case 'activity_logged':
        int basePoints = 20;
        // Bonus for early morning (before 7 AM)
        if (metadata?['hour'] != null && metadata!['hour'] < 7) {
          basePoints += 10;
        }
        // Bonus for weekend
        if (metadata?['isWeekend'] == true) {
          basePoints += 15;
        }
        return basePoints;

      case 'water_logged':
        return 5;

      case 'sleep_logged':
        return 10;

      case 'health_record_logged':
        return 15;

      // Daily goal completions
      case 'steps_goal_complete':
        return 50;

      case 'water_goal_complete':
        return 30;

      case 'sleep_goal_complete':
        return 25;

      case 'calories_goal_complete':
        return 40;

      case 'perfect_day':
        return 50; // Bonus for completing all goals

      // Distance milestones
      case 'first_1km':
        return 25;

      case 'first_5km':
        return 50;

      case 'first_10km':
        return 100;

      case 'milestone_100km':
        return 200;

      // Streak bonuses
      case 'streak_3_days':
        return 50;

      case 'streak_7_days':
        return 150;

      case 'streak_14_days':
        return 300;

      case 'streak_30_days':
        return 750;

      case 'streak_100_days':
        return 2500;

      // Weekly consistency
      case 'weekly_consistency':
        return 100;

      default:
        return 0;
    }
  }

  // ==================== STREAK MANAGEMENT ====================

  /// Update user's streak based on activity date
  Future<void> updateStreak(String userId, DateTime activityDate) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data();

      if (userData == null) return;

      final lastActiveDate = (userData['lastActiveDate'] as Timestamp?)?.toDate();
      final currentStreak = userData['currentStreak'] as int? ?? 0;
      final longestStreak = userData['longestStreak'] as int? ?? 0;

      int newStreak = 1;

      if (lastActiveDate != null) {
        final daysDifference = _daysBetween(lastActiveDate, activityDate);

        if (daysDifference == 0) {
          // Same day, don't update streak
          return;
        } else if (daysDifference == 1) {
          // Consecutive day, increment streak
          newStreak = currentStreak + 1;
        }
        // else: More than 1 day gap, reset to 1
      }

      // Check if this is a new longest streak
      final newLongestStreak = newStreak > longestStreak ? newStreak : longestStreak;

      // Update user
      await _firestore.collection('users').doc(userId).update({
        'currentStreak': newStreak,
        'longestStreak': newLongestStreak,
        'lastActiveDate': Timestamp.fromDate(activityDate),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Award streak milestone points
      await _checkStreakMilestones(userId, newStreak);
    } catch (e) {
      print('Error updating streak: $e');
      rethrow;
    }
  }

  /// Check if streak has hit milestones and award points
  Future<void> _checkStreakMilestones(String userId, int streak) async {
    if (streak == 3) {
      await awardPoints(userId: userId, actionType: 'streak_3_days');
    } else if (streak == 7) {
      await awardPoints(userId: userId, actionType: 'streak_7_days');
    } else if (streak == 14) {
      await awardPoints(userId: userId, actionType: 'streak_14_days');
    } else if (streak == 30) {
      await awardPoints(userId: userId, actionType: 'streak_30_days');
    } else if (streak == 100) {
      await awardPoints(userId: userId, actionType: 'streak_100_days');
    }
  }

  /// Calculate current streak for a user
  Future<int> calculateCurrentStreak(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      return userDoc.data()?['currentStreak'] as int? ?? 0;
    } catch (e) {
      print('Error calculating streak: $e');
      return 0;
    }
  }

  /// Calculate days between two dates (ignoring time)
  int _daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return to.difference(from).inDays;
  }

  // ==================== STATS MANAGEMENT ====================

  /// Update gamification stats for badge checking
  Future<void> updateGamificationStats(
    String userId, {
    double? distanceKm,
    bool? waterGoalHit,
    bool? stepsGoalHit,
    bool? sleepGoalHit,
    bool? caloriesGoalHit,
    int? activityHour,
    bool? isWeekend,
    bool? isHealthRecord,
  }) async {
    try {
      final statsRef = _firestore.collection('gamificationStats').doc(userId);
      final statsDoc = await statsRef.get();

      if (!statsDoc.exists) {
        // Create new stats document
        final newStats = GamificationStats(
          userId: userId,
          totalDistanceKm: distanceKm ?? 0.0,
          totalActivities: distanceKm != null ? 1 : 0,
          waterGoalDaysCount: waterGoalHit == true ? 1 : 0,
          stepsGoalDaysCount: stepsGoalHit == true ? 1 : 0,
          sleepGoalDaysCount: sleepGoalHit == true ? 1 : 0,
          caloriesGoalDaysCount: caloriesGoalHit == true ? 1 : 0,
          earliestActivityHour: activityHour ?? 24,
          weekendActivitiesCount: isWeekend == true ? 1 : 0,
          healthRecordsCount: isHealthRecord == true ? 1 : 0,
        );
        await statsRef.set(newStats.toMap());
      } else {
        // Update existing stats
        final updates = <String, dynamic>{
          'lastUpdated': FieldValue.serverTimestamp(),
        };

        if (distanceKm != null) {
          updates['totalDistanceKm'] = FieldValue.increment(distanceKm);
          updates['totalActivities'] = FieldValue.increment(1);

          // Check for longest run
          final currentLongest = statsDoc.data()?['longestRunKm'] as double? ?? 0.0;
          if (distanceKm > currentLongest) {
            updates['longestRunKm'] = distanceKm;
          }
        }

        if (waterGoalHit == true) {
          updates['waterGoalDaysCount'] = FieldValue.increment(1);
        }

        if (stepsGoalHit == true) {
          updates['stepsGoalDaysCount'] = FieldValue.increment(1);
        }

        if (sleepGoalHit == true) {
          updates['sleepGoalDaysCount'] = FieldValue.increment(1);
        }

        if (caloriesGoalHit == true) {
          updates['caloriesGoalDaysCount'] = FieldValue.increment(1);
        }

        if (activityHour != null) {
          final currentEarliest = statsDoc.data()?['earliestActivityHour'] as int? ?? 24;
          if (activityHour < currentEarliest) {
            updates['earliestActivityHour'] = activityHour;
          }
        }

        if (isWeekend == true) {
          updates['weekendActivitiesCount'] = FieldValue.increment(1);
        }

        if (isHealthRecord == true) {
          updates['healthRecordsCount'] = FieldValue.increment(1);
        }

        // Check perfect day
        if (waterGoalHit == true && stepsGoalHit == true &&
            sleepGoalHit == true && caloriesGoalHit == true) {
          updates['perfectDaysCount'] = FieldValue.increment(1);
        }

        await statsRef.update(updates);
      }
    } catch (e) {
      print('Error updating gamification stats: $e');
      rethrow;
    }
  }

  /// Get gamification stats for a user
  Future<GamificationStats> getGamificationStats(String userId) async {
    try {
      final statsDoc = await _firestore.collection('gamificationStats').doc(userId).get();

      if (!statsDoc.exists) {
        return GamificationStats(userId: userId);
      }

      return GamificationStats.fromMap(statsDoc.data()!);
    } catch (e) {
      print('Error getting gamification stats: $e');
      return GamificationStats(userId: userId);
    }
  }

  // ==================== BADGE MANAGEMENT ====================

  /// Check which badges should be unlocked for a user
  Future<List<BadgeDefinition>> checkBadgeUnlocks(String userId) async {
    try {
      // Get user's unlocked badges
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final unlockedBadges = List<String>.from(userDoc.data()?['unlockedBadges'] ?? []);

      // Get user's stats
      final stats = await getGamificationStats(userId);
      final userStreak = userDoc.data()?['currentStreak'] as int? ?? 0;

      // Get all badge definitions
      final badgeDefsSnapshot = await _firestore.collection('badgeDefinitions').get();
      final newlyUnlocked = <BadgeDefinition>[];

      for (final doc in badgeDefsSnapshot.docs) {
        final badge = BadgeDefinition.fromMap(doc.data());

        // Skip if already unlocked
        if (unlockedBadges.contains(badge.id)) continue;

        // Check if condition is met
        if (_checkBadgeCondition(badge, stats, userStreak)) {
          await unlockBadge(userId, badge.id);
          newlyUnlocked.add(badge);
        }
      }

      return newlyUnlocked;
    } catch (e) {
      print('Error checking badge unlocks: $e');
      return [];
    }
  }

  /// Check if a badge condition is met
  bool _checkBadgeCondition(BadgeDefinition badge, GamificationStats stats, int userStreak) {
    final condition = badge.condition;
    final target = condition.targetValue;

    switch (condition.type) {
      case 'total_distance':
        return stats.totalDistanceKm >= (target as num);

      case 'total_activities':
        return stats.totalActivities >= (target as int);

      case 'daily_streak':
        return userStreak >= (target as int);

      case 'water_goal_days':
        return stats.waterGoalDaysCount >= (target as int);

      case 'steps_goal_days':
        return stats.stepsGoalDaysCount >= (target as int);

      case 'sleep_goal_days':
        return stats.sleepGoalDaysCount >= (target as int);

      case 'perfect_days':
        return stats.perfectDaysCount >= (target as int);

      case 'early_bird_activities':
        return stats.earliestActivityHour < 7 && stats.totalActivities >= (target as int);

      case 'weekend_activities':
        return stats.weekendActivitiesCount >= (target as int);

      case 'health_records':
        return stats.healthRecordsCount >= (target as int);

      default:
        return false;
    }
  }

  /// Unlock a badge for a user
  Future<void> unlockBadge(String userId, String badgeId) async {
    try {
      // Add to user's unlocked badges
      await _firestore.collection('users').doc(userId).update({
        'unlockedBadges': FieldValue.arrayUnion([badgeId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Create user badge record
      final userBadge = UserBadge(
        userId: userId,
        badgeId: badgeId,
        earnedDate: DateTime.now(),
        notified: false,
      );

      await _firestore
          .collection('userBadges')
          .doc(userId)
          .collection('badges')
          .doc(badgeId)
          .set(userBadge.toMap());
    } catch (e) {
      print('Error unlocking badge: $e');
      rethrow;
    }
  }

  /// Get all badges earned by a user
  Future<List<UserBadge>> getUserBadges(String userId) async {
    try {
      final badgesSnapshot = await _firestore
          .collection('userBadges')
          .doc(userId)
          .collection('badges')
          .get();

      return badgesSnapshot.docs
          .map((doc) => UserBadge.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting user badges: $e');
      return [];
    }
  }

  /// Check if user has a specific badge
  Future<bool> hasBadge(String userId, String badgeId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final unlockedBadges = List<String>.from(userDoc.data()?['unlockedBadges'] ?? []);
      return unlockedBadges.contains(badgeId);
    } catch (e) {
      print('Error checking badge: $e');
      return false;
    }
  }
}
