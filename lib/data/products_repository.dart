import 'package:cloud_firestore/cloud_firestore.dart';

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

  Future<Product?> bySlug(String slug) async {
    final all = await load();
    for (final p in all) {
      if (p.slug == slug || p.id == slug) return p;
    }
    return null;
  }
}
