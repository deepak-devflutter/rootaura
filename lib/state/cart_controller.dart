import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../data/models/cart_item.dart';
import '../data/models/product.dart';

/// Shopping cart state. Items live in memory and, for signed-in users, are
/// mirrored to `carts/{uid}` so the cart survives a page reload.
class CartController extends ChangeNotifier {
  CartController._() {
    // Load/clear the cart as the user signs in or out.
    FirebaseAuth.instance.authStateChanges().listen(_onUser);
  }
  static final CartController instance = CartController._();

  final List<CartItem> _items = [];
  String? _uid;

  List<CartItem> get items => List.unmodifiable(_items);
  bool get isEmpty => _items.isEmpty;
  int get count => _items.fold(0, (n, i) => n + i.qty);
  double get subtotal => _items.fold(0.0, (s, i) => s + i.lineTotal);

  int qtyOf(String productId) {
    for (final i in _items) {
      if (i.productId == productId) return i.qty;
    }
    return 0;
  }

  Future<void> _onUser(User? user) async {
    _uid = user?.uid;
    if (user == null) {
      _items.clear();
      notifyListeners();
      return;
    }
    await _loadFromFirestore();
  }

  Future<void> _loadFromFirestore() async {
    final uid = _uid;
    if (uid == null) return;
    final doc =
        await FirebaseFirestore.instance.collection('carts').doc(uid).get();
    _items
      ..clear()
      ..addAll(((doc.data()?['items'] as List<dynamic>?) ?? const [])
          .map((e) => CartItem.fromMap(Map<String, dynamic>.from(e as Map))));
    notifyListeners();
  }

  Future<void> _persist() async {
    final uid = _uid;
    if (uid == null) return;
    await FirebaseFirestore.instance.collection('carts').doc(uid).set({
      'items': _items.map((i) => i.toMap()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Adds [qty] of [product], never exceeding its available stock.
  /// Returns true if the cart actually changed; false if it was already at the
  /// stock limit (so callers can warn the user).
  bool add(Product product, {int qty = 1}) {
    if (product.stock <= 0) return false;
    final i = _items.indexWhere((e) => e.productId == product.id);
    final current = i >= 0 ? _items[i].qty : 0;
    final newQty = (current + qty).clamp(1, product.stock);
    if (newQty == current) return false; // already at stock cap

    if (i >= 0) {
      _items[i] = _items[i].copyWith(qty: newQty, stock: product.stock);
    } else {
      _items.add(CartItem.fromProduct(product, qty: newQty));
    }
    notifyListeners();
    _persist();
    return true;
  }

  void setQty(String productId, int qty) {
    final i = _items.indexWhere((e) => e.productId == productId);
    if (i < 0) return;
    if (qty <= 0) {
      _items.removeAt(i);
    } else {
      _items[i] = _items[i].copyWith(qty: qty.clamp(1, _items[i].stock));
    }
    notifyListeners();
    _persist();
  }

  void remove(String productId) => setQty(productId, 0);

  void clear() {
    _items.clear();
    notifyListeners();
    _persist();
  }
}
