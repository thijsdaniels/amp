import 'package:amp/core/models/consumable.dart';
import 'package:amp/core/models/ingredient.dart';
import 'package:amp/core/models/product.dart';
import 'package:amp/core/models/recipe.dart';
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

  void _showQuantityDialog({required Consumable item}) {
    final quantityController = TextEditingController();
    final unitController = TextEditingController(
      text: item is Product ? 'g' : 'serving',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add ${item.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: unitController,
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
              final quantity = double.tryParse(quantityController.text);
              if (quantity != null) {
                setState(() {
                  // Create the reference manually based on type
                  DocumentReference<Consumable> ref;
                  if (item is Product) {
                    ref = this.ref
                        .read(productRepositoryProvider)
                        .getProductReference(item.id!);
                  } else {
                    ref = this.ref
                        .read(recipeRepositoryProvider)
                        .getRecipeReference(item.id!);
                  }

                  _ingredients.add(
                    Ingredient(
                      itemRef: ref,
                      quantity: quantity,
                      unit: unitController.text,
                    ),
                  );
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
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
                    subtitle: Text('${ingredient.quantity} ${ingredient.unit}'),
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
