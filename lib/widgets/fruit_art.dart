/// Maps a product name to its rich fruit illustration in `assets/fruit`, used
/// as an appetising fallback when a product photo is missing and as decorative
/// floating fruit in the hero.
class FruitArt {
  FruitArt._();

  static const List<String> all = [
    'strawberry', 'mango', 'banana', 'pineapple',
    'kiwi', 'blueberry', 'black-jamun', 'chikoo',
  ];

  static const Map<String, String> _aliases = {
    'jamun': 'black-jamun',
    'chiku': 'chikoo',
    'sapota': 'chikoo',
  };

  static String path(String key) => 'assets/fruit/$key.svg';

  /// Best-matching fruit illustration for a product name (null if none).
  static String? assetFor(String? name) {
    if (name == null || name.isEmpty) return null;
    final s = name.toLowerCase();
    for (final f in all) {
      if (s.contains(f.replaceAll('-', ' ')) || s.contains(f)) return path(f);
    }
    for (final entry in _aliases.entries) {
      if (s.contains(entry.key)) return path(entry.value);
    }
    return null;
  }
}
