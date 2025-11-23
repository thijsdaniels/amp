import 'package:amp/core/models/consumable.dart';
import 'package:amp/core/models/model.dart';
import 'package:amp/core/models/product.dart';
import 'package:amp/core/models/recipe.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Ingredient extends Model {
  final DocumentReference<Consumable> itemRef;
  final double quantity;

  const Ingredient({required this.itemRef, required this.quantity});

  @override
  Map<String, dynamic> toMap() {
    return {'itemRef': itemRef, 'quantity': quantity};
  }

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    if (map case {
      'itemRef': DocumentReference rawRef,
      'quantity': num quantity,
    }) {
      final typedRef = rawRef.withConverter<Consumable>(
        fromFirestore: (snapshot, _) {
          final path = snapshot.reference.path;
          if (path.contains('/products/')) {
            return Product.fromSnapshot(snapshot);
          } else if (path.contains('/recipes/')) {
            return Recipe.fromSnapshot(snapshot);
          }
          throw const FormatException('Unknown Consumable type');
        },
        toFirestore: (consumable, _) => consumable.toMap(),
      );

      return Ingredient(itemRef: typedRef, quantity: quantity.toDouble());
    } else {
      throw const FormatException('Invalid JSON format for Ingredient');
    }
  }
}
