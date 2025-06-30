import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vim_reboot/data/models/base_model.dart';
import 'package:vim_reboot/data/models/json_converters.dart';
import 'package:vim_reboot/data/models/nutrition.dart';
import 'package:vim_reboot/data/models/unit.dart';

part 'product_version.freezed.dart';
part 'product_version.g.dart';

@freezed
abstract class ProductVersion extends BaseModel with _$ProductVersion {
  ProductVersion._({
    super.id,
    required super.createdBy,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ProductVersion({
    @JsonKey(includeToJson: false, includeFromJson: false) String? id,
    required String createdBy,
    @TimestampConverter() required Timestamp createdAt,
    @TimestampConverter() required Timestamp updatedAt,
    required int version,
    required Nutrition nutrition,
    required List<Unit> units,
  }) = _ProductVersion;

  factory ProductVersion.fromJson(Map<String, dynamic> json) =>
      _$ProductVersionFromJson(json);
}
