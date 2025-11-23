import 'package:amp/core/models/document.dart';
import 'package:amp/core/models/nutrition.dart';
import 'package:amp/core/models/unit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductVersion extends Document {
  final int version;
  final Nutrition nutrition;
  final List<Unit> units;

  const ProductVersion({
    super.id,
    required super.createdBy,
    required super.createdAt,
    required super.updatedAt,
    required this.version,
    required this.nutrition,
    required this.units,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'createdBy': createdBy,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'version': version,
      'nutrition': nutrition.toMap(),
      'units': units.map((unit) => unit.toMap()).toList(),
    };
  }

  factory ProductVersion.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data();

    if (data case {
      'createdBy': String createdBy,
      'createdAt': Timestamp createdAt,
      'updatedAt': Timestamp updatedAt,
      'version': int version,
      'nutrition': Map<String, dynamic> nutritionMap,
      'units': List<dynamic> unitsList,
    }) {
      return ProductVersion(
        id: snapshot.id,
        createdBy: createdBy,
        createdAt: createdAt,
        updatedAt: updatedAt,
        version: version,
        nutrition: Nutrition.fromMap(nutritionMap),
        units: unitsList
            .map((unitMap) => Unit.fromMap(unitMap as Map<String, dynamic>))
            .toList(),
      );
    } else {
      throw const FormatException('Invalid snapshot data for ProductVersion');
    }
  }

  /// Resolves the best unit to display for a given amount in grams.
  ///
  /// Returns a record containing the [quantity] in the resolved unit and the [unit] name.
  /// If no suitable unit is found (or if grams match the default unit), returns grams.
  ({double quantity, String unit}) resolveBestUnit(double grams) {
    if (units.isEmpty) {
      return (quantity: grams, unit: 'g');
    }

    // 1. Calculate the count for each unit
    final candidates = units.map((u) {
      final count = grams / u.grams;
      return (unit: u, count: count);
    }).toList();

    // 2. Score candidates
    // We prefer:
    // - Integers (or close to integers)
    // - Reasonable magnitudes (e.g. 0.5 to 100)

    // Simple heuristic: Find the one closest to a "nice" number
    // For now, let's just pick the one that results in the value closest to 1,
    // but preferring values >= 1.

    // Actually, the user's example was "2 Large Eggs" (120g) vs "2.4 Medium Eggs" (50g).
    // If we have 120g, and units are Large (60g) and Medium (50g).
    // Large -> 2.0
    // Medium -> 2.4
    // 2.0 is "nicer".

    var bestCandidate = candidates.first;
    double bestScore = double.infinity;

    for (final candidate in candidates) {
      final count = candidate.count;

      // Score based on distance to nearest integer
      final distanceToInt = (count - count.round()).abs();

      // Penalty for very small numbers (e.g. 0.05 cups)
      final magnitudePenalty = (count < 0.1) ? 100.0 : 0.0;

      final score = distanceToInt + magnitudePenalty;

      if (score < bestScore) {
        bestScore = score;
        bestCandidate = candidate;
      }
    }

    return (quantity: bestCandidate.count, unit: bestCandidate.unit.name);
  }
}
