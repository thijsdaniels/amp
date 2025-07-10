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

  Nutrition operator +(Nutrition other) {
    return Nutrition(
      calories: calories + other.calories,
      protein: protein + other.protein,
      carbohydrates: carbohydrates + other.carbohydrates,
      fat: fat + other.fat,
    );
  }

  Nutrition operator -(Nutrition other) {
    return Nutrition(
      calories: calories - other.calories,
      protein: protein - other.protein,
      carbohydrates: carbohydrates - other.carbohydrates,
      fat: fat - other.fat,
    );
  }

  Nutrition operator *(num factor) {
    return Nutrition(
      calories: calories * factor,
      protein: protein * factor,
      carbohydrates: carbohydrates * factor,
      fat: fat * factor,
    );
  }

  Nutrition operator /(num factor) {
    return Nutrition(
      calories: calories / factor,
      protein: protein / factor,
      carbohydrates: carbohydrates / factor,
      fat: fat / factor,
    );
  }

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
