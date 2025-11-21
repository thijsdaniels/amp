import 'package:amp/core/models/model.dart';

class Nutrition extends Model {
  // Core Macros (Required)
  final double calories;
  final double protein;
  final double carbohydrates;
  final double fat;

  // Detailed Macros & Others (Optional)
  final double? saturatedFat;
  final double? monounsaturatedFat;
  final double? polyunsaturatedFat;
  final double? transFat;
  final double? cholesterol;
  final double? sodium;
  final double? salt;
  final double? fiber;
  final double? sugar;
  final double? addedSugar;
  final double? alcohol;
  final double? caffeine;

  // Vitamins (Optional)
  final double? vitaminA;
  final double? vitaminB1; // Thiamin
  final double? vitaminB2; // Riboflavin
  final double? vitaminB3; // Niacin
  final double? vitaminB5; // Pantothenic Acid
  final double? vitaminB6; // Pyridoxin
  final double? vitaminB7; // Biotin
  final double? vitaminB9; // Folate
  final double? vitaminB12; // Cobalamin
  final double? vitaminC; // Ascorbic Acid
  final double? vitaminD;
  final double? vitaminE;
  final double? vitaminK;

  // Minerals (Optional)
  final double? potassium;
  final double? calcium;
  final double? iron;
  final double? magnesium;
  final double? zinc;
  final double? copper;
  final double? manganese;
  final double? selenium;
  final double? phosphorus;
  final double? iodine;
  final double? chloride;

  const Nutrition({
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fat,
    this.saturatedFat,
    this.monounsaturatedFat,
    this.polyunsaturatedFat,
    this.transFat,
    this.cholesterol,
    this.sodium,
    this.salt,
    this.fiber,
    this.sugar,
    this.addedSugar,
    this.alcohol,
    this.caffeine,
    this.vitaminA,
    this.vitaminB1,
    this.vitaminB2,
    this.vitaminB3,
    this.vitaminB5,
    this.vitaminB6,
    this.vitaminB7,
    this.vitaminB9,
    this.vitaminB12,
    this.vitaminC,
    this.vitaminD,
    this.vitaminE,
    this.vitaminK,
    this.potassium,
    this.calcium,
    this.iron,
    this.magnesium,
    this.zinc,
    this.copper,
    this.manganese,
    this.selenium,
    this.phosphorus,
    this.iodine,
    this.chloride,
  });

  static double? _add(double? a, double? b) {
    if (a == null && b == null) return null;
    return (a ?? 0) + (b ?? 0);
  }

  static double? _subtract(double? a, double? b) {
    if (a == null && b == null) return null;
    return (a ?? 0) - (b ?? 0);
  }

  static double? _multiply(double? a, num factor) {
    if (a == null) return null;
    return a * factor;
  }

  static double? _divide(double? a, num factor) {
    if (a == null) return null;
    return a / factor;
  }

