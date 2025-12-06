import 'package:flutter/material.dart';
import '../../../models/daily_metric_model.dart';
import '../../../services/firestore_service.dart';

import 'dart:async';
import '../../../models/user_model.dart';
import '../../../models/health_record_model.dart';
import '../../../services/insights_service.dart';
import '../../../core/authentication/viewmodels/auth_provider.dart';

class HomeProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final InsightsService _insightsService = InsightsService();

  DailyMetricModel? _todayMetric;
  List<Insight> _insights = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<DailyMetricModel?>? _metricSubscription;
  UserModel? _currentUser; // Kullanıcı bilgisini sakla (lifestyle insights için gerekli)

  DailyMetricModel? get todayMetric => _todayMetric;
  List<Insight> get insights => _insights;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  @override
  void dispose() {
    _metricSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadData(String userId, UserModel? user) async {
    _isLoading = true;
    _errorMessage = null;
    _currentUser = user; // Kullanıcı bilgisini sakla
    notifyListeners();

    try {
      // 1. Günlük Metrikleri Canlı İzle (Stream)
      _metricSubscription?.cancel();
      _metricSubscription = _firestoreService.getTodayMetricStream(userId).listen((metric) {
        _todayMetric = metric;

        // Metrik her değiştiğinde yaşam tarzı analizini güncelle
        if (_todayMetric != null && _currentUser != null) {
          _updateLifestyleInsights(_todayMetric!, _currentUser!);
        }

        notifyListeners();
      }, onError: (e) {
        debugPrint('HomeProvider: Stream error - $e');
      });

      // İlk veriyi manuel çekelim ki UI hemen dolsun (Stream bazen gecikebilir)
      _todayMetric = await _firestoreService.getTodayMetric(userId);

      // 2. Sağlık Kayıtlarını Yükle (Son kayıt)
      final healthRecords = await _firestoreService.getHealthRecords(userId, limit: 1);
      final latestRecord = healthRecords.isNotEmpty ? healthRecords.first : null;

      // 3. Analizleri Oluştur
      _insights = [];

      // Level 1: Profil (WHO standartlarına göre)
      if (user != null) {
        final profileInsights = await _insightsService.analyzeProfile(user);
        _insights.addAll(profileInsights);

        // Level 2: Hastalık Riski (ML Destekli)
        final diseaseInsights = await _insightsService.analyzeDiseaseRisks(user, latestRecord);
        _insights.addAll(diseaseInsights);
      }

      // Level 3: Yaşam Tarzı (WHO ve T.C. Sağlık Bakanlığı standartlarına göre)
      if (_todayMetric != null && user != null) {
        final lifestyleInsights = await _insightsService.analyzeLifestyle(_todayMetric, user);
        _insights.addAll(lifestyleInsights);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('HomeProvider: Error loading data - $e');
      _errorMessage = 'Veriler yüklenemedi: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _updateLifestyleInsights(DailyMetricModel metric, UserModel user) async {
    // Mevcut lifestyle insight'larını temizle ve yenilerini ekle
    _insights.removeWhere((i) => i.category == 'lifestyle');
    final lifestyleInsights = await _insightsService.analyzeLifestyle(metric, user);
    _insights.addAll(lifestyleInsights);
  }

  // Eski metod uyumluluğu için (kaldırılabilir veya loadData'ya yönlendirilebilir)
  Future<void> loadTodayMetrics(String userId) async {
    // Basitçe sadece metriği yenilemek istersek
    _todayMetric = await _firestoreService.getTodayMetric(userId);
    notifyListeners();
  }

  Future<void> updateSteps(String userId, int steps) async {
    try {
      await _firestoreService.createOrUpdateTodayMetric(
        userId: userId,
        steps: steps,
      );
      await loadTodayMetrics(userId);
    } catch (e) {
      _errorMessage = 'Adım güncellenemedi: $e';
      notifyListeners();
    }
  }

  Future<void> addWater(String userId, double amount) async {
    try {
      final currentWater = _todayMetric?.waterIntake ?? 0.0;
      await _firestoreService.createOrUpdateTodayMetric(
        userId: userId,
        water: currentWater + amount,
      );
      await loadTodayMetrics(userId);
    } catch (e) {
      _errorMessage = 'Su eklenemedi: $e';
      notifyListeners();
    }
  }

  Future<void> updateCalories(String userId, int calories) async {
    try {
      await _firestoreService.createOrUpdateTodayMetric(
        userId: userId,
        calories: calories,
      );
      await loadTodayMetrics(userId);
    } catch (e) {
      _errorMessage = 'Kalori güncellenemedi: $e';
      notifyListeners();
    }
  }

  Future<void> updateSleep(String userId, int hours) async {
    try {
      await _firestoreService.createOrUpdateTodayMetric(
        userId: userId,
        sleep: hours,
      );
      await loadTodayMetrics(userId);
    } catch (e) {
      _errorMessage = 'Uyku güncellenemedi: $e';
      notifyListeners();
    }
  }
}
