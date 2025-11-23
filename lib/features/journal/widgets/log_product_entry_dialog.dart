import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:amp/core/models/product.dart';
import 'package:amp/core/models/product_version.dart';
import 'package:amp/core/models/entry.dart';
import 'package:amp/core/models/unit.dart';
import 'package:amp/core/utilities/units.dart';
import 'package:amp/features/auth/providers/uid_provider.dart';
import 'package:amp/features/products/providers/product_repository_provider.dart';
import 'package:amp/features/journal/providers/entry_repository_provider.dart';

/// A dialog widget for logging a product entry with quantity and unit selection.
class LogProductEntryDialog extends ConsumerStatefulWidget {
  const LogProductEntryDialog({
    super.key,
    required this.product,
    required this.productVersion,
  });

  final Product product;
  final ProductVersion productVersion;

  @override
  ConsumerState<LogProductEntryDialog> createState() =>
      _LogProductEntryDialogState();

  /// Shows the dialog and returns when it's dismissed.
  static Future<void> show(
    BuildContext context,
    WidgetRef ref,
    Product product,
    ProductVersion productVersion,
  ) {
    return showDialog(
      context: context,
      builder: (context) => LogProductEntryDialog(
        product: product,
        productVersion: productVersion,
      ),
    );
  }
}

class _LogProductEntryDialogState extends ConsumerState<LogProductEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _quantityController;
  late final List<Unit> _allUnits;
  Unit? _selectedUnit;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController();
    _allUnits = [Units.gram, ...widget.productVersion.units];
    _selectedUnit = Units.gram;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _handleLog() async {
    if (!_formKey.currentState!.validate()) return;

    final quantity = double.parse(_quantityController.text);
    final grams = quantity * _selectedUnit!.grams;
    final uid = ref.read(uidProvider);
    final now = Timestamp.now();

    final productEntry = ProductEntry(
      createdBy: uid,
      createdAt: now,
      updatedAt: now,
      occurredAt: now,
      productVersionRef: ref
          .read(productRepositoryProvider)
          .getProductVersionRef(widget.product.id!, widget.productVersion.id!),
      name: widget.product.name,
      quantity: grams,
    );

    try {
      await ref.read(entryRepositoryProvider).addEntry(productEntry);

      if (!mounted) return;

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.product.name} logged successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error logging entry: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Log ${widget.product.name}'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _quantityController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a quantity';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Unit>(
              initialValue: _selectedUnit,
              items: _allUnits.map((Unit unit) {
                return DropdownMenuItem<Unit>(
                  value: unit,
                  child: Text(unit.name),
                );
              }).toList(),
              onChanged: (Unit? newValue) {
                setState(() {
                  _selectedUnit = newValue;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Unit',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value == null ? 'Please select a unit' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _handleLog, child: const Text('Log')),
      ],
    );
  }
}
