import '../models/user_model.dart';
import '../models/daily_metric_model.dart';
import '../models/health_record_model.dart';
import '../models/ml_prediction_model.dart';
import 'ml_service.dart';
import 'health_standards_service.dart';

class Insight {
  final String title;
  final String message;
  final String type; // 'risk', 'warning', 'info', 'success'
  final String category; // 'obesity', 'disease', 'lifestyle'
  final String? source; // 'WHO', 'T.C. Sağlık Bakanlığı', etc.
  final String? referenceUrl; // Kaynak URL

  Insight({
    required this.title,
    required this.message,
    required this.type,
    required this.category,
    this.source,
    this.referenceUrl,
  });
}

class InsightsService {
  final MlService _mlService = MlService();
  final HealthStandardsService _healthStandards = HealthStandardsService();

  // Level 1: Profil Bazlı Analiz (BMI & Obezite) - WHO Standartlarına göre
  Future<List<Insight>> analyzeProfile(UserModel user) async {
    final insights = <Insight>[];

    if (user.height != null && user.weight != null && user.height! > 0) {
      final heightInMeters = user.height! / 100;
      final bmi = user.weight! / (heightInMeters * heightInMeters);

      // WHO standartlarını kullanarak dinamik BMI değerlendirmesi
      try {
        final bmiAssessment = await _healthStandards.evaluateBmi(
          bmi,
          user.age ?? 30,
          user.gender ?? 'Male',
        );

        insights.add(Insight(
          title: 'Vücut Kitle İndeksi (BMI)',
          message: 'BMI değeriniz: ${bmi.toStringAsFixed(1)} (${bmiAssessment.description}). '
              '${bmiAssessment.recommendation}',
          type: bmiAssessment.insightType,
          category: 'obesity',
          source: bmiAssessment.source,
          referenceUrl: 'https://www.who.int/health-topics/obesity',
        ));
      } catch (e) {
        print('BMI değerlendirme hatası: $e');
        // Fallback to basic evaluation
        insights.add(Insight(
          title: 'Vücut Kitle İndeksi (BMI)',
          message: 'BMI değeriniz: ${bmi.toStringAsFixed(1)}. Detaylı değerlendirme için standartlar yükleniyor.',
          type: 'info',
          category: 'obesity',
        ));
      }
    } else {
      insights.add(Insight(
        title: 'Profilinizi Tamamlayın',
        message: 'Daha doğru analizler için lütfen boy ve kilo bilgilerinizi profilinize ekleyin.',
        type: 'info',
        category: 'obesity',
      ));
    }

    return insights;
  }

  // Level 2: İstatistiksel Hastalık Riski (ML Destekli)
  Future<List<Insight>> analyzeDiseaseRisks(UserModel user, HealthRecordModel? latestRecord) async {
    final insights = <Insight>[];
    
    // Yeterli veri yoksa analiz yapma
    if (latestRecord == null || latestRecord.bloodGlucoseLevel == null) {
      return insights;
    }

    // ML Servisine gönderilecek verileri hazırla
    // Eksik veriler için varsayılan değerler veya profil verileri kullanılır
    try {
      final mlResponse = await _mlService.getPredictions(
        age: user.age ?? 30,
        bmi: _calculateBmi(user.height, user.weight),
        bloodGlucoseLevel: latestRecord.bloodGlucoseLevel!,
        active: user.activityLevel == 'High' ? 1 : 0,
        // Diğer parametreler varsayılan veya kayıttan alınabilir
      );

      if (mlResponse.success) {
        final results = mlResponse.results;
        
        // Diyabet Riski
        if (results['diabetes_risk']?.prediction == 1) {
          insights.add(Insight(
            title: 'Diyabet Riski Uyarısı',
            message: 'İstatistiksel modeller, kan şekeri ve diğer verilerinize dayanarak diyabet riskiniz olabileceğini öngörüyor. Lütfen bir doktora danışın.',
            type: 'risk',
            category: 'disease',
          ));
        }

        // Kalp Riski
        if (results['heart_risk']?.prediction == 1) { // Model ismine göre güncellenmeli
           insights.add(Insight(
            title: 'Kalp Sağlığı Uyarısı',
            message: 'Verileriniz kalp sağlığı açısından risk faktörleri içeriyor olabilir.',
            type: 'risk',
            category: 'disease',
          ));
        }
        
        // Diğer ML sonuçları buraya eklenebilir
      }
    } catch (e) {
      print('ML Analiz Hatası: $e');
    }

    return insights;
  }

  double _calculateBmi(double? height, double? weight) {
    if (height == null || weight == null || height == 0) return 25.0; // Varsayılan
    return weight / ((height / 100) * (height / 100));
  }

