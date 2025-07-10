import 'package:amp/core/models/nutrition.dart';
import 'package:flutter/material.dart';

class NutritionTable extends StatelessWidget {
  final Nutrition nutrition;
  final String title;

  const NutritionTable({
    super.key,
    required this.nutrition,
    this.title = 'Nutrition Facts',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        DataTable(
          columns: const [
            DataColumn(label: Text('Nutrient')),
            DataColumn(label: Text('Amount'), numeric: true),
          ],
          rows: [
            DataRow(
              cells: [
                const DataCell(Text('Calories')),
                DataCell(Text('${nutrition.calories.toStringAsFixed(0)} kcal')),
              ],
            ),
            DataRow(
              cells: [
                const DataCell(Text('Protein')),
                DataCell(Text('${nutrition.protein.toStringAsFixed(1)} g')),
              ],
            ),
            DataRow(
              cells: [
                const DataCell(Text('Carbohydrates')),
                DataCell(
                  Text('${nutrition.carbohydrates.toStringAsFixed(1)} g'),
                ),
              ],
            ),
            DataRow(
              cells: [
                const DataCell(Text('Fat')),
                DataCell(Text('${nutrition.fat.toStringAsFixed(1)} g')),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
