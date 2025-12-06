import '../../../models/daily_metric_model.dart';
import '../../../models/user_model.dart';
import '../../../services/firestore_service.dart';
import '../../../services/batch_ml_service.dart';
import '../models/daily_report_model.dart';
import '../models/weekly_report_model.dart';
import '../models/monthly_report_model.dart';
import '../../../config/app_constants.dart';

class ReportAnalysisService {
  final FirestoreService _firestoreService = FirestoreService();
  final BatchMLService _batchMLService = BatchMLService();

  /// Günlük rapor oluştur
  Future<DailyReportModel> generateDailyReport({
    required String userId,
    required UserModel userProfile,
  }) async {
    final today = DateTime.now();

    // Bugünün verisi
    final todayMetric = await _firestoreService.getTodayMetric(userId);

    // Dünün verisi (karşılaştırma için)
    final yesterdayMetrics =
        await _firestoreService.getDailyMetricsHistory(userId, days: 2);

    DailyMetricModel? yesterdayMetric;
    if (yesterdayMetrics.length >= 2) {
      yesterdayMetric = yesterdayMetrics[0];
    }

    // Son 1 günün sağlık kayıtları
    final healthRecords =
        await _firestoreService.getHealthRecords(userId, limit: 5);
    final todayHealthRecords = healthRecords
        .where((r) =>
            r.date.year == today.year &&
            r.date.month == today.month &&
            r.date.day == today.day)
        .toList();

    // ML analizi yap
    final mlResult = await _batchMLService.analyzePeriod(
      userId: userId,
      userProfile: userProfile,
      dailyMetrics: todayMetric != null ? [todayMetric] : [],
      healthRecords: todayHealthRecords,
    );

    // Dünle karşılaştırma hesapla
    double? stepsChange, waterChange, calorieChange, sleepChange;
    if (todayMetric != null && yesterdayMetric != null) {
      stepsChange = _calculatePercentageChange(
          yesterdayMetric.steps.toDouble(), todayMetric.steps.toDouble());
      waterChange = _calculatePercentageChange(
          yesterdayMetric.waterIntake, todayMetric.waterIntake);
      calorieChange = _calculatePercentageChange(
          yesterdayMetric.calorieEstimate.toDouble(),
          todayMetric.calorieEstimate.toDouble());
      sleepChange = _calculatePercentageChange(
          yesterdayMetric.sleepQuality.toDouble(),
          todayMetric.sleepQuality.toDouble());
    }

    // Hedef başarı oranı hesapla
    double goalAchievement = 0.0;
    if (todayMetric != null) {
      goalAchievement = todayMetric.overallProgress;
    }

    // Öneriler oluştur
    final recommendations = _generateDailyRecommendations(
      metric: todayMetric,
      mlResult: mlResult,
    );

    return DailyReportModel(
      userId: userId,
      date: today,
      lastUpdated: DateTime.now(),
      steps: todayMetric?.steps ?? 0,
      waterIntake: todayMetric?.waterIntake ?? 0.0,
      calorieEstimate: todayMetric?.calorieEstimate ?? 0,
      sleepQuality: todayMetric?.sleepQuality ?? 0,
      avgBloodGlucose: mlResult.avgHealthData.avgBloodGlucose,
      avgSystolicBP: mlResult.avgHealthData.avgSystolicBP,
      avgDiastolicBP: mlResult.avgHealthData.avgDiastolicBP,
      avgHeartRate: mlResult.avgHealthData.avgHeartRate,
      avgTemperature: mlResult.avgHealthData.avgTemperature,
      diabetesRisk: mlResult.diabetesRisk,
      highSugarRisk: mlResult.highSugarRisk,
      obesityRisk: mlResult.obesityRisk,
      cancerRisk: mlResult.cancerRisk,
      highCholesterolRisk: mlResult.highCholesterolRisk,
      lowActivityRisk: mlResult.lowActivityRisk,
      stepsChange: stepsChange,
      waterChange: waterChange,
      calorieChange: calorieChange,
      sleepQualityChange: sleepChange,
      dailyGoalAchievement: goalAchievement,
      recommendations: recommendations,
    );
  }

