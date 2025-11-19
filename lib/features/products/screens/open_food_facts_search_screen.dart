import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:amp/core/services/open_food_facts_service.dart';
import 'package:amp/features/products/providers/open_food_facts_service_provider.dart';
import 'package:amp/features/products/providers/prefilled_product_data_provider.dart';

/// Screen for searching Open Food Facts database.
class OpenFoodFactsSearchScreen extends ConsumerStatefulWidget {
  const OpenFoodFactsSearchScreen({super.key});

  @override
  ConsumerState<OpenFoodFactsSearchScreen> createState() =>
      _OpenFoodFactsSearchScreenState();
}

class _OpenFoodFactsSearchScreenState
    extends ConsumerState<OpenFoodFactsSearchScreen> {
  final _searchController = TextEditingController();
  List<OpenFoodFactsProductData> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final service = ref.read(openFoodFactsServiceProvider);
      final results = await service.searchProducts(query);

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error searching Open Food Facts: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Open Food Facts'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search products',
                hintText: 'Enter product name...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                _performSearch(value);
              },
              autofocus: true,
            ),
          ),
          if (_isSearching)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_searchResults.isEmpty && _searchController.text.isNotEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No products found',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            )
          else if (_searchResults.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Search for products in Open Food Facts',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final productData = _searchResults[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.inventory),
                      title: Text(productData.name),
                      subtitle: productData.barcode != null
                          ? Text('UPC: ${productData.barcode}')
                          : null,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
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
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}


