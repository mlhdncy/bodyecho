import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/badge_model.dart';

/// Service for managing badge definitions
class BadgeDefinitionsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Initialize all badge definitions in Firestore
  /// Should be called once when setting up the app
  Future<void> initializeBadgeDefinitions() async {
    final badges = _getAllBadgeDefinitions();

    for (final badge in badges) {
      await _firestore
          .collection('badgeDefinitions')
          .doc(badge.id)
          .set(badge.toMap(), SetOptions(merge: true));
    }
  }

  /// Get all badge definitions
  List<BadgeDefinition> _getAllBadgeDefinitions() {
    return [
      // ==================== ACTIVITY BADGES ====================
      BadgeDefinition(
        id: 'first_step',
        category: 'activity',
        title: 'İlk Adım',
        description: 'İlk aktiviteni kaydet',
        icon: '🚶',
        tier: 1,
        condition: BadgeCondition(
          type: 'total_activities',
          targetValue: 1,
        ),
      ),
      BadgeDefinition(
        id: '5km_walker',
        category: 'activity',
        title: '5km Yürüyüşçü',
        description: 'Toplam 5 km mesafe kat et',
        icon: '🏃',
        tier: 1,
        condition: BadgeCondition(
          type: 'total_distance',
          targetValue: 5,
        ),
      ),
      BadgeDefinition(
        id: '10km_runner',
        category: 'activity',
        title: '10km Koşucu',
        description: 'Toplam 10 km mesafe kat et',
        icon: '🏃‍♂️',
        tier: 2,
        condition: BadgeCondition(
          type: 'total_distance',
          targetValue: 10,
        ),
      ),
      BadgeDefinition(
        id: 'marathon_cyclist',
        category: 'activity',
        title: 'Maraton Bisikletçi',
        description: 'Toplam 42 km mesafe kat et',
        icon: '🚴',
        tier: 2,
        condition: BadgeCondition(
          type: 'total_distance',
          targetValue: 42,
        ),
      ),
      BadgeDefinition(
        id: '100km_master',
        category: 'activity',
        title: '100km Ustası',
        description: 'Toplam 100 km mesafe kat et',
        icon: '🏆',
        tier: 3,
        condition: BadgeCondition(
          type: 'total_distance',
          targetValue: 100,
        ),
      ),
      BadgeDefinition(
        id: '500km_legend',
        category: 'activity',
        title: '500km Efsanesi',
        description: 'Toplam 500 km mesafe kat et',
        icon: '💎',
        tier: 4,
        condition: BadgeCondition(
          type: 'total_distance',
          targetValue: 500,
        ),
      ),
      BadgeDefinition(
        id: 'beginner',
        category: 'activity',
        title: 'Başlangıç',
        description: '10 aktivite kaydet',
        icon: '📊',
        tier: 1,
        condition: BadgeCondition(
          type: 'total_activities',
          targetValue: 10,
        ),
      ),
      BadgeDefinition(
        id: 'regular_athlete',
        category: 'activity',
        title: 'Düzenli Sporcu',
        description: '50 aktivite kaydet',
        icon: '📈',
        tier: 2,
        condition: BadgeCondition(
          type: 'total_activities',
          targetValue: 50,
        ),
      ),
      BadgeDefinition(
        id: 'sports_addict',
        category: 'activity',
        title: 'Spor Bağımlısı',
        description: '100 aktivite kaydet',
        icon: '🎯',
        tier: 3,
        condition: BadgeCondition(
          type: 'total_activities',
          targetValue: 100,
        ),
      ),

      // ==================== WATER GOAL BADGES ====================
      BadgeDefinition(
        id: 'water_drinker',
        category: 'health',
        title: 'Su İçici',
        description: '7 gün su hedefine ulaş',
        icon: '💧',
        tier: 1,
        condition: BadgeCondition(
          type: 'water_goal_days',
          targetValue: 7,
        ),
      ),
      BadgeDefinition(
        id: 'water_champion',
        category: 'health',
        title: 'Su Şampiyonu',
        description: '30 gün su hedefine ulaş',
        icon: '💦',
        tier: 2,
        condition: BadgeCondition(
          type: 'water_goal_days',
          targetValue: 30,
        ),
      ),
      BadgeDefinition(
        id: 'hydration_king',
        category: 'health',
        title: 'Hidrasyon Kralı',
        description: '100 gün su hedefine ulaş',
        icon: '🌊',
        tier: 3,
        condition: BadgeCondition(
          type: 'water_goal_days',
          targetValue: 100,
        ),
      ),

      // ==================== SLEEP GOAL BADGES ====================
      BadgeDefinition(
        id: 'good_sleeper',
        category: 'health',
        title: 'İyi Uyuyan',
        description: '7 gün uyku hedefine ulaş',
        icon: '😴',
        tier: 1,
        condition: BadgeCondition(
          type: 'sleep_goal_days',
          targetValue: 7,
        ),
      ),
      BadgeDefinition(
        id: 'sleep_expert',
        category: 'health',
        title: 'Uyku Uzmanı',
        description: '30 gün uyku hedefine ulaş',
        icon: '🛌',
        tier: 2,
        condition: BadgeCondition(
          type: 'sleep_goal_days',
          targetValue: 30,
        ),
      ),
      BadgeDefinition(
        id: 'dream_king',
        category: 'health',
        title: 'Rüya Kralı',
        description: '100 gün uyku hedefine ulaş',
        icon: '🌙',
        tier: 3,
        condition: BadgeCondition(
          type: 'sleep_goal_days',
          targetValue: 100,
        ),
      ),

      // ==================== STEPS GOAL BADGES ====================
      BadgeDefinition(
        id: 'step_taker',
        category: 'health',
        title: 'Adım Atan',
        description: '7 gün adım hedefine ulaş',
        icon: '👟',
        tier: 1,
        condition: BadgeCondition(
          type: 'steps_goal_days',
          targetValue: 7,
        ),
      ),
      BadgeDefinition(
        id: 'walking_lover',
        category: 'health',
        title: 'Yürüyüş Sevdalısı',
        description: '30 gün adım hedefine ulaş',
        icon: '🚶‍♀️',
        tier: 2,
        condition: BadgeCondition(
          type: 'steps_goal_days',
          targetValue: 30,
        ),
      ),
      BadgeDefinition(
        id: 'step_legend',
        category: 'health',
        title: 'Adım Efsanesi',
        description: '100 gün adım hedefine ulaş',
        icon: '🏃',
        tier: 3,
        condition: BadgeCondition(
          type: 'steps_goal_days',
          targetValue: 100,
        ),
      ),

      // ==================== STREAK BADGES ====================
      BadgeDefinition(
        id: 'streak_3_days',
        category: 'streak',
        title: '3 Gün Serisi',
        description: '3 gün üst üste aktif ol',
        icon: '🔥',
        tier: 1,
        condition: BadgeCondition(
          type: 'daily_streak',
          targetValue: 3,
        ),
      ),
      BadgeDefinition(
        id: 'week_warrior',
        category: 'streak',
        title: 'Bir Hafta Savaşçısı',
        description: '7 gün üst üste aktif ol',
        icon: '🔥🔥',
        tier: 2,
        condition: BadgeCondition(
          type: 'daily_streak',
          targetValue: 7,
        ),
      ),
      BadgeDefinition(
        id: 'month_master',
        category: 'streak',
        title: 'Ay Ustası',
        description: '30 gün üst üste aktif ol',
        icon: '🔥🔥🔥',
        tier: 3,
        condition: BadgeCondition(
          type: 'daily_streak',
          targetValue: 30,
        ),
      ),
      BadgeDefinition(
        id: 'determined',
        category: 'streak',
        title: 'Kararlı',
        description: '50 gün üst üste aktif ol',
        icon: '⚡',
        tier: 3,
        condition: BadgeCondition(
          type: 'daily_streak',
          targetValue: 50,
        ),
      ),
      BadgeDefinition(
        id: '100_day_iron',
        category: 'streak',
        title: '100 Gün Demiri',
        description: '100 gün üst üste aktif ol',
        icon: '💪',
        tier: 4,
        condition: BadgeCondition(
          type: 'daily_streak',
          targetValue: 100,
        ),
      ),
      BadgeDefinition(
        id: 'year_hero',
        category: 'streak',
        title: 'Yılın Kahramanı',
        description: '365 gün üst üste aktif ol',
        icon: '👑',
        tier: 4,
        condition: BadgeCondition(
          type: 'daily_streak',
          targetValue: 365,
        ),
      ),

      // ==================== GOAL COMPLETION BADGES ====================
      BadgeDefinition(
        id: 'first_goal',
        category: 'goal',
        title: 'İlk Hedef',
        description: 'Tüm günlük hedefleri bir kez tamamla',
        icon: '✅',
        tier: 1,
        condition: BadgeCondition(
          type: 'perfect_days',
          targetValue: 1,
        ),
      ),
      BadgeDefinition(
        id: 'goal_hunter',
        category: 'goal',
        title: 'Hedef Avcısı',
        description: '7 gün tüm hedefleri tamamla',
        icon: '🎯',
        tier: 2,
        condition: BadgeCondition(
          type: 'perfect_days',
          targetValue: 7,
        ),
      ),
      BadgeDefinition(
        id: 'perfectionist',
        category: 'goal',
        title: 'Mükemmeliyetçi',
        description: '30 gün tüm hedefleri tamamla',
        icon: '🏆',
        tier: 3,
        condition: BadgeCondition(
          type: 'perfect_days',
          targetValue: 30,
        ),
      ),
      BadgeDefinition(
        id: 'full_performance',
        category: 'goal',
        title: 'Tam Performans',
        description: '100 gün tüm hedefleri tamamla',
        icon: '💯',
        tier: 4,
        condition: BadgeCondition(
          type: 'perfect_days',
          targetValue: 100,
        ),
      ),

      // ==================== SPECIAL BADGES ====================
      BadgeDefinition(
        id: 'early_bird',
        category: 'special',
        title: 'Erken Kuş',
        description: '5 kez sabah 7\'den önce aktivite yap',
        icon: '🌅',
        tier: 2,
        condition: BadgeCondition(
          type: 'early_bird_activities',
          targetValue: 5,
        ),
      ),
      BadgeDefinition(
        id: 'night_warrior',
        category: 'special',
        title: 'Gece Savaşçısı',
        description: '5 kez akşam 21\'den sonra aktivite yap',
        icon: '🌃',
        tier: 2,
        condition: BadgeCondition(
          type: 'weekend_activities',
          targetValue: 5,
        ),
      ),
      BadgeDefinition(
        id: 'weekend_warrior',
        category: 'special',
        title: 'Hafta Sonu Savaşçısı',
        description: '10 hafta sonu aktivitesi yap',
        icon: '🎉',
        tier: 2,
        condition: BadgeCondition(
          type: 'weekend_activities',
          targetValue: 10,
        ),
      ),
      BadgeDefinition(
        id: 'data_scientist',
        category: 'special',
        title: 'Veri Bilimci',
        description: '30 sağlık kaydı gir',
        icon: '📊',
        tier: 2,
        condition: BadgeCondition(
          type: 'health_records',
          targetValue: 30,
        ),
      ),
    ];
  }

  /// Get badges by category
  Future<List<BadgeDefinition>> getBadgesByCategory(String category) async {
    final snapshot = await _firestore
        .collection('badgeDefinitions')
        .where('category', isEqualTo: category)
        .get();

    return snapshot.docs
        .map((doc) => BadgeDefinition.fromMap(doc.data()))
        .toList();
  }

  /// Get all badge definitions from Firestore
  Future<List<BadgeDefinition>> getAllBadges() async {
    final snapshot = await _firestore.collection('badgeDefinitions').get();
    return snapshot.docs
        .map((doc) => BadgeDefinition.fromMap(doc.data()))
        .toList();
  }
}
