import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amp/core/models/entry.dart';
import 'package:amp/core/providers/selection_provider.dart';
import 'package:amp/core/widgets/delete_selection_dialog.dart';
import 'package:amp/core/widgets/selection_app_bar.dart';
import 'package:amp/features/journal/providers/entries_by_day_provider.dart';
import 'package:amp/features/journal/providers/entry_repository_provider.dart';
import 'package:amp/features/journal/providers/selected_date_provider.dart';
import 'package:amp/features/journal/widgets/group_entry_list_item.dart';
import 'package:amp/features/journal/widgets/group_entries_dialog.dart';
import 'package:amp/features/journal/widgets/product_entry_list_item.dart';
import 'package:amp/features/journal/widgets/recipe_entry_list_item.dart';
import 'package:amp/features/journal/screens/product_search_screen.dart';
import 'package:amp/features/journal/widgets/log_product_entry_dialog.dart';
import 'package:amp/core/screens/barcode_scanner_screen.dart';
import 'package:amp/features/products/providers/product_repository_provider.dart';
import 'package:amp/features/products/providers/open_food_facts_service_provider.dart';
import 'package:amp/features/products/providers/prefilled_product_data_provider.dart';
import 'package:go_router/go_router.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final entriesAsync = ref.watch(entriesByDayProvider(selectedDate));

    final selectionState = ref.watch(selectionProvider);

    return Scaffold(
      appBar: SelectionAppBar(
        title: const Text('Journal'),
        selectionActions: [
          IconButton(
            icon: const Icon(Icons.group_work_outlined),
            onPressed: selectionState.selectedIds.length > 1
                ? () => showDialog(
                    context: context,
                    builder: (context) => const GroupEntriesDialog(),
                  )
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              final selectedIds = selectionState.selectedIds.toList();
              entriesAsync.whenData((entries) {
                final selectedEntries = entries
                    .where((entry) => selectedIds.contains(entry.id))
                    .toList();
                showDialog(
                  context: context,
                  builder: (context) => DeleteSelectionDialog(
                    onDelete: (ids) async {
                      await ref
                          .read(entryRepositoryProvider)
                          .deleteEntries(ids);
                      ref.read(selectionProvider.notifier).clear();
                    },
                    items: selectedEntries,
                  ),
                );
              });
            },
          ),
        ],
      ),
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('Error fetching journal entries: $err')),
        data: (entries) {
          if (entries.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No entries for today.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return switch (entry) {
                ProductEntry() => ProductEntryListItem(entry: entry),
                RecipeEntry() => RecipeEntryListItem(entry: entry),
                GroupEntry() => GroupEntryListItem(entry: entry),
              };
            },
          );
        },
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
                    leading: const Icon(Icons.search),
                    title: const Text('Search Products'),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ProductSearchScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.qr_code_scanner),
                    title: const Text('Scan Barcode'),
                    onTap: () {
                      Navigator.of(context).pop();
                      _handleBarcodeScan();
                    },
                  ),
                ],
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _handleBarcodeScan() async {
    final barcode = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => const BarcodeScannerScreen(),
      ),
    );

    if (barcode == null || !mounted) return;

    try {
      final productRepository = ref.read(productRepositoryProvider);
      final product = await productRepository.getProductByBarcode(barcode);

      if (!mounted) return;

      if (product != null) {
        // Product found - show log dialog
        final productVersion = await productRepository.getLatestProductVersion(
          product.id!,
        );
        if (!mounted) return;
        await LogProductEntryDialog.show(
          context,
          ref,
          product,
          productVersion,
        );
      } else {
        // Product not found in user's database - try Open Food Facts
        final offService = ref.read(openFoodFactsServiceProvider);
        final offProduct = await offService.getProductByBarcode(barcode);

        if (!mounted) return;

        if (offProduct != null) {
          // Found in Open Food Facts - offer to import
          final shouldImport = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Product Found in Open Food Facts'),
              content: Text(
                'Found "${offProduct.name}" in Open Food Facts. Would you like to import it?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Import'),
                ),
              ],
            ),
          );

          if (shouldImport == true && mounted) {
            // Store prefilled data in provider
            ref.read(prefilledProductDataProvider.notifier).state =
                PrefilledProductData(
              name: offProduct.name,
              upc: offProduct.barcode,
              nutrition: offProduct.nutrition,
              units: offProduct.units,
            );
            // Navigate using go_router
            context.push('/products/add');
          }
        } else {
          // Not found anywhere - offer to create manually
          final shouldCreate = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Product Not Found'),
              content: Text(
                'No product found with barcode "$barcode" in your database or Open Food Facts. Would you like to create it manually?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Create Product'),
                ),
              ],
            ),
          );

          if (shouldCreate == true && mounted) {
            // Navigate to product creation with UPC pre-filled
            context.push('/products/add?upc=$barcode');
          }
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}
