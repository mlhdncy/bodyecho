/// Health Assessment Models
///
/// Bu dosya WHO ve T.C. Sağlık Bakanlığı standartlarına dayalı
/// sağlık değerlendirme sonuçlarını temsil eden model sınıflarını içerir.

/// BMI (Vücut Kitle İndeksi) değerlendirmesi
class BmiAssessment {
  final String category;
  final String description;
  final String riskLevel; // 'low', 'warning', 'moderate', 'high', 'very_high'
  final String recommendation;
  final String source; // "WHO" veya "T.C. Sağlık Bakanlığı"
  final double bmiValue;

  BmiAssessment({
    required this.category,
    required this.description,
    required this.riskLevel,
    required this.recommendation,
    required this.source,
    required this.bmiValue,
  });

  /// Insight type'a dönüştürme helper'ı
  String get insightType {
    switch (riskLevel) {
      case 'very_high':
      case 'high':
        return 'risk';
      case 'moderate':
      case 'warning':
        return 'warning';
      case 'low':
        return 'success';
      default:
        return 'info';
    }
  }
}

/// Kan şekeri (glucose) değerlendirmesi
class GlucoseAssessment {
  final String status; // 'normal', 'prediabetes', 'diabetes'
  final String description;
  final String warning;
  final String recommendation;
  final double? minNormal;
  final double? maxNormal;
  final String source;
  final bool isFasting;

  GlucoseAssessment({
    required this.status,
    required this.description,
    required this.warning,
    required this.recommendation,
    this.minNormal,
    this.maxNormal,
    required this.source,
    this.isFasting = true,
  });

  String get insightType {
    if (status == 'diabetes') return 'risk';
    if (status == 'prediabetes') return 'warning';
    return 'success';
  }
}

/// Kan basıncı değerlendirmesi
class BloodPressureAssessment {
  final String category; // 'optimal', 'normal', 'high_normal', 'hypertension_grade_1', etc.
  final String description;
  final String riskLevel;
  final String recommendation;
  final String source;
  final int systolic;
  final int diastolic;

  BloodPressureAssessment({
    required this.category,
    required this.description,
    required this.riskLevel,
    required this.recommendation,
    required this.source,
    required this.systolic,
    required this.diastolic,
  });

  String get insightType {
    if (riskLevel == 'very_high' || riskLevel == 'high') return 'risk';
    if (riskLevel == 'moderate' || riskLevel == 'warning') return 'warning';
    if (riskLevel == 'low') return 'success';
    return 'info';
  }
}

/// Kolesterol değerlendirmesi
class CholesterolAssessment {
  final String category;
  final String description;
  final String recommendation;
  final String source;
  final String type; // 'total', 'ldl', 'hdl', 'triglycerides'

  CholesterolAssessment({
    required this.category,
    required this.description,
    required this.recommendation,
    required this.source,
    required this.type,
  });

  String get insightType {
    if (category.contains('high') || category.contains('yüksek')) {
      return 'risk';
    }
    if (category.contains('borderline') || category.contains('sınırda')) {
      return 'warning';
    }
    return 'success';
  }
}

/// Su tüketimi önerisi
class WaterIntakeRecommendation {
  final double recommendedLiters;
  final String description;
  final String source;
  final String? specialCondition; // 'pregnant', 'breastfeeding', null

  WaterIntakeRecommendation({
    required this.recommendedLiters,
    required this.description,
    required this.source,
    this.specialCondition,
  });

  String getRecommendationText(double currentIntake) {
    if (currentIntake >= recommendedLiters) {
      return 'Harika! Su tüketim hedefinize ulaştınız (${recommendedLiters}L/gün). ${source} standartlarına uygun içiyorsunuz.';
    } else if (currentIntake >= recommendedLiters * 0.8) {
      return 'İyi gidiyorsunuz! Hedefinize az kaldı. Günlük ${recommendedLiters}L su içmeye çalışın (${source} önerisi).';
    } else if (currentIntake >= recommendedLiters * 0.5) {
      return 'Su tüketiminiz yetersiz. Hedefiniz ${recommendedLiters}L/gün (${source} önerisi). Daha fazla su için!';
    } else {
      return 'Dikkat! Su tüketiminiz çok düşük. Günde en az ${recommendedLiters}L su içmelisiniz (${source} önerisi). Susuzluk performansınızı ve sağlığınızı olumsuz etkiler.';
    }
  }
}

/// Kalori ihtiyacı önerisi
class CalorieRecommendation {
  final int dailyCalories;
  final String activityLevel; // 'sedentary', 'moderate', 'active'
  final String source;
  final String? specialCondition; // 'pregnant', 'breastfeeding', null

  CalorieRecommendation({
    required this.dailyCalories,
    required this.activityLevel,
    required this.source,
    this.specialCondition,
  });

