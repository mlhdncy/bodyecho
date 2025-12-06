import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/health_assessment_model.dart';

/// WHO ve T.C. Sağlık Bakanlığı standartlarına dayalı sağlık değerlendirme servisi
///
/// Bu servis JSON dosyalarından sağlık standartlarını yükler ve
/// kullanıcı verilerine göre kişiselleştirilmiş değerlendirmeler sağlar.
class HealthStandardsService {
  static Map<String, dynamic>? _whoStandards;
  static Map<String, dynamic>? _turkeyStandards;
  static bool _isInitialized = false;

  /// Standartları yükle (ilk çağrıda, sonrasında cache'den döner)
  Future<void> loadStandards() async {
    if (_isInitialized) return;

    try {
      // WHO standartlarını yükle
      final whoJson = await rootBundle.loadString('assets/health_standards/who_standards.json');
      _whoStandards = json.decode(whoJson);

      // T.C. Sağlık Bakanlığı standartlarını yükle
      final turkeyJson = await rootBundle.loadString('assets/health_standards/turkey_moh_standards.json');
      _turkeyStandards = json.decode(turkeyJson);

      _isInitialized = true;
      print('✅ Sağlık standartları başarıyla yüklendi');
    } catch (e) {
      print('❌ Sağlık standartları yüklenirken hata: $e');
      rethrow;
    }
  }

  /// BMI değerlendirmesi yap
  ///
  /// [bmi] - Vücut kitle indeksi
  /// [age] - Yaş (çocuk kontrolü için)
  /// [gender] - Cinsiyet ('Male' veya 'Female')
  Future<BmiAssessment> evaluateBmi(double bmi, int age, String gender) async {
    await loadStandards();

    // Çocuk kontrolü
    if (age < 18) {
      return BmiAssessment(
        category: 'children',
        description: 'Çocuk yaş grubu',
        riskLevel: 'info',
        recommendation: 'Çocuklarda BMI değerlendirmesi yaşa ve cinsiyete göre persentil tabloları kullanılarak yapılmalıdır. Bir çocuk doktoruna danışın.',
        source: 'WHO',
        bmiValue: bmi,
      );
    }

    // Yetişkin BMI kategorileri
    final categories = _whoStandards?['bmi']?['adults']?['categories'];
    if (categories == null) {
      throw Exception('BMI standartları yüklenemedi');
    }

    // BMI kategorisini belirle
    String category = 'unknown';
    Map<String, dynamic>? categoryData;

    for (var entry in categories.entries) {
      final data = entry.value as Map<String, dynamic>;
      final min = data['min'] as double?;
      final max = data['max'] as double?;

      if (min != null && max != null) {
        if (bmi >= min && bmi <= max) {
          category = entry.key;
          categoryData = data;
          break;
        }
      } else if (min != null && max == null) {
        if (bmi >= min) {
          category = entry.key;
          categoryData = data;
          break;
        }
      } else if (min == null && max != null) {
        if (bmi <= max) {
          category = entry.key;
          categoryData = data;
          break;
        }
      }
    }

    if (categoryData == null) {
      categoryData = categories['normal'];
    }

    return BmiAssessment(
      category: category,
      description: categoryData?['description'] ?? '',
      riskLevel: categoryData?['risk_level'] ?? 'info',
      recommendation: categoryData?['recommendation'] ?? '',
      source: 'WHO',
      bmiValue: bmi,
    );
  }

  /// Kan şekeri değerlendirmesi yap
  ///
  /// [glucose] - Kan şekeri değeri (mg/dL)
  /// [isFasting] - Açlık kan şekeri mi?
  Future<GlucoseAssessment> evaluateGlucose(int glucose, {bool isFasting = true}) async {
    await loadStandards();

    final glucoseType = isFasting ? 'fasting' : 'random';
    final standards = _whoStandards?['blood_glucose']?[glucoseType];

    if (standards == null) {
      throw Exception('Kan şekeri standartları yüklenemedi');
    }

    // Kategoriyi belirle
    String status = 'normal';
    Map<String, dynamic>? categoryData;

    if (glucose >= (standards['diabetes']?['min'] ?? 999)) {
      status = 'diabetes';
      categoryData = standards['diabetes'];
    } else if (glucose >= (standards['prediabetes']?['min'] ?? 999)) {
      status = 'prediabetes';
      categoryData = standards['prediabetes'];
    } else {
      status = 'normal';
      categoryData = standards['normal'];
    }

    return GlucoseAssessment(
      status: status,
      description: categoryData?['description'] ?? status,
      warning: status == 'normal' ? '' : 'Kan şekeriniz yüksek!',
      recommendation: categoryData?['recommendation'] ?? '',
      minNormal: null,
      maxNormal: standards['normal']?['max']?.toDouble(),
      source: 'WHO',
      isFasting: isFasting,
    );
  }

