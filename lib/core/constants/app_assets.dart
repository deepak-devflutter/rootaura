/// Centralised asset paths so nothing references a raw string path inline.
class AppAssets {
  AppAssets._();

  static const String _img = 'assets/images';
  static const String _svg = 'assets/svg';
  static const String _products = 'assets/product_images';

  // Photography
  static const String heroBowl = '$_img/hero_bowl.png';
  static const String lifestyleBowl = '$_img/lifestyle_bowl.png';
  static const String basket = '$_img/basket.png';

  // SVG decorations
  static const String logo = '$_svg/logo.svg';
  static const String leaf = '$_svg/leaf.svg';
  static const String leafSprig = '$_svg/leaf_sprig.svg';
  static const String sparkle = '$_svg/sparkle.svg';

  // Product pack-shots (fallbacks; primary images come from Remote Config)
  static const String mango = '$_products/Mango Freeze-Dried Chunks.png';
  static const String strawberry =
      '$_products/Strawberry Freeze-Dried Chunks.png';
  static const String blackJamun =
      '$_products/Black Jamun Freeze-Dried Chunks.png';
  static const String kiwi = '$_products/Kiwi Freeze-Dried Chunks.png';
  static const String blueberry = '$_products/Blueberry Freeze-Dried Chunks.png';
  static const String chikoo = '$_products/Chikoo Freeze-Dried Chunks.png';
}
