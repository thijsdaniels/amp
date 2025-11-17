import 'package:amp/features/products/providers/product_details_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProductDetailScreen extends ConsumerWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productDetailsAsync = ref.watch(productDetailsProvider(productId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          productDetailsAsync.when(
            data: (_) => IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                context.push('/products/$productId/edit');
              },
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: productDetailsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (details) {
          final product = details.$1;
          final productVersion = details.$2;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Version: ${productVersion.version}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 24),
                Text(
                  'Nutrition (per 100g)',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    title: const Text('Calories'),
                    trailing: Text('${productVersion.nutrition.calories} kcal'),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: const Text('Protein'),
                    trailing: Text('${productVersion.nutrition.protein} g'),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: const Text('Carbohydrates'),
                    trailing: Text(
                      '${productVersion.nutrition.carbohydrates} g',
                    ),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: const Text('Fat'),
                    trailing: Text('${productVersion.nutrition.fat} g'),
                  ),
                ),
                const SizedBox(height: 24),
                if (productVersion.units.isNotEmpty) ...[
                  Text('Units', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  ...productVersion.units.map(
                    (unit) => Card(
                      child: ListTile(
                        title: Text(unit.name),
                        trailing: Text('${unit.grams} g'),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
