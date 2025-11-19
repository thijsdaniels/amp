import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:amp/core/providers/selection_provider.dart';
import 'package:amp/core/widgets/delete_selection_dialog.dart';
import 'package:amp/core/widgets/selection_app_bar.dart';
import 'package:amp/core/screens/barcode_scanner_screen.dart';
import 'package:amp/features/products/providers/product_repository_provider.dart';
import 'package:amp/features/products/providers/products_stream_provider.dart';
import 'package:amp/features/products/providers/open_food_facts_service_provider.dart';
import 'package:amp/features/products/providers/prefilled_product_data_provider.dart';
import 'package:amp/features/products/screens/open_food_facts_search_screen.dart';
import 'package:amp/features/products/widgets/product_list_item.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  @override
  Widget build(BuildContext context) {
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
          showModalBottomSheet(
            context: context,
            builder: (context) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.add),
                    title: const Text('Add Product'),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.go('/products/add');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.qr_code_scanner),
                    title: const Text('Import by Barcode'),
                    onTap: () {
                      Navigator.of(context).pop();
                      _handleImportByBarcode(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.search),
                    title: const Text('Import by Search'),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const OpenFoodFactsSearchScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
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

  void _handleImportByBarcode(BuildContext context) async {
    final barcode = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => const BarcodeScannerScreen(),
      ),
    );

    if (barcode == null || !context.mounted) return;

    try {
      final service = ref.read(openFoodFactsServiceProvider);
      final productData = await service.getProductByBarcode(barcode);

      if (!context.mounted) return;

      if (productData != null) {
        // Store prefilled data in provider
        ref.read(prefilledProductDataProvider.notifier).state =
            PrefilledProductData(
          name: productData.name,
          upc: productData.barcode,
          nutrition: productData.nutrition,
          units: productData.units,
        );
        // Navigate using go_router
        context.push('/products/add');
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product not found in Open Food Facts for barcode: $barcode'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error searching Open Food Facts: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}
