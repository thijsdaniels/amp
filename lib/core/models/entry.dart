import 'package:amp/core/models/document.dart';
import 'package:amp/core/models/product_version.dart';
import 'package:amp/core/models/recipe_version.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

sealed class Entry extends Document {
  final Timestamp occurredAt;
  final DocumentReference<Entry>? parentRef;

  Entry({
    super.id,
    required super.createdBy,
    required super.createdAt,
    required super.updatedAt,
    required this.occurredAt,
    this.parentRef,
  });

  factory Entry.fromSnapshot(DocumentSnapshot snapshot) {
    final map = snapshot.data() as Map<String, dynamic>;
    final type = map['type'];

    switch (type) {
      case 'GROUP':
        return GroupEntry.fromMap(map, snapshot.id);
      case 'PRODUCT':
        return ProductEntry.fromMap(map, snapshot.id);
      case 'RECIPE':
        return RecipeEntry.fromMap(map, snapshot.id);
      default:
        throw Exception('Unknown Entry type: $type');
    }
  }

  Map<String, dynamic> toMap();
}

class GroupEntry extends Entry {
  final String name;

  GroupEntry({
    super.id,
    required super.createdBy,
    required super.createdAt,
    required super.updatedAt,
    required super.occurredAt,
    super.parentRef,
    required this.name,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'GROUP',
      'createdBy': createdBy,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'occurredAt': occurredAt,
      'parentRef': parentRef,
      'name': name,
    };
  }

  factory GroupEntry.fromMap(Map<String, dynamic> map, String id) {
    if (map case {
      'createdBy': String createdBy,
      'createdAt': Timestamp createdAt,
      'updatedAt': Timestamp updatedAt,
      'occurredAt': Timestamp occurredAt,
      'name': String name,
    }) {
      final rawParentRef = map['parentRef'] as DocumentReference?;
      final typedParentRef = rawParentRef?.withConverter<Entry>(
        fromFirestore: (snapshot, _) => Entry.fromSnapshot(snapshot),
        toFirestore: (entry, _) => entry.toMap(),
      );

      return GroupEntry(
        id: id,
        createdBy: createdBy,
        createdAt: createdAt,
        updatedAt: updatedAt,
        occurredAt: occurredAt,
        parentRef: typedParentRef,
        name: name,
      );
    } else {
      throw const FormatException('Invalid JSON format for GroupEntry');
    }
  }
}

class ProductEntry extends Entry {
  final DocumentReference<ProductVersion> productVersionRef;
  final String name;
  final double quantity;
  final String unit;

  ProductEntry({
    super.id,
    required super.createdBy,
    required super.createdAt,
    required super.updatedAt,
    required super.occurredAt,
    super.parentRef,
    required this.productVersionRef,
    required this.name,
    required this.quantity,
    required this.unit,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'PRODUCT',
      'createdBy': createdBy,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'occurredAt': occurredAt,
      'parentRef': parentRef,
      'productVersionRef': productVersionRef,
      'name': name,
      'quantity': quantity,
      'unit': unit,
    };
  }

  factory ProductEntry.fromMap(Map<String, dynamic> map, String id) {
    if (map case {
      'createdBy': String createdBy,
      'createdAt': Timestamp createdAt,
      'updatedAt': Timestamp updatedAt,
      'occurredAt': Timestamp occurredAt,
      'productVersionRef': DocumentReference productVersionRef,
      'name': String name,
      'quantity': num quantity,
      'unit': String unit,
    }) {
      final rawParentRef = map['parentRef'] as DocumentReference?;
      final typedParentRef = rawParentRef?.withConverter<Entry>(
        fromFirestore: (snapshot, _) => Entry.fromSnapshot(snapshot),
        toFirestore: (entry, _) => entry.toMap(),
      );

      final typedProductVersionRef = productVersionRef
          .withConverter<ProductVersion>(
            fromFirestore: (snapshot, _) =>
                ProductVersion.fromSnapshot(snapshot),
            toFirestore: (productVersion, _) => productVersion.toMap(),
          );

      return ProductEntry(
        id: id,
        createdBy: createdBy,
        createdAt: createdAt,
        updatedAt: updatedAt,
        occurredAt: occurredAt,
        parentRef: typedParentRef,
        productVersionRef: typedProductVersionRef,
        name: name,
        quantity: quantity.toDouble(),
        unit: unit,
      );
    } else {
      throw const FormatException('Invalid JSON format for ProductEntry');
    }
  }
}

class RecipeEntry extends Entry {
  final DocumentReference<RecipeVersion> recipeVersionRef;
  final String name;
  final double quantity;
  final String unit;

  RecipeEntry({
    super.id,
    required super.createdBy,
    required super.createdAt,
    required super.updatedAt,
    required super.occurredAt,
    super.parentRef,
    required this.recipeVersionRef,
    required this.name,
    required this.quantity,
    required this.unit,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'RECIPE',
      'createdBy': createdBy,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'occurredAt': occurredAt,
      'parentRef': parentRef,
      'recipeVersionRef': recipeVersionRef,
      'name': name,
      'quantity': quantity,
      'unit': unit,
    };
  }

  factory RecipeEntry.fromMap(Map<String, dynamic> map, String id) {
    if (map case {
      'createdBy': String createdBy,
      'createdAt': Timestamp createdAt,
      'updatedAt': Timestamp updatedAt,
      'occurredAt': Timestamp occurredAt,
      'recipeVersionRef': DocumentReference recipeVersionRef,
      'name': String name,
      'quantity': num quantity,
      'unit': String unit,
    }) {
      final rawParentRef = map['parentRef'] as DocumentReference?;
      final typedParentRef = rawParentRef?.withConverter<Entry>(
        fromFirestore: (snapshot, _) => Entry.fromSnapshot(snapshot),
        toFirestore: (entry, _) => entry.toMap(),
      );

      final typedRecipeVersionRef = recipeVersionRef
          .withConverter<RecipeVersion>(
            fromFirestore: (snapshot, _) =>
                RecipeVersion.fromSnapshot(snapshot),
            toFirestore: (recipeVersion, _) => recipeVersion.toMap(),
          );

      return RecipeEntry(
        id: id,
        createdBy: createdBy,
        createdAt: createdAt,
        updatedAt: updatedAt,
        occurredAt: occurredAt,
        parentRef: typedParentRef,
        recipeVersionRef: typedRecipeVersionRef,
        name: name,
        quantity: quantity.toDouble(),
        unit: unit,
      );
    } else {
      throw const FormatException('Invalid JSON format for RecipeEntry');
    }
  }
}
