import 'package:freezed_annotation/freezed_annotation.dart';

part 'nutrition.freezed.dart';
part 'nutrition.g.dart';

@freezed
abstract class Nutrition with _$Nutrition {
  const factory Nutrition({
    required double calories,
    required double protein,
    required double carbohydrates,
    required double fat,
  }) = _Nutrition;

  factory Nutrition.fromJson(Map<String, dynamic> json) =>
      _$NutritionFromJson(json);
}
