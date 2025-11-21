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

  @override
  void initState() {
    super.initState();
    // Read prefilled data from provider once on init
    final prefilledData = ref.read(prefilledProductDataProvider);
    if (prefilledData != null) {
      _cachedPrefilledData = prefilledData;
      // Clear the provider after reading to avoid stale data
      Future.microtask(() {
        ref.read(prefilledProductDataProvider.notifier).state = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormBuilderState>();
    final productRepository = ref.watch(productRepositoryProvider);

    // Use cached prefilled data if available, otherwise use widget parameters
    final effectiveName = _cachedPrefilledData?.name ?? widget.prefilledName;
    final effectiveUpc = _cachedPrefilledData?.upc ?? widget.prefilledUpc;
    final effectiveNutrition =
        _cachedPrefilledData?.nutrition ?? widget.prefilledNutrition;
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
            if (_cachedPrefilledData?.brand != null)
              'brand': _cachedPrefilledData!.brand!,
            if (effectiveNutrition != null) ...{
              'calories': effectiveNutrition.calories.toString(),
              'protein': effectiveNutrition.protein.toString(),
              'carbs': effectiveNutrition.carbohydrates.toString(),
              'fat': effectiveNutrition.fat.toString(),
              if (effectiveNutrition.saturatedFat != null)
                'saturatedFat': effectiveNutrition.saturatedFat.toString(),
              if (effectiveNutrition.monounsaturatedFat != null)
                'monounsaturatedFat': effectiveNutrition.monounsaturatedFat
                    .toString(),
              if (effectiveNutrition.polyunsaturatedFat != null)
                'polyunsaturatedFat': effectiveNutrition.polyunsaturatedFat
                    .toString(),
              if (effectiveNutrition.transFat != null)
                'transFat': effectiveNutrition.transFat.toString(),
              if (effectiveNutrition.cholesterol != null)
                'cholesterol': (effectiveNutrition.cholesterol! * 1000)
                    .toString(),
              if (effectiveNutrition.sodium != null)
                'sodium': (effectiveNutrition.sodium! * 1000).toString(),
              if (effectiveNutrition.salt != null)
                'salt': effectiveNutrition.salt.toString(),
              if (effectiveNutrition.fiber != null)
                'fiber': effectiveNutrition.fiber.toString(),
              if (effectiveNutrition.sugar != null)
                'sugar': effectiveNutrition.sugar.toString(),
              if (effectiveNutrition.addedSugar != null)
                'addedSugar': effectiveNutrition.addedSugar.toString(),
              if (effectiveNutrition.alcohol != null)
                'alcohol': effectiveNutrition.alcohol.toString(),
              if (effectiveNutrition.caffeine != null)
                'caffeine': (effectiveNutrition.caffeine! * 1000).toString(),
              if (effectiveNutrition.vitaminA != null)
                'vitaminA': (effectiveNutrition.vitaminA! * 1000000).toString(),
              if (effectiveNutrition.vitaminB1 != null)
                'vitaminB1': (effectiveNutrition.vitaminB1! * 1000).toString(),
              if (effectiveNutrition.vitaminB2 != null)
                'vitaminB2': (effectiveNutrition.vitaminB2! * 1000).toString(),
              if (effectiveNutrition.vitaminB3 != null)
                'vitaminB3': (effectiveNutrition.vitaminB3! * 1000).toString(),
              if (effectiveNutrition.vitaminB5 != null)
                'vitaminB5': (effectiveNutrition.vitaminB5! * 1000).toString(),
              if (effectiveNutrition.vitaminB6 != null)
                'vitaminB6': (effectiveNutrition.vitaminB6! * 1000).toString(),
              if (effectiveNutrition.vitaminB7 != null)
                'vitaminB7': (effectiveNutrition.vitaminB7! * 1000000)
                    .toString(),
              if (effectiveNutrition.vitaminB9 != null)
                'vitaminB9': (effectiveNutrition.vitaminB9! * 1000000)
                    .toString(),
              if (effectiveNutrition.vitaminB12 != null)
                'vitaminB12': (effectiveNutrition.vitaminB12! * 1000000)
                    .toString(),
              if (effectiveNutrition.vitaminC != null)
                'vitaminC': (effectiveNutrition.vitaminC! * 1000).toString(),
              if (effectiveNutrition.vitaminD != null)
                'vitaminD': (effectiveNutrition.vitaminD! * 1000000).toString(),
              if (effectiveNutrition.vitaminE != null)
                'vitaminE': (effectiveNutrition.vitaminE! * 1000).toString(),
              if (effectiveNutrition.vitaminK != null)
                'vitaminK': (effectiveNutrition.vitaminK! * 1000000).toString(),
              if (effectiveNutrition.potassium != null)
                'potassium': (effectiveNutrition.potassium! * 1000).toString(),
              if (effectiveNutrition.calcium != null)
                'calcium': (effectiveNutrition.calcium! * 1000).toString(),
              if (effectiveNutrition.iron != null)
                'iron': (effectiveNutrition.iron! * 1000).toString(),
              if (effectiveNutrition.magnesium != null)
                'magnesium': (effectiveNutrition.magnesium! * 1000).toString(),
              if (effectiveNutrition.zinc != null)
                'zinc': (effectiveNutrition.zinc! * 1000).toString(),
              if (effectiveNutrition.copper != null)
                'copper': (effectiveNutrition.copper! * 1000).toString(),
              if (effectiveNutrition.manganese != null)
                'manganese': (effectiveNutrition.manganese! * 1000).toString(),
              if (effectiveNutrition.selenium != null)
                'selenium': (effectiveNutrition.selenium! * 1000000).toString(),
              if (effectiveNutrition.phosphorus != null)
                'phosphorus': (effectiveNutrition.phosphorus! * 1000)
                    .toString(),
              if (effectiveNutrition.iodine != null)
                'iodine': (effectiveNutrition.iodine! * 1000000).toString(),
              if (effectiveNutrition.chloride != null)
                'chloride': (effectiveNutrition.chloride! * 1000).toString(),
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
        double? parse(String key, {double scale = 1.0}) {
          final value = formData[key];
          if (value == null || value is! String || value.isEmpty) return null;
          final parsed = double.tryParse(value);
          if (parsed == null) return null;
          return parsed / scale;
        }

        final nutrition = Nutrition(
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
        );

        await productRepository.createProduct(
          name: formData['name'] as String,
          nutrition: nutrition,
          units: formData['units'] as List<Unit>,
          upc: formData['upc'] as String?,
          brand: formData['brand'] as String?,
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
