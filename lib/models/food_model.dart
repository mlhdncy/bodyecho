class FoodModel {
  final String id;
  final String name;
  final int calories;
  final String unit; // porsiyon, adet, 100g vb.
  final String category; // genel, meyve, sebze, et vb.

  FoodModel({
    required this.id,
    required this.name,
    required this.calories,
    required this.unit,
    this.category = 'genel',
  });

  factory FoodModel.fromJson(Map<String, dynamic> json) {
    return FoodModel(
      id: json['id'],
      name: json['name'],
      calories: json['calories'],
      unit: json['unit'],
      category: json['category'] ?? 'genel',
    );
  }
}
