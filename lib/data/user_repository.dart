import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'models/address.dart';
import 'models/user_profile.dart';

/// Reads and writes the `users/{uid}` profile document.
class UserRepository {
  UserRepository._();
  static final UserRepository instance = UserRepository._();

  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('users');

  /// Creates the profile doc on first sign-in (never overwrites an existing
  /// one, so `role` and saved data are preserved).
  Future<UserProfile> ensureProfile(User user) async {
    final ref = _col.doc(user.uid);
    final snap = await ref.get();
    if (snap.exists) {
      return UserProfile.fromMap(user.uid, snap.data()!);
    }
    final profile = UserProfile(
      uid: user.uid,
      name: user.displayName ?? '',
      email: user.email ?? '',
      phone: user.phoneNumber ?? '',
    );
    await ref.set({
      ...profile.toMap(),
      'role': 'customer',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return profile;
  }

  Future<UserProfile?> fetch(String uid) async {
    final snap = await _col.doc(uid).get();
    return snap.exists ? UserProfile.fromMap(uid, snap.data()!) : null;
  }

  Future<void> save(UserProfile profile) =>
      _col.doc(profile.uid).set(profile.toMap(), SetOptions(merge: true));

  Future<UserProfile> upsertAddress(
      UserProfile profile, Address address) async {
    final list = [...profile.addresses];
    final i = list.indexWhere((a) => a.id == address.id);
    if (i >= 0) {
      list[i] = address;
    } else {
      list.add(address);
    }
    final updated = profile.copyWith(
      addresses: list,
      defaultAddressId: profile.defaultAddressId ?? address.id,
    );
    await save(updated);
    return updated;
  }

  Future<UserProfile> removeAddress(UserProfile profile, String id) async {
    final list = profile.addresses.where((a) => a.id != id).toList();
    final updated = profile.copyWith(
      addresses: list,
      defaultAddressId: profile.defaultAddressId == id
          ? (list.isNotEmpty ? list.first.id : null)
          : profile.defaultAddressId,
    );
    await save(updated);
    return updated;
  }

  Future<UserProfile> setDefaultAddress(
      UserProfile profile, String id) async {
    final updated = profile.copyWith(defaultAddressId: id);
    await save(updated);
    return updated;
  }

  // ---- Admin-only operations (guarded by security rules) ----

  /// Live stream of all customers for the admin panel, newest first.
  Stream<List<UserProfile>> streamAll() {
    return _col.snapshots().map((s) {
      final users =
          s.docs.map((d) => UserProfile.fromMap(d.id, d.data())).toList();
      users.sort((a, b) => (b.createdAt ?? DateTime(0))
          .compareTo(a.createdAt ?? DateTime(0)));
      return users;
    });
  }

  /// Live single-customer stream (reflects admin edits in real time).
  Stream<UserProfile?> streamUser(String uid) {
    return _col.doc(uid).snapshots().map(
        (d) => d.exists ? UserProfile.fromMap(uid, d.data()!) : null);
  }

  Future<void> setRole(String uid, String role) =>
      _col.doc(uid).update({'role': role});

  Future<void> setDiscount(String uid, double percent) =>
      _col.doc(uid).update({'discountPercent': percent.clamp(0, 100)});

  Future<void> setBlocked(String uid, bool blocked) =>
      _col.doc(uid).update({'blocked': blocked});

  Future<void> setNotes(String uid, String notes) =>
      _col.doc(uid).update({'adminNotes': notes});
}
