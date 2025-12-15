import 'package:flutter_test/flutter_test.dart';
import 'package:bodyecho/services/health_standards_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HealthStandardsService Tests', () {
    late HealthStandardsService service;

    setUp(() {
      service = HealthStandardsService();
    });

    test('loadStandards should load JSON files successfully', () async {
      await service.loadStandards();
      // Test başarıyla tamamlanırsa standartlar yüklenmiştir
      expect(true, true);
    });

    test('evaluateBmi should return correct assessment for normal BMI',
        () async {
      await service.loadStandards();

      final assessment = await service.evaluateBmi(22.0, 30, 'Male');

      expect(assessment.category, 'normal');
      expect(assessment.description, 'Normal');
      expect(assessment.riskLevel, 'low');
      expect(assessment.source, 'WHO');
      expect(assessment.bmiValue, 22.0);
    });

    test('evaluateBmi should return correct assessment for overweight BMI',
        () async {
      await service.loadStandards();

      final assessment = await service.evaluateBmi(27.0, 30, 'Female');

      expect(assessment.category, 'overweight');
      expect(assessment.description, 'Fazla Kilolu');
      expect(assessment.riskLevel, 'warning');
      expect(assessment.source, 'WHO');
    });

    test('evaluateBmi should return correct assessment for obese BMI',
        () async {
      await service.loadStandards();

      final assessment = await service.evaluateBmi(32.0, 40, 'Male');

      expect(assessment.category, 'obese_class_1');
      expect(assessment.description, 'Obez (Sınıf 1)');
      expect(assessment.riskLevel, 'moderate');
      expect(assessment.source, 'WHO');
    });

    test('evaluateBmi should handle children differently', () async {
      await service.loadStandards();

      final assessment = await service.evaluateBmi(18.0, 12, 'Male');

      expect(assessment.category, 'children');
      expect(assessment.riskLevel, 'info');
      expect(assessment.source, 'WHO');
    });

    test(
        'evaluateGlucose should return correct assessment for normal fasting glucose',
        () async {
      await service.loadStandards();

      final assessment = await service.evaluateGlucose(90, isFasting: true);

      expect(assessment.status, 'normal');
      expect(assessment.source, 'WHO');
      expect(assessment.isFasting, true);
    });

    test('evaluateGlucose should return correct assessment for prediabetes',
        () async {
      await service.loadStandards();

      final assessment = await service.evaluateGlucose(110, isFasting: true);

      expect(assessment.status, 'prediabetes');
      expect(assessment.source, 'WHO');
    });

    test('evaluateGlucose should return correct assessment for diabetes',
        () async {
      await service.loadStandards();

      final assessment = await service.evaluateGlucose(140, isFasting: true);

      expect(assessment.status, 'diabetes');
      expect(assessment.source, 'WHO');
    });

    test(
        'getWaterIntakeRecommendation should return correct values for male adult',
        () async {
      await service.loadStandards();

      final recommendation =
          await service.getWaterIntakeRecommendation('Male', 30);

      expect(recommendation.recommendedLiters, 3.7);
      expect(recommendation.source, 'WHO');
      expect(recommendation.description, 'Yetişkin erkek');
    });

    test(
        'getWaterIntakeRecommendation should return correct values for female adult',
        () async {
      await service.loadStandards();

      final recommendation =
          await service.getWaterIntakeRecommendation('Female', 28);

      expect(recommendation.recommendedLiters, 2.7);
      expect(recommendation.source, 'WHO');
      expect(recommendation.description, 'Yetişkin kadın');
    });

    test(
        'getWaterIntakeRecommendation should return higher values for pregnant women',
        () async {
      await service.loadStandards();

      final recommendation = await service
          .getWaterIntakeRecommendation('Female', 28, isPregnant: true);

      expect(recommendation.recommendedLiters, 3.0);
      expect(recommendation.source, 'WHO');
      expect(recommendation.specialCondition, 'pregnant');
    });

    test(
        'getWaterIntakeRecommendation should return higher values for breastfeeding women',
        () async {
      await service.loadStandards();

      final recommendation = await service
          .getWaterIntakeRecommendation('Female', 28, isBreastfeeding: true);

      expect(recommendation.recommendedLiters, 3.8);
      expect(recommendation.source, 'WHO');
      expect(recommendation.specialCondition, 'breastfeeding');
    });

    test('getSleepRecommendation should return correct values for adult',
        () async {
      await service.loadStandards();

      final recommendation = await service.getSleepRecommendation(30);

      expect(recommendation.minHours, 7.0);
      expect(recommendation.maxHours, 9.0);
      expect(recommendation.optimalHours, 8.0);
      expect(recommendation.source, 'WHO');
    });

    test('getSleepRecommendation should return correct values for elderly',
        () async {
      await service.loadStandards();

      final recommendation = await service.getSleepRecommendation(70);

      expect(recommendation.minHours, 7.0);
      expect(recommendation.maxHours, 8.0);
      expect(recommendation.source, 'WHO');
    });

    test(
        'getPhysicalActivityRecommendation should return correct values for adult',
        () async {
      await service.loadStandards();

      final recommendation =
          await service.getPhysicalActivityRecommendation(30);

      expect(recommendation.moderateIntensityMinutesPerWeek, 150);
      expect(recommendation.vigorousIntensityMinutesPerWeek, 75);
      expect(recommendation.stepsPerDay, 10000);
      expect(recommendation.source, 'WHO');
    });

    test(
        'getPhysicalActivityRecommendation should return correct values for elderly',
        () async {
      await service.loadStandards();

      final recommendation =
          await service.getPhysicalActivityRecommendation(68);

      expect(recommendation.stepsPerDay, 7000);
      expect(recommendation.source, 'WHO');
    });

    test('getCalorieRecommendation should return correct values for male',
        () async {
      await service.loadStandards();

      final recommendation =
          await service.getCalorieRecommendation(30, 'Male', 'Moderate');

      expect(recommendation.dailyCalories, greaterThan(0));
      expect(recommendation.source, 'T.C. Sağlık Bakanlığı');
      expect(recommendation.activityLevel, 'moderate');
    });

    test('getCalorieRecommendation should return correct values for female',
        () async {
      await service.loadStandards();

      final recommendation =
          await service.getCalorieRecommendation(28, 'Female', 'Low');

      expect(recommendation.dailyCalories, greaterThan(0));
      expect(recommendation.source, 'T.C. Sağlık Bakanlığı');
      expect(recommendation.activityLevel, 'sedentary');
    });

    test('getTurkeySodiumAssessment should return correct values', () async {
      await service.loadStandards();

      final assessment = await service.getTurkeySodiumAssessment();

      expect(assessment.maxDailyGrams, 5.0);
      expect(assessment.currentTurkeyAverage, 18.0);
      expect(assessment.source, 'T.C. Sağlık Bakanlığı');
      expect(assessment.highSaltFoods.length, greaterThan(0));
    });

    test('getVersionInfo should return version information', () async {
      await service.loadStandards();

      final versionInfo = service.getVersionInfo();

      expect(versionInfo['who_version'], isNotNull);
      expect(versionInfo['turkey_version'], isNotNull);
    });

    test('getReferenceUrls should return reference URLs', () async {
      await service.loadStandards();

      final urls = service.getReferenceUrls();

      expect(urls['who'], contains('who.int'));
      expect(urls['turkey'], contains('saglik.gov.tr'));
    });
  });
}
