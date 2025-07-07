import 'package:flutter/material.dart';
import 'package:amp/core/models/entry.dart';

class ProductEntryListItem extends StatelessWidget {
  final ProductEntry entry;
  final bool isSelected;
  final VoidCallback? onLongPress;
  final VoidCallback? onTap;
  final VoidCallback? onToggleSelection;

  const ProductEntryListItem({
    super.key,
    required this.entry,
    this.isSelected = false,
    this.onLongPress,
    this.onTap,
    this.onToggleSelection,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = '${entry.quantity} ${entry.unit}';

    return Card(
      child: ListTile(
        leading: const Icon(Icons.fastfood),
        title: Text(entry.name),
        subtitle: Text(subtitle),
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
