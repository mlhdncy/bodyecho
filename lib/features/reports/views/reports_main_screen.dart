import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../../../core/authentication/viewmodels/auth_provider.dart';
import '../providers/reports_provider.dart';
import 'daily_report_screen.dart';
import 'weekly_report_screen.dart';
import 'monthly_report_screen.dart';
import 'package:intl/intl.dart';

class ReportsMainScreen extends StatefulWidget {
  const ReportsMainScreen({super.key});

  @override
  State<ReportsMainScreen> createState() => _ReportsMainScreenState();
}

class _ReportsMainScreenState extends State<ReportsMainScreen> {
  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  void _loadReports() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final reportsProvider = context.read<ReportsProvider>();

      if (authProvider.currentUser != null) {
        reportsProvider.loadAllReports(
          userId: authProvider.currentUser!.anonymousId,
          userProfile: authProvider.currentUser!,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNeutral,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Raporlarım',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final authProvider = context.read<AuthProvider>();
              final reportsProvider = context.read<ReportsProvider>();
              if (authProvider.currentUser != null) {
                reportsProvider.loadAllReports(
                  userId: authProvider.currentUser!.anonymousId,
                  userProfile: authProvider.currentUser!,
                  forceRefresh: true,
                );
              }
            },
          ),
        ],
      ),
      body: Consumer<ReportsProvider>(
        builder: (context, reportsProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Günlük Rapor Kartı
                _buildDailyReportCard(context, reportsProvider),

                const SizedBox(height: 16),

                // Haftalık Rapor Kartı
                _buildWeeklyReportCard(context, reportsProvider),

                const SizedBox(height: 16),

                // Aylık Rapor Kartı
                _buildMonthlyReportCard(context, reportsProvider),

                const SizedBox(height: 24),

                // Bilgi
                _buildInfoCard(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDailyReportCard(BuildContext context, ReportsProvider provider) {
    final isLoading = provider.isDailyLoading;
    final hasError = provider.dailyError != null;
    final report = provider.dailyReport;
    final lastUpdate = provider.dailyLastUpdate;

    return _buildReportCard(
      context: context,
      title: 'Günlük Rapor',
      subtitle: 'Son 24 saat',
      icon: Icons.today,
      iconColor: AppColors.primaryBlue,
      isLoading: isLoading,
      hasError: hasError,
      errorMessage: provider.dailyError,
      lastUpdate: lastUpdate,
      onTap: () {
        if (report != null && !isLoading) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const DailyReportScreen(),
            ),
          );
        }
      },
      statsWidget: report != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${report.steps} adım',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '${report.waterIntake.toStringAsFixed(1)}L su',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  'Hedef: %${(report.dailyGoalAchievement * 100).toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildWeeklyReportCard(BuildContext context, ReportsProvider provider) {
    final isLoading = provider.isWeeklyLoading;
    final hasError = provider.weeklyError != null;
    final report = provider.weeklyReport;
    final lastUpdate = provider.weeklyLastUpdate;

    return _buildReportCard(
      context: context,
      title: 'Haftalık Rapor',
      subtitle: 'Son 7 gün',
      icon: Icons.calendar_view_week,
      iconColor: AppColors.primaryGreen,
      isLoading: isLoading,
      hasError: hasError,
      errorMessage: provider.weeklyError,
      lastUpdate: lastUpdate,
      onTap: () {
        if (report != null && !isLoading) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const WeeklyReportScreen(),
            ),
          );
        }
      },
      statsWidget: report != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ort: ${report.avgSteps.toStringAsFixed(0)} adım/gün',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '${report.daysGoalAchieved}/${report.totalDays} gün hedefe ulaştı',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  _getTrendText(report.stepsTrend),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getTrendColor(report.stepsTrend),
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildMonthlyReportCard(BuildContext context, ReportsProvider provider) {
    final isLoading = provider.isMonthlyLoading;
    final hasError = provider.monthlyError != null;
    final report = provider.monthlyReport;
    final lastUpdate = provider.monthlyLastUpdate;

    return _buildReportCard(
      context: context,
      title: 'Aylık Rapor',
      subtitle: 'Son 30 gün',
      icon: Icons.calendar_month,
      iconColor: AppColors.accentOrange,
      isLoading: isLoading,
      hasError: hasError,
      errorMessage: provider.monthlyError,
      lastUpdate: lastUpdate,
      onTap: () {
        if (report != null && !isLoading) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const MonthlyReportScreen(),
            ),
          );
        }
      },
      statsWidget: report != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Toplam: ${(report.totalSteps / 1000).toStringAsFixed(1)}K adım',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '${report.daysGoalAchieved}/${report.totalDays} gün başarılı',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (report.achievements.isNotEmpty)
                  Text(
                    '${report.achievements.length} rozet kazanıldı',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.accentOrange,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
              ],
            )
          : null,
    );
  }

  Widget _buildReportCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isLoading,
    required bool hasError,
    String? errorMessage,
    DateTime? lastUpdate,
    required VoidCallback onTap,
    Widget? statsWidget,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: isLoading || hasError ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  ),
                  if (isLoading)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                ],
              ),
              if (hasError) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[700], size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Yüklenemedi',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (statsWidget != null) ...[
                const SizedBox(height: 16),
                statsWidget,
              ],
              if (lastUpdate != null && !hasError) ...[
                const SizedBox(height: 12),
                Text(
                  'Son güncelleme: ${_formatLastUpdate(lastUpdate)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                        fontSize: 11,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.primaryBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Raporlar uygulamayı her açtığınızda otomatik güncellenir. Elle güncellemek için ↻ ikonuna tıklayın.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primaryBlue,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatLastUpdate(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) {
      return 'Az önce';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} dakika önce';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} saat önce';
    } else {
      return DateFormat('dd MMM HH:mm', 'tr_TR').format(dateTime);
    }
  }

  String _getTrendText(String trend) {
    switch (trend) {
      case 'improving':
        return '↗ İyileşiyor';
      case 'declining':
        return '↘ Düşüşte';
      default:
        return '→ Stabil';
    }
  }

  Color _getTrendColor(String trend) {
    switch (trend) {
      case 'improving':
        return Colors.green;
      case 'declining':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
