import 'package:cloud_firestore/cloud_firestore.dart';

import 'address.dart';
import 'cart_item.dart';

/// Order lifecycle states, in order. Kept as plain strings for simplicity.
class OrderStatus {
  OrderStatus._();
  static const placed = 'placed';
  static const confirmed = 'confirmed';
  static const packed = 'packed';
  static const shipped = 'shipped';
  static const delivered = 'delivered';
  static const cancelled = 'cancelled';

  static const flow = [placed, confirmed, packed, shipped, delivered];

  static String label(String s) =>
      s.isEmpty ? '' : s[0].toUpperCase() + s.substring(1);
}

class PaymentMethod {
  PaymentMethod._();
  static const cod = 'cod';
  static const upi = 'upi';
}

class PaymentStatus {
  PaymentStatus._();
  static const pending = 'pending';
  static const paid = 'paid';
}

class ShopOrder {
  final String id;
  final String uid;
  final String customerName;
  final String customerPhone;
  final List<CartItem> items;
  final Address address;
  final double subtotal;
  final double delivery;
  final double tax;
  final double discountPercent;
  final double discountAmount;
  final double total;
  final String paymentMethod;
  final String paymentStatus;
  final String status;
  final String? upiRef;
  final String? note; // customer's special request
  final DateTime createdAt;

  // Shipment (set by admin once dispatched)
  final String? courier; // e.g. "Blue Dart"
  final String? trackingId;
  final String? trackingUrl;

  const ShopOrder({
    required this.id,
    required this.uid,
    required this.customerName,
    required this.customerPhone,
    required this.items,
    required this.address,
    required this.subtotal,
    required this.delivery,
    required this.tax,
    required this.total,
    this.discountPercent = 0,
    this.discountAmount = 0,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.status,
    required this.createdAt,
    this.upiRef,
    this.note,
    this.courier,
    this.trackingId,
    this.trackingUrl,
  });

  int get itemCount => items.fold(0, (n, i) => n + i.qty);

  bool get hasShipment =>
      (courier ?? '').isNotEmpty && (trackingId ?? '').isNotEmpty;

  factory ShopOrder.fromMap(String id, Map<String, dynamic> m) {
    final ts = m['createdAt'];
    return ShopOrder(
      id: id,
      uid: m['uid'] as String? ?? '',
      customerName: m['customerName'] as String? ?? '',
      customerPhone: m['customerPhone'] as String? ?? '',
      items: (m['items'] as List<dynamic>? ?? const [])
          .map((e) => CartItem.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      address: Address.fromMap(
          Map<String, dynamic>.from(m['address'] as Map? ?? const {})),
      subtotal: (m['subtotal'] as num?)?.toDouble() ?? 0,
      delivery: (m['delivery'] as num?)?.toDouble() ?? 0,
      tax: (m['tax'] as num?)?.toDouble() ?? 0,
      discountPercent: (m['discountPercent'] as num?)?.toDouble() ?? 0,
      discountAmount: (m['discountAmount'] as num?)?.toDouble() ?? 0,
      total: (m['total'] as num?)?.toDouble() ?? 0,
      paymentMethod: m['paymentMethod'] as String? ?? PaymentMethod.cod,
      paymentStatus: m['paymentStatus'] as String? ?? PaymentStatus.pending,
      status: m['status'] as String? ?? OrderStatus.placed,
      upiRef: m['upiRef'] as String?,
      note: m['note'] as String?,
      courier: m['courier'] as String?,
      trackingId: m['trackingId'] as String?,
      trackingUrl: m['trackingUrl'] as String?,
      createdAt: ts is Timestamp ? ts.toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'items': items.map((i) => i.toMap()).toList(),
        'address': address.toMap(),
        'subtotal': subtotal,
        'delivery': delivery,
        'tax': tax,
        'discountPercent': discountPercent,
        'discountAmount': discountAmount,
        'total': total,
        'paymentMethod': paymentMethod,
        'paymentStatus': paymentStatus,
        'status': status,
        'upiRef': upiRef,
        'note': note,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
