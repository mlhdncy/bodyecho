import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../config/app_colors.dart';
import '../../../core/authentication/viewmodels/auth_provider.dart';
import '../../../services/health_standards_service.dart';
import '../../../services/insights_service.dart';
import '../../../services/firestore_service.dart';
import '../../home/viewmodels/home_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// 🔧 Debug Sayfası
///
/// Uygulama geliştiriciler için debug ve test arayüzü.
/// Tüm uygulama verileri, sistem bilgileri ve test araçları burada.
class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  final HealthStandardsService _healthStandards = HealthStandardsService();
  final FirestoreService _firestore = FirestoreService();

  bool _isLoadingStandards = false;
  Map<String, String>? _versionInfo;
  Map<String, String>? _referenceUrls;
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _loadDebugInfo();
  }

  Future<void> _loadDebugInfo() async {
    setState(() => _isLoadingStandards = true);

    try {
      // Load health standards
      await _healthStandards.loadStandards();
      _versionInfo = _healthStandards.getVersionInfo();
      _referenceUrls = _healthStandards.getReferenceUrls();

      // Get package info
      _packageInfo = await PackageInfo.fromPlatform();
    } catch (e) {
      debugPrint('Debug info load error: $e');
    }

    setState(() => _isLoadingStandards = false);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final homeProvider = context.watch<HomeProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: AppColors.backgroundNeutral,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade700,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.bug_report, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Debug Console',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {});
              _loadDebugInfo();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🔄 Debug bilgileri yenilendi'),
                  backgroundColor: AppColors.accentGreen,
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Warning Banner
          _buildWarningBanner(),
          const SizedBox(height: 16),

          // App Info
          _buildAppInfoSection(),
          const SizedBox(height: 16),

          // User Profile
          if (user != null) ...[
            _buildUserProfileSection(user),
            const SizedBox(height: 16),
          ],

          // Health Standards
          _buildHealthStandardsSection(),
          const SizedBox(height: 16),

          // Current Metrics
          _buildMetricsSection(homeProvider),
          const SizedBox(height: 16),

          // Insights
          _buildInsightsSection(homeProvider),
          const SizedBox(height: 16),

          // System Info
          _buildSystemInfoSection(),
          const SizedBox(height: 16),

          // Actions
          _buildActionsSection(),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildWarningBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200, width: 2),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_rounded, color: Colors.red.shade700, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '⚠️ Geliştirici Modu',
                  style: TextStyle(
                    color: Colors.red.shade900,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Bu sayfa yalnızca test ve geliştirme amaçlıdır. '
                  'Hassas bilgiler içerir.',
                  style: TextStyle(
                    color: Colors.red.shade800,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfoSection() {
    return _buildDebugCard(
      title: '📱 Uygulama Bilgileri',
      icon: Icons.info_outline,
      color: AppColors.primaryTeal,
      child: Column(
        children: [
          _buildInfoRow('Uygulama', 'Body Echo'),
          _buildInfoRow('Versiyon', _packageInfo?.version ?? 'Yükleniyor...'),
          _buildInfoRow('Build Number', _packageInfo?.buildNumber ?? 'Yükleniyor...'),
          _buildInfoRow('Package Name', _packageInfo?.packageName ?? 'Yükleniyor...'),
          _buildInfoRow('Ortam', Platform.environment['FLUTTER_ENV'] ?? 'Development'),
        ],
      ),
    );
  }

  Widget _buildUserProfileSection(user) {
    final bmi = (user.height != null && user.weight != null && user.height! > 0)
        ? user.weight! / ((user.height! / 100) * (user.height! / 100))
        : null;

    return _buildDebugCard(
      title: '👤 Kullanıcı Profili',
      icon: Icons.person_outline,
      color: AppColors.accentBlue,
      actions: [
        IconButton(
          icon: const Icon(Icons.copy, size: 18),
          onPressed: () => _copyToClipboard(jsonEncode(user.toMap()), 'Profil'),
          tooltip: 'JSON Kopyala',
        ),
      ],
      child: Column(
        children: [
          _buildInfoRow('ID', user.id ?? 'N/A'),
          _buildInfoRow('Anonymous ID', user.anonymousId),
          _buildInfoRow('Ad Soyad', user.fullName),
          _buildInfoRow('Email', user.email),
          _buildInfoRow('Yaş', user.age?.toString() ?? 'Girilmemiş'),
          _buildInfoRow('Cinsiyet', user.gender ?? 'Girilmemiş'),
          _buildInfoRow('Boy', user.height != null ? '${user.height!.toInt()} cm' : 'Girilmemiş'),
          _buildInfoRow('Kilo', user.weight != null ? '${user.weight!.toStringAsFixed(1)} kg' : 'Girilmemiş'),
          if (bmi != null)
            _buildInfoRow('BMI (Hesaplanan)', bmi.toStringAsFixed(2)),
          _buildInfoRow('Aktivite Seviyesi', user.activityLevel ?? 'Girilmemiş'),
          _buildInfoRow('Avatar', user.avatarType),
          _buildInfoRow('Oluşturma', DateFormat('dd.MM.yyyy HH:mm').format(user.createdAt)),
          _buildInfoRow('Güncelleme', DateFormat('dd.MM.yyyy HH:mm').format(user.updatedAt)),
        ],
      ),
    );
  }

  Widget _buildHealthStandardsSection() {
    return _buildDebugCard(
      title: '🏥 Sağlık Standartları',
      icon: Icons.health_and_safety_outlined,
      color: AppColors.accentGreen,
      actions: [
        if (_isLoadingStandards)
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else
          IconButton(
            icon: const Icon(Icons.refresh, size: 18),
            onPressed: () async {
              setState(() => _isLoadingStandards = true);
              await _loadDebugInfo();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Standartlar yenilendi')),
                );
              }
            },
            tooltip: 'Standartları Yenile',
          ),
      ],
      child: Column(
        children: [
          // WHO Standards
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.verified, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'WHO Standards',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildInfoRow('Versiyon', _versionInfo?['who_version'] ?? 'Yükleniyor...'),
                _buildInfoRow('Güncelleme', _versionInfo?['who_updated'] ?? 'Yükleniyor...'),
                _buildInfoRow('Kaynak', _referenceUrls?['who'] ?? 'Yükleniyor...'),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Turkey MOH Standards
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '🇹🇷',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'T.C. Sağlık Bakanlığı Standards',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildInfoRow('Versiyon', _versionInfo?['turkey_version'] ?? 'Yükleniyor...'),
                _buildInfoRow('Güncelleme', _versionInfo?['turkey_updated'] ?? 'Yükleniyor...'),
                _buildInfoRow('Kaynak', _referenceUrls?['turkey'] ?? 'Yükleniyor...'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsSection(HomeProvider homeProvider) {
    final metric = homeProvider.todayMetric;

    return _buildDebugCard(
      title: '📊 Güncel Metrikler',
      icon: Icons.timeline,
      color: AppColors.alertOrange,
      actions: [
        if (metric != null)
          IconButton(
            icon: const Icon(Icons.copy, size: 18),
            onPressed: () => _copyToClipboard(
              jsonEncode(metric.toMap()),
              'Metrikler',
            ),
            tooltip: 'JSON Kopyala',
          ),
      ],
      child: metric != null
          ? Column(
              children: [
                _buildInfoRow('Tarih', DateFormat('dd.MM.yyyy').format(metric.date)),
                _buildInfoRow('Adım Sayısı', '${metric.steps} adım'),
                _buildInfoRow('Su Tüketimi', '${metric.waterIntake.toStringAsFixed(2)} L'),
                _buildInfoRow('Kalori', '${metric.calorieEstimate} kcal'),
                _buildInfoRow('Uyku Kalitesi', '${metric.sleepQuality}/10'),
                const Divider(),
                _buildInfoRow('Adım İlerlemesi', '${(metric.stepsProgress * 100).toInt()}%'),
                _buildInfoRow('Su İlerlemesi', '${(metric.waterProgress * 100).toInt()}%'),
                _buildInfoRow('Kalori İlerlemesi', '${(metric.calorieProgress * 100).toInt()}%'),
                _buildInfoRow('Uyku İlerlemesi', '${(metric.sleepProgress * 100).toInt()}%'),
                _buildInfoRow(
                  'Genel İlerleme',
                  '${(metric.overallProgress * 100).toInt()}%',
                  isBold: true,
                ),
              ],
            )
          : const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Bugün için metrik yok'),
              ),
            ),
    );
  }

  Widget _buildInsightsSection(HomeProvider homeProvider) {
    final insights = homeProvider.insights;

    return _buildDebugCard(
      title: '💡 Insights (${insights.length})',
      icon: Icons.lightbulb_outline,
      color: AppColors.accentPurple,
      child: insights.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Henüz insight yok'),
              ),
            )
          : Column(
              children: insights
                  .asMap()
                  .entries
                  .map((entry) => _buildInsightItem(entry.key, entry.value))
                  .toList(),
            ),
    );
  }

  Widget _buildInsightItem(int index, Insight insight) {
    Color badgeColor;
    switch (insight.type) {
      case 'risk':
        badgeColor = Colors.red;
        break;
      case 'warning':
        badgeColor = Colors.orange;
        break;
      case 'success':
        badgeColor = Colors.green;
        break;
      default:
        badgeColor = Colors.blue;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: badgeColor.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: badgeColor.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '#${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.shade100,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: badgeColor.shade300),
                ),
                child: Text(
                  insight.type.toUpperCase(),
                  style: TextStyle(
                    color: badgeColor.shade900,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  insight.category,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (insight.source != null) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: badgeColor.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified, size: 10, color: badgeColor),
                      const SizedBox(width: 4),
                      Text(
                        insight.source!,
                        style: TextStyle(
                          fontSize: 8,
                          color: badgeColor.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            insight.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: badgeColor.shade900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            insight.message,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade800,
            ),
          ),
          if (insight.referenceUrl != null) ...[
            const SizedBox(height: 6),
            Text(
              '🔗 ${insight.referenceUrl}',
              style: TextStyle(
                fontSize: 10,
                color: Colors.blue.shade700,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSystemInfoSection() {
    return _buildDebugCard(
      title: '⚙️ Sistem Bilgileri',
      icon: Icons.settings_outlined,
      color: Colors.grey,
      child: Column(
        children: [
          _buildInfoRow('Platform', Platform.operatingSystem),
          _buildInfoRow('OS Versiyon', Platform.operatingSystemVersion),
          _buildInfoRow('Locale', Platform.localeName),
          _buildInfoRow('İşlemci Sayısı', '${Platform.numberOfProcessors}'),
          _buildInfoRow('Dart Versiyonu', Platform.version.split(' ').first),
        ],
      ),
    );
  }

  Widget _buildActionsSection() {
    return _buildDebugCard(
      title: '🔧 Test & Aksiyonlar',
      icon: Icons.build_outlined,
      color: Colors.deepPurple,
      child: Column(
        children: [
          _buildActionButton(
            'Standartları Yeniden Yükle',
            Icons.refresh,
            Colors.blue,
            () async {
              setState(() => _isLoadingStandards = true);
              await _loadDebugInfo();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Standartlar başarıyla yenilendi'),
                    backgroundColor: AppColors.accentGreen,
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 8),
          _buildActionButton(
            'Cache Temizle',
            Icons.clear_all,
            Colors.orange,
            () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Cache Temizle'),
                  content: const Text(
                    'Bu işlem uygulamayı yeniden başlatmanızı gerektirebilir. '
                    'Devam etmek istiyor musunuz?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('İptal'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('⚠️ Cache temizleme özelliği henüz aktif değil'),
                          ),
                        );
                      },
                      child: const Text('Temizle'),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          _buildActionButton(
            'Tüm Verileri Dışa Aktar (JSON)',
            Icons.download,
            Colors.green,
            () async {
              final authProvider = context.read<AuthProvider>();
              final homeProvider = context.read<HomeProvider>();

              final exportData = {
                'app_info': {
                  'version': _packageInfo?.version,
                  'build': _packageInfo?.buildNumber,
                  'package': _packageInfo?.packageName,
                },
                'user': authProvider.currentUser?.toMap(),
                'metrics': homeProvider.todayMetric?.toMap(),
                'insights': homeProvider.insights.map((i) => {
                  'title': i.title,
                  'message': i.message,
                  'type': i.type,
                  'category': i.category,
                  'source': i.source,
                  'referenceUrl': i.referenceUrl,
                }).toList(),
                'health_standards': {
                  'who': _versionInfo?['who_version'],
                  'turkey': _versionInfo?['turkey_version'],
                },
                'export_date': DateTime.now().toIso8601String(),
              };

              final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
              await Clipboard.setData(ClipboardData(text: jsonString));

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('📋 Tüm veriler JSON olarak kopyalandı!'),
                    backgroundColor: AppColors.accentGreen,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDebugCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
    List<Widget>? actions,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
                if (actions != null) ...actions,
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Future<void> _copyToClipboard(String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('📋 $label JSON kopyalandı!'),
          backgroundColor: AppColors.accentGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
