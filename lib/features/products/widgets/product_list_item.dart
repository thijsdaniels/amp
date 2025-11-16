import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:amp/core/models/product.dart';
import 'package:amp/core/mixins/selectable_item_mixin.dart';
import 'package:amp/core/providers/selection_provider.dart';
import 'package:amp/features/products/providers/product_repository_provider.dart';
import 'package:amp/core/widgets/delete_selection_dialog.dart';

class ProductListItem extends ConsumerWidget with SelectableItemMixin {
  const ProductListItem({super.key, required this.product});

  final Product product;

  @override
  String get id => product.id!;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectionState = ref.watch(selectionProvider);
    final isSelectionMode = selectionState.isSelectionActive;

    return Card(
      child: ListTile(
        leading: const Icon(Icons.inventory),
        title: Text(product.name),
        trailing: isSelectionMode
            ? const Icon(Icons.chevron_right)
            : PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) async {
                  if (value == 'delete') {
                    if (!context.mounted) return;
                    showDialog(
                      context: context,
                      builder: (context) => DeleteSelectionDialog(
                        onDelete: (ids) => ref
                            .read(productRepositoryProvider)
                            .deleteProducts(ids),
                        items: [product],
                      ),
                    );
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 20),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
              ),
        selected: isSelected(ref),
        onTap: () => handleTap(
          ref: ref,
          primaryAction: () => context.push(product.routePath),
        ),
        onLongPress: () => handleLongPress(ref: ref),
      ),
    );
  }
}
