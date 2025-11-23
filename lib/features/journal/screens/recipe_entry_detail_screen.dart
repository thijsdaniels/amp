import 'package:amp/core/models/entry.dart';
import 'package:amp/core/models/recipe.dart';
import 'package:amp/core/models/recipe_version.dart';
import 'package:amp/features/journal/providers/single_entry_provider.dart';
import 'package:amp/features/journal/widgets/nutrition_table.dart';
import 'package:amp/features/recipes/providers/recipe_repository_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecipeEntryDetailScreen extends ConsumerWidget {
  final String entryId;

  const RecipeEntryDetailScreen({super.key, required this.entryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entryAsync = ref.watch(singleEntryProvider(entryId));

    return entryAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $err')),
      ),
      data: (entry) {
        if (entry is! RecipeEntry) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Error: Not a recipe entry')),
          );
        }

        return _RecipeEntryDetailContent(entry: entry);
      },
    );
  }
}

class _RecipeEntryDetailContent extends ConsumerStatefulWidget {
  final RecipeEntry entry;

  const _RecipeEntryDetailContent({required this.entry});

  @override
  ConsumerState<_RecipeEntryDetailContent> createState() =>
      _RecipeEntryDetailContentState();
}

class _RecipeEntryDetailContentState
    extends ConsumerState<_RecipeEntryDetailContent> {
  Recipe? _recipe;
  RecipeVersion? _version;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      // Fetch Recipe Version
      final versionSnapshot = await widget.entry.recipeVersionRef
          .withConverter<RecipeVersion>(
            fromFirestore: (s, _) => RecipeVersion.fromSnapshot(s),
            toFirestore: (v, _) => v.toMap(),
          )
          .get();

      final version = versionSnapshot.data();

      // Fetch Recipe (Parent)
      // We can get the parent ref from the version ref's parent's parent
      // versionRef.parent is 'recipe_versions' collection
      // versionRef.parent.parent is the Recipe document
      final recipeSnapshot = await widget.entry.recipeVersionRef.parent.parent!
          .withConverter<Recipe>(
            fromFirestore: (s, _) => Recipe.fromSnapshot(s),
            toFirestore: (v, _) => v.toMap(),
          )
          .get();

      final recipe = recipeSnapshot.data();

      if (mounted) {
        setState(() {
          _version = version;
          _recipe = recipe;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.entry.name)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _version == null || _recipe == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.entry.name)),
        body: Center(child: Text('Error loading details: $_error')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.entry.name)),
      body: FutureBuilder(
        future: ref
            .read(recipeRepositoryProvider)
            .calculateNutrition(_version!),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final totalNutrition = snapshot.data!;

          // Calculate consumed nutrition
          // entry.quantity is grams consumed.
          // totalNutrition is for the WHOLE recipe.
          // We need total weight of the recipe to find the ratio.
          double totalWeight = 0.0;
          for (final ing in _version!.ingredients) {
            totalWeight += ing.quantity;
          }

          final ratio = totalWeight > 0
              ? widget.entry.quantity / totalWeight
              : 0.0;
          final consumedNutrition = totalNutrition * ratio;

          // Calculate servings
          String quantityText = '${widget.entry.quantity.toStringAsFixed(1)}g';
          if (_version!.servings > 0 && totalWeight > 0) {
            final servings =
                (widget.entry.quantity / totalWeight) * _version!.servings;
            quantityText =
                '${servings.toStringAsFixed(1)} servings (${widget.entry.quantity.toStringAsFixed(1)}g)';
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quantity: $quantityText',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 24),
                Text(
                  'Consumed Nutrition',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                NutritionTable(nutrition: consumedNutrition),
              ],
            ),
          );
        },
      ),
    );
  }
}
