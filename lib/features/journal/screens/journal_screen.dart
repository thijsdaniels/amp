import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amp/core/models/entry.dart';
import 'package:amp/features/journal/providers/entry_repository_provider.dart';

final journalEntriesProvider = StreamProvider<List<Entry>>((ref) {
  final entryRepo = ref.watch(entryRepositoryProvider);
  // For now, we fetch for the current day.
  // This could be enhanced later with a date picker.
  return entryRepo.getEntriesStream(DateTime.now());
});

class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(journalEntriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Journal')),
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
              final icon = switch (entry) {
                ProductEntry() => Icons.fastfood,
                RecipeEntry() => Icons.restaurant_menu,
                GroupEntry() => Icons.group_work,
              };
              final subtitle = switch (entry) {
                ProductEntry(:final quantity, :final unit) => '$quantity $unit',
                RecipeEntry(:final quantity, :final unit) => '$quantity $unit',
                GroupEntry() => null,
              };

              return Card(
                child: ListTile(
                  leading: Icon(icon),
                  title: Text(entry.name),
                  subtitle: subtitle != null ? Text(subtitle) : null,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () =>
                        _showDeleteConfirmation(context, ref, entry),
                  ),
                  // TODO: Add onTap to navigate to entry details
                ),
              );
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

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Entry entry,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry?'),
        content: Text('Are you sure you want to delete "${entry.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await ref.read(entryRepositoryProvider).deleteEntry(entry.id!);
                if (!context.mounted) return;
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Entry deleted.'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error deleting entry: $e'),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              }
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
