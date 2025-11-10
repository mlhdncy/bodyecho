import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../config/app_colors.dart';
import '../../../core/authentication/viewmodels/auth_provider.dart';
import '../../../models/activity_model.dart';
import '../viewmodels/activity_provider.dart';
import 'add_activity_screen.dart';

class ActivityLogScreen extends StatefulWidget {
  const ActivityLogScreen({super.key});

  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    final activityProvider = context.read<ActivityProvider>();
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser != null) {
      await activityProvider.loadActivities(authProvider.currentUser!.anonymousId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNeutral,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Aktivite Geçmişi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Show filter options
            },
          ),
        ],
      ),
      body: Consumer<ActivityProvider>(
        builder: (context, activityProvider, _) {
          if (activityProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (activityProvider.activities.isEmpty) {
            return _buildEmptyState(context);
          }

          return RefreshIndicator(
            onRefresh: _loadActivities,
            child: Column(
              children: [
                // Stats Summary
                _buildStatsSummary(context, activityProvider.activities),

                // Activities List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: activityProvider.activities.length,
                    itemBuilder: (context, index) {
                      final activity = activityProvider.activities[index];
                      return _buildActivityCard(context, activity);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddActivityScreen(),
            ),
          );
          if (result == true && mounted) {
            _loadActivities();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Aktivite Ekle'),
        backgroundColor: AppColors.buttonPrimary,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_run,
              size: 100,
              color: AppColors.textSecondary.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'Henüz aktivite yok',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'İlk aktivitenizi eklemek için aşağıdaki butona tıklayın',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSummary(BuildContext context, List<ActivityModel> activities) {
    final totalDuration = activities.fold<int>(
      0,
      (sum, activity) => sum + activity.duration,
    );
    final totalCalories = activities.fold<int>(
      0,
      (sum, activity) => sum + activity.caloriesBurned,
    );
    final totalDistance = activities.fold<double>(
      0.0,
      (sum, activity) => sum + activity.distance,
    );

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryTeal, AppColors.primaryTealLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryTeal.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Bu Hafta',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                context,
                icon: Icons.timer_outlined,
                value: '$totalDuration',
                unit: 'dk',
                label: 'Süre',
              ),
              _buildStatItem(
                context,
                icon: Icons.local_fire_department,
                value: '$totalCalories',
                unit: 'kcal',
                label: 'Kalori',
              ),
              _buildStatItem(
                context,
                icon: Icons.route,
                value: totalDistance.toStringAsFixed(1),
                unit: 'km',
                label: 'Mesafe',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String unit,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                unit,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ),
          ],
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

  Widget _buildActivityCard(BuildContext context, ActivityModel activity) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'tr_TR');
    final activityIcon = _getActivityIcon(activity.type);
    final activityColor = _getActivityColor(activity.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Activity Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: activityColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              activityIcon,
              color: activityColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Activity Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getActivityName(activity.type),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateFormat.format(activity.date),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildActivityMetric(
                      icon: Icons.timer,
                      value: '${activity.duration} dk',
                    ),
                    const SizedBox(width: 16),
                    _buildActivityMetric(
                      icon: Icons.route,
                      value: '${activity.distance.toStringAsFixed(1)} km',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Calories Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.alertOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.local_fire_department,
                  size: 16,
                  color: AppColors.alertOrange,
                ),
                const SizedBox(width: 4),
                Text(
                  '${activity.caloriesBurned}',
                  style: const TextStyle(
                    color: AppColors.alertOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityMetric({
    required IconData icon,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'walking':
        return Icons.directions_walk;
      case 'running':
        return Icons.directions_run;
      case 'cycling':
        return Icons.directions_bike;
      default:
        return Icons.fitness_center;
    }
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'walking':
        return AppColors.accentGreen;
      case 'running':
        return AppColors.alertOrange;
      case 'cycling':
        return AppColors.accentBlue;
      default:
        return AppColors.primaryTeal;
    }
  }

  String _getActivityName(String type) {
    switch (type) {
      case 'walking':
        return 'Yürüyüş';
      case 'running':
        return 'Koşu';
      case 'cycling':
        return 'Bisiklet';
      default:
        return 'Egzersiz';
    }
  }
}
