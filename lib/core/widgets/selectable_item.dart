import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amp/core/providers/selection_provider.dart';

enum SelectionTrigger { tap, longPress }

class SelectableItem extends ConsumerWidget {
  const SelectableItem({
    super.key,
    required this.id,
    required this.child,
    this.selectionTrigger = SelectionTrigger.longPress,
  });

  final String id;
  final Widget child;
  final SelectionTrigger selectionTrigger;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectionState = ref.watch(selectionProvider);
    final isSelected = selectionState.selectedIds.contains(id);
    final selectionController = ref.read(selectionProvider.notifier);

    void handleTap() {
      if (selectionState.isSelectionActive ||
          selectionTrigger == SelectionTrigger.tap) {
        selectionController.toggle(id);
      } else {
        // Default tap action when not in selection mode (e.g. navigate)
        // This should be handled by the child widget itself.
      }
    }

    void handleLongPress() {
      if (!selectionState.isSelectionActive &&
          selectionTrigger == SelectionTrigger.longPress) {
        selectionController.add(id);
      }
    }

    return GestureDetector(
      onTap: handleTap,
      onLongPress: handleLongPress,
      child: child,
    );
  }
}
