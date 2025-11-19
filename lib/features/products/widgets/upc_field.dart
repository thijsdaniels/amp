import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:amp/core/screens/barcode_scanner_screen.dart';

/// Reusable UPC/Barcode form field with scan button.
class UpcField extends StatelessWidget {
  final String? initialValue;
  final GlobalKey<FormBuilderState>? formKey;

  const UpcField({
    super.key,
    this.initialValue,
    this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      name: 'upc',
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: 'UPC/Barcode (optional)',
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: const Icon(Icons.qr_code_scanner),
          onPressed: () async {
            final barcode = await Navigator.of(context).push<String>(
              MaterialPageRoute(
                builder: (context) => const BarcodeScannerScreen(),
              ),
            );
            if (barcode != null) {
              // Use provided form key if available
              if (formKey?.currentState != null) {
                formKey!.currentState!.fields['upc']?.didChange(barcode);
              } else {
                // Fallback: try to get from FormBuilder context
                final formState = FormBuilder.of(context);
                formState?.fields['upc']?.didChange(barcode);
              }
            }
          },
          tooltip: 'Scan Barcode',
        ),
      ),
    );
  }
}

