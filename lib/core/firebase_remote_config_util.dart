import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';

import '../sections/products_section.dart';

class RemoteConfigUtil {
  // ----- Singleton -----
  RemoteConfigUtil._internal();
  static final RemoteConfigUtil instance = RemoteConfigUtil._internal();

  final FirebaseRemoteConfig _rc = FirebaseRemoteConfig.instance;

  // ----- Keys + Defaults -----
  static const String _webData = 'web_data';

  static const Map<String, dynamic> _defaults = {
    _webData: '{}',
  };

  // ----- Init -----
  Future<void> init() async {
    await _rc.setDefaults(_defaults);

    await _rc.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: Duration.zero, // change for prod
      ),
    );

    await _rc.fetchAndActivate();
  }

  // ----- Public Getters  -----


  List<Product> get productsConfig {
    final raw = _rc.getString(_webData);
    try {
      final productList=jsonDecode(raw)['products'] as List<dynamic>;
      return productList.map((e)=>Product.fromJson(e)).toList();
    } catch (e,s) {
      debugPrint('$e$s');
      return [];
    }
  }


}

