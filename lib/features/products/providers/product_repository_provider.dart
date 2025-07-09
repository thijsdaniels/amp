import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amp/core/providers/firestore_provider.dart';
import 'package:amp/features/auth/providers/uid_provider.dart';
import 'package:amp/features/products/data/product_repository.dart';

final productRepositoryProvider = Provider.autoDispose<ProductRepository>((
  ref,
) {
  final firestore = ref.watch(firestoreProvider);
  final uid = ref.watch(uidProvider);
  return ProductRepository(firestore: firestore, uid: uid);
});
