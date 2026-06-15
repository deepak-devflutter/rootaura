
import 'package:flutter/material.dart';

import '../sections/about_section.dart';
import '../sections/footer_section.dart';
import '../sections/hero_section.dart';
import '../sections/products_section.dart';
import '../sections/storage_section.dart';
import '../sections/usage_section.dart';
import '../sections/why_choose_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _productsKey = GlobalKey();

  void _scrollToProducts() {
    final context = _productsKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            HeroSection(onExplorePressed: _scrollToProducts),
            const AboutSection(),
            ProductsSection(key: _productsKey),
            const UsageSection(),
            const WhyChooseSection(),
            const StorageSection(),
            const FooterSection(),
          ],
        ),
      ),
    );
  }
}