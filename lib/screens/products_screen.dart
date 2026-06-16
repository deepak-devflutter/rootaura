import 'package:flutter/material.dart';

import '../sections/products_section.dart';
import '../widgets/page_scaffold.dart';

/// Full catalogue listing — reuses the products section in "show all" mode.
class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageScaffold(
      body: ProductsSection(showAll: true),
    );
  }
}
