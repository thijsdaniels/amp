import 'package:amp/core/models/entry.dart';
import 'package:amp/core/models/product_version.dart';
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

  Future<void> deleteEntries(List<String> entryIds) async {
    if (entryIds.isEmpty) return;

    final batch = _firestore.batch();
    for (final entryId in entryIds) {
      batch.delete(_entriesRef.doc(entryId));
    }
    await batch.commit();
  }

  Future<void> _updateEntry(Entry entry) async {
    if (entry.id == null) {
      throw ArgumentError('Entry must have an ID to be updated.');
    }
    final data = entry.toMap();

    // Ensure immutable fields are not updated
    data.remove('createdBy');
    data.remove('createdAt');

    // Set the update timestamp
    data['updatedAt'] = Timestamp.now();

    await _entriesRef.doc(entry.id!).update(data);
  }

  Future<void> updateProductEntryToNewVersion(
    String entryId,
    String newName,
    DocumentReference<ProductVersion> newVersionRef,
  ) async {
    final originalEntry = await getEntry(entryId) as ProductEntry;
    final updatedEntry = originalEntry.copyWith(
      name: newName,
      productVersionRef: newVersionRef,
    );
    await _updateEntry(updatedEntry);
  }

  Future<void> updateProductEntryWithNewUnit(
    String entryId,
    String newName,
    DocumentReference<ProductVersion> newVersionRef,
    String newUnit,
    double newQuantity,
  ) async {
    final originalEntry = await getEntry(entryId) as ProductEntry;
    final updatedEntry = originalEntry.copyWith(
      name: newName,
      productVersionRef: newVersionRef,
      unit: newUnit,
      quantity: newQuantity,
    );
    await _updateEntry(updatedEntry);
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

  Future<void> ungroupEntry(String groupId) async {
    final groupRef = _entriesRef.doc(groupId);

    // 1. Get all children of this group
    final childrenSnapshot = await _entriesRef
        .where('parentRef', isEqualTo: groupRef)
        .get();

    final batch = _firestore.batch();

    // 2. Set parentRef to null for all children
    for (final childDoc in childrenSnapshot.docs) {
      batch.update(childDoc.reference, {'parentRef': null});
    }

    // 3. Delete the group entry itself
    batch.delete(groupRef);

    // 4. Commit the atomic write
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
