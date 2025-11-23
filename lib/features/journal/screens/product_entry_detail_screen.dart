import 'package:amp/core/models/entry.dart';
import 'package:amp/core/models/product.dart';
import 'package:amp/core/models/product_version.dart';
import 'package:amp/features/journal/providers/entry_product_details_provider.dart';
import 'package:amp/features/journal/providers/entry_repository_provider.dart';
import 'package:amp/features/journal/providers/product_entry_provider.dart';
import 'package:amp/features/journal/providers/single_entry_provider.dart';
import 'package:amp/features/journal/widgets/nutrition_table.dart';
import 'package:amp/features/products/providers/product_repository_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductEntryDetailScreen extends ConsumerWidget {
  final String entryId;

  const ProductEntryDetailScreen({super.key, required this.entryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entryAsync = ref.watch(productEntryProvider(entryId));

    return entryAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $err')),
      ),
      data: (productEntry) {
        final detailsAsync = ref.watch(
          entryProductDetailsProvider(productEntry),
        );

        return Scaffold(
          appBar: AppBar(title: Text(productEntry.name)),
          body: detailsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
            data: (details) {
              final (product, productVersion) = details;
              final isOutdated = product.latestVersion > productVersion.version;

              final nutrition = productVersion.nutrition;

              // Resolve best display unit
              final resolved = productVersion.resolveBestUnit(
                productEntry.quantity,
              );

              // Calculate consumed nutrition (quantity is in grams)
              final consumedNutrition =
                  (nutrition / 100) * productEntry.quantity;

              return Column(
                children: [
                  if (isOutdated)
                    MaterialBanner(
                      content: const Text(
                        'This entry uses an older version of the product. Update to the latest version?',
                      ),
                      leading: const Icon(Icons.info_outline),
                      actions: [
                        TextButton(
                          onPressed: () {
                            _onUpdatePressed(
                              context,
                              ref,
                              entryId,
                              product,
                              productEntry,
                            );
                          },
                          child: const Text('Update'),
                        ),
                      ],
                    ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (product.brand != null) ...[
                            Text(
                              product.brand!,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                  ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          Text(
                            'Quantity: ${resolved.quantity.toStringAsFixed(2)} ${resolved.unit}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Consumed Nutrition',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          NutritionTable(nutrition: consumedNutrition),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _onUpdatePressed(
    BuildContext context,
    WidgetRef ref,
    String entryId,
    Product product,
    ProductEntry productEntry,
  ) async {
    final productRepo = ref.read(productRepositoryProvider);
    final entryRepo = ref.read(entryRepositoryProvider);

    final latestVersion = await productRepo.getLatestProductVersion(
      product.id!,
    );

    // Since we store grams, we can just update the version reference.
    // The gram amount remains valid.
    await entryRepo.updateProductEntryToNewVersion(
      productEntry.id!,
      product.name,
      productRepo.getProductVersionRef(product.id!, latestVersion.id!),
    );

    ref.invalidate(entryProductDetailsProvider(productEntry));
    ref.invalidate(singleEntryProvider(entryId));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entry updated to latest version')),
      );
    }
  }
}
