import 'package:cloud_firestore/cloud_firestore.dart';

/// One-time product seed for the Firestore `products` collection.
/// Copy/benefit/images come from the client; prices are PLACEHOLDERS — update
/// them in the admin dashboard or Firestore console before going live.
const String _gh =
    'https://raw.githubusercontent.com/deepak-devflutter/rootaura/main';

const List<Map<String, dynamic>> kSeedProducts = [
  {
    'id': 'mango',
    'name': 'Mango Freeze-Dried Chunks',
    'description': 'Sun-ripened mango chunks, gently freeze-dried',
    'benefit': 'Locks in natural sweetness, fiber, and daily vitamins',
    'imageUrls': ['$_gh/Mango%20Freeze-Dried%20Chunks.png'],
    'price': 249.0,
    'mrp': 299.0,
    'stock': 50,
    'active': true,
  },
  {
    'id': 'strawberry',
    'name': 'Strawberry Freeze-Dried Chunks',
    'description': 'Bright, juicy strawberries preserved at peak freshness',
    'benefit': 'Naturally rich in antioxidants for skin and vitality',
    'imageUrls': ['$_gh/Strawberry%20Freeze-Dried%20Chunks.png'],
    'price': 279.0,
    'mrp': 329.0,
    'stock': 50,
    'active': true,
  },
  {
    'id': 'black-jamun',
    'name': 'Black Jamun Freeze-Dried Chunks',
    'description': 'Traditional Indian superfruit, freeze-dried naturally',
    'benefit': 'Supports blood sugar balance and digestive wellness',
    'imageUrls': ['$_gh/Black%20Jamun%20Freeze-Dried%20Chunks.png'],
    'price': 269.0,
    'mrp': 319.0,
    'stock': 50,
    'active': true,
  },
  {
    'id': 'kiwi',
    'name': 'Kiwi Freeze-Dried Chunks',
    'description': 'Zesty kiwi chunks with real fruit crunch',
    'benefit': 'High in vitamin C to support immunity and digestion',
    'imageUrls': ['$_gh/Kiwi%20Freeze-Dried%20Chunks.png'],
    'price': 259.0,
    'mrp': 309.0,
    'stock': 50,
    'active': true,
  },
  {
    'id': 'blueberry',
    'name': 'Blueberry Freeze-Dried Chunks',
    'description': 'Premium blueberries with intense natural flavor',
    'benefit': 'Packed with antioxidants for brain and cell health',
    'imageUrls': ['$_gh/Blueberry%20Freeze-Dried%20Chunks.png'],
    'price': 299.0,
    'mrp': 349.0,
    'stock': 50,
    'active': true,
  },
  {
    'id': 'chikoo',
    'name': 'Chikoo Freeze-Dried Chunks',
    'description': 'Premium Chikoo with intense natural flavor',
    'benefit': 'Naturally sweet energy with a delicious crunch',
    'imageUrls': ['$_gh/Chikoo%20Freeze-Dried%20Chunks.png'],
    'price': 249.0,
    'mrp': 299.0,
    'stock': 50,
    'active': true,
  },
];

/// Writes the seed products (merging, so it won't wipe price edits made later).
Future<void> seedProducts() async {
  final col = FirebaseFirestore.instance.collection('products');
  final batch = FirebaseFirestore.instance.batch();
  for (final p in kSeedProducts) {
    final data = Map<String, dynamic>.from(p)..remove('id');
    batch.set(col.doc(p['id'] as String), data, SetOptions(merge: true));
  }
  await batch.commit();
}
