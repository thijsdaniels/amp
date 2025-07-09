import 'package:cloud_firestore/cloud_firestore.dart';

abstract class Document {
  final String? id;
  final String createdBy;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  Document({
    this.id,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });
}
