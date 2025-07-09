import 'package:amp/core/models/model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class Document extends Model {
  final String? id;
  final String createdBy;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  const Document({
    this.id,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });
}