  /// Haftalık rapor oluştur
  Future<WeeklyReportModel> generateWeeklyReport({
    required String userId,
    required UserModel userProfile,
  }) async {
    final now = DateTime.now();
    final weekEnd = DateTime(now.year, now.month, now.day);
    final weekStart = weekEnd.subtract(const Duration(days: 6));

    // Son 7 günün verileri
    final weekMetrics =
        await _firestoreService.getDailyMetricsHistory(userId, days: 7);

    // Önceki haftanın verileri (karşılaştırma için)
    final previousWeekMetrics =
        await _firestoreService.getDailyMetricsHistory(userId, days: 14);
    final previousWeek = previousWeekMetrics.length > 7
        ? previousWeekMetrics.sublist(0, 7)
        : <DailyMetricModel>[];

    // Son 7 günün sağlık kayıtları
    final healthRecords =
        await _firestoreService.getHealthRecords(userId, limit: 50);
    final weekHealthRecords = healthRecords
        .where((r) => r.date.isAfter(weekStart.subtract(const Duration(days: 1))))
        .toList();

    // ML analizi yap
    final mlResult = await _batchMLService.analyzePeriod(
      userId: userId,
      userProfile: userProfile,
      dailyMetrics: weekMetrics,
      healthRecords: weekHealthRecords,
    );

    // Ortalamalar
    final avgMetrics = mlResult.avgMetrics;

    // Önceki hafta ortalamalar
    AverageMetrics? prevWeekAvg;
    if (previousWeek.isNotEmpty) {
      final prevResult = await _batchMLService.analyzePeriod(
        userId: userId,
        userProfile: userProfile,
        dailyMetrics: previousWeek,
        healthRecords: [],
      );
      prevWeekAvg = prevResult.avgMetrics;
    }

    // Önceki haftayla karşılaştırma
    double? stepsChange, waterChange, caloriesChange, sleepChange;
    if (prevWeekAvg != null) {
      stepsChange = _calculatePercentageChange(
          prevWeekAvg.avgSteps, avgMetrics.avgSteps);
      waterChange = _calculatePercentageChange(
          prevWeekAvg.avgWater, avgMetrics.avgWater);
      caloriesChange = _calculatePercentageChange(
          prevWeekAvg.avgCalories, avgMetrics.avgCalories);
      sleepChange = _calculatePercentageChange(
          prevWeekAvg.avgSleepQuality, avgMetrics.avgSleepQuality);
    }

    // Hedef başarı metrikleri
    int daysGoalAchieved = 0;
    DateTime? bestDay;
    int? bestDaySteps = 0;

    for (var metric in weekMetrics) {
      if (metric.overallProgress >= 0.8) {
        daysGoalAchieved++;
      }
      if (metric.steps > (bestDaySteps ?? 0)) {
        bestDaySteps = metric.steps;
        bestDay = metric.date;
      }
    }

    final weeklyGoalAchievement =
        weekMetrics.isNotEmpty ? (daysGoalAchieved / weekMetrics.length) : 0.0;

    // Trend analizi
    final stepsTrend = _analyzeTrend(weekMetrics.map((m) => m.steps.toDouble()).toList());
    final waterTrend = _analyzeTrend(weekMetrics.map((m) => m.waterIntake).toList());
    final sleepTrend = _analyzeTrend(weekMetrics.map((m) => m.sleepQuality.toDouble()).toList());

    // Günlük veriler (grafik için)
    final dailyData = weekMetrics
        .map((m) => DailyData(
              date: m.date,
              steps: m.steps,
              waterIntake: m.waterIntake,
              calories: m.calorieEstimate,
              sleepQuality: m.sleepQuality,
            ))
        .toList();

    // Öneriler
    final recommendations = _generateWeeklyRecommendations(
      avgMetrics: avgMetrics,
      mlResult: mlResult,
      stepsTrend: stepsTrend,
      waterTrend: waterTrend,
    );

    return WeeklyReportModel(
      userId: userId,
      weekStartDate: weekStart,
      weekEndDate: weekEnd,
      lastUpdated: DateTime.now(),
      avgSteps: avgMetrics.avgSteps,
      avgWaterIntake: avgMetrics.avgWater,
      avgCalories: avgMetrics.avgCalories,
      avgSleepQuality: avgMetrics.avgSleepQuality,
      avgBloodGlucose: mlResult.avgHealthData.avgBloodGlucose,
      avgSystolicBP: mlResult.avgHealthData.avgSystolicBP,
      avgDiastolicBP: mlResult.avgHealthData.avgDiastolicBP,
      avgHeartRate: mlResult.avgHealthData.avgHeartRate,
      avgTemperature: mlResult.avgHealthData.avgTemperature,
      diabetesRisk: mlResult.diabetesRisk,
      highSugarRisk: mlResult.highSugarRisk,
      obesityRisk: mlResult.obesityRisk,
      cancerRisk: mlResult.cancerRisk,
      highCholesterolRisk: mlResult.highCholesterolRisk,
      lowActivityRisk: mlResult.lowActivityRisk,
      stepsChangeVsPreviousWeek: stepsChange,
      waterChangeVsPreviousWeek: waterChange,
      caloriesChangeVsPreviousWeek: caloriesChange,
      sleepChangeVsPreviousWeek: sleepChange,
      daysGoalAchieved: daysGoalAchieved,
      weeklyGoalAchievement: weeklyGoalAchievement,
      bestDay: bestDay,
      bestDaySteps: bestDaySteps,
      stepsTrend: stepsTrend,
      waterTrend: waterTrend,
      sleepTrend: sleepTrend,
      overallHealthTrend: stepsTrend == 'improving' ? 'improving' : 'stable',
      recommendations: recommendations,
      dailyData: dailyData,
    );
  }

