import 'package:flutter_test/flutter_test.dart';

// Copy of the logic to test it in isolation
double? parseQuantity(String quantity) {
  // Remove whitespace and convert to lowercase
  final cleaned = quantity.trim().toLowerCase();

  // Try to extract number
  final numberMatch = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(cleaned);
  if (numberMatch == null) {
    return null;
  }

  final number = double.tryParse(numberMatch.group(1)!);
  if (number == null) {
    return null;
  }

  // Convert to grams based on unit
  // BUGGY LOGIC FROM SERVICE
  if (cleaned.contains('ml')) {
    // Assume 1ml ≈ 1g for liquids (approximation)
    return number;
  } else if (cleaned.contains('g')) {
    return number;
  } else if (cleaned.contains('kg')) {
    return number * 1000;
  } else if (cleaned.contains('l')) {
    // Assume 1L ≈ 1000g for liquids (approximation)
    return number * 1000;
  }

  // Default: assume grams if no unit specified
  return number;
}

void main() {
  test('parseQuantity parses kg correctly', () {
    expect(parseQuantity('1.53 kg'), 1530.0);
  });

  test('parseQuantity parses g correctly', () {
    expect(parseQuantity('100 g'), 100.0);
  });
}
