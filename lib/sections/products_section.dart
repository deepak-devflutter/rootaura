import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_theme.dart';
import '../core/firebase_remote_config_util.dart';
import '../core/responsive.dart';
import '../firebase_options.dart';
import '../widgets/product_card.dart';

class ProductsSection extends StatefulWidget {
  const ProductsSection({super.key});

  @override
  State<ProductsSection> createState() => _ProductsSectionState();
}

class _ProductsSectionState extends State<ProductsSection> {
  late Future<List<Product>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadProducts();
  }

  void _retry() {
    setState(() {
      _future = _loadProducts();
    });
  }

  /// ✅ Pure async function — no setState, no UI logic
  Future<List<Product>> _loadProducts() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await RemoteConfigUtil.instance.init();
    debugPrint('✅ Remote Config initialized');

    return RemoteConfigUtil.instance.productsConfig;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return FutureBuilder<List<Product>>(
      future: _future,
      builder: (context, snapshot) {
        // ⏳ Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // ❌ Error
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Something went wrong'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _retry,
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        // ✅ Success
        final products = snapshot.data!;
        if (products.isEmpty) {
          return const Center(child: Text('No products available'));
        }

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.background,
                AppColors.primaryGreen.withValues(alpha: 0.03),
              ],
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 24 : 64,
            vertical: isMobile ? 60 : 100,
          ),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                children: [
                  Text(
                    'Our Products',
                    style: isMobile
                        ? AppTextStyles.sectionTitleMobile
                        : AppTextStyles.sectionTitle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    // 'Pure dehydrated fruit and vegetable powders',
                    'Premium Freeze-Dried Fruits\nReal fruit. No preservatives. Maximum flavor and nutrition.',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 64),
                  Wrap(
                    spacing: 24,
                    runSpacing: 32,
                    alignment: WrapAlignment.center,
                    children: products
                        .map((product) => ProductCard(product: product))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class Product {
  final String? name;
  final String? description;
  final String? benefit;
  final String? purchaseUrl;
  final List<String> imageUrls;

  Product({
    this.name,
    this.description,
    this.benefit,
    this.purchaseUrl,
    required this.imageUrls,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'],
      description: json['description'],
      benefit: json['benefit'],
      purchaseUrl: json['purchaseUrl'],
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
    );
  }
}
