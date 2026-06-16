import 'address.dart';

/// The customer record stored at `users/{uid}`.
class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role; // 'customer' | 'admin'
  final List<Address> addresses;
  final String? defaultAddressId;

  const UserProfile({
    required this.uid,
    this.name = '',
    this.email = '',
    this.phone = '',
    this.role = 'customer',
    this.addresses = const [],
    this.defaultAddressId,
  });

  bool get isAdmin => role == 'admin';

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
    );
  }

  factory UserProfile.fromMap(String uid, Map<String, dynamic> m) {
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
    );
  }

  /// Only the writable profile fields (role is never client-writable).
  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'phone': phone,
        'defaultAddressId': defaultAddressId,
        'addresses': addresses.map((a) => a.toMap()).toList(),
      };
}
