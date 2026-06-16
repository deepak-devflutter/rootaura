import 'product.dart';

/// A line in the cart. Stores a price snapshot so the cart total is stable even
/// if catalogue prices change while items sit in the cart.
class CartItem {
  final String productId;
  final String name;
  final String image;
  final double price;
  final int qty;

  const CartItem({
    required this.productId,
    required this.name,
    required this.image,
    required this.price,
    required this.qty,
  });

  double get lineTotal => price * qty;

  CartItem copyWith({int? qty}) => CartItem(
        productId: productId,
        name: name,
        image: image,
        price: price,
        qty: qty ?? this.qty,
      );

  factory CartItem.fromProduct(Product p, {int qty = 1}) => CartItem(
        productId: p.id,
        name: p.name ?? '',
        image: p.firstImage ?? '',
        price: p.price,
        qty: qty,
      );

  factory CartItem.fromMap(Map<String, dynamic> m) => CartItem(
        productId: m['productId'] as String? ?? '',
        name: m['name'] as String? ?? '',
        image: m['image'] as String? ?? '',
        price: (m['price'] as num?)?.toDouble() ?? 0,
        qty: (m['qty'] as num?)?.toInt() ?? 1,
      );

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'name': name,
        'image': image,
        'price': price,
        'qty': qty,
      };
}
