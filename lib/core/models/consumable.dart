import 'package:amp/core/models/document.dart';

abstract class Consumable extends Document {
  final String name;
  final int latestVersion;

  const Consumable({
    super.id,
    required super.createdBy,
    required super.createdAt,
    required super.updatedAt,
    required this.name,
    required this.latestVersion,
  });
}
