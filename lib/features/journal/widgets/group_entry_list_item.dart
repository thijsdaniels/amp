import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:amp/core/models/entry.dart';
import 'package:amp/core/mixins/selectable_item_mixin.dart';

class GroupEntryListItem extends ConsumerWidget with SelectableItemMixin {
  const GroupEntryListItem({super.key, required this.entry});

  final GroupEntry entry;

  @override
  String get id => entry.id!;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.group_work_outlined),
      selected: isSelected(ref),
      onTap: () => handleTap(
        ref: ref,
        primaryAction: () => context.push(entry.routePath),
      ),
      onLongPress: () => handleLongPress(ref: ref),
      title: Text(entry.name),
    );
  }
}
