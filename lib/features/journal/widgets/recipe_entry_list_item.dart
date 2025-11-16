import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:amp/core/models/entry.dart';
import 'package:amp/core/mixins/selectable_item_mixin.dart';

class RecipeEntryListItem extends ConsumerWidget with SelectableItemMixin {
  const RecipeEntryListItem({super.key, required this.entry});

  final RecipeEntry entry;

  @override
  String get id => entry.id!;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtitle = '${entry.quantity} ${entry.unit}';

    return Card(
      child: ListTile(
        leading: const Icon(Icons.restaurant_menu),
        title: Text(entry.name),
        subtitle: Text(subtitle),
        selected: isSelected(ref),
        onTap: () => handleTap(
          ref: ref,
          primaryAction: () => context.push(entry.routePath),
        ),
        onLongPress: () => handleLongPress(ref: ref),
      ),
    );
  }
}
