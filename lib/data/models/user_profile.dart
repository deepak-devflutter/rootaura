import 'package:cloud_firestore/cloud_firestore.dart';

import 'address.dart';

/// The customer record stored at `users/{uid}`.
///
/// Fields split into two groups:
/// - **Customer-editable**: name, email, phone, addresses, defaultAddressId
///   (written via [toMap], which deliberately omits the admin fields).
/// - **Admin-only**: role, discountPercent, blocked, adminNotes — changed only
///   through dedicated admin methods and protected by security rules.
class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role; // 'customer' | 'admin'
  final List<Address> addresses;
  final String? defaultAddressId;

  // Admin-managed
  final double discountPercent; // 0–100, applied to order subtotal
  final bool blocked;
  final String adminNotes;
  final DateTime? createdAt;

  const UserProfile({
    required this.uid,
    this.name = '',
    this.email = '',
    this.phone = '',
    this.role = 'customer',
    this.addresses = const [],
    this.defaultAddressId,
    this.discountPercent = 0,
    this.blocked = false,
    this.adminNotes = '',
    this.createdAt,
  });

  bool get isAdmin => role == 'admin';
  bool get hasDiscount => discountPercent > 0;

  Address? get defaultAddress {
    if (addresses.isEmpty) return null;
    for (final a in addresses) {
      if (a.id == defaultAddressId) return a;
    }
    return addresses.first;
  }

  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    List<Address>? addresses,
    String? defaultAddressId,
  }) {
    return UserProfile(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role,
      addresses: addresses ?? this.addresses,
      defaultAddressId: defaultAddressId ?? this.defaultAddressId,
      discountPercent: discountPercent,
      blocked: blocked,
      adminNotes: adminNotes,
      createdAt: createdAt,
    );
  }

  factory UserProfile.fromMap(String uid, Map<String, dynamic> m) {
    final ts = m['createdAt'];
    return UserProfile(
      uid: uid,
      name: m['name'] as String? ?? '',
      email: m['email'] as String? ?? '',
      phone: m['phone'] as String? ?? '',
      role: m['role'] as String? ?? 'customer',
      defaultAddressId: m['defaultAddressId'] as String?,
      addresses: (m['addresses'] as List<dynamic>? ?? const [])
          .map((e) => Address.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      discountPercent: (m['discountPercent'] as num?)?.toDouble() ?? 0,
      blocked: m['blocked'] as bool? ?? false,
      adminNotes: m['adminNotes'] as String? ?? '',
      createdAt: ts is Timestamp ? ts.toDate() : null,
    );
  }

  /// Only the customer-writable profile fields. Admin fields (role, discount,
  /// blocked, adminNotes) are intentionally excluded so a customer's own save
  /// can never change them.
  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'phone': phone,
        'defaultAddressId': defaultAddressId,
        'addresses': addresses.map((a) => a.toMap()).toList(),
      };
}
