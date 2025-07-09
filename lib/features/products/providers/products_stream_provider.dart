import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amp/core/models/product.dart';
import 'package:amp/features/products/providers/product_repository_provider.dart';

final productsStreamProvider = StreamProvider.autoDispose<List<Product>>((ref) {
  final productRepository = ref.watch(productRepositoryProvider);
  return productRepository.getProductsStream();
});