  Nutrition operator +(Nutrition other) {
    return Nutrition(
      calories: calories + other.calories,
      protein: protein + other.protein,
      carbohydrates: carbohydrates + other.carbohydrates,
      fat: fat + other.fat,
      saturatedFat: _add(saturatedFat, other.saturatedFat),
      monounsaturatedFat: _add(monounsaturatedFat, other.monounsaturatedFat),
      polyunsaturatedFat: _add(polyunsaturatedFat, other.polyunsaturatedFat),
      transFat: _add(transFat, other.transFat),
      cholesterol: _add(cholesterol, other.cholesterol),
      sodium: _add(sodium, other.sodium),
      salt: _add(salt, other.salt),
      fiber: _add(fiber, other.fiber),
      sugar: _add(sugar, other.sugar),
      addedSugar: _add(addedSugar, other.addedSugar),
      alcohol: _add(alcohol, other.alcohol),
      caffeine: _add(caffeine, other.caffeine),
      vitaminA: _add(vitaminA, other.vitaminA),
      vitaminB1: _add(vitaminB1, other.vitaminB1),
      vitaminB2: _add(vitaminB2, other.vitaminB2),
      vitaminB3: _add(vitaminB3, other.vitaminB3),
      vitaminB5: _add(vitaminB5, other.vitaminB5),
      vitaminB6: _add(vitaminB6, other.vitaminB6),
      vitaminB7: _add(vitaminB7, other.vitaminB7),
      vitaminB9: _add(vitaminB9, other.vitaminB9),
      vitaminB12: _add(vitaminB12, other.vitaminB12),
      vitaminC: _add(vitaminC, other.vitaminC),
      vitaminD: _add(vitaminD, other.vitaminD),
      vitaminE: _add(vitaminE, other.vitaminE),
      vitaminK: _add(vitaminK, other.vitaminK),
      potassium: _add(potassium, other.potassium),
      calcium: _add(calcium, other.calcium),
      iron: _add(iron, other.iron),
      magnesium: _add(magnesium, other.magnesium),
      zinc: _add(zinc, other.zinc),
      copper: _add(copper, other.copper),
      manganese: _add(manganese, other.manganese),
      selenium: _add(selenium, other.selenium),
      phosphorus: _add(phosphorus, other.phosphorus),
      iodine: _add(iodine, other.iodine),
      chloride: _add(chloride, other.chloride),
    );
  }

  Nutrition operator -(Nutrition other) {
    return Nutrition(
      calories: calories - other.calories,
      protein: protein - other.protein,
      carbohydrates: carbohydrates - other.carbohydrates,
      fat: fat - other.fat,
      saturatedFat: _subtract(saturatedFat, other.saturatedFat),
      monounsaturatedFat: _subtract(
        monounsaturatedFat,
        other.monounsaturatedFat,
      ),
      polyunsaturatedFat: _subtract(
        polyunsaturatedFat,
        other.polyunsaturatedFat,
      ),
      transFat: _subtract(transFat, other.transFat),
      cholesterol: _subtract(cholesterol, other.cholesterol),
      sodium: _subtract(sodium, other.sodium),
      salt: _subtract(salt, other.salt),
      fiber: _subtract(fiber, other.fiber),
      sugar: _subtract(sugar, other.sugar),
      addedSugar: _subtract(addedSugar, other.addedSugar),
      alcohol: _subtract(alcohol, other.alcohol),
      caffeine: _subtract(caffeine, other.caffeine),
      vitaminA: _subtract(vitaminA, other.vitaminA),
      vitaminB1: _subtract(vitaminB1, other.vitaminB1),
      vitaminB2: _subtract(vitaminB2, other.vitaminB2),
      vitaminB3: _subtract(vitaminB3, other.vitaminB3),
      vitaminB5: _subtract(vitaminB5, other.vitaminB5),
      vitaminB6: _subtract(vitaminB6, other.vitaminB6),
      vitaminB7: _subtract(vitaminB7, other.vitaminB7),
      vitaminB9: _subtract(vitaminB9, other.vitaminB9),
      vitaminB12: _subtract(vitaminB12, other.vitaminB12),
      vitaminC: _subtract(vitaminC, other.vitaminC),
      vitaminD: _subtract(vitaminD, other.vitaminD),
      vitaminE: _subtract(vitaminE, other.vitaminE),
      vitaminK: _subtract(vitaminK, other.vitaminK),
      potassium: _subtract(potassium, other.potassium),
      calcium: _subtract(calcium, other.calcium),
      iron: _subtract(iron, other.iron),
      magnesium: _subtract(magnesium, other.magnesium),
      zinc: _subtract(zinc, other.zinc),
      copper: _subtract(copper, other.copper),
      manganese: _subtract(manganese, other.manganese),
      selenium: _subtract(selenium, other.selenium),
      phosphorus: _subtract(phosphorus, other.phosphorus),
      iodine: _subtract(iodine, other.iodine),
      chloride: _subtract(chloride, other.chloride),
    );
  }

