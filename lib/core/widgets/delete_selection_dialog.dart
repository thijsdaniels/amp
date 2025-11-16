import 'package:flutter/material.dart';
import 'package:amp/core/models/named_item.dart';

/// A reusable dialog for confirming deletion of items.
class DeleteSelectionDialog extends StatelessWidget {
  const DeleteSelectionDialog({
    super.key,
    required this.onDelete,
    required this.items,
    this.onComplete,
  });

  /// The function to call when deletion is confirmed.
  /// Receives the list of IDs to delete.
  final Future<void> Function(List<String> itemIds) onDelete;

  /// The items to delete. Must have non-null IDs.
  final List<NamedItem> items;

  /// Optional: callback after successful deletion.
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    final count = items.length;
    final isSingle = count == 1;
    final itemIds = items.map((item) => item.id!).toList();

    return AlertDialog(
      title: Text(
        isSingle
            ? 'Delete "${items.first.name}"?'
            : 'Delete these $count items?',
      ),
      content: Text(
        isSingle
            ? 'Are you sure you want to delete "${items.first.name}"? This action cannot be undone.'
            : 'Are you sure you want to delete these items? This action cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            try {
              await onDelete(itemIds);
              if (!context.mounted) return;
              Navigator.of(context).pop();
              onComplete?.call();
            } catch (e) {
              if (!context.mounted) return;
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error deleting items: $e'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
