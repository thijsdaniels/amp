import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amp/core/models/entry.dart';
import 'package:amp/features/journal/providers/entry_repository_provider.dart';

/// A dialog for confirming ungrouping of group entries.
class UngroupEntriesDialog extends ConsumerWidget {
  const UngroupEntriesDialog({
    super.key,
    required this.groups,
    this.onComplete,
  });

  final List<GroupEntry> groups;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entryRepository = ref.read(entryRepositoryProvider);
    final count = groups.length;
    final isSingle = count == 1;
    final groupIds = groups.map((group) => group.id!).toList();

    return AlertDialog(
      title: Text(
        isSingle
            ? 'Ungroup "${groups.first.name}"?'
            : 'Ungroup these $count groups?',
      ),
      content: Text(
        isSingle
            ? 'This will move all entries from "${groups.first.name}" back to the main list. The group will be deleted.'
            : 'This will move all entries from these groups back to the main list. The groups will be deleted.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            try {
              // Ungroup each group
              for (final groupId in groupIds) {
                await entryRepository.ungroupEntry(groupId);
              }

              if (!context.mounted) return;
              Navigator.of(context).pop();
              onComplete?.call();
            } catch (e) {
              if (!context.mounted) return;
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error ungrouping: $e'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          },
          child: const Text('Ungroup'),
        ),
      ],
    );
  }
}
