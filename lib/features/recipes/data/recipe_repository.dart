import 'package:amp/core/models/ingredient.dart';
import 'package:amp/core/models/nutrition.dart';
import 'package:amp/core/models/product.dart';
import 'package:amp/core/models/product_version.dart';
import 'package:amp/core/models/recipe.dart';
import 'package:amp/core/models/recipe_version.dart';
import 'package:amp/core/models/unit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeRepository {
  final FirebaseFirestore _firestore;
  final String _uid;

  RecipeRepository({required FirebaseFirestore firestore, required String uid})
    : _firestore = firestore,
      _uid = uid;

  CollectionReference<Recipe> get _recipesRef => _firestore
      .collection('users')
      .doc(_uid)
      .collection('recipes')
      .withConverter<Recipe>(
        fromFirestore: (snapshot, _) => Recipe.fromSnapshot(snapshot),
        toFirestore: (recipe, _) => recipe.toMap(),
      );

  CollectionReference<RecipeVersion> _versionsRef(String recipeId) =>
      _recipesRef
          .doc(recipeId)
          .collection('versions')
          .withConverter<RecipeVersion>(
            fromFirestore: (snapshot, _) =>
                RecipeVersion.fromSnapshot(snapshot),
            toFirestore: (version, _) => version.toMap(),
          );

  Future<List<Recipe>> getRecipes() async {
    final snapshot = await _recipesRef
        .orderBy('updatedAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Stream<List<Recipe>> getRecipesStream() {
    return _recipesRef
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<Recipe?> getRecipe(String recipeId) async {
    final doc = await _recipesRef.doc(recipeId).get();
    return doc.data();
  }

  DocumentReference<Recipe> getRecipeReference(String recipeId) {
    return _recipesRef.doc(recipeId);
  }

  Future<RecipeVersion?> getLatestRecipeVersion(String recipeId) async {
    final recipeDoc = await _recipesRef.doc(recipeId).get();
    final recipe = recipeDoc.data();
    if (recipe == null) return null;

    final versionSnapshot = await _versionsRef(
      recipeId,
    ).where('version', isEqualTo: recipe.latestVersion).limit(1).get();

    if (versionSnapshot.docs.isEmpty) return null;
    return versionSnapshot.docs.first.data();
  }

  /// Calculates the total nutrition for a given RecipeVersion.
  /// This involves recursively fetching ingredients (Products or other Recipes).
  ///
  /// [visitedRecipeIds] is used for cycle detection.
  Future<Nutrition> calculateNutrition(
    RecipeVersion version, {
    Set<String>? visitedRecipeIds,
  }) async {
    final currentVisited = visitedRecipeIds ?? {};
    // Note: We don't add the current recipe ID here because we are calculating *its* nutrition
    // based on its ingredients. We check for cycles when processing ingredients.

    var totalNutrition = const Nutrition(
      calories: 0,
      protein: 0,
      carbohydrates: 0,
      fat: 0,
    );

    for (final ingredient in version.ingredients) {
      final itemDoc = await ingredient.itemRef.get();
      final item = itemDoc.data();

      if (item is Product) {
        // Fetch the latest version of the product to get nutrition
        final productVersionSnapshot = await itemDoc.reference
            .collection('versions')
            .where('version', isEqualTo: item.latestVersion)
            .limit(1)
            .withConverter<ProductVersion>(
              fromFirestore: (snapshot, _) =>
                  ProductVersion.fromSnapshot(snapshot),
              toFirestore: (v, _) => v.toMap(),
            )
            .get();

        if (productVersionSnapshot.docs.isEmpty) continue;
        final productVersion = productVersionSnapshot.docs.first.data();

        // Calculate nutrition for this ingredient
        final ratio = _calculateRatio(
          ingredient.quantity,
          ingredient.unit,
          productVersion.units,
        );
        totalNutrition += productVersion.nutrition * ratio;
      } else if (item is Recipe) {
        final recipeId = item.id!;
        if (currentVisited.contains(recipeId)) {
          throw Exception('Cycle detected in recipe ingredients: $recipeId');
        }

        final subRecipeVersion = await getLatestRecipeVersion(recipeId);
        if (subRecipeVersion == null) continue;

        // Recurse
        final subNutrition = await calculateNutrition(
          subRecipeVersion,
          visitedRecipeIds: {...currentVisited, recipeId},
        );

        double scale = 1.0;

        // Let's try to support "serving" unit.
        if (ingredient.unit.toLowerCase() == 'serving' ||
            ingredient.unit.toLowerCase() == 'servings') {
          // Use the recipe's yield (servings) to calculate per-serving nutrition
          // subNutrition is TOTAL for the recipe.
          // Per serving = subNutrition / subRecipeVersion.servings
          // Total for ingredient = Per serving * ingredient.quantity

          if (subRecipeVersion.servings > 0) {
            scale = ingredient.quantity / subRecipeVersion.servings;
          } else {
            scale = ingredient.quantity; // Fallback
          }
        } else {
          // If unit is not 'serving', we assume it's a fraction of the whole recipe
          // e.g. 0.5 of the whole recipe.
          scale = ingredient.quantity;
        }

        totalNutrition += subNutrition * scale;
      }
    }

    return totalNutrition;
  }

  double _calculateRatio(
    double quantity,
    String unit,
    List<Unit> availableUnits,
  ) {
    // 1. Find the unit definition
    final unitDef = availableUnits.firstWhere(
      (u) => u.name.toLowerCase() == unit.toLowerCase(),
      orElse: () => const Unit(name: 'unknown', grams: 0),
    );

    if (unitDef.grams > 0) {
      // Convert everything to grams
      // Nutrition is stored per 100g
      final totalGrams = quantity * unitDef.grams;
      return totalGrams / 100.0;
    } else if (unit.toLowerCase() == 'g' ||
        unit.toLowerCase() == 'gram' ||
        unit.toLowerCase() == 'grams') {
      return quantity / 100.0;
    }

    // Fallback/Error
    return 0.0;
  }

  Future<void> createRecipe({
    required String name,
    String? description,
    required List<Ingredient> ingredients,
    double servings = 1.0,
  }) async {
    final recipeRef = _recipesRef.doc();
    final now = Timestamp.now();

    final recipe = Recipe(
      id: recipeRef.id,
      createdBy: _uid,
      createdAt: now,
      updatedAt: now,
      name: name,
      latestVersion: 1,
    );

    final version = RecipeVersion(
      id: _versionsRef(recipeRef.id).doc().id,
      createdBy: _uid,
      createdAt: now,
      updatedAt: now,
      version: 1,
      servings: servings,
      units: [], // TODO: Calculate units/yield
      ingredients: ingredients,
    );

    final batch = _firestore.batch();
    batch.set(recipeRef, recipe);
    batch.set(_versionsRef(recipeRef.id).doc(version.id), version);
    await batch.commit();
  }
}
