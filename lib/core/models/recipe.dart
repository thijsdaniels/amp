import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:amp/core/models/base_model.dart';
import 'package:amp/core/models/json_converters.dart';

part 'recipe.freezed.dart';
part 'recipe.g.dart';

@freezed
abstract class Recipe extends BaseModel with _$Recipe {
  Recipe._({
    required super.createdBy,
    required super.createdAt,
    required super.updatedAt,
  });

  factory Recipe({
    @JsonKey(includeToJson: false, includeFromJson: false) String? id,
    required String createdBy,
    @TimestampConverter() required Timestamp createdAt,
    @TimestampConverter() required Timestamp updatedAt,
    required String name,
    required int latestVersion,
  }) = _Recipe;

  factory Recipe.fromJson(Map<String, dynamic> json) => _$RecipeFromJson(json);
}
