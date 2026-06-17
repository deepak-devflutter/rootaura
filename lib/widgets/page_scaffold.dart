import 'package:flutter/material.dart';

import '../core/constants/app_dimens.dart';
import 'animated_background.dart';
import 'app_footer.dart';
import 'app_header.dart';

/// Shared layout for sub-pages: solid sticky header, scrollable body, footer.
///
/// Set [ambient] to render the living animated dot/aurora background behind the
/// content — used on the lighter utility screens (cart, checkout, account…) to
/// give them a premium, alive feel.
class PageScaffold extends StatelessWidget {
  final Widget body;
  final bool ambient;
  const PageScaffold({super.key, required this.body, this.ambient = false});

  @override
  Widget build(BuildContext context) {
    final content = Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: AppDimens.headerHeight),
              body,
              const AppFooter(),
            ],
          ),
        ),
        const Positioned(top: 0, left: 0, right: 0, child: AppHeader()),
      ],
    );

    if (!ambient) return Scaffold(body: content);

    // Transparent scaffold so the animated backdrop shows through.
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedBackground(
        dotSpacing: 36,
        intensity: 0.55,
        child: content,
      ),
    );
  }
}
