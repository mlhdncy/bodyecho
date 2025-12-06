import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../../../core/authentication/viewmodels/auth_provider.dart';
import '../../../widgets/progress_bar_widget.dart';
import '../../../widgets/health_avatar_widget.dart';
import '../../../widgets/daily_progress_with_insights.dart';
import '../../../services/insights_service.dart';
import '../viewmodels/home_provider.dart';
import '../../trends/views/trends_screen.dart';
import '../../trends/views/health_risk_view.dart';
import '../../activity/views/activity_log_screen.dart';
import '../../activity/views/add_activity_screen.dart';
import '../../activity/viewmodels/activity_provider.dart';
import '../../chat/views/chat_screen.dart';
import '../../profile/views/profile_screen.dart';
import '../../nutrition/views/calorie_tracking_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeProvider = context.read<HomeProvider>();
      final activityProvider = context.read<ActivityProvider>();
      final authProvider = context.read<AuthProvider>();

      if (authProvider.currentUser != null) {
        debugPrint(
            'HomeScreen: Loading data for user ${authProvider.currentUser!.anonymousId}');
        homeProvider.loadData(
            authProvider.currentUser!.anonymousId, authProvider.currentUser);
        activityProvider.loadActivities(authProvider.currentUser!.anonymousId,
            limit: 5);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: AppColors.backgroundNeutral,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Merhaba,',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              user?.fullName ?? '',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        actions: const [],
      ),
      body: Consumer<HomeProvider>(
        builder: (context, homeProvider, _) {
          if (homeProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final metric = homeProvider.todayMetric;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Health Avatar
                _buildHealthAvatar(context, metric),

                const SizedBox(height: 20),

                // Daily Progress Card with Insights
                _buildDailyProgressWithInsights(context, metric, homeProvider.insights),

                const SizedBox(height: 20),

                // Metric Cards Grid
                _buildMetricGrid(context, metric),

                const SizedBox(height: 20),

                // Quick Actions
                _buildQuickActions(context),

                const SizedBox(height: 20),

                // Recent Activities
                _buildRecentActivities(context),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildDailyProgressWithInsights(BuildContext context, metric, List<dynamic> insights) {
    return DailyProgressWithInsights(
      metrics: metric,
      insights: insights.cast<Insight>(),
    );
  }

  Widget _buildHealthAvatar(BuildContext context, metric) {
    // Determine avatar mood based on metrics
    final stepsProgress = metric?.stepsProgress ?? 0.0;
    final waterProgress = metric?.waterProgress ?? 0.0;
    final calorieProgress = metric?.calorieProgress ?? 0.0;

    // Get activity count from ActivityProvider
    final activityProvider = context.watch<ActivityProvider>();
    final activityCount = activityProvider.activities.length;

    final mood = AvatarMoodHelper.determineMood(
      stepsProgress: stepsProgress,
      waterProgress: waterProgress,
      calorieProgress: calorieProgress,
      activityCount: activityCount,
    );

    final moodMessage = AvatarMoodHelper.getMoodMessage(mood);

    return Center(
      child: Column(
        children: [
          HealthAvatarWidget(
            mood: mood,
            size: 140,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              moodMessage,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildMetricGrid(BuildContext context, metric) {
    // Get activity count from ActivityProvider
    final activityProvider = context.watch<ActivityProvider>();
    final activityCount = activityProvider.activities.length;
    final activityProgress = activityCount / 3.0; // Goal is 3 activities

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildMetricCard(
          context,
          title: 'Su İçimi',
          value: '${metric?.waterIntake.toStringAsFixed(1) ?? '0.0'} L',
          goal: '2.5 L',
          progress: metric != null ? metric.waterProgress : 0.0,
          icon: Icons.water_drop,
          color: AppColors.accentBlue,
        ),
        _buildMetricCard(
          context,
          title: 'Kalori',
          value: '${metric?.calorieEstimate ?? 0}',
          goal: '2500 kcal',
          progress: metric != null ? metric.calorieProgress : 0.0,
          icon: Icons.local_fire_department,
          color: AppColors.alertOrange,
        ),
        _buildMetricCard(
          context,
          title: 'Uyku',
          value: '${metric?.sleepQuality ?? 0} saat',
          goal: '8 saat',
          progress: metric != null ? metric.sleepProgress : 0.0,
          icon: Icons.bedtime,
          color: AppColors.accentPurple,
        ),
        _buildMetricCard(
          context,
          title: 'Aktivite',
          value: '$activityCount',
          goal: '3 aktivite',
          progress: activityProgress,
          icon: Icons.directions_run,
          color: AppColors.accentGreen,
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required String goal,
    required double progress,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          ProgressBarWidget(
            progress: progress,
            height: 6,
            color: color,
            backgroundColor: color.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 4),
          Text(
            'Hedef: $goal',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hızlı İşlemler',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                icon: Icons.add,
                label: 'Su Ekle',
                color: AppColors.accentBlue,
                onTap: () => _showAddWaterDialog(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                context,
                icon: Icons.directions_run,
                label: 'Aktivite',
                color: AppColors.accentGreen,
                onTap: () => _navigateToAddActivity(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                icon: Icons.directions_walk,
                label: 'Adım Ekle',
                color: AppColors.primaryTeal,
                onTap: () => _showAddStepsDialog(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                context,
                icon: Icons.bedtime,
                label: 'Uyku Ekle',
                color: AppColors.accentPurple,
                onTap: () => _showAddSleepDialog(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                icon: Icons.local_fire_department,
                label: 'Kalori Ekle',
                color: AppColors.alertOrange,
                onTap: () => _showAddCaloriesDialog(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                context,
                icon: Icons.analytics,
                label: 'AI Analiz',
                color: Color(0xFF6B73FF),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HealthRiskView()),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivities(BuildContext context) {
    return Consumer<ActivityProvider>(
      builder: (context, activityProvider, _) {
        final activities = activityProvider.activities;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Son Aktiviteler',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ActivityLogScreen(),
                      ),
                    );
                  },
                  child: const Text('Tümünü Gör'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (activities.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 48,
                        color: AppColors.textSecondary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Henüz aktivite yok',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...activities.map((activity) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
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
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _getActivityColor(activity.type)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getActivityIcon(activity.type),
                              color: _getActivityColor(activity.type),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getActivityName(activity.type),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${activity.duration} dk • ${activity.distance.toStringAsFixed(1)} km',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${activity.caloriesBurned}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.alertOrange,
                                    ),
                              ),
                              const Text(
                                'kcal',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )),
          ],
        );
      },
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
        return 'Aktivite';
    }
  }

  Future<void> _navigateToAddActivity(BuildContext context) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AddActivityScreen(),
      ),
    );

    // Reload data if activity was added
    if (result == true && mounted) {
      if (!mounted) return;
      final homeProvider = context.read<HomeProvider>();
      final activityProvider = context.read<ActivityProvider>();
      final authProvider = context.read<AuthProvider>();
      if (authProvider.currentUser != null) {
        homeProvider.loadTodayMetrics(authProvider.currentUser!.anonymousId);
        activityProvider.loadActivities(authProvider.currentUser!.anonymousId,
            limit: 5);
      }
    }
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home,
                label: 'Ana Sayfa',
                isActive: true,
                onTap: () {},
              ),
              _buildNavItem(
                icon: Icons.show_chart,
                label: 'Trendler',
                isActive: false,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const TrendsScreen(),
                    ),
                  );
                },
              ),
              _buildNavItem(
                icon: Icons.history,
                label: 'Geçmiş',
                isActive: false,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ActivityLogScreen(),
                    ),
                  );
                },
              ),
              _buildNavItem(
                icon: Icons.chat_bubble_outline,
                label: 'Chat',
                isActive: false,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ChatScreen(),
                    ),
                  );
                },
              ),
              _buildNavItem(
                icon: Icons.person,
                label: 'Profil',
                isActive: false,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ProfileScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primaryTeal : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color:
                    isActive ? AppColors.primaryTeal : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddWaterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Su Ekle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ne kadar su içtiniz?'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildWaterOption(context, 0.25, '250ml'),
                _buildWaterOption(context, 0.5, '500ml'),
                _buildWaterOption(context, 1.0, '1L'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterOption(BuildContext context, double amount, String label) {
    return InkWell(
      onTap: () async {
        final homeProvider = context.read<HomeProvider>();
        final authProvider = context.read<AuthProvider>();

        if (authProvider.currentUser != null) {
          await homeProvider.addWater(
            authProvider.currentUser!.anonymousId,
            amount,
          );
          if (context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$label su eklendi!'),
                backgroundColor: AppColors.accentGreen,
              ),
            );
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.accentBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.accentBlue),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.accentBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showAddStepsDialog(BuildContext context) {
    final TextEditingController stepsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adım Ekle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Bugün kaç adım attınız?'),
            const SizedBox(height: 16),
            TextField(
              controller: stepsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Örn: 5000',
                prefixIcon: const Icon(Icons.directions_walk),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final steps = int.tryParse(stepsController.text);
              if (steps != null && steps > 0) {
                final homeProvider = context.read<HomeProvider>();
                final authProvider = context.read<AuthProvider>();

                if (authProvider.currentUser != null) {
                  await homeProvider.updateSteps(
                    authProvider.currentUser!.anonymousId,
                    steps,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$steps adım eklendi!'),
                        backgroundColor: AppColors.accentGreen,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  void _showAddSleepDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Uyku Ekle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Bu gece kaç saat uyudunuz?'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                for (int hours = 4; hours <= 10; hours++)
                  _buildSleepOption(context, hours),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepOption(BuildContext context, int hours) {
    return InkWell(
      onTap: () async {
        final homeProvider = context.read<HomeProvider>();
        final authProvider = context.read<AuthProvider>();

        if (authProvider.currentUser != null) {
          await homeProvider.updateSleep(
            authProvider.currentUser!.anonymousId,
            hours,
          );
          if (context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$hours saat uyku kaydedildi!'),
                backgroundColor: AppColors.accentGreen,
              ),
            );
          }
        }
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.accentPurple.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.accentPurple),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$hours',
              style: const TextStyle(
                color: AppColors.accentPurple,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const Text(
              'saat',
              style: TextStyle(
                color: AppColors.accentPurple,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCaloriesDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CalorieTrackingScreen()),
    );
  }
}
