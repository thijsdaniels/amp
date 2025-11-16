import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amp/core/providers/selection_provider.dart';

class SelectionAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const SelectionAppBar({
    super.key,
    required this.title,
    this.actions,
    this.selectionActions,
  });

  final Widget title;
  final List<Widget>? actions;
  final List<Widget>? selectionActions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(selectionProvider);
    final hasSelection = selection.isSelectionActive;

    if (!hasSelection) {
      return AppBar(title: title, actions: actions);
    }

    final selectionCount = selection.selectedIds.length;

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () {
          ref.read(selectionProvider.notifier).clear();
        },
      ),
      title: Text('$selectionCount selected'),
      actions: selectionActions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