  /// Aylık rapor oluştur
  Future<MonthlyReportModel> generateMonthlyReport({
    required String userId,
    required UserModel userProfile,
  }) async {
    final now = DateTime.now();
    final monthEnd = DateTime(now.year, now.month, now.day);
    final monthStart = monthEnd.subtract(const Duration(days: 29));

    // Son 30 günün verileri
    final monthMetrics =
        await _firestoreService.getDailyMetricsHistory(userId, days: 30);

    // Önceki ayın verileri
    final previousMonthMetrics =
        await _firestoreService.getDailyMetricsHistory(userId, days: 60);
    final previousMonth = previousMonthMetrics.length > 30
        ? previousMonthMetrics.sublist(0, 30)
        : <DailyMetricModel>[];

    // Sağlık kayıtları
    final healthRecords =
        await _firestoreService.getHealthRecords(userId, limit: 100);
    final monthHealthRecords = healthRecords
        .where((r) => r.date.isAfter(monthStart.subtract(const Duration(days: 1))))
        .toList();

    // ML analizi
    final mlResult = await _batchMLService.analyzePeriod(
      userId: userId,
      userProfile: userProfile,
      dailyMetrics: monthMetrics,
      healthRecords: monthHealthRecords,
    );

    final avgMetrics = mlResult.avgMetrics;

    // Önceki ay karşılaştırması
    AverageMetrics? prevMonthAvg;
    BatchMLResult? prevMonthML;
    if (previousMonth.isNotEmpty) {
      prevMonthML = await _batchMLService.analyzePeriod(
        userId: userId,
        userProfile: userProfile,
        dailyMetrics: previousMonth,
        healthRecords: [],
      );
      prevMonthAvg = prevMonthML.avgMetrics;
    }

    double? stepsChange, waterChange, caloriesChange, sleepChange;
    if (prevMonthAvg != null) {
      stepsChange = _calculatePercentageChange(
          prevMonthAvg.avgSteps, avgMetrics.avgSteps);
      waterChange = _calculatePercentageChange(
          prevMonthAvg.avgWater, avgMetrics.avgWater);
      caloriesChange = _calculatePercentageChange(
          prevMonthAvg.avgCalories, avgMetrics.avgCalories);
      sleepChange = _calculatePercentageChange(
          prevMonthAvg.avgSleepQuality, avgMetrics.avgSleepQuality);
    }

    // Risk değişimleri
    double? diabetesRiskChange, heartRiskChange, obesityRiskChange;
    if (prevMonthML != null) {
      diabetesRiskChange = (mlResult.diabetesRisk ?? 0) -
          (prevMonthML.diabetesRisk ?? 0);
      heartRiskChange = (mlResult.highSugarRisk ?? 0) -
          (prevMonthML.highSugarRisk ?? 0);
      obesityRiskChange = (mlResult.obesityRisk ?? 0) -
          (prevMonthML.obesityRisk ?? 0);
    }

    // Başarı metrikleri
    int daysGoalAchieved = 0;
    DateTime? bestDay, worstDay;
    int? bestDaySteps = 0, worstDaySteps = 999999;

    for (var metric in monthMetrics) {
      if (metric.overallProgress >= 0.8) {
        daysGoalAchieved++;
      }
      if (metric.steps > (bestDaySteps ?? 0)) {
        bestDaySteps = metric.steps;
        bestDay = metric.date;
      }
      if (metric.steps < (worstDaySteps ?? 999999) && metric.steps > 0) {
        worstDaySteps = metric.steps;
        worstDay = metric.date;
      }
    }

    // Trend analizi
    final stepsTrend = _analyzeTrend(monthMetrics.map((m) => m.steps.toDouble()).toList());
    final waterTrend = _analyzeTrend(monthMetrics.map((m) => m.waterIntake).toList());
    final sleepTrend = _analyzeTrend(monthMetrics.map((m) => m.sleepQuality.toDouble()).toList());

    String riskTrend = 'stable';
    if (diabetesRiskChange != null && diabetesRiskChange < -0.05) {
      riskTrend = 'improving';
    } else if (diabetesRiskChange != null && diabetesRiskChange > 0.05) {
      riskTrend = 'declining';
    }

    // Haftalık breakdown
    final weeklyData = _calculateWeeklyBreakdown(monthMetrics);

    // Başarı rozetleri
    final achievements = _generateAchievements(monthMetrics, mlResult);

    // Öneriler
    final recommendations = _generateMonthlyRecommendations(
      avgMetrics: avgMetrics,
      mlResult: mlResult,
      trends: {
        'steps': stepsTrend,
        'water': waterTrend,
        'sleep': sleepTrend,
      },
    );

    return MonthlyReportModel(
      userId: userId,
      monthStartDate: monthStart,
      monthEndDate: monthEnd,
      lastUpdated: DateTime.now(),
      avgSteps: avgMetrics.avgSteps,
      avgWaterIntake: avgMetrics.avgWater,
      avgCalories: avgMetrics.avgCalories,
      avgSleepQuality: avgMetrics.avgSleepQuality,
      totalSteps: avgMetrics.totalSteps,
      totalWaterIntake: avgMetrics.totalWater,
      totalCalories: avgMetrics.totalCalories,
      avgBloodGlucose: mlResult.avgHealthData.avgBloodGlucose,
      avgSystolicBP: mlResult.avgHealthData.avgSystolicBP,
      avgDiastolicBP: mlResult.avgHealthData.avgDiastolicBP,
      avgHeartRate: mlResult.avgHealthData.avgHeartRate,
      avgTemperature: mlResult.avgHealthData.avgTemperature,
      diabetesRisk: mlResult.diabetesRisk,
      highSugarRisk: mlResult.highSugarRisk,
      obesityRisk: mlResult.obesityRisk,
      cancerRisk: mlResult.cancerRisk,
      highCholesterolRisk: mlResult.highCholesterolRisk,
      lowActivityRisk: mlResult.lowActivityRisk,
      stepsChangeVsPreviousMonth: stepsChange,
      waterChangeVsPreviousMonth: waterChange,
      caloriesChangeVsPreviousMonth: caloriesChange,
      sleepChangeVsPreviousMonth: sleepChange,
      diabetesRiskChange: diabetesRiskChange,
      highSugarRiskChange: heartRiskChange,
      obesityRiskChange: obesityRiskChange,
      totalDays: 30,
      daysGoalAchieved: daysGoalAchieved,
      monthlyGoalAchievement: monthMetrics.isNotEmpty
          ? (daysGoalAchieved / monthMetrics.length)
          : 0.0,
      bestDay: bestDay,
      bestDaySteps: bestDaySteps,
      worstDay: worstDay,
      worstDaySteps: worstDaySteps == 999999 ? null : worstDaySteps,
      stepsTrend: stepsTrend,
      waterTrend: waterTrend,
      sleepTrend: sleepTrend,
      overallHealthTrend: stepsTrend == 'improving' ? 'improving' : 'stable',
      riskTrend: riskTrend,
      achievements: achievements,
      recommendations: recommendations,
      nextMonthGoals: _generateNextMonthGoals(avgMetrics: avgMetrics, mlResult: mlResult),
      weeklyData: weeklyData,
    );
  }

