import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/ml_prediction_model.dart';

class MlService {
  // Android Emulator için 10.0.2.2, iOS Simulator için 127.0.0.1
  // Gerçek cihaz için bilgisayarınızın yerel IP'sini kullanın (örn: 192.168.1.35)
  static const String _baseUrl = 'http://10.0.2.2:5000'; 
  
  Future<MlResponse> getPredictions({
    required int age,
    required double bmi,
    required int bloodGlucoseLevel,
    required int active,
    String gender = 'Female',
    int hypertension = 0,
    int heartDisease = 0,
    String smokingHistory = 'never',
    double hbA1cLevel = 5.5,
    int calories = 2000,
    int sodium = 2000,
    int cholesterol = 150,
    int waterIntake = 2000,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/predict');
      
      final body = {
        "age": age,
        "bmi": bmi,
        "blood_glucose_level": bloodGlucoseLevel,
        "active": active,
        "gender": gender,
        "hypertension": hypertension,
        "heart_disease": heartDisease,
        "smoking_history": smokingHistory,
        "HbA1c_level": hbA1cLevel,
        "Calories_kcal": calories,
        "Sodium_mg": sodium,
        "Cholesterol_mg": cholesterol,
        "Water_Intake_ml": waterIntake,
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return MlResponse.fromJson(jsonResponse);
      } else {
        return MlResponse(
          success: false,
          results: {},
          error: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return MlResponse(
        success: false,
        results: {},
        error: 'Connection error: $e',
      );
    }
  }
}
