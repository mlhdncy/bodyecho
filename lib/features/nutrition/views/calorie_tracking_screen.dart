import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../../../core/authentication/viewmodels/auth_provider.dart';
import '../../home/viewmodels/home_provider.dart';
import '../viewmodels/nutrition_provider.dart';
import '../../../models/food_model.dart';

class CalorieTrackingScreen extends StatelessWidget {
  const CalorieTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nutritionProvider = context.watch<NutritionProvider>();
    final totalCalories = nutritionProvider.totalCalories;

    return Scaffold(
      backgroundColor: AppColors.backgroundNeutral,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Calorie Tracking',
            style: TextStyle(color: AppColors.textPrimary)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: () {
              nutritionProvider.clearAll();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Card
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.alertOrange, Colors.orangeAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.alertOrange.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Consumed',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Calories',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  '$totalCalories kcal',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Meal Sections
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildMealSection(context, 'Breakfast', 'breakfast',
                    nutritionProvider.breakfast),
                const SizedBox(height: 16),
                _buildMealSection(
                    context, 'Lunch', 'lunch', nutritionProvider.lunch),
                const SizedBox(height: 16),
                _buildMealSection(context, 'Dinner', 'dinner',
                    nutritionProvider.dinner),
                const SizedBox(height: 16),
                _buildMealSection(context, 'Snacks', 'snack',
                    nutritionProvider.snacks),
                const SizedBox(height: 100), // Bottom padding for FAB
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final homeProvider = context.read<HomeProvider>();
          final authProvider = context.read<AuthProvider>();

          if (authProvider.currentUser != null) {
            await homeProvider.updateCalories(
              authProvider.currentUser!.anonymousId,
              totalCalories,
            );
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Daily calories updated!'),
                  backgroundColor: AppColors.accentGreen,
                ),
              );
              Navigator.pop(context);
            }
          }
        },
        backgroundColor: AppColors.primaryTeal,
        icon: const Icon(Icons.check),
        label: const Text('Save & Finish'),
      ),
    );
  }

  Widget _buildMealSection(
    BuildContext context,
    String title,
    String mealType,
    List<FoodModel> foods,
  ) {
    int sectionCalories = 0;
    for (var f in foods) sectionCalories += f.calories;

    return Container(
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
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '$sectionCalories kcal',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => _showFoodSearchSheet(context, mealType),
                  icon: const Icon(Icons.add_circle,
                      color: AppColors.primaryTeal, size: 32),
                ),
              ],
            ),
          ),
          if (foods.isNotEmpty) const Divider(height: 1),
          ...foods.map((food) => ListTile(
                title: Text(food.name),
                subtitle: Text('${food.calories} kcal / ${food.unit}'),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle_outline,
                      color: AppColors.error),
                  onPressed: () {
                    context
                        .read<NutritionProvider>()
                        .removeFood(food, mealType);
                  },
                ),
              )),
        ],
      ),
    );
  }

  void _showFoodSearchSheet(BuildContext context, String mealType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FoodSearchSheet(mealType: mealType),
    );
  }
}

class _FoodSearchSheet extends StatefulWidget {
  final String mealType;

  const _FoodSearchSheet({required this.mealType});

  @override
  State<_FoodSearchSheet> createState() => _FoodSearchSheetState();
}

class _FoodSearchSheetState extends State<_FoodSearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<FoodModel> _searchResults = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialFoods();
  }

  Future<void> _loadInitialFoods() async {
    final provider = context.read<NutritionProvider>();
    final foods = await provider.searchFoods(''); // Get all or popular
    if (mounted) {
      setState(() {
        _searchResults = foods;
      });
    }
  }

  Future<void> _search(String query) async {
    setState(() => _isLoading = true);
    final provider = context.read<NutritionProvider>();
    final results = await provider.searchFoods(query);
    if (mounted) {
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search food...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AppColors.backgroundNeutral,
              ),
              onChanged: _search,
            ),
          ),

          // Results
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final food = _searchResults[index];
                      return ListTile(
                        title: Text(food.name),
                        subtitle: Text('${food.calories} kcal / ${food.unit}'),
                        trailing:
                            const Icon(Icons.add, color: AppColors.primaryTeal),
                        onTap: () {
                          context
                              .read<NutritionProvider>()
                              .addFood(food, widget.mealType);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${food.name} added!'),
                              duration: const Duration(seconds: 1),
                              backgroundColor: AppColors.accentGreen,
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
