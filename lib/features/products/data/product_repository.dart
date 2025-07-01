import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:amp/core/models/product.dart';
import 'package:amp/core/models/product_version.dart';
import 'package:amp/core/models/nutrition.dart';
import 'package:amp/core/models/unit.dart';

class ProductRepository {
  final FirebaseFirestore _firestore;
  final String _uid;

  ProductRepository({required FirebaseFirestore firestore, required String uid})
    : _firestore = firestore,
      _uid = uid;

  CollectionReference<Product> get _productsRef => _firestore
      .collection('users')
      .doc(_uid)
      .collection('products')
      .withConverter<Product>(
        fromFirestore: (snapshot, _) => Product.fromJson(snapshot.data()!),
        toFirestore: (product, _) => product.toJson(),
      );

  CollectionReference<ProductVersion> _productVersionsRef(String productId) =>
      _productsRef
          .doc(productId)
          .collection('product_versions')
          .withConverter<ProductVersion>(
            fromFirestore: (snapshot, _) =>
                ProductVersion.fromJson(snapshot.data()!),
            toFirestore: (productVersion, _) => productVersion.toJson(),
          );

  Future<void> createProduct({
    required String name,
    required Nutrition nutrition,
    required List<Unit> units,
  }) async {
    final now = Timestamp.now();
    final batch = _firestore.batch();

    // 1. Create the parent Product document reference
    final productRef = _productsRef.doc();

    // 2. Define the initial ProductVersion
    final initialVersion = ProductVersion(
      createdBy: _uid,
      createdAt: now,
      updatedAt: now,
      version: 1,
      nutrition: nutrition,
      units: units,
    );

    // 3. Define the parent Product
    final product = Product(
      id: productRef.id,
      name: name,
      createdBy: _uid,
      createdAt: now,
      updatedAt: now,
      latestVersion: 1,
    );

    // 4. Add both operations to the batch
    batch.set(productRef, product);
    batch.set(_productVersionsRef(productRef.id).doc(), initialVersion);

    // 5. Commit the batch
    await batch.commit();
  }

  Stream<List<Product>> getProductsStream() {
    return _productsRef.orderBy('name').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final product = doc.data();
        return product.copyWith(id: doc.id);
      }).toList();
    });
  }
}
