import 'package:flutter/material.dart';

/// Static, non-product content for the marketing site. Kept as plain data so
/// sections stay declarative and copy is easy to tweak.

class InfoItem {
  final IconData icon;
  final String title;
  final String subtitle;

  /// Product photo shown on the "Why us" card (overflows top-right). Swap per
  /// item later; defaults to the shared placeholder.
  final String image;

  const InfoItem(
    this.icon,
    this.title,
    this.subtitle, {
    this.image = 'assets/whyus/Perfect On-the-Go.webp',
  });
}

class UsageItem {
  final String emoji;
  final IconData icon;
  final String title;
  final String description;

  /// Background dish photo (asset path) — swap per item in assets/images.
  final String image;

  const UsageItem(
    this.emoji,
    this.icon,
    this.title,
    this.description, {
    this.image = 'assets/images/basket.webp',
  });
}

class RecipeItem {
  final String emoji;
  final String title;
  final List<String> ingredients;

  /// Recipe photo (asset path) — swap per recipe in assets/images.
  final String image;

  const RecipeItem(
    this.emoji,
    this.title,
    this.ingredients, {
    this.image = 'assets/images/basket.webp',
  });
}

class Testimonial {
  final String quote;
  final String name;
  final String role;
  final int rating;

  const Testimonial(this.quote, this.name, this.role, this.rating);
}

class NavLink {
  final String label;
  final String anchor; // section key on the home page
  const NavLink(this.label, this.anchor);
}

class AppContent {
  AppContent._();

  // ---- Why-choose pillars ----
  static const List<InfoItem> whyChoose = [
    InfoItem(
      Icons.ac_unit_rounded,
      'Freeze-Dried Technology',
      'Preserves natural flavour & nutrients at low temperature.',
      image: 'assets/whyus/Freeze-Dried Technology.webp'
    ),
    InfoItem(
      Icons.spa_rounded,
      'No Preservatives',
      'Made from real fruits with nothing artificial added.',
        image: 'assets/whyus/No Preservatives.webp'
    ),
    InfoItem(
      Icons.schedule_rounded,
      'Long Shelf Life',
      'Stays fresh for months at room temperature.',
        image: 'assets/whyus/Long Shelf Life.webp'

    ),
    InfoItem(
      Icons.flight_takeoff_rounded,
      'Perfect On-the-Go',
      'Lightweight, convenient and built for a busy lifestyle.',
    ),
    InfoItem(
      Icons.verified_rounded,
      'Hygienic Processing',
      'Crafted under strict, hygienic quality standards.',
        image: 'assets/whyus/Hygienic Processing.webp'

    ),
    InfoItem(
      Icons.favorite_rounded,
      'Real Fruit. Real Taste.',
      'Crunchy, delicious and naturally satisfying.',
        image: 'assets/whyus/Real Fruit Real Taste.webp'

    ),
  ];

  // ---- Ways to enjoy ---- (image paths are temporary; swap per item later)
  static const List<UsageItem> usages = [
    UsageItem(
      '🥣',
      Icons.breakfast_dining_rounded,
      'Yogurt & Parfaits',
      'Add a crunchy burst of fruit to yogurt, parfaits and breakfast bowls.',
      image: 'assets/images/Yogurt & Parfaits.webp',
    ),
    UsageItem(
      '🥤',
      Icons.local_cafe_rounded,
      'Smoothies & Shakes',
      'Blend with milk, yogurt or smoothies for natural fruit flavour.',
      image: 'assets/images/Smoothies & Shakes.webp',
    ),
    UsageItem(
      '🍓',
      Icons.lunch_dining_rounded,
      'Healthy Snacking',
      'Enjoy straight from the pack for a convenient, guilt-free snack.',
      image: 'assets/images/Healthy Snacking.webp',
    ),
    UsageItem(
      '🥗',
      Icons.rice_bowl_rounded,
      'Fruit Bowls & Salads',
      'Add texture, colour and sweetness to fruit bowls and salads.',
      image: 'assets/images/Fruit Bowls & Salads.webp',
    ),
    UsageItem(
      '🍰',
      Icons.cake_rounded,
      'Desserts & Toppings',
      'Perfect for cakes, ice creams, pancakes, granola and baked treats.',
      image: 'assets/images/Desserts & Toppings.webp',
    ),
    UsageItem(
      '🎒',
      Icons.backpack_rounded,
      'On-the-Go Goodness',
      'Lightweight and mess-free, perfect for any adventure.',
      image: 'assets/images/On-the-Go Goodness.webp',
    ),
  ];

