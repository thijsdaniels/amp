import 'package:amp/core/models/entry.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EntryRepository {
  final FirebaseFirestore _firestore;
  final String _uid;

  EntryRepository({required FirebaseFirestore firestore, required String uid})
    : _firestore = firestore,
      _uid = uid;

  CollectionReference<Entry> get _entriesRef => _firestore
      .collection('users')
      .doc(_uid)
      .collection('entries')
      .withConverter<Entry>(
        fromFirestore: (snapshot, _) => Entry.fromSnapshot(snapshot),
        toFirestore: (entry, _) => entry.toMap(),
      );

  Stream<List<Entry>> getEntriesStream(DateTime day) {
    final startOfDay = Timestamp.fromDate(
      DateTime(day.year, day.month, day.day),
    );
    final endOfDay = Timestamp.fromDate(
      DateTime(day.year, day.month, day.day, 23, 59, 59),
    );

    return _entriesRef
        .where('parentRef', isNull: true)
        .where('occurredAt', isGreaterThanOrEqualTo: startOfDay)
        .where('occurredAt', isLessThanOrEqualTo: endOfDay)
        .orderBy('occurredAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Stream<List<Entry>> getEntriesByParentIdStream(String parentId) {
    final parentRef = _entriesRef.doc(parentId);
    return _entriesRef
        .where('parentRef', isEqualTo: parentRef)
        .orderBy('occurredAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> deleteEntry(String entryId) async {
    await _entriesRef.doc(entryId).delete();
  }

  Future<void> groupEntries(List<String> entryIds, String name) async {
    if (entryIds.isEmpty) return;

    // 1. Fetch the entries to be grouped to find the earliest timestamp
    final entriesSnapshot = await _entriesRef
        .where(FieldPath.documentId, whereIn: entryIds)
        .get();
    final entries = entriesSnapshot.docs.map((doc) => doc.data()).toList();

    if (entries.isEmpty) return;

    // 2. Find the earliest occurredAt timestamp
    final earliestTimestamp = entries.fold(
      entries.first.occurredAt,
      (earliest, current) => current.occurredAt.compareTo(earliest) < 0
          ? current.occurredAt
          : earliest,
    );

    final batch = _firestore.batch();
    final now = Timestamp.now();

    // 3. Create the new GroupEntry with the calculated timestamp
    final newGroupRef = _entriesRef.doc();
    final newGroup = GroupEntry(
      createdBy: _uid,
      createdAt: now,
      updatedAt: now,
      occurredAt: earliestTimestamp,
      name: name,
    );
    batch.set(newGroupRef, newGroup);

    // 4. Update the parentRef for all selected entries
    for (final entryId in entryIds) {
      final entryRef = _entriesRef.doc(entryId);
      batch.update(entryRef, {'parentRef': newGroupRef});
    }

    // 5. Commit the atomic write
    await batch.commit();
  }

  Future<DocumentReference<Entry>> addEntry(Entry entry) async {
    return _entriesRef.add(entry);
  }

  Future<Entry> getEntry(String entryId) async {
    final doc = await _entriesRef.doc(entryId).get();
    return doc.data()!;
  }
}
