class MlPredictionResult {
  final String modelName;
  final int prediction;
  final double probability;
  final String riskLevel;

  MlPredictionResult({
    required this.modelName,
    required this.prediction,
    required this.probability,
    required this.riskLevel,
  });

  factory MlPredictionResult.fromJson(String name, Map<String, dynamic> json) {
    return MlPredictionResult(
      modelName: name,
      prediction: json['prediction'] as int,
      probability: (json['probability'] as num).toDouble(),
      riskLevel: json['risk_level'] as String,
    );
  }
}

class MlResponse {
  final bool success;
  final Map<String, MlPredictionResult> results;
  final String? error;

  MlResponse({
    required this.success,
    required this.results,
    this.error,
  });

  factory MlResponse.fromJson(Map<String, dynamic> json) {
    final resultsMap = <String, MlPredictionResult>{};
    
    if (json['results'] != null) {
      (json['results'] as Map<String, dynamic>).forEach((key, value) {
        resultsMap[key] = MlPredictionResult.fromJson(key, value as Map<String, dynamic>);
      });
    }

    return MlResponse(
      success: json['success'] as bool,
      results: resultsMap,
      error: json['error'] as String?,
    );
  }
}
