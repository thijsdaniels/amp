import 'package:amp/core/models/document.dart';
import 'package:amp/core/models/nutrition.dart';
import 'package:amp/core/models/unit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductVersion extends Document {
  final int version;
  final Nutrition nutrition;
  final List<Unit> units;

  const ProductVersion({
    super.id,
    required super.createdBy,
    required super.createdAt,
    required super.updatedAt,
    required this.version,
    required this.nutrition,
    required this.units,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'createdBy': createdBy,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'version': version,
      'nutrition': nutrition.toMap(),
      'units': units.map((unit) => unit.toMap()).toList(),
    };
  }

  factory ProductVersion.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data();

    if (data case {
      'createdBy': String createdBy,
      'createdAt': Timestamp createdAt,
      'updatedAt': Timestamp updatedAt,
      'version': int version,
      'nutrition': Map<String, dynamic> nutritionMap,
      'units': List<dynamic> unitsList,
    }) {
      return ProductVersion(
        id: snapshot.id,
        createdBy: createdBy,
        createdAt: createdAt,
        updatedAt: updatedAt,
        version: version,
        nutrition: Nutrition.fromMap(nutritionMap),
        units: unitsList
            .map((unitMap) => Unit.fromMap(unitMap as Map<String, dynamic>))
            .toList(),
      );
    } else {
      throw const FormatException('Invalid snapshot data for ProductVersion');
    }
  }
}
