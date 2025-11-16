import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:amp/core/models/entry.dart';
import 'package:amp/core/mixins/selectable_item_mixin.dart';
import 'package:amp/core/providers/selection_provider.dart';
import 'package:amp/features/journal/providers/entry_repository_provider.dart';
import 'package:amp/core/widgets/delete_selection_dialog.dart';

class RecipeEntryListItem extends ConsumerWidget with SelectableItemMixin {
  const RecipeEntryListItem({super.key, required this.entry});

  final RecipeEntry entry;

  @override
  String get id => entry.id!;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtitle = '${entry.quantity} ${entry.unit}';
    final selectionState = ref.watch(selectionProvider);
    final isSelectionMode = selectionState.isSelectionActive;

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
        trailing: isSelectionMode
            ? null
            : PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) async {
                  if (value == 'delete') {
                    if (!context.mounted) return;
                    showDialog(
                      context: context,
                      builder: (context) => DeleteSelectionDialog(
                        onDelete: (ids) => ref
                            .read(entryRepositoryProvider)
                            .deleteEntries(ids),
                        items: [entry],
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
      ),
    );
  }
}