  Nutrition operator *(num factor) {
    return Nutrition(
      calories: calories * factor,
      protein: protein * factor,
      carbohydrates: carbohydrates * factor,
      fat: fat * factor,
      saturatedFat: _multiply(saturatedFat, factor),
      monounsaturatedFat: _multiply(monounsaturatedFat, factor),
      polyunsaturatedFat: _multiply(polyunsaturatedFat, factor),
      transFat: _multiply(transFat, factor),
      cholesterol: _multiply(cholesterol, factor),
      sodium: _multiply(sodium, factor),
      salt: _multiply(salt, factor),
      fiber: _multiply(fiber, factor),
      sugar: _multiply(sugar, factor),
      addedSugar: _multiply(addedSugar, factor),
      alcohol: _multiply(alcohol, factor),
      caffeine: _multiply(caffeine, factor),
      vitaminA: _multiply(vitaminA, factor),
      vitaminB1: _multiply(vitaminB1, factor),
      vitaminB2: _multiply(vitaminB2, factor),
      vitaminB3: _multiply(vitaminB3, factor),
      vitaminB5: _multiply(vitaminB5, factor),
      vitaminB6: _multiply(vitaminB6, factor),
      vitaminB7: _multiply(vitaminB7, factor),
      vitaminB9: _multiply(vitaminB9, factor),
      vitaminB12: _multiply(vitaminB12, factor),
      vitaminC: _multiply(vitaminC, factor),
      vitaminD: _multiply(vitaminD, factor),
      vitaminE: _multiply(vitaminE, factor),
      vitaminK: _multiply(vitaminK, factor),
      potassium: _multiply(potassium, factor),
      calcium: _multiply(calcium, factor),
      iron: _multiply(iron, factor),
      magnesium: _multiply(magnesium, factor),
      zinc: _multiply(zinc, factor),
      copper: _multiply(copper, factor),
      manganese: _multiply(manganese, factor),
      selenium: _multiply(selenium, factor),
      phosphorus: _multiply(phosphorus, factor),
      iodine: _multiply(iodine, factor),
      chloride: _multiply(chloride, factor),
    );
  }

