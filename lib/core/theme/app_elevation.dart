import 'package:flutter/material.dart';

/// Warm, two-layer elevation scale — a tight **contact** shadow + a wide soft
/// **ambient** shadow, tinted warm (not pure black). This layered depth is the
/// single biggest "expensive" lever; every surface consumes this scale instead
/// of hand-rolled magic-number shadows.
class AppElevation {
  AppElevation._();

  // Warm shadow tints (light theme).
  static const Color _contact = Color(0x141C1A17); // warm near-black
  static const Color _ambient = Color(0x18241B0A); // warm brown

  static List<BoxShadow> e0(bool dark) => const [];

  static List<BoxShadow> e1(bool dark) => dark ? _darkE1 : _lightE1;
  static List<BoxShadow> e2(bool dark) => dark ? _darkE2 : _lightE2;
  static List<BoxShadow> e3(bool dark) => dark ? _darkE3 : _lightE3;
  static List<BoxShadow> e4(bool dark) => dark ? _darkE4 : _lightE4;

  // ---- light ----
  static const _lightE1 = [
    BoxShadow(color: Color(0x0A1C1A17), blurRadius: 5, offset: Offset(0, 2)),
    BoxShadow(
        color: Color(0x0F241B0A),
        blurRadius: 16,
        spreadRadius: -2,
        offset: Offset(0, 8)),
  ];
  static const _lightE2 = [
    BoxShadow(color: _contact, blurRadius: 3, offset: Offset(0, 1)),
    BoxShadow(
        color: _ambient,
        blurRadius: 28,
        spreadRadius: -4,
        offset: Offset(0, 14)),
  ];
  static const _lightE3 = [
    BoxShadow(color: Color(0x1A1C1A17), blurRadius: 4, offset: Offset(0, 2)),
    BoxShadow(
        color: Color(0x22241B0A),
        blurRadius: 40,
        spreadRadius: -6,
        offset: Offset(0, 20)),
  ];
  static const _lightE4 = [
    BoxShadow(color: Color(0x1F1C1A17), blurRadius: 6, offset: Offset(0, 3)),
    BoxShadow(
        color: Color(0x2E241B0A),
        blurRadius: 60,
        spreadRadius: -8,
        offset: Offset(0, 30)),
  ];

  // ---- dark (deeper, blacker) ----
  static const _darkE1 = [
    BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 3)),
  ];
  static const _darkE2 = [
    BoxShadow(color: Color(0x40000000), blurRadius: 2, offset: Offset(0, 1)),
    BoxShadow(
        color: Color(0x55000000),
        blurRadius: 30,
        spreadRadius: -4,
        offset: Offset(0, 16)),
  ];
  static const _darkE3 = [
    BoxShadow(
        color: Color(0x66000000),
        blurRadius: 42,
        spreadRadius: -6,
        offset: Offset(0, 22)),
  ];
  static const _darkE4 = [
    BoxShadow(
        color: Color(0x77000000),
        blurRadius: 64,
        spreadRadius: -8,
        offset: Offset(0, 32)),
  ];
}