  String get description {
    String activityDesc;
    switch (activityLevel) {
      case 'sedentary':
        activityDesc = 'sedanter (hareketsiz)';
        break;
      case 'moderate':
        activityDesc = 'orta düzey aktif';
        break;
      case 'active':
        activityDesc = 'aktif';
        break;
      default:
        activityDesc = 'orta düzey aktif';
    }

    if (specialCondition == 'pregnant') {
      return '$activityDesc yaşam tarzı ve hamilelik durumunuz için günlük $dailyCalories kalori önerilir.';
    } else if (specialCondition == 'breastfeeding') {
      return '$activityDesc yaşam tarzı ve emzirme durumunuz için günlük $dailyCalories kalori önerilir.';
    }

    return '$activityDesc yaşam tarzınız için günlük $dailyCalories kalori önerilir.';
  }
}

/// Uyku önerisi
class SleepRecommendation {
  final double minHours;
  final double maxHours;
  final double optimalHours;
  final String ageGroup;
  final String source;

  SleepRecommendation({
    required this.minHours,
    required this.maxHours,
    required this.optimalHours,
    required this.ageGroup,
    required this.source,
  });

  String getRecommendationText(double? currentSleep) {
    if (currentSleep == null) {
      return 'Yaş grubunuz için önerilen uyku süresi: $minHours-$maxHours saat (optimal: $optimalHours saat). ${source} standartlarına göre.';
    }

    if (currentSleep >= minHours && currentSleep <= maxHours) {
      return 'Mükemmel! Uyku süreniz ($currentSleep saat) ideal aralıkta ($minHours-$maxHours saat). ${source} standartlarına uygun.';
    } else if (currentSleep < minHours) {
      final deficit = minHours - currentSleep;
      return 'Uyku süreniz yetersiz. ${deficit.toStringAsFixed(1)} saat daha fazla uyumalısınız. Önerilen: $minHours-$maxHours saat (${source}).';
    } else {
      return 'Çok fazla uyuyorsunuz. Önerilen uyku süresi: $minHours-$maxHours saat (${source}).';
    }
  }
}

/// Fiziksel aktivite önerisi
class PhysicalActivityRecommendation {
  final int moderateIntensityMinutesPerWeek;
  final int? vigorousIntensityMinutesPerWeek;
  final int stepsPerDay;
  final String ageGroup;
  final String source;
  final String? specialNote;

  PhysicalActivityRecommendation({
    required this.moderateIntensityMinutesPerWeek,
    this.vigorousIntensityMinutesPerWeek,
    required this.stepsPerDay,
    required this.ageGroup,
    required this.source,
    this.specialNote,
  });

  String getStepsRecommendation(int currentSteps) {
    if (currentSteps >= stepsPerDay) {
      return 'Harika! Günlük adım hedefinize ulaştınız ($currentSteps/$stepsPerDay adım). ${source} önerilerine uygun hareket ediyorsunuz.';
    } else if (currentSteps >= stepsPerDay * 0.8) {
      final remaining = stepsPerDay - currentSteps;
      return 'İyi gidiyorsunuz! Hedefinize $remaining adım kaldı. Günlük $stepsPerDay adım hedefleyin (${source}).';
    } else if (currentSteps >= stepsPerDay * 0.5) {
      return 'Adım sayınız ortalamanın altında. Hedefiniz: $stepsPerDay adım/gün (${source} önerisi). Daha fazla yürüyün!';
    } else {
      return 'Dikkat! Çok az hareket ediyorsunuz. Günde en az $stepsPerDay adım atmalısınız (${source} önerisi). Kısa yürüyüşler yapın.';
    }
  }

  String get weeklyActivityRecommendation {
    if (vigorousIntensityMinutesPerWeek != null) {
      return 'Haftada $moderateIntensityMinutesPerWeek dakika orta yoğunlukta VEYA $vigorousIntensityMinutesPerWeek dakika yüksek yoğunlukta egzersiz yapın (${source} önerisi).';
    }
    return 'Haftada $moderateIntensityMinutesPerWeek dakika orta yoğunlukta egzersiz yapın (${source} önerisi).';
  }
}

/// Tuz/Sodyum tüketimi değerlendirmesi (Türkiye'ye özel)
class SodiumAssessment {
  final double maxDailyGrams;
  final double currentTurkeyAverage;
  final List<String> highSaltFoods;
  final String recommendation;
  final String source;

  SodiumAssessment({
    required this.maxDailyGrams,
    required this.currentTurkeyAverage,
    required this.highSaltFoods,
    required this.recommendation,
    required this.source,
  });

  String get warningMessage {
    return 'Türkiye\'de ortalama tuz tüketimi ${currentTurkeyAverage}g/gün (önerilen: ${maxDailyGrams}g/gün). '
        'Türk mutfağında yüksek tuz riski vardır: ${highSaltFoods.take(3).join(", ")}. $recommendation';
  }
}
