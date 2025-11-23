import 'package:amp/core/models/recipe.dart';
import 'package:amp/core/models/recipe_version.dart';
import 'package:amp/features/recipes/providers/recipe_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final recipeDetailsProvider =
    FutureProvider.family<(Recipe?, RecipeVersion?), String>((
      ref,
      recipeId,
    ) async {
      final recipeRepo = ref.watch(recipeRepositoryProvider);

      // Fetch both in parallel for efficiency
      final recipeFuture = recipeRepo.getRecipe(recipeId);
      final versionFuture = recipeRepo.getLatestRecipeVersion(recipeId);

      final recipe = await recipeFuture;
      final version = await versionFuture;

      return (recipe, version);
    });
