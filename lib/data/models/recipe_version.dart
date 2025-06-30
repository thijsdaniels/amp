import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vim_reboot/data/models/base_model.dart';
import 'package:vim_reboot/data/models/ingredient.dart';
import 'package:vim_reboot/data/models/json_converters.dart';
import 'package:vim_reboot/data/models/unit.dart';

part 'recipe_version.freezed.dart';
part 'recipe_version.g.dart';

@freezed
abstract class RecipeVersion extends BaseModel with _$RecipeVersion {
  RecipeVersion._({
    super.id,
    required super.createdBy,
    required super.createdAt,
    required super.updatedAt,
  });

  factory RecipeVersion({
    @JsonKey(includeToJson: false, includeFromJson: false) String? id,
    required String createdBy,
    @TimestampConverter() required Timestamp createdAt,
    @TimestampConverter() required Timestamp updatedAt,
    required int version,
    required List<Ingredient> ingredients,
    required List<Unit> units,
  }) = _RecipeVersion;

  factory RecipeVersion.fromJson(Map<String, dynamic> json) =>
      _$RecipeVersionFromJson(json);
}
