import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../providers/reports_provider.dart';
import 'package:intl/intl.dart';

class MonthlyReportScreen extends StatelessWidget {
  const MonthlyReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNeutral,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Aylık Rapor',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: Consumer<ReportsProvider>(
        builder: (context, provider, _) {
          final report = provider.monthlyReport;

          if (provider.isMonthlyLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (report == null) {
            return const Center(
              child: Text('Aylık rapor bulunamadı'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildPeriodHeader(context, report),
                const SizedBox(height: 20),
                _buildMonthlySummary(context, report),
                const SizedBox(height: 20),
                _buildGoalAchievement(context, report),
                const SizedBox(height: 20),
                _buildTrends(context, report),
                const SizedBox(height: 20),
                if (report.achievements.isNotEmpty)
                  _buildAchievements(context, report),
                if (report.achievements.isNotEmpty)
                  const SizedBox(height: 20),
                if (report.recommendations.isNotEmpty)
                  _buildRecommendations(context, report),
                if (report.nextMonthGoals.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _buildNextMonthGoals(context, report),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPeriodHeader(BuildContext context, report) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryTeal, AppColors.primaryTealLight],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            '${DateFormat('d MMM', 'tr_TR').format(report.monthStartDate)} - ${DateFormat('d MMM yyyy', 'tr_TR').format(report.monthEndDate)}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Son 30 Gün',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlySummary(BuildContext context, report) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aylık Özet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildMetricRow(
              context,
              'Toplam Adım',
              '${(report.totalSteps / 1000).toStringAsFixed(1)}K',
              report.stepsChangeVsPreviousMonth,
            ),
            const Divider(),
            _buildMetricRow(
              context,
              'Günlük Ort. Adım',
              '${report.avgSteps.toStringAsFixed(0)}',
              null,
            ),
            const Divider(),
            _buildMetricRow(
              context,
              'Toplam Su',
              '${report.totalWaterIntake.toStringAsFixed(1)}L',
              report.waterChangeVsPreviousMonth,
            ),
            const Divider(),
            _buildMetricRow(
              context,
              'Toplam Kalori',
              '${(report.totalCalories / 1000).toStringAsFixed(1)}K',
              report.caloriesChangeVsPreviousMonth,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalAchievement(BuildContext context, report) {
    final percentage = (report.monthlyGoalAchievement * 100).toInt();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Aylık Başarı',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn(
                  context,
                  '${report.daysGoalAchieved}',
                  'Başarılı Gün',
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: Colors.grey[300],
                ),
                _buildStatColumn(
                  context,
                  '%$percentage',
                  'Başarı Oranı',
                ),
              ],
            ),
            if (report.bestDay != null && report.worstDay != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'En İyi Gün',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('d MMM', 'tr_TR').format(report.bestDay!),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          '${report.bestDaySteps} adım',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'En Düşük Gün',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('d MMM', 'tr_TR').format(report.worstDay!),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          '${report.worstDaySteps} adım',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTrends(BuildContext context, report) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Uzun Vadeli Trendler',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildTrendRow(context, 'Adım', report.stepsTrend),
            const Divider(),
            _buildTrendRow(context, 'Su', report.waterTrend),
            const Divider(),
            _buildTrendRow(context, 'Uyku', report.sleepTrend),
            const Divider(),
            _buildTrendRow(context, 'Risk Skorları', report.riskTrend),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievements(BuildContext context, report) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Başarılar',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...report.achievements.map((achievement) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Text(
                      achievement.icon,
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            achievement.title,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            achievement.description,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations(BuildContext context, report) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: AppColors.primaryTeal),
                const SizedBox(width: 8),
                Text(
                  'Öneriler',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...report.recommendations.map<Widget>((rec) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4, right: 8),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.primaryTeal,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(child: Text(rec)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildNextMonthGoals(BuildContext context, report) {
    return Card(
      elevation: 2,
      color: AppColors.primaryTeal.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flag, color: AppColors.primaryTeal),
                const SizedBox(width: 8),
                Text(
                  'Gelecek Ay Hedefleri',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryTeal,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...report.nextMonthGoals.map<Widget>((goal) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 20,
                      color: AppColors.primaryTeal,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(goal)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryTeal,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildMetricRow(BuildContext context, String label, String value, double? change) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Row(
          children: [
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (change != null) ...[
              const SizedBox(width: 8),
              _buildChangeIndicator(change),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildTrendRow(BuildContext context, String label, String trend) {
    final icon = trend == 'improving'
        ? Icons.trending_up
        : trend == 'declining'
            ? Icons.trending_down
            : Icons.trending_flat;

    final color = trend == 'improving'
        ? Colors.green
        : trend == 'declining'
            ? Colors.red
            : Colors.grey;

    final text = trend == 'improving'
        ? 'İyileşiyor'
        : trend == 'declining'
            ? 'Düşüşte'
            : 'Stabil';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChangeIndicator(double change) {
    final isPositive = change > 0;
    final color = isPositive ? Colors.green : Colors.red;

    return Row(
      children: [
        Icon(
          isPositive ? Icons.arrow_upward : Icons.arrow_downward,
          size: 14,
          color: color,
        ),
        Text(
          '${change.abs().toStringAsFixed(0)}%',
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