  /// Kan basıncı değerlendirmesi
  ///
  /// [systolic] - Sistolik basınç (üst değer)
  /// [diastolic] - Diyastolik basınç (alt değer)
  Future<BloodPressureAssessment> evaluateBloodPressure(int systolic, int diastolic) async {
    await loadStandards();

    final standards = _whoStandards?['blood_pressure']?['adults'];
    if (standards == null) {
      throw Exception('Kan basıncı standartları yüklenemedi');
    }

    // Kategoriyi belirle (sistolik veya diyastolik'ten yüksek olanı alırız)
    String category = 'optimal';
    Map<String, dynamic>? categoryData = standards['optimal'];

    for (var entry in standards.entries) {
      if (entry.key == 'unit' || entry.key == 'reference') continue;

      final data = entry.value as Map<String, dynamic>;
      final sysMin = data['systolic']?['min'] as int?;
      final sysMax = data['systolic']?['max'] as int?;
      final diaMin = data['diastolic']?['min'] as int?;
      final diaMax = data['diastolic']?['max'] as int?;

      bool sysMatch = false;
      bool diaMatch = false;

      // Sistolik kontrol
      if (sysMin != null && sysMax != null) {
        sysMatch = systolic >= sysMin && systolic <= sysMax;
      } else if (sysMin != null && sysMax == null) {
        sysMatch = systolic >= sysMin;
      } else if (sysMin == null && sysMax != null) {
        sysMatch = systolic <= sysMax;
      }

      // Diyastolik kontrol
      if (diaMin != null && diaMax != null) {
        diaMatch = diastolic >= diaMin && diastolic <= diaMax;
      } else if (diaMin != null && diaMax == null) {
        diaMatch = diastolic >= diaMin;
      } else if (diaMin == null && diaMax != null) {
        diaMatch = diastolic <= diaMax;
      }

      if (sysMatch || diaMatch) {
        category = entry.key;
        categoryData = data;
      }
    }

    return BloodPressureAssessment(
      category: category,
      description: categoryData?['description'] ?? category,
      riskLevel: categoryData?['risk_level'] ?? 'info',
      recommendation: categoryData?['recommendation'] ?? '',
      source: 'WHO',
      systolic: systolic,
      diastolic: diastolic,
    );
  }

