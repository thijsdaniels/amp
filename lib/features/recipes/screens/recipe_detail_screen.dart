import 'package:amp/core/models/ingredient.dart';
import 'package:amp/core/models/product.dart';
import 'package:amp/core/models/product_version.dart';
import 'package:amp/core/models/recipe.dart';
import 'package:amp/features/recipes/providers/recipe_details_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecipeDetailScreen extends ConsumerWidget {
  final String recipeId;

  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipeDetailsAsync = ref.watch(recipeDetailsProvider(recipeId));

    return Scaffold(
      appBar: AppBar(title: const Text('Recipe Details')),
      body: recipeDetailsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (data) {
          final recipe = data.$1;
          final version = data.$2;

          if (recipe == null || version == null) {
            return const Center(child: Text('Recipe not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Servings: ${version.servings}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  'Ingredients:',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: version.ingredients.length,
                  itemBuilder: (context, index) {
                    final ingredient = version.ingredients[index];
                    return IngredientListItem(ingredient: ingredient);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class IngredientListItem extends StatelessWidget {
  final Ingredient ingredient;

  const IngredientListItem({super.key, required this.ingredient});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: ingredient.itemRef.get(),
      builder: (context, itemSnapshot) {
        if (!itemSnapshot.hasData) {
          return const ListTile(title: Text('Loading...'));
        }
        final itemData = itemSnapshot.data!.data();

        if (itemData is Product) {
          return FutureBuilder<DocumentSnapshot>(
            future: ingredient.itemRef
                .collection('product_versions')
                .doc(itemData.latestVersion.toString())
                .withConverter<ProductVersion>(
                  fromFirestore: (s, _) => ProductVersion.fromSnapshot(s),
                  toFirestore: (v, _) => v.toMap(),
                )
                .get(),
            builder: (context, versionSnapshot) {
              if (!versionSnapshot.hasData) {
                return ListTile(
                  title: Text(itemData.name),
                  subtitle: const Text('Loading details...'),
                );
              }
              final version = versionSnapshot.data!.data() as ProductVersion?;
              if (version == null) {
                return ListTile(
                  title: Text(itemData.name),
                  subtitle: Text('${ingredient.quantity.toStringAsFixed(1)}g'),
                );
              }

              final resolved = version.resolveBestUnit(ingredient.quantity);
              return ListTile(
                title: Text(itemData.name),
                subtitle: Text(
                  '${resolved.quantity.toStringAsFixed(2)} ${resolved.unit}',
                ),
              );
            },
          );
        } else if (itemData is Recipe) {
          return ListTile(
            title: Text(itemData.name),
            subtitle: Text('${ingredient.quantity.toStringAsFixed(1)}g'),
          );
        }

        return const ListTile(title: Text('Unknown Item'));
      },
    );
  }
}
