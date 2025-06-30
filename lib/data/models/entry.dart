import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vim_reboot/data/models/base_model.dart';
import 'package:vim_reboot/data/models/json_converters.dart';

part 'entry.freezed.dart';
part 'entry.g.dart';

@Freezed(unionKey: 'type')
abstract class Entry extends BaseModel with _$Entry {
  Entry._({
    super.id,
    required super.createdBy,
    required super.createdAt,
    required super.updatedAt,
  });

  @FreezedUnionValue('GROUP')
  factory Entry.group({
    @JsonKey(includeToJson: false, includeFromJson: false) String? id,
    required String createdBy,
    @TimestampConverter() required Timestamp createdAt,
    @TimestampConverter() required Timestamp updatedAt,
    @DocumentReferenceConverter() DocumentReference? parentRef,
    required String name,
  }) = GroupEntry;

  @FreezedUnionValue('RECIPE')
  factory Entry.recipe({
    @JsonKey(includeToJson: false, includeFromJson: false) String? id,
    required String createdBy,
    @TimestampConverter() required Timestamp createdAt,
    @TimestampConverter() required Timestamp updatedAt,
    @DocumentReferenceConverter() DocumentReference? parentRef,
    @DocumentReferenceConverter() required DocumentReference recipeVersionRef,
    required double quantity,
    required String unit,
  }) = RecipeEntry;

  @FreezedUnionValue('PRODUCT')
  factory Entry.product({
    @JsonKey(includeToJson: false, includeFromJson: false) String? id,
    required String createdBy,
    @TimestampConverter() required Timestamp createdAt,
    @TimestampConverter() required Timestamp updatedAt,
    @DocumentReferenceConverter() DocumentReference? parentRef,
    @DocumentReferenceConverter() required DocumentReference productVersionRef,
    required double quantity,
    required String unit,
  }) = ProductEntry;

  factory Entry.fromJson(Map<String, dynamic> json) => _$EntryFromJson(json);
}
