/// Store-wide commerce settings. These are the few values the client needs to
/// fill in to go live. Keep real secrets (payment keys) out of the client —
/// those belong in Cloud Functions in Phase 2.
class ShopConfig {
  ShopConfig._();

  static const String currency = '₹';

  // ---- Delivery ----
  static const double deliveryFee = 49;
  static const double freeDeliveryOver = 499;

  // Tax is treated as included in the displayed price for now (GST inclusive).
  static const double taxPercent = 0;

  // ---- UPI (manual confirmation flow) ----
  // TODO(client): set the real UPI ID and payee name.
  static const String upiId = 'rootaura@upi';
  static const String upiPayeeName = 'Rootaura Naturals';

  // ---- Admin access ----
  // TODO(client): add the admin email(s). These also belong in firestore.rules
  // so the database enforces the same access. UI gating alone is not security.
  static const List<String> adminEmails = <String>[
    // 'owner@example.com',
  ];

  static double deliveryFor(double subtotal) =>
      (subtotal <= 0 || subtotal >= freeDeliveryOver) ? 0 : deliveryFee;

  static String money(double v) => '$currency${v.toStringAsFixed(0)}';
}
