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
      return 'Great! You have reached your water intake goal (${recommendedLiters}L/day). You are drinking according to ${source} standards.';
    } else if (currentIntake >= recommendedLiters * 0.8) {
      return 'You are doing well! Almost at your goal. Try to drink ${recommendedLiters}L of water daily (${source} recommendation).';
    } else if (currentIntake >= recommendedLiters * 0.5) {
      return 'Your water intake is insufficient. Your goal is ${recommendedLiters}L/day (${source} recommendation). Drink more water!';
    } else {
      return 'Warning! Your water intake is very low. You should drink at least ${recommendedLiters}L of water per day (${source} recommendation). Dehydration negatively affects your performance and health.';
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
        activityDesc = 'sedentary';
        break;
      case 'moderate':
        activityDesc = 'moderately active';
        break;
      case 'active':
        activityDesc = 'active';
        break;
      default:
        activityDesc = 'moderately active';
    }

    if (specialCondition == 'pregnant') {
      return 'For your $activityDesc lifestyle and pregnancy, $dailyCalories calories per day is recommended.';
    } else if (specialCondition == 'breastfeeding') {
      return 'For your $activityDesc lifestyle and breastfeeding, $dailyCalories calories per day is recommended.';
    }

    return 'For your $activityDesc lifestyle, $dailyCalories calories per day is recommended.';
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
      return 'Recommended sleep duration for your age group: $minHours-$maxHours hours (optimal: $optimalHours hours). According to $source standards.';
    }

    if (currentSleep >= minHours && currentSleep <= maxHours) {
      return 'Excellent! Your sleep duration ($currentSleep hours) is in the ideal range ($minHours-$maxHours hours). Meets $source standards.';
    } else if (currentSleep < minHours) {
      final deficit = minHours - currentSleep;
      return 'Your sleep duration is insufficient. You should sleep ${deficit.toStringAsFixed(1)} hours more. Recommended: $minHours-$maxHours hours ($source).';
    } else {
      return 'You are sleeping too much. Recommended sleep duration: $minHours-$maxHours hours ($source).';
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
      return 'Great! You have reached your daily step goal ($currentSteps/$stepsPerDay steps). You are moving according to $source recommendations.';
    } else if (currentSteps >= stepsPerDay * 0.8) {
      final remaining = stepsPerDay - currentSteps;
      return 'You are doing well! $remaining steps left to your goal. Aim for $stepsPerDay steps daily ($source).';
    } else if (currentSteps >= stepsPerDay * 0.5) {
      return 'Your step count is below average. Your goal: $stepsPerDay steps/day ($source recommendation). Walk more!';
    } else {
      return 'Warning! You are moving very little. You should take at least $stepsPerDay steps per day ($source recommendation). Take short walks.';
    }
  }

  String get weeklyActivityRecommendation {
    if (vigorousIntensityMinutesPerWeek != null) {
      return 'Exercise $moderateIntensityMinutesPerWeek minutes of moderate intensity OR $vigorousIntensityMinutesPerWeek minutes of vigorous intensity per week ($source recommendation).';
    }
    return 'Exercise $moderateIntensityMinutesPerWeek minutes of moderate intensity per week ($source recommendation).';
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
    return 'Average salt consumption in Turkey is ${currentTurkeyAverage}g/day (recommended: ${maxDailyGrams}g/day). '
        'High salt risk in Turkish cuisine: ${highSaltFoods.take(3).join(", ")}. $recommendation';
  }
}
