import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../../../core/authentication/viewmodels/auth_provider.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../models/activity_model.dart';
import '../viewmodels/activity_provider.dart';

class AddActivityScreen extends StatefulWidget {
  const AddActivityScreen({super.key});

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _durationController = TextEditingController();
  final _distanceController = TextEditingController();

  String _selectedActivityType = 'walking';
  int _calculatedCalories = 0;

  // Fallback calories-per-minute values for activity types.
  // These values are used when AppConstants.activityCalories is not available.
  static const Map<String, int> _activityCalories = {
    'walking': 5,
    'running': 10,
    'cycling': 8,
  };

  @override
  void dispose() {
    _durationController.dispose();
    _distanceController.dispose();
    super.dispose();
  }

  void _calculateCalories() {
    final duration = int.tryParse(_durationController.text) ?? 0;
    if (duration > 0) {
      final caloriesPerMinute = _activityCalories[_selectedActivityType] ?? 5;
      setState(() {
        _calculatedCalories = duration * caloriesPerMinute;
      });
    }
  }

  Future<void> _handleAddActivity() async {
    if (!_formKey.currentState!.validate()) return;

    final activityProvider = context.read<ActivityProvider>();
    final authProvider = context.read<AuthProvider>();

    if (authProvider.currentUser == null) return;

    final activity = ActivityModel(
      userId: authProvider.currentUser!.anonymousId,
      type: _selectedActivityType,
      duration: int.parse(_durationController.text),
      distance: double.parse(_distanceController.text),
      caloriesBurned: _calculatedCalories,
      date: DateTime.now(),
    );

    try {
      await activityProvider.addActivity(activity);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aktivite başarıyla eklendi!'),
            backgroundColor: AppColors.accentGreen,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${activityProvider.errorMessage}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNeutral,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Aktivite Ekle'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Activity Type Selection
              Container(
                padding: const EdgeInsets.all(20),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aktivite Türü',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildActivityTypeOption(
                            type: 'walking',
                            icon: Icons.directions_walk,
                            label: 'Yürüyüş',
                            color: AppColors.accentGreen,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActivityTypeOption(
                            type: 'running',
                            icon: Icons.directions_run,
                            label: 'Koşu',
                            color: AppColors.alertOrange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActivityTypeOption(
                            type: 'cycling',
                            icon: Icons.directions_bike,
                            label: 'Bisiklet',
                            color: AppColors.accentBlue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Activity Details
              Container(
                padding: const EdgeInsets.all(20),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aktivite Detayları',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      label: 'Süre (dakika)',
                      hint: 'Örn: 30',
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.timer,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Süre gerekli';
                        }
                        if (int.tryParse(value) == null || int.parse(value) <= 0) {
                          return 'Geçerli bir süre girin';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        _calculateCalories();
                      },
                    ),

                    const SizedBox(height: 16),

                    CustomTextField(
                      label: 'Mesafe (km)',
                      hint: 'Örn: 5.0',
                      controller: _distanceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      prefixIcon: Icons.route,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Mesafe gerekli';
                        }
                        if (double.tryParse(value) == null || double.parse(value) <= 0) {
                          return 'Geçerli bir mesafe girin';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Calorie Estimate
              if (_calculatedCalories > 0)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.alertOrange, Color(0xFFFF8A65)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.alertOrange.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tahmini Kalori',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '$_calculatedCalories kcal',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 32),

              // Add Button
              Consumer<ActivityProvider>(
                builder: (context, activityProvider, _) {
                  return CustomButton(
                    title: 'AKTİVİTE EKLE',
                    onPressed: _handleAddActivity,
                    isLoading: activityProvider.isLoading,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityTypeOption({
    required String type,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final isSelected = _selectedActivityType == type;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedActivityType = type;
        });
        _calculateCalories();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.textSecondary.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : AppColors.textSecondary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
