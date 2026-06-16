/// A saved delivery address.
class Address {
  final String id;
  final String label; // Home, Work…
  final String name; // recipient
  final String phone;
  final String line1;
  final String line2;
  final String city;
  final String state;
  final String pincode;

  const Address({
    required this.id,
    required this.label,
    required this.name,
    required this.phone,
    required this.line1,
    this.line2 = '',
    required this.city,
    required this.state,
    required this.pincode,
  });

  String get oneLine {
    final parts = [line1, if (line2.isNotEmpty) line2, city, '$state $pincode'];
    return parts.join(', ');
  }

  factory Address.fromMap(Map<String, dynamic> m) => Address(
        id: m['id'] as String? ?? '',
        label: m['label'] as String? ?? 'Home',
        name: m['name'] as String? ?? '',
        phone: m['phone'] as String? ?? '',
        line1: m['line1'] as String? ?? '',
        line2: m['line2'] as String? ?? '',
        city: m['city'] as String? ?? '',
        state: m['state'] as String? ?? '',
        pincode: m['pincode'] as String? ?? '',
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'label': label,
        'name': name,
        'phone': phone,
        'line1': line1,
        'line2': line2,
        'city': city,
        'state': state,
        'pincode': pincode,
      };
}