  /// Su tüketimi önerisi al
  ///
  /// [gender] - Cinsiyet ('Male' veya 'Female')
  /// [age] - Yaş
  /// [isPregnant] - Hamile mi?
  /// [isBreastfeeding] - Emziriyor mu?
  Future<WaterIntakeRecommendation> getWaterIntakeRecommendation(
    String gender,
    int age, {
    bool isPregnant = false,
    bool isBreastfeeding = false,
  }) async {
    await loadStandards();

    final waterStandards = _whoStandards?['water_intake'];
    if (waterStandards == null) {
      throw Exception('Su tüketimi standartları yüklenemedi');
    }

    String? specialCondition;
    double recommendedLiters;
    String description;

    if (isBreastfeeding) {
      recommendedLiters = waterStandards['breastfeeding']['min']?.toDouble() ?? 3.8;
      description = 'Emziren kadın';
      specialCondition = 'breastfeeding';
    } else if (isPregnant) {
      recommendedLiters = waterStandards['pregnant']['min']?.toDouble() ?? 3.0;
      description = 'Hamile kadın';
      specialCondition = 'pregnant';
    } else if (age >= 65) {
      if (gender == 'Male') {
        recommendedLiters = waterStandards['elderly_65_plus']['male']?.toDouble() ?? 3.7;
      } else {
        recommendedLiters = waterStandards['elderly_65_plus']['female']?.toDouble() ?? 2.7;
      }
      description = 'Yaşlı yetişkin (65+ yaş)';
    } else if (age >= 18) {
      if (gender == 'Male') {
        recommendedLiters = waterStandards['male_adult']['min']?.toDouble() ?? 3.7;
        description = 'Yetişkin erkek';
      } else {
        recommendedLiters = waterStandards['female_adult']['min']?.toDouble() ?? 2.7;
        description = 'Yetişkin kadın';
      }
    } else if (age >= 14) {
      if (gender == 'Male') {
        recommendedLiters = waterStandards['children_14_18']['male']?.toDouble() ?? 3.3;
      } else {
        recommendedLiters = waterStandards['children_14_18']['female']?.toDouble() ?? 2.3;
      }
      description = 'Genç (14-18 yaş)';
    } else {
      recommendedLiters = 2.0;
      description = 'Çocuk';
    }

    return WaterIntakeRecommendation(
      recommendedLiters: recommendedLiters,
      description: description,
      source: 'WHO',
      specialCondition: specialCondition,
    );
  }

  /// Kalori ihtiyacı önerisi al
  ///
  /// [age] - Yaş
  /// [gender] - Cinsiyet ('Male' veya 'Female')
  /// [activityLevel] - Aktivite seviyesi ('Low', 'Moderate', 'High')
  /// [isPregnant] - Hamile mi?
  /// [isBreastfeeding] - Emziriyor mu?
  Future<CalorieRecommendation> getCalorieRecommendation(
    int age,
    String gender,
    String activityLevel, {
    bool isPregnant = false,
    bool isBreastfeeding = false,
  }) async {
    await loadStandards();

    final nutritionStandards = _turkeyStandards?['nutrition']?['daily_calorie_intake'];
    if (nutritionStandards == null) {
      throw Exception('Kalori standartları yüklenemedi');
    }

    // Aktivite seviyesini normalize et
    String normalizedActivity = 'moderate';
    if (activityLevel == 'Low') {
      normalizedActivity = 'sedentary';
    } else if (activityLevel == 'High') {
      normalizedActivity = 'active';
    }

    String? specialCondition;
    int calories;

    // Özel durumlar (hamilelik, emzirme)
    if (isBreastfeeding) {
      calories = nutritionStandards['female']['breastfeeding_0_6_months'] as int? ?? 2500;
      specialCondition = 'breastfeeding';
    } else if (isPregnant) {
      calories = nutritionStandards['female']['pregnant_second_trimester'] as int? ?? 2300;
      specialCondition = 'pregnant';
    } else {
      // Yaş grubunu belirle
      String ageGroup;
      if (age >= 18 && age <= 30) {
        ageGroup = '18-30';
      } else if (age >= 31 && age <= 50) {
        ageGroup = '31-50';
      } else if (age >= 51 && age <= 70) {
        ageGroup = '51-70';
      } else {
        ageGroup = '70+';
      }

      final genderKey = gender == 'Male' ? 'male' : 'female';
      calories = nutritionStandards[genderKey][normalizedActivity][ageGroup] as int? ?? 2000;
    }

    return CalorieRecommendation(
      dailyCalories: calories,
      activityLevel: normalizedActivity,
      source: 'T.C. Sağlık Bakanlığı',
      specialCondition: specialCondition,
    );
  }

