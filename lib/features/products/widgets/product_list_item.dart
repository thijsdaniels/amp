import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:amp/core/models/product.dart';
import 'package:amp/core/mixins/selectable_item_mixin.dart';

class ProductListItem extends ConsumerWidget with SelectableItemMixin {
  const ProductListItem({super.key, required this.product});

  final Product product;

  @override
  String get id => product.id!;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.inventory),
        title: Text(product.name),
        trailing: const Icon(Icons.chevron_right),
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
