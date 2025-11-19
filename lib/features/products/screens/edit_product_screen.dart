import 'package:amp/features/products/providers/product_details_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/nutrition.dart';
import '../../../core/models/product.dart';
import '../../../core/models/product_version.dart';
import '../../../core/models/unit.dart';
import '../providers/product_repository_provider.dart';
import '../widgets/nutrition_form_fields.dart';
import '../widgets/upc_field.dart';

class EditProductScreen extends ConsumerStatefulWidget {
  final String productId;
  const EditProductScreen({super.key, required this.productId});

  @override
  ConsumerState<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends ConsumerState<EditProductScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  void _submitForm({
    required Product originalProduct,
    required ProductVersion originalVersion,
  }) async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final productRepository = ref.read(productRepositoryProvider);
      final formData = _formKey.currentState!.value;

      try {
        // Extract UPC from form data, handling empty strings
        final upcValue = formData['upc'] as String?;
        final upc = upcValue?.trim().isEmpty == true ? null : upcValue?.trim();

        await productRepository.createNewProductVersion(
          productId: widget.productId,
          name: formData['name'],
          nutrition: Nutrition(
            calories: double.parse(formData['calories']),
            protein: double.parse(formData['protein']),
            carbohydrates: double.parse(formData['carbs']),
            fat: double.parse(formData['fat']),
          ),
          units: formData['units'],
          upc: upc,
        );

        ref.invalidate(productDetailsProvider(widget.productId));

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating product: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productDetailsAsync = ref.watch(
      productDetailsProvider(widget.productId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        actions: [
          productDetailsAsync.when(
            data: (details) => TextButton(
              onPressed: () => _submitForm(
                originalProduct: details.$1,
                originalVersion: details.$2,
              ),
              child: const Text('Save'),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: productDetailsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
        data: (details) {
          final (product, productVersion) = details;
          return _EditProductForm(
            formKey: _formKey,
            product: product,
            productVersion: productVersion,
          );
        },
      ),
    );
  }
}

class _EditProductForm extends StatelessWidget {
  final GlobalKey<FormBuilderState> formKey;
  final Product product;
  final ProductVersion productVersion;

  const _EditProductForm({
    required this.formKey,
    required this.product,
    required this.productVersion,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: FormBuilder(
        key: formKey,
        initialValue: {
          'name': product.name,
          'upc': product.upc ?? '',
          'calories': productVersion.nutrition.calories.toString(),
          'protein': productVersion.nutrition.protein.toString(),
          'carbs': productVersion.nutrition.carbohydrates.toString(),
          'fat': productVersion.nutrition.fat.toString(),
          'units': productVersion.units,
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product Name
            FormBuilderTextField(
              name: 'name',
              decoration: const InputDecoration(
                labelText: 'Product Name',
                border: OutlineInputBorder(),
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.minLength(2),
              ]),
            ),

            const SizedBox(height: 16),

            // UPC/Barcode
            UpcField(formKey: formKey),

            const SizedBox(height: 16),

            // Nutrition Section
            const NutritionFormFields(),

            const SizedBox(height: 24),

            // Units Section
            const Text(
              'Available Units',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            // Units List
            FormBuilderField<List<Unit>>(
              name: 'units',
              builder: (field) {
                final units = field.value ?? [];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (field.errorText != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          field.errorText!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ...units.asMap().entries.map((entry) {
                      final index = entry.key;
                      final unit = entry.value;

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  initialValue: unit.name,
                                  decoration: const InputDecoration(
                                    labelText: 'Unit Name',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) {
                                    final updatedUnits = List<Unit>.from(units);
                                    updatedUnits[index] = unit.copyWith(
                                      name: value,
                                    );
                                    field.didChange(updatedUnits);
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  initialValue: unit.grams.toString(),
                                  decoration: const InputDecoration(
                                    labelText: 'Grams',
                                    border: OutlineInputBorder(),
                                    suffixText: 'g',
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    final grams = double.tryParse(value) ?? 0.0;
                                    final updatedUnits = List<Unit>.from(units);
                                    updatedUnits[index] = unit.copyWith(
                                      grams: grams,
                                    );
                                    field.didChange(updatedUnits);
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  final updatedUnits = List<Unit>.from(units);
                                  updatedUnits.removeAt(index);
                                  field.didChange(updatedUnits);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        final updatedUnits = List<Unit>.from(units);
                        updatedUnits.add(const Unit(name: '', grams: 0));
                        field.didChange(updatedUnits);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Unit'),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
