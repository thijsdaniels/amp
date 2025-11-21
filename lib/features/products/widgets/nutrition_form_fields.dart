import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

/// Reusable form fields for nutrition information (per 100g).
class NutritionFormFields extends StatelessWidget {
  const NutritionFormFields({super.key});

  Widget _buildField(String name, String label, String suffix) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: FormBuilderTextField(
        name: name,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixText: suffix,
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return null;
          }
          return FormBuilderValidators.compose([
            FormBuilderValidators.numeric(),
            FormBuilderValidators.min(0),
          ])(value);
        },
      ),
    );
  }

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
        // Core Macros (Required)
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
        const SizedBox(height: 12),

        // Advanced Nutrition (Optional)
        ExpansionTile(
          maintainState: true,
          title: const Text('Advanced Nutrition'),
          children: [
            const SizedBox(height: 12),
            // Fats
            _buildField('saturatedFat', 'Saturated Fat', 'g'),
            _buildField('monounsaturatedFat', 'Monounsaturated Fat', 'g'),
            _buildField('polyunsaturatedFat', 'Polyunsaturated Fat', 'g'),
            _buildField('transFat', 'Trans Fat', 'g'),
            _buildField('cholesterol', 'Cholesterol', 'mg'),

            // Salts
            _buildField('sodium', 'Sodium', 'mg'),
            _buildField('salt', 'Salt', 'g'),

            // Carbs details
            _buildField('fiber', 'Dietary Fiber', 'g'),
            _buildField('sugar', 'Sugars', 'g'),
            _buildField('addedSugar', 'Added Sugars', 'g'),

            // Other
            _buildField('alcohol', 'Alcohol', '% vol'),
            _buildField('caffeine', 'Caffeine', 'mg'),

            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Vitamins',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            _buildField('vitaminA', 'Vitamin A', 'µg'),
            _buildField('vitaminB1', 'Vitamin B1 (Thiamin)', 'mg'),
            _buildField('vitaminB2', 'Vitamin B2 (Riboflavin)', 'mg'),
            _buildField('vitaminB3', 'Vitamin B3 (Niacin)', 'mg'),
            _buildField('vitaminB5', 'Vitamin B5 (Pantothenic Acid)', 'mg'),
            _buildField('vitaminB6', 'Vitamin B6 (Pyridoxin)', 'mg'),
            _buildField('vitaminB7', 'Vitamin B7 (Biotin)', 'µg'),
            _buildField('vitaminB9', 'Vitamin B9 (Folate)', 'µg'),
            _buildField('vitaminB12', 'Vitamin B12 (Cobalamin)', 'µg'),
            _buildField('vitaminC', 'Vitamin C', 'mg'),
            _buildField('vitaminD', 'Vitamin D', 'µg'),
            _buildField('vitaminE', 'Vitamin E', 'mg'),
            _buildField('vitaminK', 'Vitamin K', 'µg'),

            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Minerals',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            _buildField('potassium', 'Potassium', 'mg'),
            _buildField('calcium', 'Calcium', 'mg'),
            _buildField('iron', 'Iron', 'mg'),
            _buildField('magnesium', 'Magnesium', 'mg'),
            _buildField('zinc', 'Zinc', 'mg'),
            _buildField('copper', 'Copper', 'mg'),
            _buildField('manganese', 'Manganese', 'mg'),
            _buildField('selenium', 'Selenium', 'µg'),
            _buildField('phosphorus', 'Phosphorus', 'mg'),
            _buildField('iodine', 'Iodine', 'µg'),
            _buildField('chloride', 'Chloride', 'mg'),
          ],
        ),
      ],
    );
  }
}
