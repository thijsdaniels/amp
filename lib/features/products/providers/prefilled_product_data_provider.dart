import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amp/core/models/nutrition.dart';
import 'package:amp/core/models/unit.dart';

/// Data class for prefilled product form data.
class PrefilledProductData {
  final String? name;
  final String? upc;
  final String? brand;
  final Nutrition? nutrition;
  final List<Unit>? units;

  const PrefilledProductData({
    this.name,
    this.upc,
    this.brand,
    this.nutrition,
    this.units,
  });
}

/// Provider for temporarily storing prefilled product data during navigation.
final prefilledProductDataProvider = StateProvider<PrefilledProductData?>(
  (ref) => null,
);
