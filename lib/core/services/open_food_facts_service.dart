import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:amp/core/models/nutrition.dart';
import 'package:amp/core/models/unit.dart' as app_models;

/// Data class representing a product from Open Food Facts
/// that can be converted to our Product model.
class OpenFoodFactsProductData {
  final String name;
  final String? barcode;
  final String? brand;
  final Nutrition nutrition;
  final List<app_models.Unit> units;

  const OpenFoodFactsProductData({
    required this.name,
    this.barcode,
    this.brand,
    required this.nutrition,
    required this.units,
  });
}

/// Service for interacting with Open Food Facts API.
class OpenFoodFactsService {
  /// Fetches a product by barcode (UPC/EAN).
  ///
  /// Returns product data if found, null otherwise.
  Future<OpenFoodFactsProductData?> getProductByBarcode(String barcode) async {
    try {
      final configuration = ProductQueryConfiguration(
        barcode,
        version: ProductQueryVersion.v3,
      );

      final result = await OpenFoodAPIClient.getProductV3(configuration);

      if (result.product == null) {
        return null;
      }

      return _convertProduct(result.product!);
    } catch (e) {
      // Handle API errors gracefully
      return null;
    }
  }

  /// Searches for products by name.
  ///
  /// Returns a list of product data matching the query.
  Future<List<OpenFoodFactsProductData>> searchProducts(String query) async {
    if (query.isEmpty) {
      return [];
    }

    try {
      final searchResult = await OpenFoodAPIClient.searchProducts(
        null, // No authentication required for read operations
        ProductSearchQueryConfiguration(
          parametersList: [
            SearchTerms(terms: [query]),
          ],
          version: ProductQueryVersion.v3,
        ),
      );

      if (searchResult.products == null || searchResult.products!.isEmpty) {
        return [];
      }

      return searchResult.products!
          .map((product) => _convertProduct(product))
          .where((data) => data != null)
          .cast<OpenFoodFactsProductData>()
          .toList();
    } catch (e) {
      // Handle API errors gracefully
      return [];
    }
  }

  /// Converts an Open Food Facts Product to our data format.
  OpenFoodFactsProductData? _convertProduct(Product product) {
    // Extract product name
    final name = product.productName;
    if (name == null || name.isEmpty) {
      return null; // Skip products without a name
    }

    // Extract barcode
    final barcode = product.barcode;

    // Extract brand
    final brands = product.brands;

    // Extract nutrition (per 100g)
    final nutrition = _extractNutrition(product);

    // Extract units
    final units = _extractUnits(product);

    return OpenFoodFactsProductData(
      name: name,
      barcode: barcode,
      brand: brands,
      nutrition: nutrition,
      units: units,
    );
  }

  /// Extracts nutrition information from Open Food Facts product.
  Nutrition _extractNutrition(Product product) {
    final nutriments = product.nutriments;
    if (nutriments == null) {
      // Return zero nutrition if not available
      return const Nutrition(calories: 0, protein: 0, carbohydrates: 0, fat: 0);
    }

    double? get(Nutrient nutrient) =>
        nutriments.getValue(nutrient, PerSize.oneHundredGrams);

    // Get values per 100g
    final calories = get(Nutrient.energyKCal) ?? 0.0;
    final protein = get(Nutrient.proteins) ?? 0.0;
    final carbohydrates = get(Nutrient.carbohydrates) ?? 0.0;
    final fat = get(Nutrient.fat) ?? 0.0;

    return Nutrition(
      calories: calories,
      protein: protein,
      carbohydrates: carbohydrates,
      fat: fat,
      saturatedFat: get(Nutrient.saturatedFat),
      monounsaturatedFat: get(Nutrient.monounsaturatedFat),
      polyunsaturatedFat: get(Nutrient.polyunsaturatedFat),
      transFat: get(Nutrient.transFat),
      cholesterol: get(Nutrient.cholesterol),
      sodium: get(Nutrient.sodium),
      salt: get(Nutrient.salt),
      fiber: get(Nutrient.fiber),
      sugar: get(Nutrient.sugars),
      // addedSugars is sometimes not available directly, check package docs if needed
      // but Nutrient.addedSugars exists in recent versions
      addedSugar: get(Nutrient.addedSugars),
      alcohol: get(Nutrient.alcohol),
      caffeine: get(Nutrient.caffeine),
      vitaminA: get(Nutrient.vitaminA),
      vitaminB1: get(Nutrient.vitaminB1),
      vitaminB2: get(Nutrient.vitaminB2),
      vitaminB3: get(Nutrient.vitaminPP), // Niacin
      vitaminB5: get(Nutrient.pantothenicAcid),
      vitaminB6: get(Nutrient.vitaminB6),
      vitaminB7: get(Nutrient.biotin),
      vitaminB9: get(Nutrient.vitaminB9),
      vitaminB12: get(Nutrient.vitaminB12),
      vitaminC: get(Nutrient.vitaminC),
      vitaminD: get(Nutrient.vitaminD),
      vitaminE: get(Nutrient.vitaminE),
      vitaminK: get(Nutrient.vitaminK),
      potassium: get(Nutrient.potassium),
      calcium: get(Nutrient.calcium),
      iron: get(Nutrient.iron),
      magnesium: get(Nutrient.magnesium),
      zinc: get(Nutrient.zinc),
      copper: get(Nutrient.copper),
      manganese: get(Nutrient.manganese),
      selenium: get(Nutrient.selenium),
      phosphorus: get(Nutrient.phosphorus),
      iodine: get(Nutrient.iodine),
      chloride: get(Nutrient.chloride),
    );
  }

  /// Extracts units from Open Food Facts product.
  List<app_models.Unit> _extractUnits(Product product) {
    final units = <app_models.Unit>[];

    // Add serving size if available
    if (product.servingSize != null && product.servingSize!.isNotEmpty) {
      // Try to parse serving size (e.g., "330ml" or "100g")
      final servingSize = product.servingSize!;
      final quantity = _parseQuantity(servingSize);
      if (quantity != null) {
        units.add(app_models.Unit(name: 'Serving', grams: quantity));
      }
    }

    // Add quantity if available (e.g., "330ml")
    if (product.quantity != null && product.quantity!.isNotEmpty) {
      final quantity = product.quantity!;
      final grams = _parseQuantity(quantity);
      if (grams != null) {
        units.add(app_models.Unit(name: 'Container', grams: grams));
      }
    }

    return units;
  }

  /// Parses quantity string to extract grams.
  ///
  /// Handles formats like "330ml", "100g", "250ml", etc.
  /// Returns grams equivalent, or null if parsing fails.
  double? _parseQuantity(String quantity) {
    // Remove whitespace and convert to lowercase
    final cleaned = quantity.trim().toLowerCase();

    // Try to extract number
    final numberMatch = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(cleaned);
    if (numberMatch == null) {
      return null;
    }

    final number = double.tryParse(numberMatch.group(1)!);
    if (number == null) {
      return null;
    }

    // Convert to grams based on unit
    if (cleaned.contains('ml')) {
      // Assume 1ml ≈ 1g for liquids (approximation)
      return number;
    } else if (cleaned.contains('kg')) {
      return number * 1000;
    } else if (cleaned.contains('mg')) {
      return number / 1000;
    } else if (cleaned.contains('g')) {
      return number;
    } else if (cleaned.contains('l')) {
      // Assume 1L ≈ 1000g for liquids (approximation)
      return number * 1000;
    }

    // Default: assume grams if no unit specified
    return number;
  }
}