  // Level 3: Günlük Yaşam Tarzı (Daily Metrics) - WHO ve T.C. Sağlık Bakanlığı standartlarına göre
  Future<List<Insight>> analyzeLifestyle(DailyMetricModel? todayMetric, UserModel user) async {
    final insights = <Insight>[];

    if (todayMetric == null) return insights;

    // Su Tüketimi - Dinamik standartlar (yaş, cinsiyet, hamilelik durumu)
    try {
      final waterRecommendation = await _healthStandards.getWaterIntakeRecommendation(
        user.gender ?? 'Male',
        user.age ?? 30,
        isPregnant: false, // UserModel'de bu alan yok, gerekirse eklenebilir
        isBreastfeeding: false,
      );

      final currentWater = todayMetric.waterIntake;
      final recommendedWater = waterRecommendation.recommendedLiters;

      if (currentWater < recommendedWater * 0.5) {
        insights.add(Insight(
          title: 'Su Tüketimi Çok Düşük',
          message: waterRecommendation.getRecommendationText(currentWater),
          type: 'warning',
          category: 'lifestyle',
          source: waterRecommendation.source,
          referenceUrl: 'https://www.who.int/water_sanitation_health/dwq',
        ));
      } else if (currentWater >= recommendedWater) {
        insights.add(Insight(
          title: 'Harika Hidrasyon',
          message: waterRecommendation.getRecommendationText(currentWater),
          type: 'success',
          category: 'lifestyle',
          source: waterRecommendation.source,
        ));
      } else if (currentWater < recommendedWater * 0.8) {
        insights.add(Insight(
          title: 'Su Tüketimi Düşük',
          message: waterRecommendation.getRecommendationText(currentWater),
          type: 'info',
          category: 'lifestyle',
          source: waterRecommendation.source,
        ));
      }
    } catch (e) {
      print('Su tüketimi değerlendirme hatası: $e');
    }

    // Adım Sayısı - Dinamik standartlar (yaşa göre)
    try {
      final activityRecommendation = await _healthStandards.getPhysicalActivityRecommendation(
        user.age ?? 30,
      );

      final currentSteps = todayMetric.steps;
      final recommendedSteps = activityRecommendation.stepsPerDay;

      if (currentSteps < recommendedSteps * 0.3) {
        insights.add(Insight(
          title: 'Harekete Geçin',
          message: activityRecommendation.getStepsRecommendation(currentSteps),
          type: 'warning',
          category: 'lifestyle',
          source: activityRecommendation.source,
          referenceUrl: 'https://www.who.int/news-room/fact-sheets/detail/physical-activity',
        ));
      } else if (currentSteps >= recommendedSteps) {
        insights.add(Insight(
          title: 'Mükemmel Aktivite',
          message: activityRecommendation.getStepsRecommendation(currentSteps),
          type: 'success',
          category: 'lifestyle',
          source: activityRecommendation.source,
        ));
      } else if (currentSteps < recommendedSteps * 0.8) {
        insights.add(Insight(
          title: 'Daha Fazla Hareket',
          message: activityRecommendation.getStepsRecommendation(currentSteps),
          type: 'info',
          category: 'lifestyle',
          source: activityRecommendation.source,
        ));
      }
    } catch (e) {
      print('Aktivite değerlendirme hatası: $e');
    }

    // Uyku - Dinamik standartlar (yaşa göre)
    if (todayMetric.sleepQuality > 0) {
      try {
        final sleepRecommendation = await _healthStandards.getSleepRecommendation(
          user.age ?? 30,
        );

        // sleepQuality 1-10 arası, saat cinsine çevirelim (varsayımsal)
        // Gerçek uyku saati verisi varsa onu kullanın
        final sleepHours = todayMetric.sleepQuality.toDouble(); // Bu kısım gerçek veri yapısına göre ayarlanmalı

        if (todayMetric.sleepQuality < 6) {
          insights.add(Insight(
            title: 'Uyku Kalitesi Düşük',
            message: 'Son zamanlarda uyku kaliteniz düşük görünüyor. '
                '${sleepRecommendation.getRecommendationText(null)} '
                'Yatmadan önce ekranlardan uzak durmayı deneyin.',
            type: 'warning',
            category: 'lifestyle',
            source: sleepRecommendation.source,
          ));
        } else if (todayMetric.sleepQuality >= 8) {
          insights.add(Insight(
            title: 'Mükemmel Uyku',
            message: 'Uyku kaliteniz harika! Böyle devam edin. ${sleepRecommendation.source} standartlarına uygun dinleniyorsunuz.',
            type: 'success',
            category: 'lifestyle',
            source: sleepRecommendation.source,
          ));
        }
      } catch (e) {
        print('Uyku değerlendirme hatası: $e');
      }
    }

    return insights;
  }
}