  // Helper methods

  double _calculatePercentageChange(double oldValue, double newValue) {
    if (oldValue == 0) return 0.0;
    return ((newValue - oldValue) / oldValue) * 100;
  }

  String _analyzeTrend(List<double> values) {
    if (values.length < 3) return 'stable';

    // Basit trend analizi: ilk yarı vs ikinci yarı
    final mid = values.length ~/ 2;
    final firstHalf = values.sublist(0, mid);
    final secondHalf = values.sublist(mid);

    final firstAvg = firstHalf.reduce((a, b) => a + b) / firstHalf.length;
    final secondAvg = secondHalf.reduce((a, b) => a + b) / secondHalf.length;

    final change = ((secondAvg - firstAvg) / firstAvg) * 100;

    if (change > 10) return 'improving';
    if (change < -10) return 'declining';
    return 'stable';
  }

  List<String> _generateDailyRecommendations({
    DailyMetricModel? metric,
    required BatchMLResult mlResult,
  }) {
    final List<String> recommendations = [];

    if (metric == null) {
      recommendations.add('Bugün henüz veri girmediniz. Günlük takibinizi başlatın!');
      return recommendations;
    }

    // Su tüketimi
    if (metric.waterIntake < AppConstants.defaultWaterGoal * 0.8) {
      final remaining = AppConstants.defaultWaterGoal - metric.waterIntake;
      recommendations.add('Su tüketiminizi ${remaining.toStringAsFixed(1)}L artırın');
    }

    // Adım sayısı
    if (metric.steps < AppConstants.defaultStepsGoal * 0.8) {
      final remaining = AppConstants.defaultStepsGoal - metric.steps;
      recommendations.add('Hedefe ulaşmak için $remaining adım daha atın');
    }

    // ML risk uyarıları
    if ((mlResult.diabetesRisk ?? 0) > 0.5) {
      recommendations.add('Diyabet riskiniz yüksek. Kan şekerinizi düzenli takip edin');
    }

    if ((mlResult.lowActivityRisk ?? 0) > 0.5) {
      recommendations.add('Aktivite seviyenizi artırın. Günlük 30 dakika yürüyüş önerilir');
    }

    return recommendations;
  }

