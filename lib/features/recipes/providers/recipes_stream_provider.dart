import 'package:amp/core/models/recipe.dart';
import 'package:amp/features/recipes/providers/recipe_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final recipesStreamProvider = StreamProvider.autoDispose<List<Recipe>>((ref) {
  final recipeRepository = ref.watch(recipeRepositoryProvider);
  return recipeRepository.getRecipesStream();
});
