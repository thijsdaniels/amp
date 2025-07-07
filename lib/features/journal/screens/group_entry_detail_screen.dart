import 'package:amp/core/models/entry.dart';
import 'package:amp/features/journal/providers/entry_repository_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:amp/features/journal/widgets/group_entry_list_item.dart';
import 'package:amp/features/journal/widgets/product_entry_list_item.dart';
import 'package:amp/features/journal/widgets/recipe_entry_list_item.dart';

final groupChildrenProvider = StreamProvider.family<List<Entry>, String>((
  ref,
  groupId,
) {
  final entryRepo = ref.watch(entryRepositoryProvider);
  return entryRepo.getEntriesByParentIdStream(groupId);
});

final singleEntryProvider = FutureProvider.family<Entry, String>((
  ref,
  entryId,
) {
  final entryRepo = ref.watch(entryRepositoryProvider);
  return entryRepo.getEntry(entryId);
});

class GroupEntryDetailScreen extends ConsumerWidget {
  final String entryId;
  final GroupEntry? entry;

  const GroupEntryDetailScreen({super.key, required this.entryId, this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupEntry = entry;

    if (groupEntry != null) {
      return _buildView(context, ref, groupEntry);
    }

    final groupAsync = ref.watch(singleEntryProvider(entryId));

    return groupAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $err')),
      ),
      data: (groupData) => _buildView(context, ref, groupData as GroupEntry),
    );
  }

  Widget _buildView(BuildContext context, WidgetRef ref, GroupEntry group) {
    final childrenAsync = ref.watch(groupChildrenProvider(group.id!));
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
                  onTap: () =>
                      context.push('/journal/group/${entry.id}', extra: entry),
                ),
                ProductEntry() => ProductEntryListItem(
                  entry: entry,
                  onTap: () => context.push(
                    '/journal/product/${entry.id}',
                    extra: entry,
                  ),
                ),
                RecipeEntry() => RecipeEntryListItem(
                  entry: entry,
                  onTap: () =>
                      context.push('/journal/recipe/${entry.id}', extra: entry),
                ),
              };
            },
          );
        },
      ),
    );
  }
}
