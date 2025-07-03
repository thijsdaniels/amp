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

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  bool _isSelectionMode = false;
  final Set<String> _selectedEntryIds = {};

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(journalEntriesProvider);

    return Scaffold(
      appBar: _buildAppBar(),
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
                _ => null,
              };
              final subtitle = switch (entry) {
                ProductEntry(:final quantity, :final unit) => '$quantity $unit',
                RecipeEntry(:final quantity, :final unit) => '$quantity $unit',
                GroupEntry() => null,
              };

              final isSelected = _selectedEntryIds.contains(entry.id!);

              return Card(
                child: ListTile(
                  leading: Icon(icon),
                  title: Text(entry.name),
                  subtitle: subtitle != null ? Text(subtitle) : null,
                  trailing: _isSelectionMode
                      ? Checkbox(
                          value: isSelected,
                          onChanged: (_) => _onTap(entry),
                        )
                      : null,
                  onLongPress: () => _onLongPress(entry),
                  onTap: () => _onTap(entry),
                  selected: isSelected,
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

  AppBar _buildAppBar() {
    if (!_isSelectionMode) {
      return AppBar(title: const Text('Journal'));
    }

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () {
          setState(() {
            _isSelectionMode = false;
            _selectedEntryIds.clear();
          });
        },
      ),
      title: Text('${_selectedEntryIds.length} selected'),
      actions: [
        IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _showDeleteConfirmation(context),
        ),
      ],
    );
  }

  void _onLongPress(Entry entry) {
    if (_isSelectionMode) return;
    setState(() {
      _isSelectionMode = true;
      _selectedEntryIds.add(entry.id!);
    });
  }

  void _onTap(Entry entry) {
    if (!_isSelectionMode) {
      // TODO: Handle navigation to detail screen
      return;
    }
    setState(() {
      if (_selectedEntryIds.contains(entry.id!)) {
        _selectedEntryIds.remove(entry.id!);
        if (_selectedEntryIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedEntryIds.add(entry.id!);
      }
    });
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${_selectedEntryIds.length} Entries?'),
        content: const Text(
          'Are you sure you want to delete the selected entries? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final repo = ref.read(entryRepositoryProvider);
                // Create a copy to avoid concurrent modification errors
                final idsToDelete = List<String>.from(_selectedEntryIds);
                for (final entryId in idsToDelete) {
                  await repo.deleteEntry(entryId);
                }

                setState(() {
                  _selectedEntryIds.clear();
                  _isSelectionMode = false;
                });

                if (!context.mounted) return;
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${idsToDelete.length} entries deleted.'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error deleting entries: $e'),
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
