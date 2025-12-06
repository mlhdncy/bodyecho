import '../models/daily_metric_model.dart';
import '../models/health_record_model.dart';
import '../models/user_model.dart';
import 'ml_service.dart';
import '../models/ml_prediction_model.dart';

class BatchMLService {
  final MlService _mlService = MlService();

  /// Batch ML analizi - Kullanıcının son N günlük verileriyle ML tahmin yapar
  Future<BatchMLResult> analyzePeriod({
    required String userId,
    required UserModel userProfile,
    required List<DailyMetricModel> dailyMetrics,
    required List<HealthRecordModel> healthRecords,
  }) async {
    // Eğer veri yoksa boş sonuç döndür
    if (dailyMetrics.isEmpty) {
      return BatchMLResult(
        mlResponse: null,
        avgMetrics: AverageMetrics.empty(),
        avgHealthData: AverageHealthData.empty(),
      );
    }

    // 1. Ortalama metrikleri hesapla
    final avgMetrics = _calculateAverageMetrics(dailyMetrics);

    // 2. Ortalama sağlık verilerini hesapla
    final avgHealthData = _calculateAverageHealthData(healthRecords);

    // 3. ML servisine gönderilecek parametreleri hazırla
    final mlParams = _prepareMlParams(
      userProfile: userProfile,
      avgMetrics: avgMetrics,
      avgHealthData: avgHealthData,
    );

    // 4. ML tahmin servisi çağır
    MlResponse? mlResponse;
    try {
      mlResponse = await _mlService.getPredictions(
        age: mlParams['age'],
        bmi: mlParams['bmi'],
        bloodGlucoseLevel: mlParams['bloodGlucoseLevel'],
        active: mlParams['active'],
        gender: mlParams['gender'],
        hypertension: mlParams['hypertension'],
        heartDisease: mlParams['heartDisease'],
        smokingHistory: mlParams['smokingHistory'],
        hbA1cLevel: mlParams['hbA1cLevel'],
        calories: mlParams['calories'],
        sodium: mlParams['sodium'],
        cholesterol: mlParams['cholesterol'],
        waterIntake: mlParams['waterIntake'],
      );
    } catch (e) {
      print('Batch ML error: $e');
      mlResponse = null;
    }

    return BatchMLResult(
      mlResponse: mlResponse,
      avgMetrics: avgMetrics,
      avgHealthData: avgHealthData,
    );
  }

  /// Ortalama günlük metrikleri hesapla
  AverageMetrics _calculateAverageMetrics(List<DailyMetricModel> metrics) {
    if (metrics.isEmpty) return AverageMetrics.empty();

    int totalSteps = 0;
    double totalWater = 0.0;
    int totalCalories = 0;
    int totalSleep = 0;

    for (var metric in metrics) {
      totalSteps += metric.steps;
      totalWater += metric.waterIntake;
      totalCalories += metric.calorieEstimate;
      totalSleep += metric.sleepQuality;
    }

    final count = metrics.length;

    return AverageMetrics(
      avgSteps: totalSteps / count,
      avgWater: totalWater / count,
      avgCalories: totalCalories / count,
      avgSleepQuality: totalSleep / count,
      totalSteps: totalSteps,
      totalWater: totalWater,
      totalCalories: totalCalories,
      daysWithData: count,
    );
  }

  /// Ortalama sağlık verilerini hesapla
  AverageHealthData _calculateAverageHealthData(
      List<HealthRecordModel> records) {
    if (records.isEmpty) return AverageHealthData.empty();

    double totalGlucose = 0;
    double totalSystolic = 0;
    double totalDiastolic = 0;
    double totalHeartRate = 0;
    double totalTemp = 0;

    int glucoseCount = 0;
    int bpCount = 0;
    int hrCount = 0;
    int tempCount = 0;

    for (var record in records) {
      if (record.bloodGlucoseLevel != null) {
        totalGlucose += record.bloodGlucoseLevel!.toDouble();
        glucoseCount++;
      }
      if (record.systolicBP != null && record.diastolicBP != null) {
        totalSystolic += record.systolicBP!.toDouble();
        totalDiastolic += record.diastolicBP!.toDouble();
        bpCount++;
      }
      if (record.heartRate != null) {
        totalHeartRate += record.heartRate!.toDouble();
        hrCount++;
      }
      if (record.temperature != null) {
        totalTemp += record.temperature!;
        tempCount++;
      }
    }

    return AverageHealthData(
      avgBloodGlucose: glucoseCount > 0 ? totalGlucose / glucoseCount : null,
      avgSystolicBP: bpCount > 0 ? totalSystolic / bpCount : null,
      avgDiastolicBP: bpCount > 0 ? totalDiastolic / bpCount : null,
      avgHeartRate: hrCount > 0 ? totalHeartRate / hrCount : null,
      avgTemperature: tempCount > 0 ? totalTemp / tempCount : null,
    );
  }