  Nutrition operator /(num factor) {
    return Nutrition(
      calories: calories / factor,
      protein: protein / factor,
      carbohydrates: carbohydrates / factor,
      fat: fat / factor,
      saturatedFat: _divide(saturatedFat, factor),
      monounsaturatedFat: _divide(monounsaturatedFat, factor),
      polyunsaturatedFat: _divide(polyunsaturatedFat, factor),
      transFat: _divide(transFat, factor),
      cholesterol: _divide(cholesterol, factor),
      sodium: _divide(sodium, factor),
      salt: _divide(salt, factor),
      fiber: _divide(fiber, factor),
      sugar: _divide(sugar, factor),
      addedSugar: _divide(addedSugar, factor),
      alcohol: _divide(alcohol, factor),
      caffeine: _divide(caffeine, factor),
      vitaminA: _divide(vitaminA, factor),
      vitaminB1: _divide(vitaminB1, factor),
      vitaminB2: _divide(vitaminB2, factor),
      vitaminB3: _divide(vitaminB3, factor),
      vitaminB5: _divide(vitaminB5, factor),
      vitaminB6: _divide(vitaminB6, factor),
      vitaminB7: _divide(vitaminB7, factor),
      vitaminB9: _divide(vitaminB9, factor),
      vitaminB12: _divide(vitaminB12, factor),
      vitaminC: _divide(vitaminC, factor),
      vitaminD: _divide(vitaminD, factor),
      vitaminE: _divide(vitaminE, factor),
      vitaminK: _divide(vitaminK, factor),
      potassium: _divide(potassium, factor),
      calcium: _divide(calcium, factor),
      iron: _divide(iron, factor),
      magnesium: _divide(magnesium, factor),
      zinc: _divide(zinc, factor),
      copper: _divide(copper, factor),
      manganese: _divide(manganese, factor),
      selenium: _divide(selenium, factor),
      phosphorus: _divide(phosphorus, factor),
      iodine: _divide(iodine, factor),
      chloride: _divide(chloride, factor),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'calories': calories,
      'protein': protein,
      'carbohydrates': carbohydrates,
      'fat': fat,
      if (saturatedFat != null) 'saturatedFat': saturatedFat,
      if (monounsaturatedFat != null) 'monounsaturatedFat': monounsaturatedFat,
      if (polyunsaturatedFat != null) 'polyunsaturatedFat': polyunsaturatedFat,
      if (transFat != null) 'transFat': transFat,
      if (cholesterol != null) 'cholesterol': cholesterol,
      if (sodium != null) 'sodium': sodium,
      if (salt != null) 'salt': salt,
      if (fiber != null) 'fiber': fiber,
      if (sugar != null) 'sugar': sugar,
      if (addedSugar != null) 'addedSugar': addedSugar,
      if (alcohol != null) 'alcohol': alcohol,
      if (caffeine != null) 'caffeine': caffeine,
      if (vitaminA != null) 'vitaminA': vitaminA,
      if (vitaminB1 != null) 'vitaminB1': vitaminB1,
      if (vitaminB2 != null) 'vitaminB2': vitaminB2,
      if (vitaminB3 != null) 'vitaminB3': vitaminB3,
      if (vitaminB5 != null) 'vitaminB5': vitaminB5,
      if (vitaminB6 != null) 'vitaminB6': vitaminB6,
      if (vitaminB7 != null) 'vitaminB7': vitaminB7,
      if (vitaminB9 != null) 'vitaminB9': vitaminB9,
      if (vitaminB12 != null) 'vitaminB12': vitaminB12,
      if (vitaminC != null) 'vitaminC': vitaminC,
      if (vitaminD != null) 'vitaminD': vitaminD,
      if (vitaminE != null) 'vitaminE': vitaminE,
      if (vitaminK != null) 'vitaminK': vitaminK,
      if (potassium != null) 'potassium': potassium,
      if (calcium != null) 'calcium': calcium,
      if (iron != null) 'iron': iron,
      if (magnesium != null) 'magnesium': magnesium,
      if (zinc != null) 'zinc': zinc,
      if (copper != null) 'copper': copper,
      if (manganese != null) 'manganese': manganese,
      if (selenium != null) 'selenium': selenium,
      if (phosphorus != null) 'phosphorus': phosphorus,
      if (iodine != null) 'iodine': iodine,
      if (chloride != null) 'chloride': chloride,
    };
  }

