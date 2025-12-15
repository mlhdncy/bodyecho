import 'package:flutter/material.dart';
import '../../../models/food_model.dart';
import '../../../services/nutrition_service.dart';

class NutritionProvider with ChangeNotifier {
  final NutritionService _nutritionService = NutritionService();

  // Meal Lists
  final List<FoodModel> _breakfast = [];
  final List<FoodModel> _lunch = [];
  final List<FoodModel> _dinner = [];
  final List<FoodModel> _snacks = [];

  // Getters
  List<FoodModel> get breakfast => _breakfast;
  List<FoodModel> get lunch => _lunch;
  List<FoodModel> get dinner => _dinner;
  List<FoodModel> get snacks => _snacks;

  int get totalCalories => _calculateTotalCalories();

  int _calculateTotalCalories() {
    int total = 0;
    for (var food in _breakfast) {
      total += food.calories;
    }
    for (var food in _lunch) {
      total += food.calories;
    }
    for (var food in _dinner) {
      total += food.calories;
    }
    for (var food in _snacks) {
      total += food.calories;
    }
    return total;
  }

  // Actions
  void addFood(FoodModel food, String mealType) {
    switch (mealType) {
      case 'breakfast':
        _breakfast.add(food);
        break;
      case 'lunch':
        _lunch.add(food);
        break;
      case 'dinner':
        _dinner.add(food);
        break;
      case 'snack':
        _snacks.add(food);
        break;
    }
    notifyListeners();
  }

  void removeFood(FoodModel food, String mealType) {
    switch (mealType) {
      case 'breakfast':
        _breakfast.remove(food);
        break;
      case 'lunch':
        _lunch.remove(food);
        break;
      case 'dinner':
        _dinner.remove(food);
        break;
      case 'snack':
        _snacks.remove(food);
        break;
    }
    notifyListeners();
  }

  Future<List<FoodModel>> searchFoods(String query) {
    return _nutritionService.searchFoods(query);
  }

  void clearAll() {
    _breakfast.clear();
    _lunch.clear();
    _dinner.clear();
    _snacks.clear();
    notifyListeners();
  }
}
