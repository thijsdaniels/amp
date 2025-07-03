import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:amp/core/models/entry.dart';

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
        fromFirestore: (snapshot, _) => Entry.fromJson(snapshot.data()!),
        toFirestore: (entry, _) => entry.toJson(),
      );

  Stream<List<Entry>> getEntriesStream(DateTime day) {
    final startOfDay = Timestamp.fromDate(
      DateTime(day.year, day.month, day.day),
    );
    final endOfDay = Timestamp.fromDate(
      DateTime(day.year, day.month, day.day, 23, 59, 59),
    );

    return _entriesRef
        .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
        .where('createdAt', isLessThanOrEqualTo: endOfDay)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final entry = doc.data();
            return entry.copyWith(id: doc.id);
          }).toList(),
        );
  }

  Future<void> deleteEntry(String entryId) async {
    try {
      await _entriesRef.doc(entryId).delete();
    } catch (e) {
      print('Error deleting entry: $e');
      rethrow;
    }
  }

  Future<DocumentReference<Entry>> addEntry(Entry entry) async {
    try {
      final docRef = await _entriesRef.add(entry);
      return docRef;
    } catch (e) {
      print('Error adding entry: $e');
      rethrow;
    }
  }
}
