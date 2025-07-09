import 'package:amp/core/models/model.dart';
import 'package:amp/core/models/product_version.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Ingredient extends Model {
  final DocumentReference<ProductVersion> productVersionRef;
  final double quantity;
  final String unit;

  const Ingredient({
    required this.productVersionRef,
    required this.quantity,
    required this.unit,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'productVersionRef': productVersionRef,
      'quantity': quantity,
      'unit': unit,
    };
  }

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    if (map case {
      'productVersionRef': DocumentReference productVersionRef,
      'quantity': num quantity,
      'unit': String unit,
    }) {
      final typedProductVersionRef = productVersionRef
          .withConverter<ProductVersion>(
            fromFirestore: (snapshot, _) =>
                ProductVersion.fromSnapshot(snapshot),
            toFirestore: (productVersion, _) => productVersion.toMap(),
          );

      return Ingredient(
        productVersionRef: typedProductVersionRef,
        quantity: quantity.toDouble(),
        unit: unit,
      );
    } else {
      throw const FormatException('Invalid JSON format for Ingredient');
    }
  }
}
