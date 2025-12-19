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
          'Weekly Report',
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
              child: Text('Weekly report not found'),
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
                _buildMLRiskSection(context, report),
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
            '${DateFormat('MMM d', 'en_US').format(report.weekStartDate)} - ${DateFormat('MMM d, yyyy', 'en_US').format(report.weekEndDate)}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Last 7 Days',
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
              'Weekly Averages',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow(
              context,
              'Steps',
              '${report.avgSteps.toStringAsFixed(0)}/day',
              report.stepsChangeVsPreviousWeek,
            ),
            const Divider(),
            _buildSummaryRow(
              context,
              'Water',
              '${report.avgWaterIntake.toStringAsFixed(1)}L/day',
              report.waterChangeVsPreviousWeek,
            ),
            const Divider(),
            _buildSummaryRow(
              context,
              'Calories',
              '${report.avgCalories.toStringAsFixed(0)} kcal/day',
              report.caloriesChangeVsPreviousWeek,
            ),
            const Divider(),
            _buildSummaryRow(
              context,
              'Sleep',
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
              'Trends',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildTrendRow(context, 'Steps', report.stepsTrend),
            const Divider(),
            _buildTrendRow(context, 'Water', report.waterTrend),
            const Divider(),
            _buildTrendRow(context, 'Sleep', report.sleepTrend),
            const Divider(),
            _buildTrendRow(context, 'Overall Health', report.overallHealthTrend),
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
              'Weekly Achievement',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              '${report.daysGoalAchieved} / ${report.totalDays} days',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentGreen,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Goal Reached ($percentage%)',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (report.bestDay != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Best Day: ${DateFormat('MMMM d', 'en_US').format(report.bestDay!)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '${report.bestDaySteps} steps',
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
                  'Recommendations',
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
        ? 'Improving'
        : trend == 'declining'
            ? 'Declining'
            : 'Stable';

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

  Widget _buildMLRiskSection(BuildContext context, report) {
    final risks = <Map<String, dynamic>>[
      if (report.diabetesRisk != null)
        {'name': 'Diabetes', 'value': report.diabetesRisk as double},
      if (report.highSugarRisk != null)
        {'name': 'High Sugar', 'value': report.highSugarRisk as double},
      if (report.obesityRisk != null)
        {'name': 'Obesity', 'value': report.obesityRisk as double},
      if (report.cancerRisk != null)
        {'name': 'Cancer', 'value': report.cancerRisk as double},
      if (report.highCholesterolRisk != null)
        {'name': 'High Cholesterol', 'value': report.highCholesterolRisk as double},
      if (report.lowActivityRisk != null)
        {'name': 'Low Activity', 'value': report.lowActivityRisk as double},
    ];

    if (risks.isEmpty) return const SizedBox.shrink();

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
                Icon(Icons.analytics, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'ML Risk Analysis',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...risks.map((risk) {
              final percentage = ((risk['value'] as double) * 100).toInt();
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(risk['name'] as String),
                        Text(
                          '%$percentage',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getRiskColor(percentage),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: risk['value'] as double,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation(
                        _getRiskColor(percentage),
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

  Color _getRiskColor(int percentage) {
    if (percentage < 30) return Colors.green;
    if (percentage < 60) return Colors.orange;
    return Colors.red;
  }
}
