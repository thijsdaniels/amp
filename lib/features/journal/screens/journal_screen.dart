import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amp/core/models/entry.dart';
import 'package:amp/core/widgets/delete_selection_dialog.dart';
import 'package:amp/core/widgets/selection_app_bar.dart';
import 'package:amp/features/journal/providers/entries_by_day_provider.dart';
import 'package:amp/features/journal/providers/entry_repository_provider.dart';
import 'package:amp/features/journal/providers/selected_date_provider.dart';
import 'package:amp/features/journal/widgets/group_entry_list_item.dart';
import 'package:amp/features/journal/widgets/group_entries_dialog.dart';
import 'package:amp/features/journal/widgets/product_entry_list_item.dart';
import 'package:amp/features/journal/widgets/recipe_entry_list_item.dart';

class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final entriesAsync = ref.watch(entriesByDayProvider(selectedDate));

    return Scaffold(
      appBar: SelectionAppBar(
        title: const Text('Journal'),
        selectionActions: [
          IconButton(
            icon: const Icon(Icons.group_work_outlined),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => const GroupEntriesDialog(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => DeleteSelectionDialog(
                onDelete: (ids) =>
                    ref.read(entryRepositoryProvider).deleteEntries(ids),
              ),
            ),
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
          // TODO: Quick add food entry
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Quick add food - coming soon!')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
