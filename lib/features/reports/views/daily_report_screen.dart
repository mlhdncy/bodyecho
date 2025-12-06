import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../providers/reports_provider.dart';
import 'package:intl/intl.dart';

class DailyReportScreen extends StatelessWidget {
  const DailyReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNeutral,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Günlük Rapor',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: Consumer<ReportsProvider>(
        builder: (context, provider, _) {
          final report = provider.dailyReport;

          if (provider.isDailyLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (report == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.report_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Günlük rapor bulunamadı',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Tarih Başlığı
                _buildDateHeader(context, report.date),

                const SizedBox(height: 20),

                // Hedef Başarı Göstergesi
                _buildGoalProgress(context, report),

                const SizedBox(height: 20),

                // Aktivite Metrikleri
                _buildActivitySection(context, report),

                const SizedBox(height: 20),

                // Sağlık Metrikleri
                _buildHealthSection(context, report),

                const SizedBox(height: 20),

                // ML Risk Skorları
                _buildRiskScoresSection(context, report),

                const SizedBox(height: 20),

                // Öneriler
                _buildRecommendationsSection(context, report),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateHeader(BuildContext context, DateTime date) {
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
            DateFormat('d MMMM yyyy', 'tr_TR').format(date),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('EEEE', 'tr_TR').format(date),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalProgress(BuildContext context, report) {
    final percentage = (report.dailyGoalAchievement * 100).toInt();
    final color = percentage >= 80
        ? Colors.green
        : percentage >= 50
            ? Colors.orange
            : Colors.red;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Günlük Hedef Başarısı',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: report.dailyGoalAchievement,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                  Center(
                    child: Text(
                      '%$percentage',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitySection(BuildContext context, report) {
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
                Icon(Icons.directions_walk, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Aktivite',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMetricRow(
              context,
              'Adım',
              '${report.steps}',
              report.stepsChange,
            ),
            const Divider(),
            _buildMetricRow(
              context,
              'Su Tüketimi',
              '${report.waterIntake.toStringAsFixed(1)} L',
              report.waterChange,
            ),
            const Divider(),
            _buildMetricRow(
              context,
              'Kalori',
              '${report.calorieEstimate} kcal',
              report.calorieChange,
            ),
            const Divider(),
            _buildMetricRow(
              context,
              'Uyku Kalitesi',
              '${report.sleepQuality}/10',
              report.sleepQualityChange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthSection(BuildContext context, report) {
    if (report.avgBloodGlucose == null &&
        report.avgSystolicBP == null &&
        report.avgHeartRate == null) {
      return const SizedBox.shrink();
    }

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
                Icon(Icons.favorite, color: Colors.red[400]),
                const SizedBox(width: 8),
                Text(
                  'Sağlık Verileri',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (report.avgBloodGlucose != null)
              _buildHealthMetric(
                context,
                'Kan Şekeri',
                '${report.avgBloodGlucose.toStringAsFixed(0)} mg/dL',
              ),
            if (report.avgSystolicBP != null && report.avgDiastolicBP != null) ...[
              const Divider(),
              _buildHealthMetric(
                context,
                'Tansiyon',
                '${report.avgSystolicBP.toStringAsFixed(0)}/${report.avgDiastolicBP.toStringAsFixed(0)}',
              ),
            ],
            if (report.avgHeartRate != null) ...[
              const Divider(),
              _buildHealthMetric(
                context,
                'Nabız',
                '${report.avgHeartRate.toStringAsFixed(0)} bpm',
              ),
            ],
            if (report.avgTemperature != null) ...[
              const Divider(),
              _buildHealthMetric(
                context,
                'Vücut Isısı',
                '${report.avgTemperature.toStringAsFixed(1)} °C',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRiskScoresSection(BuildContext context, report) {
    final risks = [
      if (report.diabetesRisk != null)
        {'name': 'Diyabet', 'value': report.diabetesRisk},
      if (report.heartDiseaseRisk != null)
        {'name': 'Kalp Hastalığı', 'value': report.heartDiseaseRisk},
      if (report.obesityRisk != null)
        {'name': 'Obezite', 'value': report.obesityRisk},
      if (report.cancerRisk != null)
        {'name': 'Kanser', 'value': report.cancerRisk},
      if (report.highCholesterolRisk != null)
        {'name': 'Yüksek Kolesterol', 'value': report.highCholesterolRisk},
      if (report.lowActivityRisk != null)
        {'name': 'Düşük Aktivite', 'value': report.lowActivityRisk},
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
                  'ML Risk Analizi',
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

  Widget _buildRecommendationsSection(BuildContext context, report) {
    if (report.recommendations.isEmpty) return const SizedBox.shrink();

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
                Icon(Icons.lightbulb, color: Colors.green),
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
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        rec,
                        style: Theme.of(context).textTheme.bodyMedium,
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

  Widget _buildMetricRow(BuildContext context, String label, String value, double? change) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Row(
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
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

  Widget _buildHealthMetric(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
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

  Color _getRiskColor(int percentage) {
    if (percentage < 30) return Colors.green;
    if (percentage < 60) return Colors.orange;
    return Colors.red;
  }
}