  // ---- Quick recipes ----
  static const List<RecipeItem> recipes = [
    RecipeItem('🥝', 'Kiwi Yogurt Parfait', [
      'Greek yogurt',
      'Rootaura Kiwi',
      'Honey',
      'Granola',
    ], image: 'assets/images/Kiwi Yogurt Parfait.webp'),
    RecipeItem(
      '🖤',
      'Black Jamun Fruit Chaat',
      ['Mixed fruits', 'Rootaura Black Jamun', 'Black salt', 'Chaat masala'],
      image: 'assets/images/Black Jamun Fruit Chaat.webp',
    ),
    RecipeItem('🥭', 'Mango Smoothie', [
      'Banana',
      'Milk / yogurt',
      'Rootaura Mango',
    ], image: 'assets/images/Mango Smoothie.webp'),
  ];

  // ---- Storage tips ----
  static const List<InfoItem> storageTips = [
    InfoItem(
      Icons.thermostat_rounded,
      'Store in a Cool, Dry Place',
      'Keep away from direct sunlight, heat and moisture.',
      image: 'assets/product_storage/Store in a Cool, Dry Place.webp'
    ),
    InfoItem(
      Icons.lock_rounded,
      'Reseal After Every Use',
      'Seal the pouch tightly to maintain freshness and crunch.',
      image: 'assets/product_storage/Reseal After Every Use.webp'
    ),
    InfoItem(
      Icons.clean_hands_rounded,
      'Use Clean, Dry Hands or Spoon',
      'Avoid introducing moisture into the pack.',
      image: 'assets/product_storage/Use Clean, Dry Hands or Spoon.webp'
    ),
    InfoItem(
      Icons.inventory_2_rounded,
      'Transfer to an Airtight Container',
      'For best results once the pouch is opened.',
      image: 'assets/product_storage/Transfer to an Airtight Container.webp'
    ),
    InfoItem(
      Icons.water_drop_outlined,
      'Avoid Humidity Exposure',
      'Freeze-dried fruits absorb moisture and lose their crisp texture.',
      image: 'assets/product_storage/Avoid Humidity Exposure.webp'
    ),
    InfoItem(
      Icons.kitchen_outlined,
      'Refrigeration Not Required',
      'Store at room temperature in a cool, dry place.',
      image: 'assets/product_storage/Refrigeration Not Required.webp'
    ),
  ];

  // ---- Testimonials ----
  static const List<Testimonial> testimonials = [
    Testimonial(
      'Absolutely love the crunch and natural taste. The perfect healthy snack for my kids!',
      'Priya S.',
      'Verified Buyer',
      5,
    ),
    Testimonial(
      'Finally a snack that is tasty AND healthy. Mango is my favourite by far.',
      'Rohit K.',
      'Verified Buyer',
      5,
    ),
    Testimonial(
      'Great quality and super convenient for travel and the office. Highly recommend.',
      'Ananya T.',
      'Verified Buyer',
      5,
    ),
  ];

  // ---- Home nav anchors ----
  static const List<NavLink> navLinks = [
    NavLink('Home', 'home'),
    NavLink('About Us', 'about'),
    NavLink('Our Products', 'products'),
    NavLink('Why Choose Us', 'why'),
    NavLink('Recipes', 'recipes'),
    NavLink('Storage Guide', 'storage'),
    NavLink('Contact Us', 'contact'),
  ];
}