  /// Uyku önerisi al
  ///
  /// [age] - Yaş
  Future<SleepRecommendation> getSleepRecommendation(int age) async {
    await loadStandards();

    final sleepStandards = _whoStandards?['sleep'];
    if (sleepStandards == null) {
      throw Exception('Uyku standartları yüklenemedi');
    }

    String ageGroup;
    Map<String, dynamic>? sleepData;

    if (age >= 65) {
      ageGroup = 'elderly_65_plus';
      sleepData = sleepStandards['elderly_65_plus'];
    } else if (age >= 18) {
      ageGroup = 'adult_18_64_years';
      sleepData = sleepStandards['adult_18_64_years'];
    } else if (age >= 14) {
      ageGroup = 'teen_14_17_years';
      sleepData = sleepStandards['teen_14_17_years'];
    } else if (age >= 6) {
      ageGroup = 'school_age_6_13_years';
      sleepData = sleepStandards['school_age_6_13_years'];
    } else if (age >= 3) {
      ageGroup = 'preschool_3_5_years';
      sleepData = sleepStandards['preschool_3_5_years'];
    } else {
      ageGroup = 'toddler_1_2_years';
      sleepData = sleepStandards['toddler_1_2_years'];
    }

    return SleepRecommendation(
      minHours: sleepData?['min']?.toDouble() ?? 7.0,
      maxHours: sleepData?['max']?.toDouble() ?? 9.0,
      optimalHours: sleepData?['optimal']?.toDouble() ?? 8.0,
      ageGroup: ageGroup,
      source: 'WHO',
    );
  }

  /// Fiziksel aktivite önerisi al
  ///
  /// [age] - Yaş
  Future<PhysicalActivityRecommendation> getPhysicalActivityRecommendation(int age) async {
    await loadStandards();

    final activityStandards = _whoStandards?['physical_activity'];
    if (activityStandards == null) {
      throw Exception('Fiziksel aktivite standartları yüklenemedi');
    }

    String ageGroup;
    Map<String, dynamic>? activityData;

    if (age >= 65) {
      ageGroup = 'elderly_65_plus';
      activityData = activityStandards['elderly_65_plus'];
    } else if (age >= 18) {
      ageGroup = 'adults_18_64';
      activityData = activityStandards['adults_18_64'];
    } else {
      ageGroup = 'children_5_17';
      activityData = activityStandards['children_5_17'];
    }

    return PhysicalActivityRecommendation(
      moderateIntensityMinutesPerWeek: activityData?['moderate_intensity_minutes_per_week'] as int? ?? 150,
      vigorousIntensityMinutesPerWeek: activityData?['vigorous_intensity_minutes_per_week'] as int?,
      stepsPerDay: activityData?['steps_per_day'] as int? ?? 10000,
      ageGroup: ageGroup,
      source: 'WHO',
      specialNote: activityData?['description'] as String?,
    );
  }

  /// Türkiye'ye özel tuz/sodyum değerlendirmesi
  Future<SodiumAssessment> getTurkeySodiumAssessment() async {
    await loadStandards();

    final sodiumData = _turkeyStandards?['nutrition']?['salt'];
    final highSaltFoods = _turkeyStandards?['nutrition']?['dietary_guidelines_turkey'];

    if (sodiumData == null) {
      throw Exception('Tuz standartları yüklenemedi');
    }

    // Yüksek tuzlu yiyecekler listesi
    final highSaltFoodsList = _turkeyStandards?['nutrition']?['salt']?['high_salt_foods_turkey'] as List<dynamic>?;

    return SodiumAssessment(
      maxDailyGrams: sodiumData['max_daily_grams']?.toDouble() ?? 5.0,
      currentTurkeyAverage: sodiumData['current_turkey_average_grams']?.toDouble() ?? 18.0,
      highSaltFoods: highSaltFoodsList?.cast<String>() ?? [],
      recommendation: sodiumData['recommendation'] ?? '',
      source: 'T.C. Sağlık Bakanlığı',
    );
  }

  /// Standartların versiyon bilgisini al
  Map<String, String> getVersionInfo() {
    return {
      'who_version': _whoStandards?['version'] ?? 'unknown',
      'who_updated': _whoStandards?['last_updated'] ?? 'unknown',
      'turkey_version': _turkeyStandards?['version'] ?? 'unknown',
      'turkey_updated': _turkeyStandards?['last_updated'] ?? 'unknown',
    };
  }

  /// Standartların kaynak URL'lerini al
  Map<String, String> getReferenceUrls() {
    return {
      'who': _whoStandards?['reference_url'] ?? 'https://www.who.int/',
      'turkey': _turkeyStandards?['reference_url'] ?? 'https://www.saglik.gov.tr/',
    };
  }
}
