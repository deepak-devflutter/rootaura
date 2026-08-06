import 'package:cloud_firestore/cloud_firestore.dart';

/// A customer product review. Document id is deterministic
/// (`<productId>__<uid>`) so each customer has at most one review per product
/// and can edit it in place.
class Review {
  final String id;
  final String productId;
  final String productName; // denormalised for admin/profile lists
  final String orderId; // the order this review is tied to (audit trail)
  final String uid;
  final String userName;
  final int rating; // 1..5
  final String text;
  final DateTime? createdAt;

  // Admin-managed
  final bool hidden;
  final String? adminReply;
  final DateTime? adminReplyAt;

  const Review({
    required this.id,
    required this.productId,
    this.productName = '',
    this.orderId = '',
    required this.uid,
    this.userName = '',
    required this.rating,
    this.text = '',
    this.createdAt,
    this.hidden = false,
    this.adminReply,
    this.adminReplyAt,
  });

  /// One review per product per order, so buying the same product in multiple
  /// orders yields a separate, independently editable review each time.
  static String docId(String orderId, String productId) =>
      '${orderId}__$productId';

  bool get hasReply => (adminReply ?? '').trim().isNotEmpty;

  factory Review.fromMap(String id, Map<String, dynamic> m) {
    DateTime? ts(dynamic v) => v is Timestamp ? v.toDate() : null;
    return Review(
      id: id,
      productId: m['productId'] as String? ?? '',
      productName: m['productName'] as String? ?? '',
      orderId: m['orderId'] as String? ?? '',
      uid: m['uid'] as String? ?? '',
      userName: m['userName'] as String? ?? '',
      rating: (m['rating'] as num?)?.toInt() ?? 0,
      text: m['text'] as String? ?? '',
      createdAt: ts(m['createdAt']),
      hidden: m['hidden'] as bool? ?? false,
      adminReply: m['adminReply'] as String?,
      adminReplyAt: ts(m['adminReplyAt']),
    );
  }

  /// Only the customer-writable fields — admin fields (`hidden`, `adminReply`)
  /// are intentionally omitted so a customer's save never changes them.
  Map<String, dynamic> toCustomerMap() => {
        'productId': productId,
        'productName': productName,
        'orderId': orderId,
        'uid': uid,
        'userName': userName,
        'rating': rating,
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
