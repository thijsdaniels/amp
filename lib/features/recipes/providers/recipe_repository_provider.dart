import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amp/core/providers/firestore_provider.dart';
import 'package:amp/features/auth/providers/uid_provider.dart';
import 'package:amp/features/recipes/data/recipe_repository.dart';

final recipeRepositoryProvider = Provider.autoDispose<RecipeRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final uid = ref.watch(uidProvider);
  return RecipeRepository(firestore: firestore, uid: uid);
});
