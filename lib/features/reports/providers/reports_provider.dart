import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../models/daily_report_model.dart';
import '../models/weekly_report_model.dart';
import '../models/monthly_report_model.dart';
import '../services/report_analysis_service.dart';

class ReportsProvider with ChangeNotifier {
  final ReportAnalysisService _reportService = ReportAnalysisService();

  // Reports
  DailyReportModel? _dailyReport;
  WeeklyReportModel? _weeklyReport;
  MonthlyReportModel? _monthlyReport;

  // Loading states
  bool _isDailyLoading = false;
  bool _isWeeklyLoading = false;
  bool _isMonthlyLoading = false;

  // Error messages
  String? _dailyError;
  String? _weeklyError;
  String? _monthlyError;

  // Cache timestamps
  DateTime? _dailyLastUpdate;
  DateTime? _weeklyLastUpdate;
  DateTime? _monthlyLastUpdate;

  // Getters
  DailyReportModel? get dailyReport => _dailyReport;
  WeeklyReportModel? get weeklyReport => _weeklyReport;
  MonthlyReportModel? get monthlyReport => _monthlyReport;

  bool get isDailyLoading => _isDailyLoading;
  bool get isWeeklyLoading => _isWeeklyLoading;
  bool get isMonthlyLoading => _isMonthlyLoading;

  String? get dailyError => _dailyError;
  String? get weeklyError => _weeklyError;
  String? get monthlyError => _monthlyError;

  DateTime? get dailyLastUpdate => _dailyLastUpdate;
  DateTime? get weeklyLastUpdate => _weeklyLastUpdate;
  DateTime? get monthlyLastUpdate => _monthlyLastUpdate;

  /// Günlük raporu yükle
  Future<void> loadDailyReport({
    required String userId,
    required UserModel userProfile,
    bool forceRefresh = false,
  }) async {
    // Cache kontrolü: 1 saat içinde güncellenmişse yeniden çekme
    if (!forceRefresh && _shouldUseCachedDaily()) {
      return;
    }

    _isDailyLoading = true;
    _dailyError = null;
    notifyListeners();

    try {
      _dailyReport = await _reportService.generateDailyReport(
        userId: userId,
        userProfile: userProfile,
      );
      _dailyLastUpdate = DateTime.now();
      _isDailyLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('ReportsProvider: Daily report error - $e');
      _dailyError = 'Günlük rapor yüklenemedi: $e';
      _isDailyLoading = false;
      notifyListeners();
    }
  }

  /// Haftalık raporu yükle
  Future<void> loadWeeklyReport({
    required String userId,
    required UserModel userProfile,
    bool forceRefresh = false,
  }) async {
    // Cache kontrolü: 6 saat içinde güncellenmişse yeniden çekme
    if (!forceRefresh && _shouldUseCachedWeekly()) {
      return;
    }

    _isWeeklyLoading = true;
    _weeklyError = null;
    notifyListeners();

    try {
      _weeklyReport = await _reportService.generateWeeklyReport(
        userId: userId,
        userProfile: userProfile,
      );
      _weeklyLastUpdate = DateTime.now();
      _isWeeklyLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('ReportsProvider: Weekly report error - $e');
      _weeklyError = 'Haftalık rapor yüklenemedi: $e';
      _isWeeklyLoading = false;
      notifyListeners();
    }
  }

  /// Aylık raporu yükle
  Future<void> loadMonthlyReport({
    required String userId,
    required UserModel userProfile,
    bool forceRefresh = false,
  }) async {
    // Cache kontrolü: 24 saat içinde güncellenmişse yeniden çekme
    if (!forceRefresh && _shouldUseCachedMonthly()) {
      return;
    }

    _isMonthlyLoading = true;
    _monthlyError = null;
    notifyListeners();

    try {
      _monthlyReport = await _reportService.generateMonthlyReport(
        userId: userId,
        userProfile: userProfile,
      );
      _monthlyLastUpdate = DateTime.now();
      _isMonthlyLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('ReportsProvider: Monthly report error - $e');
      _monthlyError = 'Aylık rapor yüklenemedi: $e';
      _isMonthlyLoading = false;
      notifyListeners();
    }
  }

  /// Tüm raporları yükle (paralel)
  Future<void> loadAllReports({
    required String userId,
    required UserModel userProfile,
    bool forceRefresh = false,
  }) async {
    await Future.wait([
      loadDailyReport(
          userId: userId, userProfile: userProfile, forceRefresh: forceRefresh),
      loadWeeklyReport(
          userId: userId, userProfile: userProfile, forceRefresh: forceRefresh),
      loadMonthlyReport(
          userId: userId, userProfile: userProfile, forceRefresh: forceRefresh),
    ]);
  }

  /// Cache kontrolü - Günlük rapor (1 saat)
  bool _shouldUseCachedDaily() {
    if (_dailyReport == null || _dailyLastUpdate == null) return false;
    final diff = DateTime.now().difference(_dailyLastUpdate!);
    return diff.inHours < 1;
  }

  /// Cache kontrolü - Haftalık rapor (6 saat)
  bool _shouldUseCachedWeekly() {
    if (_weeklyReport == null || _weeklyLastUpdate == null) return false;
    final diff = DateTime.now().difference(_weeklyLastUpdate!);
    return diff.inHours < 6;
  }

  /// Cache kontrolü - Aylık rapor (24 saat)
  bool _shouldUseCachedMonthly() {
    if (_monthlyReport == null || _monthlyLastUpdate == null) return false;
    final diff = DateTime.now().difference(_monthlyLastUpdate!);
    return diff.inHours < 24;
  }

  /// Cache'i temizle
  void clearCache() {
    _dailyReport = null;
    _weeklyReport = null;
    _monthlyReport = null;
    _dailyLastUpdate = null;
    _weeklyLastUpdate = null;
    _monthlyLastUpdate = null;
    notifyListeners();
  }
}
