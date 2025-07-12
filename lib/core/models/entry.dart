import 'package:amp/core/models/document.dart';
import 'package:amp/core/models/product_version.dart';
import 'package:amp/core/models/recipe_version.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum EntryType { group, product, recipe }

sealed class Entry extends Document {
  final Timestamp occurredAt;
  final DocumentReference<Entry>? parentRef;
  final EntryType type;

  const Entry({
    super.id,
    required super.createdBy,
    required super.createdAt,
    required super.updatedAt,
    required this.type,
    required this.occurredAt,
    this.parentRef,
  });

  factory Entry.fromSnapshot(DocumentSnapshot snapshot) {
    final map = snapshot.data() as Map<String, dynamic>;
    final typeString = map['type'] as String;
    final type = EntryType.values.byName(typeString);

    switch (type) {
      case EntryType.group:
        return GroupEntry.fromMap(map, snapshot.id);
      case EntryType.product:
        return ProductEntry.fromMap(map, snapshot.id);
      case EntryType.recipe:
        return RecipeEntry.fromMap(map, snapshot.id);
    }
  }

  Entry copyWith();
}

class GroupEntry extends Entry {
  final String name;

  const GroupEntry({
    super.id,
    required super.createdBy,
    required super.createdAt,
    required super.updatedAt,
    required super.occurredAt,
    super.parentRef,
    required this.name,
  }) : super(type: EntryType.group);

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
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

  @override
  GroupEntry copyWith({
    String? id,
    String? createdBy,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    Timestamp? occurredAt,
    DocumentReference<Entry>? parentRef,
    String? name,
  }) {
    return GroupEntry(
      id: id ?? this.id,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      occurredAt: occurredAt ?? this.occurredAt,
      parentRef: parentRef ?? this.parentRef,
      name: name ?? this.name,
    );
  }
}

class ProductEntry extends Entry {
  final DocumentReference<ProductVersion> productVersionRef;
  final String name;
  final double quantity;
  final String unit;

  const ProductEntry({
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
  }) : super(type: EntryType.product);

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
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

  @override
  ProductEntry copyWith({
    String? id,
    String? createdBy,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    Timestamp? occurredAt,
    DocumentReference<Entry>? parentRef,
    DocumentReference<ProductVersion>? productVersionRef,
    String? name,
    double? quantity,
    String? unit,
  }) {
    return ProductEntry(
      id: id ?? this.id,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      occurredAt: occurredAt ?? this.occurredAt,
      parentRef: parentRef ?? this.parentRef,
      productVersionRef: productVersionRef ?? this.productVersionRef,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
    );
  }
}

class RecipeEntry extends Entry {
  final DocumentReference<RecipeVersion> recipeVersionRef;
  final String name;
  final double quantity;
  final String unit;

  const RecipeEntry({
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
  }) : super(type: EntryType.recipe);

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
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

  @override
  RecipeEntry copyWith({
    String? id,
    String? createdBy,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    Timestamp? occurredAt,
    DocumentReference<Entry>? parentRef,
    DocumentReference<RecipeVersion>? recipeVersionRef,
    String? name,
    double? quantity,
    String? unit,
  }) {
    return RecipeEntry(
      id: id ?? this.id,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      occurredAt: occurredAt ?? this.occurredAt,
      parentRef: parentRef ?? this.parentRef,
      recipeVersionRef: recipeVersionRef ?? this.recipeVersionRef,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
    );
  }
}
