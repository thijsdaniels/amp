import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amp/core/providers/selection_provider.dart';
import 'package:amp/features/journal/providers/entry_repository_provider.dart';
import 'package:amp/features/journal/services/group_name_generator.dart';

/// A dialog for grouping selected journal entries.
class GroupEntriesDialog extends ConsumerStatefulWidget {
  const GroupEntriesDialog({super.key});

  @override
  ConsumerState<GroupEntriesDialog> createState() => _GroupEntriesDialogState();
}

class _GroupEntriesDialogState extends ConsumerState<GroupEntriesDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  bool _isGeneratingName = false;
  final _groupNameGenerator = GroupNameGenerator();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _generateGroupName();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _generateGroupName() async {
    final selectionState = ref.read(selectionProvider);
    final selectedIds = selectionState.selectedIds.toList();

    if (selectedIds.isEmpty) return;

    setState(() {
      _isGeneratingName = true;
    });

    try {
      // Fetch entry names
      final entryRepository = ref.read(entryRepositoryProvider);
      final entries = await Future.wait(
        selectedIds.map((id) => entryRepository.getEntry(id)),
      );

      final entryNames = entries.map((entry) => entry.name).toList();

      // Generate name using AI
      final generatedName = await _groupNameGenerator.generateGroupName(
        entryNames,
      );

      if (generatedName != null && mounted) {
        _nameController.text = generatedName;
      }
    } catch (e) {
      // Silently fail - user can still enter a name manually
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingName = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectionState = ref.read(selectionProvider);
    final selectionController = ref.read(selectionProvider.notifier);
    final entryRepository = ref.read(entryRepositoryProvider);

    return AlertDialog(
      title: const Text('Name Your Group'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'e.g., Breakfast',
                suffixIcon: _isGeneratingName
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            if (_isGeneratingName)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Generating name...',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final groupName = _nameController.text;
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
