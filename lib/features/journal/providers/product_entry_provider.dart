import 'package:amp/core/models/entry.dart';
import 'package:amp/features/journal/providers/single_entry_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final productEntryProvider = Provider.family<AsyncValue<ProductEntry>, String>((
  ref,
  entryId,
) {
  final entryAsync = ref.watch(singleEntryProvider(entryId));

  return entryAsync.when(
    data: (entry) {
      if (entry is ProductEntry) {
        return AsyncValue.data(entry);
      }
      return AsyncValue.error(
        'Entry with ID $entryId is not a ProductEntry, but ${entry.runtimeType}',
        StackTrace.current,
      );
    },
    loading: () => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
  );
});
