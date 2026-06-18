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
  /// Sorted client-side so it needs no composite index.
  Stream<List<ShopOrder>> ordersForUser(String uid) {
    return _col.where('uid', isEqualTo: uid).snapshots().map((s) {
      final orders =
          s.docs.map((d) => ShopOrder.fromMap(d.id, d.data())).toList();
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    });
  }

  Future<ShopOrder?> byId(String id) async {
    final snap = await _col.doc(id).get();
    return snap.exists ? ShopOrder.fromMap(id, snap.data()!) : null;
  }

  /// Live single-order stream (status, payment, shipment update in real time).
  Stream<ShopOrder?> streamOrder(String id) {
    return _col.doc(id).snapshots().map(
        (d) => d.exists ? ShopOrder.fromMap(id, d.data()!) : null);
  }

  /// Customer-initiated cancellation — only allowed while still 'placed'
  /// (the security rules enforce the same).
  Future<void> cancelByCustomer(String id) =>
      _col.doc(id).update({'status': OrderStatus.cancelled});

  // ---- Admin ----
  /// Newest-first orders for the admin console. Pass [limit] to cap how many
  /// documents are read/streamed — pagination uses a growing limit so Firestore
  /// never reads the entire (unbounded) collection at once.
  Stream<List<ShopOrder>> allOrders({int? limit}) {
    Query<Map<String, dynamic>> q =
        _col.orderBy('createdAt', descending: true);
    if (limit != null) q = q.limit(limit);
    return q.snapshots().map(
        (s) => s.docs.map((d) => ShopOrder.fromMap(d.id, d.data())).toList());
  }

  Future<void> updateStatus(String orderId, String status) =>
      _col.doc(orderId).update({'status': status});

  /// Set payment status to paid or back to pending (rollback).
  Future<void> setPaymentStatus(String orderId, String status) =>
      _col.doc(orderId).update({'paymentStatus': status});

  Future<void> updateShipment(
    String orderId, {
    required String courier,
    required String trackingId,
    String? trackingUrl,
  }) =>
      _col.doc(orderId).update({
        'courier': courier,
        'trackingId': trackingId,
        'trackingUrl': trackingUrl,
      });
}
