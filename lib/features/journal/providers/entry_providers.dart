import 'package:amp/core/models/entry.dart';
import 'package:amp/features/journal/providers/entry_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fetches a single entry document by its ID.
final singleEntryProvider = FutureProvider.family<Entry, String>((
  ref,
  entryId,
) {
  final entryRepo = ref.watch(entryRepositoryProvider);
  return entryRepo.getEntry(entryId);
});
