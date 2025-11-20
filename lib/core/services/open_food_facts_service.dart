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

    // Get values per 100g
    final calories =
        nutriments.getValue(Nutrient.energyKCal, PerSize.oneHundredGrams) ??
        0.0;

    final protein =
        nutriments.getValue(Nutrient.proteins, PerSize.oneHundredGrams) ?? 0.0;

    final carbohydrates =
        nutriments.getValue(Nutrient.carbohydrates, PerSize.oneHundredGrams) ??
        0.0;

    final fat =
        nutriments.getValue(Nutrient.fat, PerSize.oneHundredGrams) ?? 0.0;

    return Nutrition(
      calories: calories,
      protein: protein,
      carbohydrates: carbohydrates,
      fat: fat,
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
        units.add(app_models.Unit(name: servingSize, grams: quantity));
      }
    }

    // Add quantity if available (e.g., "330ml")
    if (product.quantity != null && product.quantity!.isNotEmpty) {
      final quantity = product.quantity!;
      final grams = _parseQuantity(quantity);
      if (grams != null && !units.any((u) => u.name == quantity)) {
        units.add(app_models.Unit(name: quantity, grams: grams));
      }
    }

    // If no units found, add a default "piece" unit
    if (units.isEmpty) {
      units.add(const app_models.Unit(name: 'piece', grams: 100));
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
    } else if (cleaned.contains('g')) {
      return number;
    } else if (cleaned.contains('kg')) {
      return number * 1000;
    } else if (cleaned.contains('l')) {
      // Assume 1L ≈ 1000g for liquids (approximation)
      return number * 1000;
    }

    // Default: assume grams if no unit specified
    return number;
  }
}
