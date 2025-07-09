import 'package:amp/core/models/unit.dart';

sealed class Units {
  Units._();

  static const Unit gram = Unit(name: 'Grams', grams: 1);
  static const Unit ounce = Unit(name: 'Ounces', grams: 28.3495);
  static const Unit pound = Unit(name: 'Pounds', grams: 453.592);
  static const Unit cup = Unit(name: 'Cups', grams: 236.588);
  static const Unit tablespoon = Unit(name: 'Tablespoons', grams: 14.7868);
  static const Unit teaspoon = Unit(name: 'Teaspoons', grams: 4.92892);
}
