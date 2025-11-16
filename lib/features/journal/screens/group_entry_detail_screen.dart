import 'package:amp/core/models/entry.dart';
import 'package:amp/core/providers/selection_provider.dart';
import 'package:amp/core/widgets/delete_selection_dialog.dart';
import 'package:amp/core/widgets/selection_app_bar.dart';
import 'package:amp/features/journal/providers/entries_by_parent_provider.dart';
import 'package:amp/features/journal/providers/entry_repository_provider.dart';
import 'package:amp/features/journal/providers/group_entry_provider.dart';
import 'package:amp/features/journal/widgets/group_entry_list_item.dart';
import 'package:amp/features/journal/widgets/group_entries_dialog.dart';
import 'package:amp/features/journal/widgets/product_entry_list_item.dart';
import 'package:amp/features/journal/widgets/recipe_entry_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GroupEntryDetailScreen extends ConsumerWidget {
  final String entryId;

  const GroupEntryDetailScreen({super.key, required this.entryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(groupEntryProvider(entryId));

    return groupAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $err')),
      ),
      data: (group) {
        final childrenAsync = ref.watch(entriesByParentProvider(group.id!));
        final selectionState = ref.watch(selectionProvider);

        return Scaffold(
          appBar: SelectionAppBar(
            title: Text(group.name),
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
                  childrenAsync.whenData((children) {
                    final selectedEntries = children
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
          body: childrenAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
            data: (children) {
              if (children.isEmpty) {
                return const Center(child: Text('This group is empty.'));
              }
              return ListView.builder(
                itemCount: children.length,
                itemBuilder: (context, index) {
                  final entry = children[index];
                  return switch (entry) {
                    GroupEntry() => GroupEntryListItem(entry: entry),
                    ProductEntry() => ProductEntryListItem(entry: entry),
                    RecipeEntry() => RecipeEntryListItem(entry: entry),
                  };
                },
              );
            },
          ),
        );
      },
    );
  }
}
