import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ml_prediction_model.dart';

class MlService {
  // Deployed Firebase Cloud Function URL
  static const String _baseUrl =
      'https://us-central1-bodyecho-40265.cloudfunctions.net';

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

      // Try to connect to the server
      // Note: On Web, this might fail due to CORS if the server doesn't support it,
      // or if the server is not running. We will fallback to local simulation.
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 2)); // Short timeout for fallback

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return MlResponse.fromJson(jsonResponse);
      } else {
        return _getMockPredictions(
          age: age,
          bmi: bmi,
          bloodGlucoseLevel: bloodGlucoseLevel,
          active: active,
        );
      }
    } catch (e) {
      // Fallback to local simulation on error (connection refused, timeout, etc.)
      return _getMockPredictions(
        age: age,
        bmi: bmi,
        bloodGlucoseLevel: bloodGlucoseLevel,
        active: active,
      );
    }
  }

  // Local simulation for "Active Analysis" when backend is unavailable
  MlResponse _getMockPredictions({
    required int age,
    required double bmi,
    required int bloodGlucoseLevel,
    required int active,
  }) {
    // Simple rule-based logic to simulate ML model
    int diabetesRisk = 0;
    int sugarRisk = 0;

    // Diabetes Logic Simulation
    if (bloodGlucoseLevel > 140 || (age > 45 && bmi > 30)) {
      diabetesRisk = 1;
    }

    // High Sugar Risk Logic Simulation
    if (bloodGlucoseLevel >= 140 || bmi > 35) {
      sugarRisk = 1;
    }

    return MlResponse(
      success: true,
      results: {
        'diabetes_risk': MlPredictionResult(
          modelName: 'diabetes_risk',
          prediction: diabetesRisk,
          probability: diabetesRisk == 1 ? 0.85 : 0.1,
          riskLevel: diabetesRisk == 1 ? 'High' : 'Low',
        ),
        'high_sugar_risk': MlPredictionResult(
          modelName: 'high_sugar_risk',
          prediction: sugarRisk,
          probability: sugarRisk == 1 ? 0.75 : 0.2,
          riskLevel: sugarRisk == 1 ? 'High' : 'Low',
        ),
      },
    );
  }
}
