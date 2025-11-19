import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/nutrition.dart';
import '../../../core/models/unit.dart';
import '../data/product_repository.dart';
import '../providers/product_repository_provider.dart';
import '../providers/prefilled_product_data_provider.dart';
import '../widgets/nutrition_form_fields.dart';
import '../widgets/upc_field.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({
    super.key,
    this.prefilledUpc,
    this.prefilledName,
    this.prefilledNutrition,
    this.prefilledUnits,
  });

  final String? prefilledUpc;
  final String? prefilledName;
  final Nutrition? prefilledNutrition;
  final List<Unit>? prefilledUnits;

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  PrefilledProductData? _cachedPrefilledData;
  bool _hasReadPrefilledData = false;

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormBuilderState>();
    final productRepository = ref.watch(productRepositoryProvider);
    
    // Read prefilled data from provider once on first build
    if (!_hasReadPrefilledData) {
      final prefilledData = ref.read(prefilledProductDataProvider);
      if (prefilledData != null) {
        _cachedPrefilledData = prefilledData;
        // Clear the provider after reading
        ref.read(prefilledProductDataProvider.notifier).state = null;
      }
      _hasReadPrefilledData = true;
    }
    
    // Use cached prefilled data if available, otherwise use widget parameters
    final effectiveName = _cachedPrefilledData?.name ?? widget.prefilledName;
    final effectiveUpc = _cachedPrefilledData?.upc ?? widget.prefilledUpc;
    final effectiveNutrition = _cachedPrefilledData?.nutrition ?? widget.prefilledNutrition;
    final effectiveUnits = _cachedPrefilledData?.units ?? widget.prefilledUnits;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
        actions: [
          TextButton(
            onPressed: () => _submitForm(context, formKey, productRepository),
            child: const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: formKey,
          initialValue: {
            if (effectiveName != null) 'name': effectiveName,
            if (effectiveNutrition != null) ...{
              'calories': effectiveNutrition.calories.toString(),
              'protein': effectiveNutrition.protein.toString(),
              'carbs': effectiveNutrition.carbohydrates.toString(),
              'fat': effectiveNutrition.fat.toString(),
            },
            if (effectiveUnits != null) 'units': effectiveUnits,
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
              UpcField(initialValue: effectiveUpc, formKey: formKey),

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
                initialValue: effectiveUnits ?? const [],
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
                                      final updatedUnits = List<Unit>.from(
                                        units,
                                      );
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
                                      final grams = num.tryParse(value) ?? 0;
                                      final updatedUnits = List<Unit>.from(
                                        units,
                                      );
                                      updatedUnits[index] = unit.copyWith(
                                        grams: grams,
                                      );
                                      field.didChange(updatedUnits);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (units.length > 1)
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      final updatedUnits = List<Unit>.from(
                                        units,
                                      );
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
      ),
    );
  }

  void _submitForm(
    BuildContext context,
    GlobalKey<FormBuilderState> formKey,
    ProductRepository productRepository,
  ) async {
    if (formKey.currentState?.saveAndValidate() ?? false) {
      final formData = formKey.currentState!.value;

      try {
        final nutrition = Nutrition(
          calories: double.parse(formData['calories'] as String),
          protein: double.parse(formData['protein'] as String),
          carbohydrates: double.parse(formData['carbs'] as String),
          fat: double.parse(formData['fat'] as String),
        );

        await productRepository.createProduct(
          name: formData['name'] as String,
          nutrition: nutrition,
          units: formData['units'] as List<Unit>,
          upc: formData['upc'] as String?,
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product created successfully!')),
          );
          context.pop();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error creating product: $e')));
        }
      }
    }
  }

}
