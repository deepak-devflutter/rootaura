import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/cart_item.dart';
import 'models/product.dart';

/// Reads the product catalogue from Firestore `products`. Results are cached
/// for the session so the home grid, listing page and detail page share a
/// single fetch.
class ProductsRepository {
  ProductsRepository._internal();
  static final ProductsRepository instance = ProductsRepository._internal();

  final _col = FirebaseFirestore.instance.collection('products');
  Future<List<Product>>? _cache;

  Future<List<Product>> load({bool forceRefresh = false}) {
    if (forceRefresh) _cache = null;
    return _cache ??= _fetch();
  }

  Future<List<Product>> _fetch() async {
    final snap = await _col.where('active', isEqualTo: true).get();
    final list =
        snap.docs.map((d) => Product.fromMap(d.id, d.data())).toList();
    // Stable ordering by name keeps the grid from reshuffling between loads.
    list.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
    return list;
  }

  /// Live stream of active products for the storefront, so price/stock and
  /// out-of-stock state reflect in real time. Sorted client-side.
  Stream<List<Product>> streamActive() {
    return _col.where('active', isEqualTo: true).snapshots().map((s) {
      final list =
          s.docs.map((d) => Product.fromMap(d.id, d.data())).toList();
      list.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
      return list;
    });
  }

  Future<Product?> bySlug(String slug) async {
    final all = await load();
    for (final p in all) {
      if (p.slug == slug || p.id == slug) return p;
    }
    return null;
  }

  // ---- Admin CRUD ----

  /// Live stream of ALL products (including inactive) for the admin panel.
  Stream<List<Product>> streamAll() {
    return _col.orderBy('name').snapshots().map(
        (s) => s.docs.map((d) => Product.fromMap(d.id, d.data())).toList());
  }

  /// A fresh random document id — used to namespace image uploads before the
  /// product doc is written.
  String newId() => _col.doc().id;

  /// Creates a product with a random Firestore-generated id.
  Future<String> create(Product product) async {
    final ref = await _col.add(product.toMap());
    _cache = null; // invalidate so the storefront refetches
    return ref.id;
  }

  Future<void> update(String id, Product product) async {
    await _col.doc(id).set(product.toMap(), SetOptions(merge: true));
    _cache = null;
  }

  Future<void> delete(String id) async {
    await _col.doc(id).delete();
    _cache = null;
  }

  /// Atomically reduces stock for each ordered item (never below 0). Runs in a
  /// transaction so concurrent orders can't oversell. Called after an order is
  /// placed; failures are non-fatal (manual reconciliation as backstop).
  Future<void> decrementStock(List<CartItem> items) async {
    final db = FirebaseFirestore.instance;
    await db.runTransaction((txn) async {
      final refs = items.map((i) => _col.doc(i.productId)).toList();
      final snaps = <DocumentSnapshot<Map<String, dynamic>>>[];
      for (final r in refs) {
        snaps.add(await txn.get(r));
      }
      for (var i = 0; i < items.length; i++) {
        final snap = snaps[i];
        if (!snap.exists) continue;
        final current = (snap.data()?['stock'] as num?)?.toInt() ?? 0;
        txn.update(refs[i], {'stock': max(0, current - items[i].qty)});
      }
    });
    _cache = null;
  }
}
