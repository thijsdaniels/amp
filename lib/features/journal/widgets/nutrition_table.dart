import 'package:amp/core/models/nutrition.dart';
import 'package:flutter/material.dart';

class NutritionTable extends StatelessWidget {
  final Nutrition nutrition;

  const NutritionTable({super.key, required this.nutrition});

  @override
  Widget build(BuildContext context) {
    // Helper to create vitamin rows with scaling
    final vitamins = <Widget>[];
    void addVitamin(
      String label,
      double? value,
      String unit, {
      double scale = 1.0,
    }) {
      if (value != null && value > 0) {
        vitamins.add(
          _NutritionRow(
            label: label,
            value: value * scale,
            unit: unit,
            indent: true,
          ),
        );
      }
    }

    addVitamin('Vitamin A', nutrition.vitaminA, 'µg', scale: 1000000);
    addVitamin('Vitamin B1 (Thiamin)', nutrition.vitaminB1, 'mg', scale: 1000);
    addVitamin(
      'Vitamin B2 (Riboflavin)',
      nutrition.vitaminB2,
      'mg',
      scale: 1000,
    );
    addVitamin('Vitamin B3 (Niacin)', nutrition.vitaminB3, 'mg', scale: 1000);
    addVitamin(
      'Vitamin B5 (Pantothenic Acid)',
      nutrition.vitaminB5,
      'mg',
      scale: 1000,
    );
    addVitamin('Vitamin B6', nutrition.vitaminB6, 'mg', scale: 1000);
    addVitamin(
      'Vitamin B7 (Biotin)',
      nutrition.vitaminB7,
      'µg',
      scale: 1000000,
    );
    addVitamin(
      'Vitamin B9 (Folate)',
      nutrition.vitaminB9,
      'µg',
      scale: 1000000,
    );
    addVitamin('Vitamin B12', nutrition.vitaminB12, 'µg', scale: 1000000);
    addVitamin('Vitamin C', nutrition.vitaminC, 'mg', scale: 1000);
    addVitamin('Vitamin D', nutrition.vitaminD, 'µg', scale: 1000000);
    addVitamin('Vitamin E', nutrition.vitaminE, 'mg', scale: 1000);
    addVitamin('Vitamin K', nutrition.vitaminK, 'µg', scale: 1000000);

    // Helper to create mineral rows with scaling
    final minerals = <Widget>[];
    void addMineral(
      String label,
      double? value,
      String unit, {
      double scale = 1.0,
    }) {
      if (value != null && value > 0) {
        minerals.add(
          _NutritionRow(
            label: label,
            value: value * scale,
            unit: unit,
            indent: true,
          ),
        );
      }
    }

    addMineral('Calcium', nutrition.calcium, 'mg', scale: 1000);
    addMineral('Iron', nutrition.iron, 'mg', scale: 1000);
    addMineral('Magnesium', nutrition.magnesium, 'mg', scale: 1000);
    addMineral('Phosphorus', nutrition.phosphorus, 'mg', scale: 1000);
    addMineral('Potassium', nutrition.potassium, 'mg', scale: 1000);
    addMineral('Sodium', nutrition.sodium, 'mg', scale: 1000);
    addMineral('Zinc', nutrition.zinc, 'mg', scale: 1000);
    addMineral('Copper', nutrition.copper, 'mg', scale: 1000);
    addMineral('Manganese', nutrition.manganese, 'mg', scale: 1000);
    addMineral('Selenium', nutrition.selenium, 'µg', scale: 1000000);
    addMineral('Iodine', nutrition.iodine, 'µg', scale: 1000000);
    addMineral('Chloride', nutrition.chloride, 'mg', scale: 1000);

    return Column(
      children: [
        _NutritionRow(
          label: 'Calories',
          value: nutrition.calories,
          unit: 'kcal',
          bold: true,
        ),
        const Divider(),
        _NutritionRow(
          label: 'Fat',
          value: nutrition.fat,
          unit: 'g',
          bold: true,
        ),
        _NutritionRow(
          label: 'Saturated Fat',
          value: nutrition.saturatedFat,
          unit: 'g',
          indent: true,
        ),
        _NutritionRow(
          label: 'Monounsaturated Fat',
          value: nutrition.monounsaturatedFat,
          unit: 'g',
          indent: true,
        ),
        _NutritionRow(
          label: 'Polyunsaturated Fat',
          value: nutrition.polyunsaturatedFat,
          unit: 'g',
          indent: true,
        ),
        _NutritionRow(
          label: 'Trans Fat',
          value: nutrition.transFat,
          unit: 'g',
          indent: true,
        ),
        _NutritionRow(
          label: 'Cholesterol',
          value: nutrition.cholesterol != null
              ? nutrition.cholesterol! * 1000
              : null,
          unit: 'mg',
          indent: true,
        ),
        const Divider(),
        _NutritionRow(
          label: 'Carbohydrates',
          value: nutrition.carbohydrates,
          unit: 'g',
          bold: true,
        ),
        _NutritionRow(
          label: 'Fiber',
          value: nutrition.fiber,
          unit: 'g',
          indent: true,
        ),
        _NutritionRow(
          label: 'Sugars',
          value: nutrition.sugar,
          unit: 'g',
          indent: true,
        ),
        _NutritionRow(
          label: 'Added Sugars',
          value: nutrition.addedSugar,
          unit: 'g',
          indent: true,
        ),
        const Divider(),
        _NutritionRow(
          label: 'Protein',
          value: nutrition.protein,
          unit: 'g',
          bold: true,
        ),
        if ((nutrition.alcohol != null && nutrition.alcohol! > 0) ||
            (nutrition.caffeine != null && nutrition.caffeine! > 0)) ...[
          const Divider(),
          _NutritionRow(label: 'Alcohol', value: nutrition.alcohol, unit: 'g'),
          _NutritionRow(
            label: 'Caffeine',
            value: nutrition.caffeine != null
                ? nutrition.caffeine! * 1000
                : null,
            unit: 'mg',
          ),
        ],
        if (vitamins.isNotEmpty) ...[
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              children: [
                Text('Vitamins', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          ...vitamins,
        ],
        if (minerals.isNotEmpty) ...[
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              children: [
                Text('Minerals', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          ...minerals,
        ],
      ],
    );
  }
}

class _NutritionRow extends StatelessWidget {
  final String label;
  final double? value;
  final String unit;
  final bool bold;
  final bool indent;

  const _NutritionRow({
    required this.label,
    required this.value,
    required this.unit,
    this.bold = false,
    this.indent = false,
  });

  bool get hasValue => value != null && value! > 0;

  @override
  Widget build(BuildContext context) {
    if (!hasValue) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.only(left: indent ? 16.0 : 0),
            child: Text(
              label,
              style: bold ? const TextStyle(fontWeight: FontWeight.bold) : null,
            ),
          ),
          Text(
            '${value!.toStringAsFixed(unit == 'mg' || unit == 'µg' ? 1 : 1)} $unit',
            style: bold ? const TextStyle(fontWeight: FontWeight.bold) : null,
          ),
        ],
      ),
    );
  }
}
