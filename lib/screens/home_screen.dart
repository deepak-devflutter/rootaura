import 'package:flutter/material.dart';

import '../core/constants/app_durations.dart';
import '../sections/about_section.dart';
import '../sections/cta_section.dart';
import '../sections/hero_section.dart';
import '../sections/products_section.dart';
import '../sections/recipes_section.dart';
import '../sections/storage_section.dart';
import '../sections/testimonials_section.dart';
import '../sections/trust_strip.dart';
import '../sections/usage_section.dart';
import '../sections/values_band.dart';
import '../sections/why_choose_section.dart';
import '../widgets/app_footer.dart';
import '../widgets/app_header.dart';

/// One-page home with sticky header, anchor scrolling and a back-press guard
/// so the site never exits on the first Android back gesture.
class HomeScreen extends StatefulWidget {
  final String? initialSection;
  const HomeScreen({super.key, this.initialSection});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scroll = ScrollController();

  final Map<String, GlobalKey> _keys = {
    'home': GlobalKey(),
    'about': GlobalKey(),
    'products': GlobalKey(),
    'why': GlobalKey(),
    'recipes': GlobalKey(),
    'storage': GlobalKey(),
    'contact': GlobalKey(),
  };

  @override
  void initState() {
    super.initState();
    if (widget.initialSection != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollTo(widget.initialSection!);
      });
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _scrollTo(String anchor) {
    if (anchor == 'home') {
      _scroll.animateTo(0,
          duration: AppDurations.scrollTo, curve: Curves.easeInOut);
      return;
    }
    final ctx = _keys[anchor]?.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx,
          duration: AppDurations.scrollTo, curve: Curves.easeInOut);
    }
  }

  Future<void> _onPop(bool didPop, Object? result) async {
    if (didPop) return;
    // Instead of exiting, glide back to the top of the page.
    if (_scroll.hasClients && _scroll.offset > 0) {
      _scrollTo('home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _onPop,
      child: Scaffold(
        body: Stack(
          children: [
            SingleChildScrollView(
              controller: _scroll,
              child: Column(
                children: [
                  KeyedSubtree(
                      key: _keys['home'],
                      child: HeroSection(
                          onExplore: () => _scrollTo('products'))),
                  const TrustStrip(),
                  KeyedSubtree(
                      key: _keys['about'], child: const AboutSection()),
                  KeyedSubtree(
                      key: _keys['products'], child: const ProductsSection()),
                  KeyedSubtree(
                      key: _keys['why'], child: const WhyChooseSection()),
                  const UsageSection(),
                  KeyedSubtree(
                      key: _keys['recipes'], child: const RecipesSection()),
                  const ValuesBand(),
                  KeyedSubtree(
                      key: _keys['storage'], child: const StorageSection()),
                  const TestimonialsSection(),
                  KeyedSubtree(
                      key: _keys['contact'], child: const CtaSection()),
                  AppFooter(onNavTap: _scrollTo),
                ],
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AppHeader(
                scrollController: _scroll,
                onNavTap: _scrollTo,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
