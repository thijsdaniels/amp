import 'package:amp/core/models/entry.dart';
import 'package:amp/features/journal/providers/single_entry_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final groupEntryProvider = Provider.family<AsyncValue<GroupEntry>, String>((
  ref,
  entryId,
) {
  final entryAsync = ref.watch(singleEntryProvider(entryId));

  return entryAsync.when(
    data: (entry) {
      if (entry is GroupEntry) {
        return AsyncValue.data(entry);
      }
      return AsyncValue.error(
        'Entry with ID $entryId is not a GroupEntry, but ${entry.runtimeType}',
        StackTrace.current,
      );
    },
    loading: () => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
  );
});
