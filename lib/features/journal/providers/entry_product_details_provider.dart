import 'package:amp/core/models/entry.dart';
import 'package:amp/core/models/product.dart';
import 'package:amp/core/models/product_version.dart';
import 'package:amp/features/products/providers/product_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final entryProductDetailsProvider =
    FutureProvider.family<(Product, ProductVersion), ProductEntry>((
      ref,
      entry,
    ) async {
      final productRepo = ref.watch(productRepositoryProvider);
      final productRef = entry.productVersionRef.parent.parent;

      if (productRef == null) {
        throw Exception('Could not determine product reference from entry.');
      }

      // Fetch both in parallel for efficiency
      final productFuture = productRepo.getProduct(productRef.id);
      final productVersionFuture = entry.productVersionRef.get();

      final product = await productFuture;
      final productVersionDoc = await productVersionFuture;
      final productVersion = productVersionDoc.data()!;

      return (product, productVersion);
    });
