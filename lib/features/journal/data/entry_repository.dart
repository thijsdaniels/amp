import 'package:amp/core/models/entry.dart';
import 'package:amp/core/models/ingredient.dart';
import 'package:amp/core/models/product.dart';
import 'package:amp/core/models/product_version.dart';
import 'package:amp/core/models/recipe.dart';
import 'package:amp/core/models/recipe_version.dart';
import 'package:amp/features/recipes/data/recipe_repository.dart';
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

  /// Logs a recipe consumption, creating a recursive tree of entries.
  Future<void> logRecipeEntry({
    required Recipe recipe,
    required RecipeVersion version,
    required DateTime date,
    required double servings,
    required RecipeRepository recipeRepository,
  }) async {
    final now = Timestamp.now();
    final occurredAt = Timestamp.fromDate(date);
    final batch = _firestore.batch();

    // 1. Create Root RecipeEntry
    final rootEntryRef = _entriesRef.doc();
    final rootEntry = RecipeEntry(
      id: rootEntryRef.id,
      createdBy: _uid,
      createdAt: now,
      updatedAt: now,
      occurredAt: occurredAt,
      recipeVersionRef: FirebaseFirestore.instance
          .collection('recipes')
          .doc(recipe.id)
          .collection('versions')
          .doc(version.id)
          .withConverter(
            fromFirestore: (s, _) => RecipeVersion.fromSnapshot(s),
            toFirestore: (v, _) => v.toMap(),
          ),
      quantity: servings,
      unit: 'servings',
      name: recipe.name,
    );
    batch.set(rootEntryRef, rootEntry);

    // 2. Recursively log ingredients
    // Calculate scale factor: how much of the recipe yield are we consuming?
    // If recipe yields 4 servings and we eat 2, scale is 0.5.
    // If recipe yields 0 (undefined), assume 1.
    final scaleFactor = version.servings > 0
        ? servings / version.servings
        : 1.0;

    await _logIngredients(
      batch: batch,
      ingredients: version.ingredients,
      parentRef: rootEntryRef,
      occurredAt: occurredAt,
      scaleFactor: scaleFactor,
      recipeRepository: recipeRepository,
      now: now,
    );

    await batch.commit();
  }

  Future<void> _logIngredients({
    required WriteBatch batch,
    required List<Ingredient> ingredients,
    required DocumentReference<Entry> parentRef,
    required Timestamp occurredAt,
    required double scaleFactor,
    required RecipeRepository recipeRepository,
    required Timestamp now,
  }) async {
    for (final ingredient in ingredients) {
      final itemDoc = await ingredient.itemRef.get();
      final item = itemDoc.data();

      if (item is Product) {
        // Fetch latest product version
        final productVersionSnapshot = await itemDoc.reference
            .collection('versions')
            .where('version', isEqualTo: item.latestVersion)
            .limit(1)
            .withConverter<ProductVersion>(
              fromFirestore: (s, _) => ProductVersion.fromSnapshot(s),
              toFirestore: (v, _) => v.toMap(),
            )
            .get();

        if (productVersionSnapshot.docs.isEmpty) continue;
        final productVersionRef = productVersionSnapshot.docs.first.reference;

        // Calculate scaled quantity
        final quantity = ingredient.quantity * scaleFactor;

        final entryRef = _entriesRef.doc();
        final entry = ProductEntry(
          id: entryRef.id,
          createdBy: _uid,
          createdAt: now,
          updatedAt: now,
          occurredAt: occurredAt,
          productVersionRef: productVersionRef,
          quantity: quantity,
          unit: ingredient.unit,
          name: item.name,
          parentRef: parentRef,
        );
        batch.set(entryRef, entry);
      } else if (item is Recipe) {
        // Fetch latest recipe version
        final subRecipeVersion = await recipeRepository.getLatestRecipeVersion(
          item.id!,
        );
        if (subRecipeVersion == null) continue;

        // Calculate scaled servings for the sub-recipe
        double subServings;
        if (ingredient.unit.toLowerCase() == 'serving' ||
            ingredient.unit.toLowerCase() == 'servings') {
          // If ingredient is defined in servings, we just scale the servings
          subServings = ingredient.quantity * scaleFactor;
        } else {
          // Fallback: treat as servings for now or 1.0.
          subServings = ingredient.quantity * scaleFactor;
        }

        final entryRef = _entriesRef.doc();
        final entry = RecipeEntry(
          id: entryRef.id,
          createdBy: _uid,
          createdAt: now,
          updatedAt: now,
          occurredAt: occurredAt,
          recipeVersionRef: FirebaseFirestore.instance
              .collection('recipes')
              .doc(item.id)
              .collection('versions')
              .doc(subRecipeVersion.id)
              .withConverter(
                fromFirestore: (s, _) => RecipeVersion.fromSnapshot(s),
                toFirestore: (v, _) => v.toMap(),
              ),
          quantity: subServings,
          unit: 'servings',
          name: item.name,
          parentRef: parentRef,
        );
        batch.set(entryRef, entry);

        // Recurse
        final subScaleFactor = subRecipeVersion.servings > 0
            ? subServings / subRecipeVersion.servings
            : 1.0;

        await _logIngredients(
          batch: batch,
          ingredients: subRecipeVersion.ingredients,
          parentRef: entryRef,
          occurredAt: occurredAt,
          scaleFactor: subScaleFactor,
          recipeRepository: recipeRepository,
          now: now,
        );
      }
    }
  }
}
