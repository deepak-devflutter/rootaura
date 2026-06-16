import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/order.dart';

/// Creates and reads orders in the `orders` collection.
class OrderRepository {
  OrderRepository._();
  static final OrderRepository instance = OrderRepository._();

  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('orders');

  /// Writes a new order and returns its generated id.
  Future<String> place(ShopOrder order) async {
    final ref = await _col.add(order.toMap());
    return ref.id;
  }

  /// Live stream of the signed-in customer's orders, newest first.
  Stream<List<ShopOrder>> ordersForUser(String uid) {
    return _col
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => ShopOrder.fromMap(d.id, d.data())).toList());
  }

  Future<ShopOrder?> byId(String id) async {
    final snap = await _col.doc(id).get();
    return snap.exists ? ShopOrder.fromMap(id, snap.data()!) : null;
  }

  // ---- Admin ----
  Stream<List<ShopOrder>> allOrders() {
    return _col.orderBy('createdAt', descending: true).snapshots().map(
        (s) => s.docs.map((d) => ShopOrder.fromMap(d.id, d.data())).toList());
  }

  Future<void> updateStatus(String orderId, String status) =>
      _col.doc(orderId).update({'status': status});

  Future<void> markPaid(String orderId) =>
      _col.doc(orderId).update({'paymentStatus': PaymentStatus.paid});
}
