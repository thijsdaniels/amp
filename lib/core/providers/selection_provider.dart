import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SelectionMode { single, multi }

@immutable
class SelectionState {
  const SelectionState({this.selectedIds = const {}});

  final Set<String> selectedIds;

  bool get isSelectionActive => selectedIds.isNotEmpty;

  SelectionState copyWith({Set<String>? selectedIds}) {
    return SelectionState(selectedIds: selectedIds ?? this.selectedIds);
  }
}

class SelectionController extends StateNotifier<SelectionState> {
  SelectionController({this.selectionMode = SelectionMode.multi})
    : super(const SelectionState());

  final SelectionMode selectionMode;

  void toggle(String id) {
    final newSelectedIds = Set<String>.from(state.selectedIds);

    switch (selectionMode) {
      case SelectionMode.multi:
        if (newSelectedIds.contains(id)) {
          newSelectedIds.remove(id);
        } else {
          newSelectedIds.add(id);
        }
        break;
      case SelectionMode.single:
        if (newSelectedIds.contains(id)) {
          // Deselect if the same item is tapped again
          newSelectedIds.clear();
        } else {
          // Select the new item, clearing any previous selection
          newSelectedIds.clear();
          newSelectedIds.add(id);
        }
        break;
    }
    state = state.copyWith(selectedIds: newSelectedIds);
  }

  void add(String id) {
    if (selectionMode == SelectionMode.single) {
      state = state.copyWith(selectedIds: {id});
      return;
    }
    final newSelectedIds = Set<String>.from(state.selectedIds)..add(id);
    state = state.copyWith(selectedIds: newSelectedIds);
  }

  void remove(String id) {
    final newSelectedIds = Set<String>.from(state.selectedIds)..remove(id);
    state = state.copyWith(selectedIds: newSelectedIds);
  }

  void clear() {
    state = state.copyWith(selectedIds: {});
  }
}

/// Provides a global selection controller for the app.
///
/// Since users typically interact with only one list at a time, a single
/// global selection state is sufficient. The provider is auto-dispose, so
/// it will be cleared when no widgets are watching it.
final selectionProvider =
    StateNotifierProvider.autoDispose<SelectionController, SelectionState>(
      (ref) => SelectionController(),
    );
