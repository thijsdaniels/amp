import 'package:amp/core/models/entry.dart';
import 'package:amp/core/models/product.dart';
import 'package:amp/core/models/product_version.dart';
import 'package:amp/core/models/unit.dart';
import 'package:amp/core/utilities/units.dart';
import 'package:amp/features/journal/providers/entry_product_details_provider.dart';
import 'package:amp/features/journal/providers/entry_repository_provider.dart';
import 'package:amp/features/journal/providers/product_entry_provider.dart';
import 'package:amp/features/journal/providers/single_entry_provider.dart';
import 'package:amp/features/journal/widgets/nutrition_table.dart';
import 'package:amp/features/products/providers/product_repository_provider.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductEntryDetailScreen extends ConsumerWidget {
  final String entryId;

  const ProductEntryDetailScreen({super.key, required this.entryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entryAsync = ref.watch(productEntryProvider(entryId));

    return entryAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $err')),
      ),
      data: (productEntry) {
        final detailsAsync = ref.watch(
          entryProductDetailsProvider(productEntry),
        );

        return Scaffold(
          appBar: AppBar(title: Text(productEntry.name)),
          body: detailsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
            data: (details) {
              final (product, productVersion) = details;
              final isOutdated = product.latestVersion > productVersion.version;

              final nutrition = productVersion.nutrition;
              Unit? unit = _getUnit(productEntry, productVersion);

              if (unit == null) {
                return Center(
                  child: Text(
                    'Error: The unit "${productEntry.unit}" was not found for this product.',
                    textAlign: TextAlign.center,
                  ),
                );
              }

              final consumedNutrition =
                  (nutrition / 100) * productEntry.quantity * unit.grams;

              return Column(
                children: [
                  if (isOutdated)
                    MaterialBanner(
                      content: const Text(
                        'This entry uses an older version of the product. Update to the latest version?',
                      ),
                      leading: const Icon(Icons.info_outline),
                      actions: [
                        TextButton(
                          onPressed: () {
                            _onUpdatePressed(
                              context,
                              ref,
                              entryId,
                              product,
                              productEntry,
                              productVersion,
                            );
                          },
                          child: const Text('Update'),
                        ),
                      ],
                    ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (product.brand != null) ...[
                            Text(
                              product.brand!,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                  ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          Text(
                            'Quantity: ${productEntry.quantity} ${unit.name}',
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Consumed Nutrition',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          NutritionTable(nutrition: consumedNutrition),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<(Unit, double)?> _showUnitSelectionDialog(
    BuildContext context,
    List<Unit> availableUnits,
    double originalQuantity,
  ) {
    return showDialog<(Unit, double)?>(
      context: context,
      builder: (context) {
        final formKey = GlobalKey<FormBuilderState>();
        Unit? selectedUnit;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Unit not found'),
              content: FormBuilder(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'The original unit for this entry is no longer available. Please select a new unit and confirm the quantity.',
                    ),
                    const SizedBox(height: 24),
                    FormBuilderTextField(
                      name: 'quantity',
                      initialValue: originalQuantity.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null ||
                            double.tryParse(value) == null ||
                            double.parse(value) <= 0) {
                          return 'Please enter a valid quantity.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ...availableUnits.map(
                      (unit) => RadioListTile<Unit>(
                        title: Text(unit.name),
                        value: unit,
                        groupValue: selectedUnit,
                        onChanged: (value) {
                          setState(() {
                            selectedUnit = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (selectedUnit != null &&
                        formKey.currentState!.saveAndValidate()) {
                      final newQuantity = double.parse(
                        formKey.currentState!.value['quantity'],
                      );
                      Navigator.of(context).pop((selectedUnit!, newQuantity));
                    }
                  },
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _onUpdatePressed(
    BuildContext context,
    WidgetRef ref,
    String entryId,
    Product product,
    ProductEntry productEntry,
    ProductVersion productVersion,
  ) async {
    final productRepo = ref.read(productRepositoryProvider);
    final entryRepo = ref.read(entryRepositoryProvider);

    final latestVersion = await productRepo.getLatestProductVersion(
      product.id!,
    );

    final currentUnit = _getUnit(productEntry, productVersion);

    final newUnit = latestVersion.units.firstWhereOrNull(
      (u) => u.name == currentUnit?.name,
    );

    if (newUnit != null) {
      // Unit still exists, update directly
      await entryRepo.updateProductEntryToNewVersion(
        productEntry.id!,
        product.name,
        productRepo.getProductVersionRef(product.id!, latestVersion.id!),
      );
    } else {
      // Unit does not exist, show dialog
      if (!context.mounted) return;
      final selectedUnitAndQuantity = await _showUnitSelectionDialog(
        context,
        latestVersion.units,
        productEntry.quantity,
      );
      if (selectedUnitAndQuantity != null) {
        final (selectedUnit, newQuantity) = selectedUnitAndQuantity;
        await entryRepo.updateProductEntryWithNewUnit(
          productEntry.id!,
          product.name,
          productRepo.getProductVersionRef(product.id!, latestVersion.id!),
          selectedUnit.name,
          newQuantity,
        );
      }
    }
    ref.invalidate(entryProductDetailsProvider(productEntry));
    ref.invalidate(singleEntryProvider(entryId));
  }

  Unit? _getUnit(ProductEntry productEntry, ProductVersion productVersion) {
    if (productEntry.unit == Units.gram.name) {
      return Units.gram;
    }

    return productVersion.units.firstWhereOrNull(
      (unit) => unit.name == productEntry.unit,
    );
  }
}
