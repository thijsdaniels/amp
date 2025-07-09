import 'package:amp/core/models/entry.dart';
import 'package:amp/features/journal/providers/entry_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fetches a stream of sub-entries for a given parent (group) ID.
final entriesByParentProvider = StreamProvider.autoDispose
    .family<List<Entry>, String>((ref, parentId) {
      final entryRepo = ref.watch(entryRepositoryProvider);
      return entryRepo.getEntriesByParentIdStream(parentId);
    });
