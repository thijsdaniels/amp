import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

/// Reusable form fields for nutrition information (per 100g).
class NutritionFormFields extends StatelessWidget {
  const NutritionFormFields({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Nutrition Information (per 100g)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        // Calories
        FormBuilderTextField(
          name: 'calories',
          decoration: const InputDecoration(
            labelText: 'Calories',
            border: OutlineInputBorder(),
            suffixText: 'kcal',
          ),
          keyboardType: TextInputType.number,
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(),
            FormBuilderValidators.numeric(),
            FormBuilderValidators.min(0),
          ]),
        ),
        const SizedBox(height: 12),
        // Protein
        FormBuilderTextField(
          name: 'protein',
          decoration: const InputDecoration(
            labelText: 'Protein',
            border: OutlineInputBorder(),
            suffixText: 'g',
          ),
          keyboardType: TextInputType.number,
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(),
            FormBuilderValidators.numeric(),
            FormBuilderValidators.min(0),
          ]),
        ),
        const SizedBox(height: 12),
        // Carbs
        FormBuilderTextField(
          name: 'carbs',
          decoration: const InputDecoration(
            labelText: 'Carbohydrates',
            border: OutlineInputBorder(),
            suffixText: 'g',
          ),
          keyboardType: TextInputType.number,
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(),
            FormBuilderValidators.numeric(),
            FormBuilderValidators.min(0),
          ]),
        ),
        const SizedBox(height: 12),
        // Fat
        FormBuilderTextField(
          name: 'fat',
          decoration: const InputDecoration(
            labelText: 'Fat',
            border: OutlineInputBorder(),
            suffixText: 'g',
          ),
          keyboardType: TextInputType.number,
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(),
            FormBuilderValidators.numeric(),
            FormBuilderValidators.min(0),
          ]),
        ),
      ],
    );
  }
}

