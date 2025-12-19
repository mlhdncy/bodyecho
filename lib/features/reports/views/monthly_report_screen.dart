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
          'Monthly Report',
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
              child: Text('Monthly report not found'),
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
                _buildMLRiskSection(context, report),
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
            '${DateFormat('MMM d', 'en_US').format(report.monthStartDate)} - ${DateFormat('MMM d, yyyy', 'en_US').format(report.monthEndDate)}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Last 30 Days',
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
              'Monthly Summary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildMetricRow(
              context,
              'Total Steps',
              '${(report.totalSteps / 1000).toStringAsFixed(1)}K',
              report.stepsChangeVsPreviousMonth,
            ),
            const Divider(),
            _buildMetricRow(
              context,
              'Daily Avg. Steps',
              '${report.avgSteps.toStringAsFixed(0)}',
              null,
            ),
            const Divider(),
            _buildMetricRow(
              context,
              'Total Water',
              '${report.totalWaterIntake.toStringAsFixed(1)}L',
              report.waterChangeVsPreviousMonth,
            ),
            const Divider(),
            _buildMetricRow(
              context,
              'Total Calories',
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
              'Monthly Achievement',
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
                  'Successful Days',
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: Colors.grey[300],
                ),
                _buildStatColumn(
                  context,
                  '$percentage%',
                  'Success Rate',
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
                          'Best Day',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMM d', 'en_US').format(report.bestDay!),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          '${report.bestDaySteps} steps',
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
                          'Lowest Day',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMM d', 'en_US').format(report.worstDay!),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          '${report.worstDaySteps} steps',
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
              'Long-term Trends',
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
            _buildTrendRow(context, 'Risk Scores', report.riskTrend),
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
              'Achievements',
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
                  'Next Month Goals',
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
        {'name': 'Diabetes', 'value': report.diabetesRisk as double, 'change': report.diabetesRiskChange},
      if (report.highSugarRisk != null)
        {'name': 'High Sugar', 'value': report.highSugarRisk as double, 'change': report.highSugarRiskChange},
      if (report.obesityRisk != null)
        {'name': 'Obesity', 'value': report.obesityRisk as double, 'change': report.obesityRiskChange},
      if (report.cancerRisk != null)
        {'name': 'Cancer', 'value': report.cancerRisk as double, 'change': report.cancerRiskChange},
      if (report.highCholesterolRisk != null)
        {'name': 'High Cholesterol', 'value': report.highCholesterolRisk as double, 'change': report.cholesterolRiskChange},
      if (report.lowActivityRisk != null)
        {'name': 'Low Activity', 'value': report.lowActivityRisk as double, 'change': null},
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
              final change = risk['change'] as double?;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(risk['name'] as String),
                        Row(
                          children: [
                            Text(
                              '%$percentage',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _getRiskColor(percentage),
                              ),
                            ),
                            if (change != null) ...[
                              const SizedBox(width: 8),
                              _buildRiskChangeIndicator(change),
                            ],
                          ],
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

  Widget _buildRiskChangeIndicator(double change) {
    final changePercent = (change * 100).toInt();
    final isImproving = change < 0; // Risk azalıyorsa iyi
    final color = isImproving ? Colors.green : Colors.red;

    return Row(
      children: [
        Icon(
          isImproving ? Icons.arrow_downward : Icons.arrow_upward,
          size: 12,
          color: color,
        ),
        Text(
          '${changePercent.abs()}%',
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getRiskColor(int percentage) {
    if (percentage < 30) return Colors.green;
    if (percentage < 60) return Colors.orange;
    return Colors.red;
  }
}