  /// ML servisine gönderilecek parametreleri hazırla
  Map<String, dynamic> _prepareMlParams({
    required UserModel userProfile,
    required AverageMetrics avgMetrics,
    required AverageHealthData avgHealthData,
  }) {
    // BMI hesapla
    final heightM = userProfile.height / 100;
    final bmi = userProfile.weight / (heightM * heightM);

    // Aktivite seviyesi: Low=0, Moderate=1, High=2
    int activeLevel = 0;
    if (userProfile.activityLevel == 'Moderate') {
      activeLevel = 1;
    } else if (userProfile.activityLevel == 'High') {
      activeLevel = 2;
    }

    return {
      'age': userProfile.age,
      'bmi': bmi,
      'bloodGlucoseLevel':
          avgHealthData.avgBloodGlucose?.round() ?? 100, // Default 100
      'active': activeLevel,
      'gender': userProfile.gender,
      'hypertension': (avgHealthData.avgSystolicBP != null &&
              avgHealthData.avgSystolicBP! > 140)
          ? 1
          : 0,
      'heartDisease': 0, // Bu veriyi profilde saklamıyoruz, default 0
      'smokingHistory': 'never', // Bu veriyi profilde saklamıyoruz
      'hbA1cLevel': 5.5, // Bu veriyi profilde saklamıyoruz
      'calories': avgMetrics.avgCalories.round(),
      'sodium': 2000, // Default değer
      'cholesterol': 150, // Default değer
      'waterIntake': (avgMetrics.avgWater * 1000).round(), // L -> ml
    };
  }
}

/// Batch ML analiz sonucu
class BatchMLResult {
  final MlResponse? mlResponse;
  final AverageMetrics avgMetrics;
  final AverageHealthData avgHealthData;

  BatchMLResult({
    required this.mlResponse,
    required this.avgMetrics,
    required this.avgHealthData,
  });

  /// ML risk skorlarını al
  double? get diabetesRisk =>
      mlResponse?.results['diabetes_risk']?.probability;
  double? get highSugarRisk => mlResponse?.results['high_sugar_risk']?.probability;
  double? get obesityRisk => mlResponse?.results['obesity_risk']?.probability;
  double? get cancerRisk => mlResponse?.results['cancer_risk']?.probability;
  double? get highCholesterolRisk =>
      mlResponse?.results['high_cholesterol_risk']?.probability;
  double? get lowActivityRisk =>
      mlResponse?.results['low_activity_risk']?.probability;
}

/// Ortalama günlük metrikler
class AverageMetrics {
  final double avgSteps;
  final double avgWater;
  final double avgCalories;
  final double avgSleepQuality;
  final int totalSteps;
  final double totalWater;
  final int totalCalories;
  final int daysWithData;

  AverageMetrics({
    required this.avgSteps,
    required this.avgWater,
    required this.avgCalories,
    required this.avgSleepQuality,
    required this.totalSteps,
    required this.totalWater,
    required this.totalCalories,
    required this.daysWithData,
  });

  factory AverageMetrics.empty() {
    return AverageMetrics(
      avgSteps: 0,
      avgWater: 0,
      avgCalories: 0,
      avgSleepQuality: 0,
      totalSteps: 0,
      totalWater: 0,
      totalCalories: 0,
      daysWithData: 0,
    );
  }
}

/// Ortalama sağlık verileri
class AverageHealthData {
  final double? avgBloodGlucose;
  final double? avgSystolicBP;
  final double? avgDiastolicBP;
  final double? avgHeartRate;
  final double? avgTemperature;

  AverageHealthData({
    this.avgBloodGlucose,
    this.avgSystolicBP,
    this.avgDiastolicBP,
    this.avgHeartRate,
    this.avgTemperature,
  });

  factory AverageHealthData.empty() {
    return AverageHealthData();
  }
}
