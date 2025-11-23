import 'package:amp/core/models/consumable.dart';
import 'package:amp/core/models/ingredient.dart';
import 'package:amp/core/models/product.dart';
import 'package:amp/core/models/recipe.dart';
import 'package:amp/core/models/unit.dart';
import 'package:amp/features/products/providers/product_repository_provider.dart';
import 'package:amp/features/recipes/providers/recipe_repository_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddRecipeScreen extends ConsumerStatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  ConsumerState<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends ConsumerState<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _servingsController = TextEditingController(text: '1');

  final List<Ingredient> _ingredients = [];

  @override
  void dispose() {
    _nameController.dispose();
    _servingsController.dispose();
    super.dispose();
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) return;
    if (_ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one ingredient')),
      );
      return;
    }

    try {
      await ref
          .read(recipeRepositoryProvider)
          .createRecipe(
            name: _nameController.text,
            ingredients: _ingredients,
            servings: double.parse(_servingsController.text),
          );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving recipe: $e')));
      }
    }
  }

  void _addIngredient() async {
    final type = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Add Ingredient Type'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'product'),
            child: const Text('Product'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'recipe'),
            child: const Text('Recipe'),
          ),
        ],
      ),
    );

    if (type == null) return;

    if (type == 'product') {
      _addProductIngredient();
    } else {
      _addRecipeIngredient();
    }
  }

  void _addProductIngredient() async {
    final products = await ref.read(productRepositoryProvider).getProducts();

    if (!mounted) return;

    final selectedProduct = await showDialog<Product>(
      context: context,
      builder: (context) => Dialog(
        child: ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ListTile(
              title: Text(product.name),
              onTap: () => Navigator.pop(context, product),
            );
          },
        ),
      ),
    );

    if (selectedProduct == null) return;
    if (!mounted) return;

    _showQuantityDialog(item: selectedProduct);
  }

  void _addRecipeIngredient() async {
    final recipes = await ref.read(recipeRepositoryProvider).getRecipes();

    if (!mounted) return;

    final selectedRecipe = await showDialog<Recipe>(
      context: context,
      builder: (context) => Dialog(
        child: ListView.builder(
          itemCount: recipes.length,
          itemBuilder: (context, index) {
            final recipe = recipes[index];
            return ListTile(
              title: Text(recipe.name),
              onTap: () => Navigator.pop(context, recipe),
            );
          },
        ),
      ),
    );

    if (selectedRecipe == null) return;
    if (!mounted) return;

    _showQuantityDialog(item: selectedRecipe);
  }

  void _showQuantityDialog({required Consumable item}) async {
    final result = await showDialog<Ingredient>(
      context: context,
      builder: (context) => IngredientEntryDialog(item: item),
    );

    if (result != null) {
      setState(() {
        _ingredients.add(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Recipe'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveRecipe),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Recipe Name'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _servingsController,
                    decoration: const InputDecoration(
                      labelText: 'Servings (Yield)',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value == null || double.tryParse(value) == null
                        ? 'Invalid number'
                        : null,
                  ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ingredients',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle),
                    onPressed: _addIngredient,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _ingredients.length,
                itemBuilder: (context, index) {
                  final ingredient = _ingredients[index];
                  return ListTile(
                    title: FutureBuilder<DocumentSnapshot<Consumable>>(
                      future: ingredient.itemRef.get(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const Text('Loading...');
                        final data = snapshot.data!.data();
                        return Text(data?.name ?? 'Unknown');
                      },
                    ),
                    subtitle: Text(
                      '${ingredient.quantity.toStringAsFixed(1)}g',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _ingredients.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class IngredientEntryDialog extends ConsumerStatefulWidget {
  final Consumable item;

  const IngredientEntryDialog({super.key, required this.item});

  @override
  ConsumerState<IngredientEntryDialog> createState() =>
      _IngredientEntryDialogState();
}

class _IngredientEntryDialogState extends ConsumerState<IngredientEntryDialog> {
  final _quantityController = TextEditingController();
  String? _selectedUnit;
  List<Unit> _availableUnits = [];
  bool _isLoading = true;
  double _recipeTotalWeight = 0.0;
  double _recipeYield = 1.0;

  @override
  void initState() {
    super.initState();
    _loadUnits();
  }

  Future<void> _loadUnits() async {
    try {
      if (widget.item is Product) {
        final product = widget.item as Product;
        final version = await ref
            .read(productRepositoryProvider)
            .getLatestProductVersion(product.id!);

        if (mounted) {
          setState(() {
            _availableUnits = version.units;
            _isLoading = false;
            _selectedUnit = 'g';
          });
        }
      } else if (widget.item is Recipe) {
        final recipe = widget.item as Recipe;
        final version = await ref
            .read(recipeRepositoryProvider)
            .getLatestRecipeVersion(recipe.id!);

        if (mounted) {
          if (version != null) {
            double weight = 0.0;
            for (final ing in version.ingredients) {
              weight += ing.quantity;
            }
            setState(() {
              _recipeTotalWeight = weight;
              _recipeYield = version.servings;
              _isLoading = false;
              _selectedUnit = 'g';
            });
          } else {
            setState(() {
              _isLoading = false;
              _selectedUnit = 'g';
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _selectedUnit = 'g';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AlertDialog(
        content: SizedBox(
          height: 100,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    // Build unit dropdown items
    final unitItems = <DropdownMenuItem<String>>[
      const DropdownMenuItem(value: 'g', child: Text('grams (g)')),
    ];

    for (final unit in _availableUnits) {
      unitItems.add(DropdownMenuItem(value: unit.name, child: Text(unit.name)));
    }

    if (widget.item is Recipe && _recipeTotalWeight > 0) {
      unitItems.add(
        const DropdownMenuItem(value: 'serving', child: Text('serving')),
      );
    }

    return AlertDialog(
      title: Text('Add ${widget.item.name}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _quantityController,
            decoration: const InputDecoration(labelText: 'Quantity'),
            keyboardType: TextInputType.number,
            autofocus: true,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedUnit,
            items: unitItems,
            onChanged: (value) {
              setState(() {
                _selectedUnit = value;
              });
            },
            decoration: const InputDecoration(labelText: 'Unit'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final quantity = double.tryParse(_quantityController.text);
            if (quantity != null && _selectedUnit != null) {
              double grams = 0.0;

              if (_selectedUnit == 'g') {
                grams = quantity;
              } else if (_selectedUnit == 'serving' && widget.item is Recipe) {
                // Convert serving to grams
                // 1 serving = TotalWeight / Yield
                // grams = quantity * (TotalWeight / Yield)
                if (_recipeYield > 0) {
                  grams = quantity * (_recipeTotalWeight / _recipeYield);
                } else {
                  grams =
                      quantity * _recipeTotalWeight; // Fallback if yield is 0
                }
              } else {
                // Find unit def
                final unitDef = _availableUnits.firstWhere(
                  (u) => u.name == _selectedUnit,
                  orElse: () => const Unit(name: 'unknown', grams: 0),
                );
                grams = quantity * unitDef.grams;
              }

              // Create reference
              DocumentReference<Consumable> ref;
              if (widget.item is Product) {
                ref = this.ref
                    .read(productRepositoryProvider)
                    .getProductReference(widget.item.id!);
              } else {
                ref = this.ref
                    .read(recipeRepositoryProvider)
                    .getRecipeReference(widget.item.id!);
              }

              Navigator.pop(context, Ingredient(itemRef: ref, quantity: grams));
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
