import 'package:flutter/material.dart';

/// Lightweight app-wide theme switcher. No external state package needed —
/// [MaterialApp] rebuilds via a [ValueListenableBuilder] on this notifier.
class ThemeController {
  ThemeController._();

  static final ValueNotifier<ThemeMode> mode =
      ValueNotifier<ThemeMode>(ThemeMode.light);

  static bool get isDark => mode.value == ThemeMode.dark;

  static void toggle() {
    mode.value = isDark ? ThemeMode.light : ThemeMode.dark;
  }
}
