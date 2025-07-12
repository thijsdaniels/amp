import 'package:amp/core/models/nutrition.dart';
import 'package:amp/core/models/product.dart';
import 'package:amp/core/models/product_version.dart';
import 'package:amp/core/models/unit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
        fromFirestore: (snapshot, _) => Product.fromSnapshot(snapshot),
        toFirestore: (product, _) => product.toMap(),
      );

  CollectionReference<ProductVersion> _productVersionsRef(String productId) =>
      _productsRef
          .doc(productId)
          .collection('product_versions')
          .withConverter<ProductVersion>(
            fromFirestore: (snapshot, _) =>
                ProductVersion.fromSnapshot(snapshot),
            toFirestore: (productVersion, _) => productVersion.toMap(),
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

  Future<void> createNewProductVersion({
    required String productId,
    required String name,
    required Nutrition nutrition,
    required List<Unit> units,
  }) async {
    final originalProduct = await getProduct(productId);
    final now = Timestamp.now();
    final newVersionNumber = originalProduct.latestVersion + 1;

    final updatedProduct = originalProduct.copyWith(
      name: name,
      latestVersion: newVersionNumber,
      updatedAt: now,
    );

    final newVersion = ProductVersion(
      createdBy: _uid,
      createdAt: now,
      updatedAt: now,
      version: newVersionNumber,
      nutrition: nutrition,
      units: units,
    );

    await _updateProduct(product: updatedProduct, version: newVersion);
  }

  Future<void> _updateProduct({
    required Product product,
    required ProductVersion version,
  }) async {
    assert(product.id != null, 'Product ID cannot be null when updating.');

    final batch = _firestore.batch();

    final productRef = _productsRef.doc(product.id);
    final versionRef = _productVersionsRef(product.id!).doc();

    batch.update(productRef, product.toMap());
    batch.set(versionRef, version);

    await batch.commit();
  }

  Stream<List<Product>> getProductsStream() {
    return _productsRef.orderBy('name').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  Future<Product> getProduct(String productId) async {
    final doc = await _productsRef.doc(productId).get();
    return doc.data()!;
  }

  Stream<Product> getProductStream(String productId) {
    return _productsRef
        .doc(productId)
        .snapshots()
        .map((snapshot) => snapshot.data()!);
  }

  Future<ProductVersion> getLatestProductVersion(String productId) async {
    final snapshot = await _productVersionsRef(
      productId,
    ).orderBy('version', descending: true).limit(1).get();
    final doc = snapshot.docs.first;
    return doc.data();
  }

  DocumentReference<ProductVersion> getProductVersionRef(
    String productId,
    String productVersionId,
  ) {
    return _productVersionsRef(productId).doc(productVersionId);
  }
}
