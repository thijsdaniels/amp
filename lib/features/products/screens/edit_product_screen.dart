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

        double? parse(String key, {double scale = 1.0}) {
          final value = formData[key];
          if (value == null || value is! String || value.isEmpty) return null;
          final parsed = double.tryParse(value);
          if (parsed == null) return null;
          return parsed / scale;
        }

        await productRepository.createNewProductVersion(
          productId: widget.productId,
          name: formData['name'],
          nutrition: Nutrition(
            calories: parse('calories') ?? 0,
            protein: parse('protein') ?? 0,
            carbohydrates: parse('carbs') ?? 0,
            fat: parse('fat') ?? 0,
            saturatedFat: parse('saturatedFat'),
            monounsaturatedFat: parse('monounsaturatedFat'),
            polyunsaturatedFat: parse('polyunsaturatedFat'),
            transFat: parse('transFat'),
            cholesterol: parse('cholesterol', scale: 1000),
            sodium: parse('sodium', scale: 1000),
            salt: parse('salt'),
            fiber: parse('fiber'),
            sugar: parse('sugar'),
            addedSugar: parse('addedSugar'),
            alcohol: parse('alcohol'),
            caffeine: parse('caffeine', scale: 1000),
            vitaminA: parse('vitaminA', scale: 1000000),
            vitaminB1: parse('vitaminB1', scale: 1000),
            vitaminB2: parse('vitaminB2', scale: 1000),
            vitaminB3: parse('vitaminB3', scale: 1000),
            vitaminB5: parse('vitaminB5', scale: 1000),
            vitaminB6: parse('vitaminB6', scale: 1000),
            vitaminB7: parse('vitaminB7', scale: 1000000),
            vitaminB9: parse('vitaminB9', scale: 1000000),
            vitaminB12: parse('vitaminB12', scale: 1000000),
            vitaminC: parse('vitaminC', scale: 1000),
            vitaminD: parse('vitaminD', scale: 1000000),
            vitaminE: parse('vitaminE', scale: 1000),
            vitaminK: parse('vitaminK', scale: 1000000),
            potassium: parse('potassium', scale: 1000),
            calcium: parse('calcium', scale: 1000),
            iron: parse('iron', scale: 1000),
            magnesium: parse('magnesium', scale: 1000),
            zinc: parse('zinc', scale: 1000),
            copper: parse('copper', scale: 1000),
            manganese: parse('manganese', scale: 1000),
            selenium: parse('selenium', scale: 1000000),
            phosphorus: parse('phosphorus', scale: 1000),
            iodine: parse('iodine', scale: 1000000),
            chloride: parse('chloride', scale: 1000),
          ),
          units: formData['units'],
          upc: upc,
          brand: formData['brand'] as String?,
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
    final n = productVersion.nutrition;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: FormBuilder(
        key: formKey,
        initialValue: {
          'name': product.name,
          'brand': product.brand ?? '',
          'upc': product.upc ?? '',
          'calories': n.calories.toString(),
          'protein': n.protein.toString(),
          'carbs': n.carbohydrates.toString(),
          'fat': n.fat.toString(),
          if (n.saturatedFat != null) 'saturatedFat': n.saturatedFat.toString(),
          if (n.monounsaturatedFat != null)
            'monounsaturatedFat': n.monounsaturatedFat.toString(),
          if (n.polyunsaturatedFat != null)
            'polyunsaturatedFat': n.polyunsaturatedFat.toString(),
          if (n.transFat != null) 'transFat': n.transFat.toString(),
          if (n.cholesterol != null)
            'cholesterol': (n.cholesterol! * 1000).toString(),
          if (n.sodium != null) 'sodium': (n.sodium! * 1000).toString(),
          if (n.salt != null) 'salt': n.salt.toString(),
          if (n.fiber != null) 'fiber': n.fiber.toString(),
          if (n.sugar != null) 'sugar': n.sugar.toString(),
          if (n.addedSugar != null) 'addedSugar': n.addedSugar.toString(),
          if (n.alcohol != null) 'alcohol': n.alcohol.toString(),
          if (n.caffeine != null) 'caffeine': (n.caffeine! * 1000).toString(),
          if (n.vitaminA != null)
            'vitaminA': (n.vitaminA! * 1000000).toString(),
          if (n.vitaminB1 != null)
            'vitaminB1': (n.vitaminB1! * 1000).toString(),
          if (n.vitaminB2 != null)
            'vitaminB2': (n.vitaminB2! * 1000).toString(),
          if (n.vitaminB3 != null)
            'vitaminB3': (n.vitaminB3! * 1000).toString(),
          if (n.vitaminB5 != null)
            'vitaminB5': (n.vitaminB5! * 1000).toString(),
          if (n.vitaminB6 != null)
            'vitaminB6': (n.vitaminB6! * 1000).toString(),
          if (n.vitaminB7 != null)
            'vitaminB7': (n.vitaminB7! * 1000000).toString(),
          if (n.vitaminB9 != null)
            'vitaminB9': (n.vitaminB9! * 1000000).toString(),
          if (n.vitaminB12 != null)
            'vitaminB12': (n.vitaminB12! * 1000000).toString(),
          if (n.vitaminC != null) 'vitaminC': (n.vitaminC! * 1000).toString(),
          if (n.vitaminD != null)
            'vitaminD': (n.vitaminD! * 1000000).toString(),
          if (n.vitaminE != null) 'vitaminE': (n.vitaminE! * 1000).toString(),
          if (n.vitaminK != null)
            'vitaminK': (n.vitaminK! * 1000000).toString(),
          if (n.potassium != null)
            'potassium': (n.potassium! * 1000).toString(),
          if (n.calcium != null) 'calcium': (n.calcium! * 1000).toString(),
          if (n.iron != null) 'iron': (n.iron! * 1000).toString(),
          if (n.magnesium != null)
            'magnesium': (n.magnesium! * 1000).toString(),
          if (n.zinc != null) 'zinc': (n.zinc! * 1000).toString(),
          if (n.copper != null) 'copper': (n.copper! * 1000).toString(),
          if (n.manganese != null)
            'manganese': (n.manganese! * 1000).toString(),
          if (n.selenium != null)
            'selenium': (n.selenium! * 1000000).toString(),
          if (n.phosphorus != null)
            'phosphorus': (n.phosphorus! * 1000).toString(),
          if (n.iodine != null) 'iodine': (n.iodine! * 1000000).toString(),
          if (n.chloride != null) 'chloride': (n.chloride! * 1000).toString(),
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

            // Brand
            FormBuilderTextField(
              name: 'brand',
              decoration: const InputDecoration(
                labelText: 'Brand Name',
                border: OutlineInputBorder(),
              ),
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
