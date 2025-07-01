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

  Future<List<Entry>> getEntriesForDay(DateTime day) async {
    // Create Timestamps for the start and end of the given day.
    final startOfDay = Timestamp.fromDate(
      DateTime(day.year, day.month, day.day),
    );
    final endOfDay = Timestamp.fromDate(
      DateTime(day.year, day.month, day.day, 23, 59, 59),
    );

    try {
      final querySnapshot = await _entriesRef
          .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
          .where('createdAt', isLessThanOrEqualTo: endOfDay)
          .orderBy('createdAt', descending: true)
          .get();

      // We need to manually add the document ID to our model object after creation.
      final entries = querySnapshot.docs.map((doc) {
        final entry = doc.data();
        // The freezed `copyWith` will be very useful here.
        // We'll need to make sure our models have it properly configured.
        return entry.copyWith(id: doc.id);
      }).toList();

      return entries;
    } catch (e) {
      // It's good practice to log the error and rethrow or handle it.
      print('Error fetching entries: $e');
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
