import 'package:amp/core/models/recipe.dart';
import 'package:amp/features/recipes/providers/recipes_stream_provider.dart';
import 'package:amp/features/recipes/screens/add_recipe_screen.dart';
import 'package:amp/features/recipes/screens/recipe_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecipeListScreen extends ConsumerWidget {
  final void Function(Recipe)? onSelect;

  const RecipeListScreen({super.key, this.onSelect});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipesAsync = ref.watch(recipesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(onSelect != null ? 'Select Recipe' : 'Recipes'),
      ),
      body: recipesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (recipes) {
          if (recipes.isEmpty) {
            return const Center(child: Text('No recipes yet. Create one!'));
          }

          return ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return ListTile(
                title: Text(recipe.name),
                subtitle: Text('Version ${recipe.latestVersion}'),
                onTap: () {
                  if (onSelect != null) {
                    onSelect!(recipe);
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            RecipeDetailScreen(recipeId: recipe.id!),
                      ),
                    );
                  }
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddRecipeScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
