import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amp/core/models/entry.dart';
import 'package:amp/core/models/product.dart';
import 'package:amp/core/models/product_version.dart';
import 'package:amp/core/models/unit.dart';
import 'package:amp/core/models/units.dart';
import 'package:amp/features/auth/providers/uid_provider.dart';
import 'package:amp/features/journal/providers/entry_repository_provider.dart';
import 'package:amp/features/products/providers/product_repository_provider.dart';

final productDetailsProvider =
    FutureProvider.family<(Product, ProductVersion), String>((
      ref,
      productId,
    ) async {
      final productRepo = ref.watch(productRepositoryProvider);
      // Fetch both in parallel for efficiency
      final productFuture = productRepo.getProduct(productId);
      final productVersionFuture = productRepo.getLatestProductVersion(
        productId,
      );

      final product = await productFuture;
      final productVersion = await productVersionFuture;

      return (product, productVersion);
    });

class ProductDetailScreen extends ConsumerWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productDetailsAsync = ref.watch(productDetailsProvider(productId));

    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: productDetailsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (details) {
          final product = details.$1;
          final productVersion = details.$2;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Version: ${productVersion.version}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 24),
                Text(
                  'Nutrition (per 100g)',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    title: const Text('Calories'),
                    trailing: Text('${productVersion.nutrition.calories} kcal'),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: const Text('Protein'),
                    trailing: Text('${productVersion.nutrition.protein} g'),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: const Text('Carbohydrates'),
                    trailing: Text(
                      '${productVersion.nutrition.carbohydrates} g',
                    ),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: const Text('Fat'),
                    trailing: Text('${productVersion.nutrition.fat} g'),
                  ),
                ),
                const SizedBox(height: 24),
                if (productVersion.units.isNotEmpty) ...[
                  Text('Units', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  ...productVersion.units.map(
                    (unit) => Card(
                      child: ListTile(
                        title: Text(unit.name),
                        trailing: Text('${unit.grams} g'),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
      floatingActionButton: productDetailsAsync.when(
        data: (details) => FloatingActionButton(
          onPressed: () {
            _showLogDialog(context, ref, details.$1, details.$2);
          },
          child: const Icon(Icons.add_chart),
        ),
        loading: () => null,
        error: (e, s) => null,
      ),
    );
  }

  void _showLogDialog(
    BuildContext context,
    WidgetRef ref,
    Product product,
    ProductVersion productVersion,
  ) {
    final allUnits = [Units.gram, ...productVersion.units];

    final formKey = GlobalKey<FormState>();
    final quantityController = TextEditingController();
    Unit? selectedUnit = Units.gram;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Log ${product.name}'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: quantityController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a quantity';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<Unit>(
                      value: selectedUnit,
                      items: allUnits.map((Unit unit) {
                        return DropdownMenuItem<Unit>(
                          value: unit,
                          child: Text(unit.name),
                        );
                      }).toList(),
                      onChanged: (Unit? newValue) {
                        setState(() {
                          selectedUnit = newValue;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null ? 'Please select a unit' : null,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final quantity = double.parse(quantityController.text);
                      final uid = ref.read(uidProvider);
                      final now = Timestamp.now();

                      final productEntry = Entry.product(
                        createdBy: uid,
                        createdAt: now,
                        updatedAt: now,
                        productVersionRef: ref
                            .read(productRepositoryProvider)
                            .getProductVersionRef(
                              product.id!,
                              productVersion.id!,
                            ),
                        name: product.name,
                        quantity: quantity,
                        unit: selectedUnit!.name,
                      );

                      try {
                        await ref
                            .read(entryRepositoryProvider)
                            .addEntry(productEntry);

                        if (!context.mounted) return;

                        Navigator.of(context).pop();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${product.name} logged successfully!',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        if (!context.mounted) return;

                        Navigator.of(context).pop();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error logging entry: $e'),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.error,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Log'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
