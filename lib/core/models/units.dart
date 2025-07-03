import 'package:amp/core/models/unit.dart';

sealed class Units {
  Units._();

  static const Unit gram = Unit(name: 'Grams', symbol: 'g', grams: 1);

  static const Unit ounce = Unit(name: 'Ounces', symbol: 'oz', grams: 28.3495);

  static const Unit pound = Unit(name: 'Pounds', symbol: 'lb', grams: 453.592);

  static const Unit cup = Unit(name: 'Cups', symbol: 'cup', grams: 236.588);

  static const Unit tablespoon = Unit(
    name: 'Tablespoons',
    symbol: 'tbsp',
    grams: 14.7868,
  );

  static const Unit teaspoon = Unit(
    name: 'Teaspoons',
    symbol: 'tsp',
    grams: 4.92892,
  );
}