  List<String> _generateWeeklyRecommendations({
    required AverageMetrics avgMetrics,
    required BatchMLResult mlResult,
    required String stepsTrend,
    required String waterTrend,
  }) {
    final List<String> recommendations = [];

    if (stepsTrend == 'declining') {
      recommendations.add('Adım sayınız düşüşte. Haftalık hedef: 10% artış');
    } else if (stepsTrend == 'improving') {
      recommendations.add('Harika! Aktivite seviyeniz artıyor. Devam edin!');
    }

    if (waterTrend == 'declining') {
      recommendations.add('Su tüketiminiz azaldı. Günlük ${AppConstants.defaultWaterGoal}L hedefleyin');
    }

    if ((mlResult.diabetesRisk ?? 0) > 0.3) {
      recommendations.add('Haftalık kan şekeri ortalamanız yüksek. Doktor kontrolü önerilir');
    }

    return recommendations;
  }

  List<String> _generateMonthlyRecommendations({
    required AverageMetrics avgMetrics,
    required BatchMLResult mlResult,
    required Map<String, String> trends,
  }) {
    final List<String> recommendations = [];

    if (avgMetrics.avgSteps < 7000) {
      recommendations.add('Aylık ortalama adımınız düşük. 8000+ hedefleyin');
    }

    if (trends['steps'] == 'improving') {
      recommendations.add('Bu ayki gelişiminiz mükemmel! Hedeflerinizi yükseltin');
    }

    if ((mlResult.diabetesRisk ?? 0) > 0.4) {
      recommendations.add('Uzun vadeli diyabet riskiniz orta-yüksek. Yaşam tarzı değişikliği önerilir');
    }

    return recommendations;
  }

