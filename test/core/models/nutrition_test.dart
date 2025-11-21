import 'package:amp/core/models/nutrition.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Nutrition', () {
    test('supports value equality', () {
      const nutrition1 = Nutrition(
        calories: 100,
        protein: 10,
        carbohydrates: 20,
        fat: 5,
        vitaminC: 10,
      );
      const nutrition2 = Nutrition(
        calories: 100,
        protein: 10,
        carbohydrates: 20,
        fat: 5,
        vitaminC: 10,
      );
      expect(nutrition1, equals(nutrition2));
    });

    test('toMap and fromMap work correctly with all fields', () {
      const nutrition = Nutrition(
        calories: 100,
        protein: 10,
        carbohydrates: 20,
        fat: 5,
        saturatedFat: 1.5,
        monounsaturatedFat: 2.5,
        polyunsaturatedFat: 0.5,
        transFat: 0.1,
        cholesterol: 50,
        sodium: 100,
        salt: 0.25,
        fiber: 3,
        sugar: 5,
        addedSugar: 2,
        alcohol: 0,
        caffeine: 10,
        vitaminA: 100,
        vitaminB1: 1.1,
        vitaminB2: 1.2,
        vitaminB3: 14,
        vitaminB5: 5,
        vitaminB6: 1.3,
        vitaminB7: 30,
        vitaminB9: 400,
        vitaminB12: 2.4,
        vitaminC: 60,
        vitaminD: 10,
        vitaminE: 12,
        vitaminK: 75,
        potassium: 2000,
        calcium: 800,
        iron: 14,
        magnesium: 300,
        zinc: 10,
        copper: 1,
        manganese: 2,
        selenium: 55,
        phosphorus: 700,
        iodine: 150,
        chloride: 200,
      );

      final map = nutrition.toMap();
      final fromMap = Nutrition.fromMap(map);

      expect(fromMap, equals(nutrition));
      expect(fromMap.vitaminC, 60);
      expect(fromMap.calcium, 800);
    });

    test('arithmetic operations work correctly', () {
      const n1 = Nutrition(
        calories: 100,
        protein: 10,
        carbohydrates: 20,
        fat: 5,
        vitaminC: 10,
      );
      const n2 = Nutrition(
        calories: 50,
        protein: 5,
        carbohydrates: 10,
        fat: 2.5,
        vitaminC: 5,
      );

      final sum = n1 + n2;
      expect(sum.calories, 150);
      expect(sum.vitaminC, 15);

      final diff = n1 - n2;
      expect(diff.calories, 50);
      expect(diff.vitaminC, 5);

      final scaled = n1 * 2;
      expect(scaled.calories, 200);
      expect(scaled.vitaminC, 20);

      final divided = n1 / 2;
      expect(divided.calories, 50);
      expect(divided.vitaminC, 5);
    });

    test('handles nulls in arithmetic operations', () {
      const n1 = Nutrition(
        calories: 100,
        protein: 10,
        carbohydrates: 20,
        fat: 5,
        vitaminC: 10,
      );
      const n2 = Nutrition(
        calories: 50,
        protein: 5,
        carbohydrates: 10,
        fat: 2.5,
        // vitaminC is null here
      );

      final sum = n1 + n2;
      expect(sum.vitaminC, 10); // 10 + null (0) = 10

      final diff = n1 - n2;
      expect(diff.vitaminC, 10); // 10 - null (0) = 10
    });
  });
}
