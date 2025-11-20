import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../config/app_colors.dart';
import '../../../services/firestore_service.dart';
import '../../../models/daily_metric_model.dart';
import '../../../core/authentication/viewmodels/auth_provider.dart';

class TrendsScreen extends StatefulWidget {
  const TrendsScreen({super.key});

  @override
  State<TrendsScreen> createState() => _TrendsScreenState();
}

class _TrendsScreenState extends State<TrendsScreen> {
  String _selectedPeriod = 'week'; // week, month
  bool _isLoading = true;
  List<DailyMetricModel> _history = [];
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.currentUser?.anonymousId;
      
      if (userId != null) {
        // Hafta için 7, Ay için 30 gün
        final days = _selectedPeriod == 'week' ? 7 : 30;
        final history = await _firestoreService.getDailyMetricsHistory(userId, days: days);
        
        setState(() {
          _history = history;
        });
      }
    } catch (e) {
      debugPrint('TrendsScreen: Error loading history - $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNeutral,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Trendler'),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Period Selector
              _buildPeriodSelector(),

              const SizedBox(height: 20),

              // Steps Chart
              _buildChartCard(
                title: 'Adım Sayısı',
                icon: Icons.directions_walk,
                color: AppColors.primaryTeal,
                chart: _buildStepsChart(),
              ),

              const SizedBox(height: 16),

              // Water Chart
              _buildChartCard(
                title: 'Su Tüketimi',
                icon: Icons.water_drop,
                color: AppColors.accentBlue,
                chart: _buildWaterChart(),
              ),

              const SizedBox(height: 16),

              // Calories Chart
              _buildChartCard(
                title: 'Kalori',
                icon: Icons.local_fire_department,
                color: AppColors.alertOrange,
                chart: _buildCaloriesChart(),
              ),

              const SizedBox(height: 20),

              // Stats Summary
              _buildStatsSummary(),
            ],
          ),
        ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildPeriodButton('Hafta', 'week'),
          ),
          Expanded(
            child: _buildPeriodButton('Ay', 'month'),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String label, String value) {
    final isSelected = _selectedPeriod == value;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPeriod = value;
        });
        _loadHistory();
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryTeal : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildChartCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget chart,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: _history.isEmpty 
              ? const Center(child: Text('Veri yok')) 
              : chart,
          ),
        ],
      ),
    );
  }

  Widget _buildStepsChart() {
    final spots = _history.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.steps.toDouble());
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < _history.length) {
                  final date = _history[value.toInt()].date;
                  return Text(
                    DateFormat('E', 'tr_TR').format(date), // Gün ismi
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primaryTeal,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primaryTeal.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterChart() {
    final spots = _history.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.waterIntake);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < _history.length) {
                  final date = _history[value.toInt()].date;
                  return Text(
                    DateFormat('E', 'tr_TR').format(date),
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.accentBlue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.accentBlue.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaloriesChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < _history.length) {
                  final date = _history[value.toInt()].date;
                  return Text(
                    DateFormat('E', 'tr_TR').format(date),
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: _history.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.calorieEstimate.toDouble(),
                color: AppColors.alertOrange,
                width: 12,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatsSummary() {
    if (_history.isEmpty) return const SizedBox.shrink();

    final avgSteps = (_history.map((m) => m.steps).reduce((a, b) => a + b) / _history.length).toInt();
    final totalWater = _history.map((m) => m.waterIntake).reduce((a, b) => a + b);
    final totalCalories = _history.map((m) => m.calorieEstimate).reduce((a, b) => a + b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryTeal, AppColors.primaryTealLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_selectedPeriod == 'week' ? 'Bu Hafta' : 'Bu Ay'} Özeti',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('Ort. Adım', '$avgSteps', Icons.directions_walk),
              _buildStatItem('Top. Su', '${totalWater.toStringAsFixed(1)} L', Icons.water_drop),
              _buildStatItem('Top. Kalori', '$totalCalories', Icons.local_fire_department),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
