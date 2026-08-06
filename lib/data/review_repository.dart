import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/review.dart';

/// Reads and writes product reviews in the `reviews` collection.
class ReviewRepository {
  ReviewRepository._();
  static final ReviewRepository instance = ReviewRepository._();

  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('reviews');

  void _sortNewest(List<Review> list) => list.sort((a, b) =>
      (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));

  /// Live reviews for a product (newest first), sorted client-side so no
  /// composite index is needed.
  Stream<List<Review>> forProduct(String productId) {
    return _col.where('productId', isEqualTo: productId).snapshots().map((s) {
      final list =
          s.docs.map((d) => Review.fromMap(d.id, d.data())).toList();
      _sortNewest(list);
      return list;
    });
  }

  /// Live reviews written by a specific user (for their profile / admin view).
  Stream<List<Review>> forUser(String uid) {
    return _col.where('uid', isEqualTo: uid).snapshots().map((s) {
      final list =
          s.docs.map((d) => Review.fromMap(d.id, d.data())).toList();
      _sortNewest(list);
      return list;
    });
  }

  /// All reviews for the admin moderation console (newest first, capped).
  Stream<List<Review>> streamAll({int? limit}) {
    Query<Map<String, dynamic>> q =
        _col.orderBy('createdAt', descending: true);
    if (limit != null) q = q.limit(limit);
    return q.snapshots().map(
        (s) => s.docs.map((d) => Review.fromMap(d.id, d.data())).toList());
  }

  /// Fetch a single review by its document id (used to prefill the editor).
  Future<Review?> byId(String id) async {
    final snap = await _col.doc(id).get();
    return snap.exists ? Review.fromMap(snap.id, snap.data()!) : null;
  }

  /// Creates or updates the customer's review (upsert; admin fields untouched).
  Future<void> submit(Review review) =>
      _col.doc(review.id).set(review.toCustomerMap(), SetOptions(merge: true));

  Future<void> deleteMine(String id) => _col.doc(id).delete();

  // ---- Admin moderation ----
  Future<void> setHidden(String id, bool hidden) =>
      _col.doc(id).update({'hidden': hidden});

  Future<void> reply(String id, String text) => _col.doc(id).update({
        'adminReply': text,
        'adminReplyAt': FieldValue.serverTimestamp(),
      });

  Future<void> clearReply(String id) => _col.doc(id).update({
        'adminReply': FieldValue.delete(),
        'adminReplyAt': FieldValue.delete(),
      });
}
