import 'package:amp/core/models/document.dart';
import 'package:amp/core/models/named_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Product extends Document with NamedItem {
  final String name;
  final int latestVersion;
  final String? upc;

  const Product({
    super.id,
    required super.createdBy,
    required super.createdAt,
    required super.updatedAt,
    required this.name,
    required this.latestVersion,
    this.upc,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'createdBy': createdBy,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'name': name,
      'latestVersion': latestVersion,
      if (upc != null) 'upc': upc,
    };
  }

  Product copyWith({
    String? id,
    String? createdBy,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    String? name,
    int? latestVersion,
    String? upc,
  }) {
    return Product(
      id: id ?? this.id,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      latestVersion: latestVersion ?? this.latestVersion,
      upc: upc ?? this.upc,
    );
  }

  factory Product.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data();

    if (data case {
      'createdBy': String createdBy,
      'createdAt': Timestamp createdAt,
      'updatedAt': Timestamp updatedAt,
      'name': String name,
      'latestVersion': int latestVersion,
    }) {
      // Extract UPC if it exists, otherwise null
      final upc = data['upc'] as String?;

      return Product(
        id: snapshot.id,
        createdBy: createdBy,
        createdAt: createdAt,
        updatedAt: updatedAt,
        name: name,
        latestVersion: latestVersion,
        upc: upc,
      );
    } else {
      throw const FormatException('Invalid snapshot data for Product');
    }
  }

  /// Returns the route path to navigate to this product's detail screen.
  String get routePath {
    return '/products/$id';
  }
}
