import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/food_model.dart';

class NutritionService {
  // Cloud Function URL
  static const String _baseUrl = 'https://search-food-xxuiubzqna-uc.a.run.app';

  Future<List<FoodModel>> searchFoods(String query) async {
    if (query.isEmpty) return [];

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'query': query}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseFatSecretResponse(data);
      } else {
        print(
            'Cloud Function Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Cloud Function Exception: $e');
    }
    return [];
  }

  List<FoodModel> _parseFatSecretResponse(Map<String, dynamic> data) {
    List<FoodModel> foods = [];

    if (data['foods'] != null && data['foods']['food'] != null) {
      final foodList = data['foods']['food'];

      // Handle case where single result is a map, not a list
      final List<dynamic> items = foodList is List ? foodList : [foodList];

      for (var item in items) {
        try {
          final String description = item['food_description'] ?? '';
          final int calories = _extractCalories(description);
          final String unit = _extractUnit(description);

          foods.add(FoodModel(
            id: item['food_id'],
            name: item['food_name'],
            calories: calories,
            unit: unit,
            category: item['food_type'] ?? 'genel',
          ));
        } catch (e) {
          print('Error parsing food item: $e');
        }
      }
    }
    return foods;
  }

  int _extractCalories(String description) {
    // Example: "Per 100g - Calories: 52kcal | Fat: 0.17g ..."
    // Regex to find "Calories: 52"
    final RegExp regex = RegExp(r'Calories:\s*(\d+)');
    final match = regex.firstMatch(description);
    if (match != null) {
      return int.tryParse(match.group(1) ?? '0') ?? 0;
    }
    return 0;
  }

  String _extractUnit(String description) {
    // Example: "Per 100g - Calories..." or "Per 1 cup - Calories..."
    final RegExp regex = RegExp(r'Per\s(.*?)\s-');
    final match = regex.firstMatch(description);
    if (match != null) {
      return match.group(1) ?? 'porsiyon';
    }
    return 'porsiyon';
  }

  // Placeholder for compatibility if needed
  Future<List<FoodModel>> getAllFoods() async {
    return [];
  }
}
