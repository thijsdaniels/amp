import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amp/core/providers/selection_provider.dart';

/// A mixin to provide selection functionality to any widget.
///
/// The class using this mixin must be a [ConsumerWidget] or [ConsumerStatefulWidget]
/// and must provide the unique [id] of the item it represents.
///
/// The mixin uses the global [selectionProvider] to manage selection state.
mixin SelectableItemMixin {
  /// The unique identifier for the item. This must be implemented by the
  /// class using the mixin.
  String get id;

  /// Checks if the current item is selected.
  ///
  /// Listens to the [selectionProvider] and returns `true` if the item's [id]
  /// is present in the set of selected IDs.
  bool isSelected(WidgetRef ref) {
    final selectionState = ref.watch(selectionProvider);
    return selectionState.selectedIds.contains(id);
  }

  /// Handles the tap gesture on the item.
  ///
  /// If selection mode is active, it toggles the selection state of the item.
  /// Otherwise, it executes the provided [primaryAction].
  void handleTap({
    required WidgetRef ref,
    required VoidCallback primaryAction,
  }) {
    final selectionState = ref.read(selectionProvider);
    final selectionController = ref.read(selectionProvider.notifier);

    if (selectionState.isSelectionActive) {
      selectionController.toggle(id);
    } else {
      primaryAction();
    }
  }

  /// Handles the long-press gesture on the item.
  ///
  /// If selection mode is not active, it initiates selection mode by adding
  /// the current item's [id] to the selection.
  void handleLongPress({required WidgetRef ref}) {
    final selectionState = ref.read(selectionProvider);
    final selectionController = ref.read(selectionProvider.notifier);

    if (!selectionState.isSelectionActive) {
      selectionController.add(id);
    }
  }
}
