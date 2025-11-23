import 'package:amp/core/models/ingredient.dart';
import 'package:amp/core/models/nutrition.dart';
import 'package:amp/core/models/product.dart';
import 'package:amp/core/models/product_version.dart';
import 'package:amp/core/models/recipe.dart';
import 'package:amp/core/models/recipe_version.dart';
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
          .collection('recipe_versions')
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
        // Optimization: Use the version number as ID if possible, but for now we query
        // because we haven't migrated ProductRepository yet.
        // Wait, we are doing a fresh start, so we CAN assume the new ID structure.
        // But we need to know the version number. Product has `latestVersion`.

        final productVersionSnapshot = await itemDoc.reference
            .collection('product_versions')
            .doc(item.latestVersion.toString()) // direct access optimization
            .withConverter<ProductVersion>(
              fromFirestore: (snapshot, _) =>
                  ProductVersion.fromSnapshot(snapshot),
              toFirestore: (v, _) => v.toMap(),
            )
            .get();

        final productVersion = productVersionSnapshot.data();
        if (productVersion == null) continue;

        // Calculate nutrition for this ingredient
        // quantity is in grams. Nutrition is per 100g.
        final ratio = ingredient.quantity / 100.0;
        totalNutrition += productVersion.nutrition * ratio;
      } else if (item is Recipe) {
        final recipeId = item.id!;
        if (currentVisited.contains(recipeId)) {
          throw Exception('Cycle detected in recipe ingredients: $recipeId');
        }

        final subRecipeVersion = await getLatestRecipeVersion(recipeId);
        if (subRecipeVersion == null) continue;

        // Recurse to get total nutrition of the sub-recipe
        final subNutrition = await calculateNutrition(
          subRecipeVersion,
          visitedRecipeIds: {...currentVisited, recipeId},
        );

        // Calculate total weight of the sub-recipe to determine the ratio
        double subRecipeTotalWeight = 0.0;
        for (final subIngredient in subRecipeVersion.ingredients) {
          subRecipeTotalWeight += subIngredient.quantity;
        }

        if (subRecipeTotalWeight > 0) {
          final scale = ingredient.quantity / subRecipeTotalWeight;
          totalNutrition += subNutrition * scale;
        }
      }
    }

    return totalNutrition;
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
