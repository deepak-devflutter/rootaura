import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens external URLs with graceful failure feedback.
class UrlHelper {
  UrlHelper._();

  static Future<void> open(BuildContext context, String? url) async {
    final value = (url ?? '').trim();
    final messenger = ScaffoldMessenger.of(context);
    if (value.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('This product is coming soon.')),
      );
      return;
    }
    final uri = Uri.tryParse(value);
    if (uri == null || !await launchUrl(uri, mode: LaunchMode.platformDefault)) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not open the link.')),
      );
    }
  }

  static Future<void> launch(String url, {LaunchMode? mode}) async {
    final uri = Uri.tryParse(url.trim());
    if (uri != null) {
      await launchUrl(uri, mode: mode ?? LaunchMode.platformDefault);
    }
  }
}
