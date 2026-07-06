/// Centralised asset paths so nothing references a raw string path inline.
class AppAssets {
  AppAssets._();

  static const String _img = 'assets/images';
  static const String _svg = 'assets/svg';

  // Photography
  static const String heroBowl = '$_img/hero_bowl.webp';
  static const String lifestyleBowl = '$_img/lifestyle_bowl.webp';
  static const String basket = '$_img/basket.webp';

  // SVG decorations
  static const String logo = '$_svg/logo.svg';
  static const String leaf = '$_svg/leaf.svg';
  static const String leafSprig = '$_svg/leaf_sprig.svg';
  static const String sparkle = '$_svg/sparkle.svg';
}
