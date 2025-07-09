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
