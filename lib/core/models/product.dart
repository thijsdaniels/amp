import 'package:amp/core/models/document.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Product extends Document {
  final String name;
  final int latestVersion;

  const Product({
    super.id,
    required super.createdBy,
    required super.createdAt,
    required super.updatedAt,
    required this.name,
    required this.latestVersion,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'createdBy': createdBy,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'name': name,
      'latestVersion': latestVersion,
    };
  }

  Product copyWith({
    String? id,
    String? createdBy,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    String? name,
    int? latestVersion,
  }) {
    return Product(
      id: id ?? this.id,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      latestVersion: latestVersion ?? this.latestVersion,
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
      return Product(
        id: snapshot.id,
        createdBy: createdBy,
        createdAt: createdAt,
        updatedAt: updatedAt,
        name: name,
        latestVersion: latestVersion,
      );
    } else {
      throw const FormatException('Invalid snapshot data for Product');
    }
  }
}
