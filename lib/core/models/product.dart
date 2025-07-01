import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:amp/core/models/json_converters.dart';
import 'package:amp/core/models/base_model.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@freezed
abstract class Product extends BaseModel with _$Product {
  Product._({
    super.id,
    required super.createdBy,
    required super.createdAt,
    required super.updatedAt,
  });

  factory Product({
    @JsonKey(includeToJson: false, includeFromJson: false) String? id,
    required String name,
    required String createdBy,
    @TimestampConverter() required Timestamp createdAt,
    @TimestampConverter() required Timestamp updatedAt,
    required int latestVersion,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}
