import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amp/core/providers/selection_provider.dart';
import 'package:amp/features/journal/providers/entry_repository_provider.dart';

/// A dialog for grouping selected journal entries.
class GroupEntriesDialog extends ConsumerWidget {
  const GroupEntriesDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final selectionState = ref.read(selectionProvider);
    final selectionController = ref.read(selectionProvider.notifier);
    final entryRepository = ref.read(entryRepositoryProvider);

    return AlertDialog(
      title: const Text('Name Your Group'),
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'e.g., Breakfast'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a name';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            if (formKey.currentState!.validate()) {
              final groupName = nameController.text;
              try {
                await entryRepository.groupEntries(
                  selectionState.selectedIds.toList(),
                  groupName,
                );
                selectionController.clear();

                if (!context.mounted) return;
                Navigator.of(context).pop();
              } catch (e) {
                if (!context.mounted) return;
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error creating group: $e'),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              }
            }
          },
          child: const Text('Group'),
        ),
      ],
    );
  }
}
