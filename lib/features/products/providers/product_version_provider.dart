import 'package:amp/core/models/product_version.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fetches a ProductVersion document from a given DocumentReference.
final productVersionProvider = FutureProvider.autoDispose
    .family<ProductVersion, DocumentReference<ProductVersion>>((
      ref,
      docRef,
    ) async {
      final snapshot = await docRef.get();
      return snapshot.data()!;
    });