  factory Nutrition.fromMap(Map<String, dynamic> map) {
    if (map case {
      'calories': num calories,
      'protein': num protein,
      'carbohydrates': num carbohydrates,
      'fat': num fat,
    }) {
      return Nutrition(
        calories: calories.toDouble(),
        protein: protein.toDouble(),
        carbohydrates: carbohydrates.toDouble(),
        fat: fat.toDouble(),
        saturatedFat: (map['saturatedFat'] as num?)?.toDouble(),
        monounsaturatedFat: (map['monounsaturatedFat'] as num?)?.toDouble(),
        polyunsaturatedFat: (map['polyunsaturatedFat'] as num?)?.toDouble(),
        transFat: (map['transFat'] as num?)?.toDouble(),
        cholesterol: (map['cholesterol'] as num?)?.toDouble(),
        sodium: (map['sodium'] as num?)?.toDouble(),
        salt: (map['salt'] as num?)?.toDouble(),
        fiber: (map['fiber'] as num?)?.toDouble(),
        sugar: (map['sugar'] as num?)?.toDouble(),
        addedSugar: (map['addedSugar'] as num?)?.toDouble(),
        alcohol: (map['alcohol'] as num?)?.toDouble(),
        caffeine: (map['caffeine'] as num?)?.toDouble(),
        vitaminA: (map['vitaminA'] as num?)?.toDouble(),
        vitaminB1: (map['vitaminB1'] as num?)?.toDouble(),
        vitaminB2: (map['vitaminB2'] as num?)?.toDouble(),
        vitaminB3: (map['vitaminB3'] as num?)?.toDouble(),
        vitaminB5: (map['vitaminB5'] as num?)?.toDouble(),
        vitaminB6: (map['vitaminB6'] as num?)?.toDouble(),
        vitaminB7: (map['vitaminB7'] as num?)?.toDouble(),
        vitaminB9: (map['vitaminB9'] as num?)?.toDouble(),
        vitaminB12: (map['vitaminB12'] as num?)?.toDouble(),
        vitaminC: (map['vitaminC'] as num?)?.toDouble(),
        vitaminD: (map['vitaminD'] as num?)?.toDouble(),
        vitaminE: (map['vitaminE'] as num?)?.toDouble(),
        vitaminK: (map['vitaminK'] as num?)?.toDouble(),
        potassium: (map['potassium'] as num?)?.toDouble(),
        calcium: (map['calcium'] as num?)?.toDouble(),
        iron: (map['iron'] as num?)?.toDouble(),
        magnesium: (map['magnesium'] as num?)?.toDouble(),
        zinc: (map['zinc'] as num?)?.toDouble(),
        copper: (map['copper'] as num?)?.toDouble(),
        manganese: (map['manganese'] as num?)?.toDouble(),
        selenium: (map['selenium'] as num?)?.toDouble(),
        phosphorus: (map['phosphorus'] as num?)?.toDouble(),
        iodine: (map['iodine'] as num?)?.toDouble(),
        chloride: (map['chloride'] as num?)?.toDouble(),
      );
    } else {
      throw const FormatException('Invalid JSON format for Nutrition');
    }
  }
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Nutrition &&
        other.calories == calories &&
        other.protein == protein &&
        other.carbohydrates == carbohydrates &&
        other.fat == fat &&
        other.saturatedFat == saturatedFat &&
        other.monounsaturatedFat == monounsaturatedFat &&
        other.polyunsaturatedFat == polyunsaturatedFat &&
        other.transFat == transFat &&
        other.cholesterol == cholesterol &&
        other.sodium == sodium &&
        other.salt == salt &&
        other.fiber == fiber &&
        other.sugar == sugar &&
        other.addedSugar == addedSugar &&
        other.alcohol == alcohol &&
        other.caffeine == caffeine &&
        other.vitaminA == vitaminA &&
        other.vitaminB1 == vitaminB1 &&
        other.vitaminB2 == vitaminB2 &&
        other.vitaminB3 == vitaminB3 &&
        other.vitaminB5 == vitaminB5 &&
        other.vitaminB6 == vitaminB6 &&
        other.vitaminB7 == vitaminB7 &&
        other.vitaminB9 == vitaminB9 &&
        other.vitaminB12 == vitaminB12 &&
        other.vitaminC == vitaminC &&
        other.vitaminD == vitaminD &&
        other.vitaminE == vitaminE &&
        other.vitaminK == vitaminK &&
        other.potassium == potassium &&
        other.calcium == calcium &&
        other.iron == iron &&
        other.magnesium == magnesium &&
        other.zinc == zinc &&
        other.copper == copper &&
        other.manganese == manganese &&
        other.selenium == selenium &&
        other.phosphorus == phosphorus &&
        other.iodine == iodine &&
        other.chloride == chloride;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      calories,
      protein,
      carbohydrates,
      fat,
      saturatedFat,
      monounsaturatedFat,
      polyunsaturatedFat,
      transFat,
      cholesterol,
      sodium,
      salt,
      fiber,
      sugar,
      addedSugar,
      alcohol,
      caffeine,
      vitaminA,
      vitaminB1,
      vitaminB2,
      vitaminB3,
      vitaminB5,
      vitaminB6,
      vitaminB7,
      vitaminB9,
      vitaminB12,
      vitaminC,
      vitaminD,
      vitaminE,
      vitaminK,
      potassium,
      calcium,
      iron,
      magnesium,
      zinc,
      copper,
      manganese,
      selenium,
      phosphorus,
      iodine,
      chloride,
    ]);
  }
}
