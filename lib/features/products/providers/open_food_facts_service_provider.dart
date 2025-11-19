import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amp/core/services/open_food_facts_service.dart';

/// Provider for Open Food Facts service.
final openFoodFactsServiceProvider = Provider<OpenFoodFactsService>((ref) {
  return OpenFoodFactsService();
});

