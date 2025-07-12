import 'package:amp/core/models/entry.dart';
import 'package:amp/features/journal/providers/entries_by_parent_provider.dart';
import 'package:amp/features/journal/providers/group_entry_provider.dart';
import 'package:amp/features/journal/widgets/group_entry_list_item.dart';
import 'package:amp/features/journal/widgets/product_entry_list_item.dart';
import 'package:amp/features/journal/widgets/recipe_entry_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

        return Scaffold(
          appBar: AppBar(title: Text(group.name)),
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
                    GroupEntry() => GroupEntryListItem(
                      entry: entry,
                      onTap: () => context.push('/journal/group/${entry.id}'),
                    ),
                    ProductEntry() => ProductEntryListItem(
                      entry: entry,
                      onTap: () => context.push('/journal/product/${entry.id}'),
                    ),
                    RecipeEntry() => RecipeEntryListItem(
                      entry: entry,
                      onTap: () => context.push('/journal/recipe/${entry.id}'),
                    ),
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
