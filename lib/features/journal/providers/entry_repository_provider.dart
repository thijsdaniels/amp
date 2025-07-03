import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amp/core/providers/firestore_provider.dart';
import 'package:amp/features/auth/providers/uid_provider.dart';
import 'package:amp/features/journal/data/entry_repository.dart';

final entryRepositoryProvider = Provider<EntryRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final uid = ref.watch(uidProvider);
  return EntryRepository(firestore: firestore, uid: uid);
});