  List<String> _generateNextMonthGoals({
    required AverageMetrics avgMetrics,
    required BatchMLResult mlResult,
  }) {
    final List<String> goals = [];

    goals.add('Günlük ortalama ${(avgMetrics.avgSteps * 1.1).round()} adıma ulaş');
    goals.add('Su tüketimini ${(AppConstants.defaultWaterGoal).toStringAsFixed(1)}L/gün yap');
    goals.add('Ayda en az 25 gün hedeflere ulaş');

    return goals;
  }

  List<WeeklyData> _calculateWeeklyBreakdown(List<DailyMetricModel> monthMetrics) {
    final List<WeeklyData> weeklyData = [];

    for (int week = 0; week < 4; week++) {
      final weekStart = week * 7;
      final weekEnd = (week + 1) * 7;

      if (weekStart >= monthMetrics.length) break;

      final weekMetrics = monthMetrics.sublist(
        weekStart,
        weekEnd > monthMetrics.length ? monthMetrics.length : weekEnd,
      );

      if (weekMetrics.isEmpty) continue;

      final avgSteps =
          weekMetrics.map((m) => m.steps).reduce((a, b) => a + b) /
              weekMetrics.length;
      final avgWater =
          weekMetrics.map((m) => m.waterIntake).reduce((a, b) => a + b) /
              weekMetrics.length;
      final avgCalories =
          weekMetrics.map((m) => m.calorieEstimate).reduce((a, b) => a + b) /
              weekMetrics.length;

      weeklyData.add(WeeklyData(
        weekNumber: week + 1,
        avgSteps: avgSteps,
        avgWater: avgWater,
        avgCalories: avgCalories,
      ));
    }

    return weeklyData;
  }

  List<Achievement> _generateAchievements(
      List<DailyMetricModel> metrics, BatchMLResult mlResult) {
    final List<Achievement> achievements = [];

    // 7 gün üst üste hedef
    int consecutiveDays = 0;
    int maxConsecutive = 0;
    for (var metric in metrics) {
      if (metric.overallProgress >= 0.8) {
        consecutiveDays++;
        if (consecutiveDays > maxConsecutive) maxConsecutive = consecutiveDays;
      } else {
        consecutiveDays = 0;
      }
    }

    if (maxConsecutive >= 7) {
      achievements.add(Achievement(
        id: 'consecutive_7',
        title: '7 Gün Seri',
        description: 'Üst üste 7 gün hedefe ulaştınız!',
        icon: '🔥',
        earnedDate: DateTime.now(),
      ));
    }

    // 20+ gün hedef
    final totalGoalDays = metrics.where((m) => m.overallProgress >= 0.8).length;
    if (totalGoalDays >= 20) {
      achievements.add(Achievement(
        id: 'total_20',
        title: 'Aylık Şampiyon',
        description: 'Ayda 20+ gün hedefe ulaştınız!',
        icon: '🏆',
        earnedDate: DateTime.now(),
      ));
    }

    // Risk azaltma
    if ((mlResult.diabetesRisk ?? 1.0) < 0.3) {
      achievements.add(Achievement(
        id: 'low_diabetes_risk',
        title: 'Sağlıklı Yaşam',
        description: 'Diyabet riskiniz düşük seviyede!',
        icon: '💚',
        earnedDate: DateTime.now(),
      ));
    }

    return achievements;
  }
}
