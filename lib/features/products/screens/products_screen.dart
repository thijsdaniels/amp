import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:amp/core/providers/selection_provider.dart';
import 'package:amp/core/widgets/delete_selection_dialog.dart';
import 'package:amp/core/widgets/selection_app_bar.dart';
import 'package:amp/features/products/providers/product_repository_provider.dart';
import 'package:amp/features/products/providers/products_stream_provider.dart';
import 'package:amp/features/products/widgets/product_list_item.dart';

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsyncValue = ref.watch(productsStreamProvider);

    return Scaffold(
      appBar: SelectionAppBar(
        title: const Text('Products'),
        selectionActions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              final selectionState = ref.read(selectionProvider);
              final selectedIds = selectionState.selectedIds.toList();
              productsAsyncValue.whenData((products) {
                final selectedProducts = products
                    .where((product) => selectedIds.contains(product.id))
                    .toList();
                showDialog(
                  context: context,
                  builder: (context) => DeleteSelectionDialog(
                    onDelete: (ids) async {
                      await ref.read(productRepositoryProvider).deleteProducts(ids);
                      ref.read(selectionProvider.notifier).clear();
                    },
                    items: selectedProducts,
                  ),
                );
              });
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/products/add');
        },
        child: const Icon(Icons.add),
      ),
      body: productsAsyncValue.when(
        data: (products) {
          if (products.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No products yet!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap the + button to add your first product',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductListItem(product: product);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error loading products',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
