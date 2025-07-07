import 'package:flutter/material.dart';
import 'package:amp/core/models/entry.dart';

class GroupEntryListItem extends StatelessWidget {
  final GroupEntry entry;
  final bool isSelected;
  final VoidCallback? onLongPress;
  final VoidCallback? onTap;
  final VoidCallback? onToggleSelection;

  const GroupEntryListItem({
    super.key,
    required this.entry,
    this.isSelected = false,
    this.onLongPress,
    this.onTap,
    this.onToggleSelection,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.group_work),
        title: Text(entry.name),
        trailing: onToggleSelection != null
            ? Checkbox(
                value: isSelected,
                onChanged: (_) => onToggleSelection?.call(),
              )
            : null,
        onLongPress: onLongPress,
        onTap: onToggleSelection ?? onTap,
        selected: isSelected,
      ),
    );
  }
}
