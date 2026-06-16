/// A freeze-dried fruit product. Source of truth is the Firestore `products`
/// collection (it carries price and stock); marketing copy/images come along
/// for the ride.
class Product {
  final String id;
  final String? name;
  final String? description;
  final String? benefit;
  final String? purchaseUrl;
  final List<String> imageUrls;
  final double price; // selling price (₹)
  final double mrp; // strike-through price (₹), 0 if none
  final int stock; // available units
  final bool active;

  const Product({
    this.id = '',
    this.name,
    this.description,
    this.benefit,
    this.purchaseUrl,
    this.imageUrls = const [],
    this.price = 0,
    this.mrp = 0,
    this.stock = 0,
    this.active = true,
  });

  String? get firstImage => imageUrls.isNotEmpty ? imageUrls.first : null;

  bool get inStock => stock > 0;
  bool get hasDiscount => mrp > price && price > 0;
  int get discountPercent =>
      hasDiscount ? (((mrp - price) / mrp) * 100).round() : 0;

  /// Slug used for detail-page routing; falls back to the doc id.
  String get slug {
    final base = (name ?? id).toLowerCase();
    final s = base
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'(^-|-$)'), '');
    return s.isEmpty ? id : s;
  }

  factory Product.fromMap(String id, Map<String, dynamic> m) {
    return Product(
      id: id,
      name: m['name'] as String?,
      description: m['description'] as String?,
      benefit: m['benefit'] as String?,
      purchaseUrl: m['purchaseUrl'] as String?,
      imageUrls: List<String>.from(m['imageUrls'] ?? const []),
      price: (m['price'] as num?)?.toDouble() ?? 0,
      mrp: (m['mrp'] as num?)?.toDouble() ?? 0,
      stock: (m['stock'] as num?)?.toInt() ?? 0,
      active: m['active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'description': description,
        'benefit': benefit,
        'purchaseUrl': purchaseUrl,
        'imageUrls': imageUrls,
        'price': price,
        'mrp': mrp,
        'stock': stock,
        'active': active,
      };
}
