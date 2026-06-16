import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Result of an Indian pincode lookup.
class PincodeInfo {
  final String state;
  final String district; // used as the "city" field
  final List<String> areas; // post-office / locality names

  const PincodeInfo({
    required this.state,
    required this.district,
    required this.areas,
  });
}

/// Looks up city/state/locality for an Indian pincode using the free India Post
/// API (no key, no Firebase cost). Results are cached in memory for the session
/// so each pincode is fetched at most once.
class PincodeService {
  PincodeService._();
  static final PincodeService instance = PincodeService._();

  final Map<String, PincodeInfo?> _cache = {};

  Future<PincodeInfo?> lookup(String pincode) async {
    if (pincode.length != 6) return null;
    if (_cache.containsKey(pincode)) return _cache[pincode];

    try {
      final res = await http
          .get(Uri.parse('https://api.postalpincode.in/pincode/$pincode'))
          .timeout(const Duration(seconds: 6));
      if (res.statusCode != 200) return _cache[pincode] = null;

      final data = jsonDecode(res.body);
      final first = (data is List && data.isNotEmpty) ? data.first : null;
      if (first == null || first['Status'] != 'Success') {
        return _cache[pincode] = null;
      }
      final offices = (first['PostOffice'] as List<dynamic>? ?? const []);
      if (offices.isEmpty) return _cache[pincode] = null;

      final info = PincodeInfo(
        state: offices.first['State'] as String? ?? '',
        district: offices.first['District'] as String? ?? '',
        areas: offices
            .map((o) => (o['Name'] as String? ?? '').trim())
            .where((s) => s.isNotEmpty)
            .toSet()
            .toList(),
      );
      return _cache[pincode] = info;
    } catch (e) {
      debugPrint('Pincode lookup failed: $e');
      return null; // not cached, so a later retry can still succeed
    }
  }
}
