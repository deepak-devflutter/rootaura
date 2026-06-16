import 'product.dart';

/// A line in the cart. Stores a price snapshot so the cart total is stable even
/// if catalogue prices change while items sit in the cart, plus the available
/// [stock] so quantity can never exceed what's in stock.
class CartItem {
  final String productId;
  final String name;
  final String image;
  final double price;
  final int qty;
  final int stock;

  const CartItem({
    required this.productId,
    required this.name,
    required this.image,
    required this.price,
    required this.qty,
    this.stock = 99,
  });

  double get lineTotal => price * qty;
  bool get atMax => qty >= stock;

  CartItem copyWith({int? qty, int? stock}) => CartItem(
        productId: productId,
        name: name,
        image: image,
        price: price,
        qty: qty ?? this.qty,
        stock: stock ?? this.stock,
      );

  factory CartItem.fromProduct(Product p, {int qty = 1}) => CartItem(
        productId: p.id,
        name: p.name ?? '',
        image: p.firstImage ?? '',
        price: p.price,
        qty: qty,
        stock: p.stock,
      );

  factory CartItem.fromMap(Map<String, dynamic> m) => CartItem(
        productId: m['productId'] as String? ?? '',
        name: m['name'] as String? ?? '',
        image: m['image'] as String? ?? '',
        price: (m['price'] as num?)?.toDouble() ?? 0,
        qty: (m['qty'] as num?)?.toInt() ?? 1,
        stock: (m['stock'] as num?)?.toInt() ?? 99,
      );

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'name': name,
        'image': image,
        'price': price,
        'qty': qty,
        'stock': stock,
      };
}
