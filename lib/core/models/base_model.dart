import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:amp/core/models/json_converters.dart';

abstract class BaseModel {
  final String createdBy;
  @TimestampConverter()
  final Timestamp createdAt;
  @TimestampConverter()
  final Timestamp updatedAt;

  BaseModel({
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });
}
