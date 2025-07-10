import 'package:amp/core/models/entry.dart';
import 'package:amp/features/journal/providers/single_entry_provider.dart';
import 'package:amp/features/journal/widgets/nutrition_table.dart';
import 'package:amp/features/products/providers/product_version_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductEntryDetailScreen extends ConsumerWidget {
  final String entryId;
  final ProductEntry? entry;

  const ProductEntryDetailScreen({
    super.key,
    required this.entryId,
    this.entry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productEntry = entry;

    if (productEntry != null) {
      return _buildView(context, ref, productEntry);
    }

    final entryAsync =
        ref.watch(singleEntryProvider(entryId)) as AsyncValue<ProductEntry>;

    return entryAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $err')),
      ),
      data: (entryData) => _buildView(context, ref, entryData),
    );
  }

  Widget _buildView(
    BuildContext context,
    WidgetRef ref,
    ProductEntry productEntry,
  ) {
    final productVersionAsync = ref.watch(
      productVersionProvider(productEntry.productVersionRef),
    );

    return Scaffold(
      appBar: AppBar(title: Text(productEntry.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quantity: ${productEntry.quantity} ${productEntry.unit}'),
            productVersionAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (productVersion) {
                final nutrition = productVersion.nutrition;

                final consumedNutrition =
                    (nutrition / 100) * productEntry.quantity;

                return NutritionTable(
                  title: 'Consumed Nutrition',
                  nutrition: consumedNutrition,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
