import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vim_reboot/data/models/json_converters.dart';

abstract class BaseModel {
  final String? id;
  final String createdBy;
  @TimestampConverter()
  final Timestamp createdAt;
  @TimestampConverter()
  final Timestamp updatedAt;

  const BaseModel({
    this.id,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });
}
