import 'package:cloud_firestore/cloud_firestore.dart';

/// Badge condition type for checking when a badge should be unlocked
class BadgeCondition {
  final String type; // 'total_distance', 'daily_streak', 'water_goal_days', etc.
  final dynamic targetValue; // Numeric target or condition value
  final String? timeframe; // 'daily', 'weekly', 'monthly', 'alltime'

  BadgeCondition({
    required this.type,
    required this.targetValue,
    this.timeframe,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'targetValue': targetValue,
      'timeframe': timeframe,
    };
  }

  factory BadgeCondition.fromMap(Map<String, dynamic> map) {
    return BadgeCondition(
      type: map['type'] ?? '',
      targetValue: map['targetValue'],
      timeframe: map['timeframe'] as String?,
    );
  }
}

/// Badge definition - describes what the badge is and how to earn it
class BadgeDefinition {
  final String id;
  final String category; // 'activity', 'health', 'streak', 'goal', 'special'
  final String title; // Turkish: 'İlk 5km'
  final String description; // Turkish: '5 km mesafeyi tamamla'
  final String icon; // Emoji: '🏃'
  final int tier; // 1=Bronz, 2=Gümüş, 3=Altın, 4=Platin
  final BadgeCondition condition;

  BadgeDefinition({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.icon,
    required this.tier,
    required this.condition,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'title': title,
      'description': description,
      'icon': icon,
      'tier': tier,
      'condition': condition.toMap(),
    };
  }

  factory BadgeDefinition.fromMap(Map<String, dynamic> map) {
    return BadgeDefinition(
      id: map['id'] ?? '',
      category: map['category'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      icon: map['icon'] ?? '🏆',
      tier: map['tier'] as int? ?? 1,
      condition: BadgeCondition.fromMap(map['condition'] as Map<String, dynamic>? ?? {}),
    );
  }
}

/// User's earned badge
class UserBadge {
  final String userId;
  final String badgeId;
  final DateTime earnedDate;
  final bool notified; // Has user seen the unlock notification?

  UserBadge({
    required this.userId,
    required this.badgeId,
    required this.earnedDate,
    this.notified = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'badgeId': badgeId,
      'earnedDate': Timestamp.fromDate(earnedDate),
      'notified': notified,
    };
  }

  factory UserBadge.fromMap(Map<String, dynamic> map) {
    return UserBadge(
      userId: map['userId'] ?? '',
      badgeId: map['badgeId'] ?? '',
      earnedDate: (map['earnedDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notified: map['notified'] as bool? ?? false,
    );
  }

  UserBadge copyWith({
    String? userId,
    String? badgeId,
    DateTime? earnedDate,
    bool? notified,
  }) {
    return UserBadge(
      userId: userId ?? this.userId,
      badgeId: badgeId ?? this.badgeId,
      earnedDate: earnedDate ?? this.earnedDate,
      notified: notified ?? this.notified,
    );
  }
}
