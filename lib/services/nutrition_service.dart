import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/food_model.dart';

class NutritionService {
  // Cloud Function URL
  static const String _baseUrl = 'https://search-food-xxuiubzqna-uc.a.run.app';

  // Retry configuration
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);
  static const Duration _timeout = Duration(seconds: 30);

  /// Search for foods with retry mechanism and better error handling
  Future<List<FoodModel>> searchFoods(String query) async {
    if (query.isEmpty) return [];

    int retryCount = 0;
    Exception? lastException;

    while (retryCount < _maxRetries) {
      try {
        final response = await http
            .post(
              Uri.parse(_baseUrl),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({'query': query}),
            )
            .timeout(_timeout);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          // Handle new response format with success/error envelope
          if (data is Map<String, dynamic>) {
            if (data['success'] == true && data['data'] != null) {
              return _parseFatSecretResponse(data['data']);
            } else if (data['success'] == false) {
              // Handle error response from Cloud Function
              final errorCode = data['error_code'] ?? 'UNKNOWN';
              final errorMessage = data['error'] ?? 'Unknown error';
              print('API Error [$errorCode]: $errorMessage');

              // Don't retry on certain errors
              if (errorCode == 'MISSING_QUERY' ||
                  errorCode == 'AUTH_FAILED' ||
                  errorCode == 'MISSING_CREDENTIALS') {
                throw Exception('$errorCode: $errorMessage');
              }

              // Retry on other errors
              lastException = Exception('$errorCode: $errorMessage');
            } else {
              // Legacy format without success envelope
              return _parseFatSecretResponse(data);
            }
          }
        } else if (response.statusCode == 400) {
          // Bad request - don't retry
          print('Bad Request: ${response.body}');
          throw Exception('Invalid request: ${response.body}');
        } else if (response.statusCode == 401 || response.statusCode == 403) {
          // Auth error - don't retry
          print('Authentication Error: ${response.statusCode}');
          throw Exception('Authentication failed');
        } else if (response.statusCode == 429) {
          // Rate limit - wait longer before retry
          print('Rate limit exceeded, waiting before retry...');
          await Future.delayed(Duration(seconds: 5));
          lastException = Exception('Rate limit exceeded');
        } else {
          // Other errors - retry
          print('HTTP Error: ${response.statusCode} - ${response.body}');
          lastException =
              Exception('HTTP ${response.statusCode}: ${response.body}');
        }
      } on TimeoutException catch (e) {
        print('Request timeout (attempt ${retryCount + 1}/$_maxRetries): $e');
        lastException = Exception('Request timeout');
      } on http.ClientException catch (e) {
        print('Network error (attempt ${retryCount + 1}/$_maxRetries): $e');
        lastException = Exception('Network error: $e');
      } catch (e) {
        print('Unexpected error (attempt ${retryCount + 1}/$_maxRetries): $e');
        lastException = Exception('Unexpected error: $e');
      }

      // Increment retry count and wait before next attempt
      retryCount++;
      if (retryCount < _maxRetries) {
        print('Retrying in ${_retryDelay.inSeconds} seconds...');
        await Future.delayed(_retryDelay);
      }
    }

    // All retries exhausted
    print('All retry attempts failed. Last error: $lastException');
    return [];
  }

  /// Parse FatSecret API response with robust error handling
  List<FoodModel> _parseFatSecretResponse(Map<String, dynamic> data) {
    List<FoodModel> foods = [];

    try {
      // Check if response has foods data
      if (data['foods'] == null) {
        print('No foods data in response');
        return foods;
      }

      final foodsData = data['foods'];

      // Check if food list exists
      if (foodsData['food'] == null) {
        print('No food items in response');
        return foods;
      }

      final foodList = foodsData['food'];

      // Handle case where single result is a map, not a list
      final List<dynamic> items = foodList is List ? foodList : [foodList];

      print('Parsing ${items.length} food items');

      for (var item in items) {
        try {
          // Validate required fields
          if (item['food_id'] == null || item['food_name'] == null) {
            print('Skipping item with missing required fields');
            continue;
          }

          final String description = item['food_description'] ?? '';
          final int calories = _extractCalories(description);
          final String unit = _extractUnit(description);

          // Only add if we could extract meaningful data
          if (calories > 0 || description.isNotEmpty) {
            foods.add(FoodModel(
              id: item['food_id'],
              name: item['food_name'] ?? 'Unknown',
              calories: calories,
              unit: unit,
              category: _mapFoodType(item['food_type'] ?? ''),
            ));
          }
        } catch (e) {
          print('Error parsing individual food item: $e');
          // Continue parsing other items
          continue;
        }
      }

      print('Successfully parsed ${foods.length} food items');
    } catch (e) {
      print('Error parsing FatSecret response: $e');
    }

    return foods;
  }

  /// Extract calories from food description with multiple patterns
  int _extractCalories(String description) {
    if (description.isEmpty) return 0;

    try {
      // Try multiple regex patterns for different formats
      final patterns = [
        RegExp(r'Calories:\s*(\d+\.?\d*)kcal', caseSensitive: false),
        RegExp(r'Calories:\s*(\d+\.?\d*)', caseSensitive: false),
        RegExp(r'(\d+\.?\d*)\s*kcal', caseSensitive: false),
        RegExp(r'Cal:\s*(\d+\.?\d*)', caseSensitive: false),
      ];

      for (var pattern in patterns) {
        final match = pattern.firstMatch(description);
        if (match != null && match.group(1) != null) {
          final value = double.tryParse(match.group(1)!);
          if (value != null && value > 0) {
            return value.round();
          }
        }
      }
    } catch (e) {
      print('Error extracting calories: $e');
    }

    return 0;
  }

  /// Extract serving unit from food description with multiple patterns
  String _extractUnit(String description) {
    if (description.isEmpty) return 'porsiyon';

    try {
      // Try multiple regex patterns for different formats
      final patterns = [
        RegExp(r'Per\s+(.*?)\s*-', caseSensitive: false),
        RegExp(r'Per\s+(.*?):', caseSensitive: false),
        RegExp(r'Serving Size:\s*(.*?)[\|\-]', caseSensitive: false),
      ];

      for (var pattern in patterns) {
        final match = pattern.firstMatch(description);
        if (match != null && match.group(1) != null) {
          final unit = match.group(1)!.trim();
          if (unit.isNotEmpty && unit.length < 50) {
            // Sanity check
            return unit;
          }
        }
      }
    } catch (e) {
      print('Error extracting unit: $e');
    }

    return 'porsiyon';
  }

  /// Map FatSecret food_type to Turkish categories
  String _mapFoodType(String foodType) {
    if (foodType.isEmpty) return 'genel';

    final Map<String, String> typeMapping = {
      'generic': 'genel',
      'brand': 'marka',
      'branded': 'marka',
      'restaurant': 'restoran',
      'Branded': 'marka',
      'Generic': 'genel',
    };

    return typeMapping[foodType] ?? 'genel';
  }

  // Placeholder for compatibility if needed
  Future<List<FoodModel>> getAllFoods() async {
    return [];
  }
}
