import 'package:amp/core/models/entry.dart';
import 'package:amp/features/journal/providers/entry_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fetches a stream of top-level entries for a given day.
final entriesByDayProvider = StreamProvider.autoDispose
    .family<List<Entry>, DateTime>((ref, day) {
      final entryRepo = ref.watch(entryRepositoryProvider);
      return entryRepo.getEntriesStream(day);
    });
