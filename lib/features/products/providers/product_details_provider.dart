import 'package:amp/core/models/product.dart';
import 'package:amp/core/models/product_version.dart';
import 'package:amp/features/products/providers/product_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final productDetailsProvider =
    FutureProvider.family<(Product, ProductVersion), String>((
      ref,
      productId,
    ) async {
      final productRepo = ref.watch(productRepositoryProvider);

      // Fetch both in parallel for efficiency
      final productFuture = productRepo.getProduct(productId);
      final productVersionFuture = productRepo.getLatestProductVersion(
        productId,
      );

      final product = await productFuture;
      final productVersion = await productVersionFuture;

      return (product, productVersion);
    });
