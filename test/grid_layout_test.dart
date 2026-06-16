import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:rootaura_naturals/core/theme/app_theme.dart';
import 'package:rootaura_naturals/data/app_content.dart';
import 'package:rootaura_naturals/data/models/product.dart';
import 'package:rootaura_naturals/widgets/content_cards.dart';
import 'package:rootaura_naturals/widgets/product_card.dart';
import 'package:rootaura_naturals/widgets/responsive_grid.dart';

/// These tests lay out the grid + cards at a real desktop size and assert no
/// layout exceptions fire — specifically guarding the IntrinsicHeight + Expanded
/// pattern used by the product and testimonial cards.
Widget _host(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    // go_router context is needed because ProductCard reads it on build setup.
    home: Scaffold(
      body: InheritedGoRouter(
        goRouter: GoRouter(routes: [GoRoute(path: '/', builder: (_, __) => child)]),
        child: SingleChildScrollView(
          child: Padding(padding: const EdgeInsets.all(24), child: child),
        ),
      ),
    ),
  );
}

void main() {
  const products = [
    Product(
      name: 'Mango Freeze-Dried Chunks',
      description: 'Sun-ripened mango chunks, gently freeze-dried for a crunch.',
      benefit: 'Locks in natural sweetness, fiber, and daily vitamins',
      purchaseUrl: 'https://example.com',
      imageUrls: ['https://example.com/mango.png'],
    ),
    Product(
      name: 'Kiwi',
      description: 'Short text.',
      benefit: 'Vitamin C',
      imageUrls: [],
    ),
    Product(
      name: 'Strawberry Freeze-Dried Chunks',
      description:
          'A much longer description that wraps onto two full lines to force '
          'uneven natural content heights across the row of product cards.',
      benefit: 'Naturally rich in antioxidants for skin and vitality',
      purchaseUrl: 'https://example.com',
      imageUrls: ['https://example.com/s.png'],
    ),
  ];

  testWidgets('product grid lays out with equal-height cards, no exceptions',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_host(
      ResponsiveGrid(
        mobile: 1,
        tablet: 2,
        desktop: 3,
        children: products.map((p) => ProductCard(product: p)).toList(),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.takeException(), isNull);

    // Equal height: the three cards in one row must share the same height.
    final sizes = tester
        .widgetList<ProductCard>(find.byType(ProductCard))
        .map((w) => tester.getSize(find.byWidget(w)).height)
        .toSet();
    expect(sizes.length, 1, reason: 'all cards in a row should be equal height');
  });

  testWidgets('testimonial grid (Expanded-in-column) lays out cleanly',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_host(
      ResponsiveGrid(
        desktop: 3,
        children: AppContent.testimonials
            .map((t) => TestimonialCard(item: t))
            .toList(),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
  });

  testWidgets('info + usage grids lay out cleanly', (tester) async {
    tester.view.physicalSize = const Size(1400, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_host(
      Column(children: [
        ResponsiveGrid(
          desktop: 3,
          children: AppContent.whyChoose.map((i) => InfoCard(item: i)).toList(),
        ),
        ResponsiveGrid(
          desktop: 5,
          children: AppContent.usages.map((i) => UsageCard(item: i)).toList(),
        ),
      ]),
    ));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
  });
}
