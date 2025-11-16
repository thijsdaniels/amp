import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amp/core/providers/selection_provider.dart';

/// A reusable dialog for confirming deletion of selected items.
///
/// This dialog reads the current selection state and allows the user to
/// confirm deletion of the selected items.
class DeleteSelectionDialog extends ConsumerWidget {
  const DeleteSelectionDialog({super.key, required this.onDelete});

  /// The function to call when deletion is confirmed.
  /// Receives the list of selected IDs to delete.
  final Future<void> Function(List<String> selectedIds) onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectionState = ref.read(selectionProvider);
    final selectionController = ref.read(selectionProvider.notifier);
    final count = selectionState.selectedIds.length;

    return AlertDialog(
      title: Text('Delete $count ${count == 1 ? 'item' : 'items'}?'),
      content: const Text(
        'Are you sure you want to delete the selected items? This action cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            try {
              await onDelete(selectionState.selectedIds.toList());
              selectionController.clear();
              if (!context.mounted) return;
              Navigator.of(context).pop();
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
