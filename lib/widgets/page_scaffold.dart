import 'package:flutter/material.dart';

import '../core/constants/app_dimens.dart';
import 'app_footer.dart';
import 'app_header.dart';

/// Shared layout for sub-pages: solid sticky header, scrollable body, footer.
class PageScaffold extends StatelessWidget {
  final Widget body;
  const PageScaffold({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
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
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppHeader(),
          ),
        ],
      ),
    );
  }
}
