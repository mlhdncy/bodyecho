import '../models/user_model.dart';
import '../models/daily_metric_model.dart';
import '../models/health_record_model.dart';
import '../models/ml_prediction_model.dart';
import 'ml_service.dart';

class Insight {
  final String title;
  final String message;
  final String type; // 'risk', 'warning', 'info', 'success'
  final String category; // 'obesity', 'disease', 'lifestyle'

  Insight({
    required this.title,
    required this.message,
    required this.type,
    required this.category,
  });
}

class InsightsService {
  final MlService _mlService = MlService();

  // Level 1: Profil Bazlı Analiz (BMI & Obezite)
  List<Insight> analyzeProfile(UserModel user) {
    final insights = <Insight>[];

    if (user.height != null && user.weight != null && user.height! > 0) {
      final heightInMeters = user.height! / 100;
      final bmi = user.weight! / (heightInMeters * heightInMeters);
      
      String bmiCategory;
      String type;
      
      if (bmi < 18.5) {
        bmiCategory = 'Zayıf';
        type = 'warning';
      } else if (bmi < 25) {
        bmiCategory = 'Normal';
        type = 'success';
      } else if (bmi < 30) {
        bmiCategory = 'Fazla Kilolu';
        type = 'warning';
      } else {
        bmiCategory = 'Obez';
        type = 'risk';
      }

      insights.add(Insight(
        title: 'Vücut Kitle İndeksi (BMI)',
        message: 'BMI değeriniz: ${bmi.toStringAsFixed(1)} ($bmiCategory). '
            '${_getBmiAdvice(bmi)}',
        type: type,
        category: 'obesity',
      ));
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

  String _getBmiAdvice(double bmi) {
    if (bmi < 18.5) return 'Sağlıklı bir şekilde kilo almak için beslenmenize dikkat etmelisiniz.';
    if (bmi < 25) return 'Harika! Kilonuzu korumaya devam edin.';
    if (bmi < 30) return 'Daha hareketli bir yaşam ve dengeli beslenme ile ideal kilonuza ulaşabilirsiniz.';
    return 'Sağlığınız için bir uzmana danışarak kilo vermeyi hedeflemelisiniz.';
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

  // Level 3: Günlük Yaşam Tarzı (Daily Metrics)
  List<Insight> analyzeLifestyle(DailyMetricModel? todayMetric) {
    final insights = <Insight>[];

    if (todayMetric == null) return insights;

    // Su Tüketimi
    if (todayMetric.waterIntake < 1.5) {
      insights.add(Insight(
        title: 'Su Tüketimi Düşük',
        message: 'Bugün yeterince su içmediniz. Hedefinize ulaşmak için bir bardak su için!',
        type: 'info',
        category: 'lifestyle',
      ));
    } else if (todayMetric.waterIntake >= 2.5) {
       insights.add(Insight(
        title: 'Harika Hidrasyon',
        message: 'Su tüketim hedefiniz harika gidiyor!',
        type: 'success',
        category: 'lifestyle',
      ));
    }

    // Adım Sayısı
    if (todayMetric.steps < 3000) {
      insights.add(Insight(
        title: 'Harekete Geçin',
        message: 'Bugün çok az hareket ettiniz. Kısa bir yürüyüşe ne dersiniz?',
        type: 'info',
        category: 'lifestyle',
      ));
    }

    // Uyku
    if (todayMetric.sleepQuality > 0 && todayMetric.sleepQuality < 6) {
       insights.add(Insight(
        title: 'Uyku Kalitesi',
        message: 'Son zamanlarda uyku kaliteniz düşük görünüyor. Yatmadan önce ekranlardan uzak durmayı deneyin.',
        type: 'warning',
        category: 'lifestyle',
      ));
    }

    return insights;
  }
}
