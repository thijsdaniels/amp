import 'package:amp/core/models/model.dart';

class Nutrition extends Model {
  final double calories;
  final double protein;
  final double carbohydrates;
  final double fat;

  const Nutrition({
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fat,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'calories': calories,
      'protein': protein,
      'carbohydrates': carbohydrates,
      'fat': fat,
    };
  }

  factory Nutrition.fromMap(Map<String, dynamic> map) {
    if (map case {
      'calories': num calories,
      'protein': num protein,
      'carbohydrates': num carbohydrates,
      'fat': num fat,
    }) {
      return Nutrition(
        calories: calories.toDouble(),
        protein: protein.toDouble(),
        carbohydrates: carbohydrates.toDouble(),
        fat: fat.toDouble(),
      );
    } else {
      throw const FormatException('Invalid JSON format for Nutrition');
    }
  }
}
