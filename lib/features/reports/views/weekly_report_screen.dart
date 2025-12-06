import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../providers/reports_provider.dart';
import 'package:intl/intl.dart';

class WeeklyReportScreen extends StatelessWidget {
  const WeeklyReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNeutral,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Haftalık Rapor',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: Consumer<ReportsProvider>(
        builder: (context, provider, _) {
          final report = provider.weeklyReport;

          if (provider.isWeeklyLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (report == null) {
            return Center(
              child: Text('Haftalık rapor bulunamadı'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildPeriodHeader(context, report),
                const SizedBox(height: 20),
                _buildWeeklySummary(context, report),
                const SizedBox(height: 20),
                _buildTrendsSection(context, report),
                const SizedBox(height: 20),
                _buildGoalAchievement(context, report),
                const SizedBox(height: 20),
                if (report.recommendations.isNotEmpty)
                  _buildRecommendations(context, report),
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
          colors: [AppColors.accentGreen, AppColors.success],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            '${DateFormat('d MMM', 'tr_TR').format(report.weekStartDate)} - ${DateFormat('d MMM yyyy', 'tr_TR').format(report.weekEndDate)}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Son 7 Gün',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklySummary(BuildContext context, report) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Haftalık Ortalamalar',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow(
              context,
              'Adım',
              '${report.avgSteps.toStringAsFixed(0)}/gün',
              report.stepsChangeVsPreviousWeek,
            ),
            const Divider(),
            _buildSummaryRow(
              context,
              'Su',
              '${report.avgWaterIntake.toStringAsFixed(1)}L/gün',
              report.waterChangeVsPreviousWeek,
            ),
            const Divider(),
            _buildSummaryRow(
              context,
              'Kalori',
              '${report.avgCalories.toStringAsFixed(0)} kcal/gün',
              report.caloriesChangeVsPreviousWeek,
            ),
            const Divider(),
            _buildSummaryRow(
              context,
              'Uyku',
              '${report.avgSleepQuality.toStringAsFixed(1)}/10',
              report.sleepChangeVsPreviousWeek,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendsSection(BuildContext context, report) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trendler',
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
            _buildTrendRow(context, 'Genel Sağlık', report.overallHealthTrend),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalAchievement(BuildContext context, report) {
    final percentage = (report.weeklyGoalAchievement * 100).toInt();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Haftalık Başarı',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              '${report.daysGoalAchieved} / ${report.totalDays} gün',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentGreen,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hedefe Ulaşıldı (%$percentage)',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (report.bestDay != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'En İyi Gün: ${DateFormat('d MMMM', 'tr_TR').format(report.bestDay!)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '${report.bestDaySteps} adım',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentGreen,
                    ),
              ),
            ],
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
                Icon(Icons.lightbulb, color: AppColors.accentGreen),
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
                        color: AppColors.accentGreen,
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

  Widget _buildSummaryRow(BuildContext context, String label, String value, double? change) {
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
