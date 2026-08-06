import 'package:flutter/material.dart';

import '../../core/constants/app_dimens.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/page_scaffold.dart';
import '../../widgets/section.dart';
import 'admin_customers_tab.dart';
import 'admin_orders_tab.dart';
import 'admin_products_tab.dart';
import 'admin_reviews_tab.dart';

/// Admin console: a simple two-section switch (Orders / Products) that plays
/// nicely with the page's single scroll view.
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _section = 0;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return PageScaffold(
      body: SectionContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Admin Console',
                style: AppTextStyles.h1.copyWith(color: brand.textPrimary)),
            const SizedBox(height: AppDimens.lg),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<int>(
                segments: const [
                  ButtonSegment(
                      value: 0,
                      label: Text('Orders'),
                      icon: Icon(Icons.receipt_long_outlined)),
                  ButtonSegment(
                      value: 1,
                      label: Text('Products'),
                      icon: Icon(Icons.inventory_2_outlined)),
                  ButtonSegment(
                      value: 2,
                      label: Text('Customers'),
                      icon: Icon(Icons.people_alt_outlined)),
                  ButtonSegment(
                      value: 3,
                      label: Text('Reviews'),
                      icon: Icon(Icons.reviews_outlined)),
                ],
                selected: {_section},
                onSelectionChanged: (s) => setState(() => _section = s.first),
              ),
            ),
            const SizedBox(height: AppDimens.xl),
            switch (_section) {
              0 => const AdminOrdersTab(),
              1 => const AdminProductsTab(),
              2 => const AdminCustomersTab(),
              _ => const AdminReviewsTab(),

            },
          ],
        ),
      ),
    );
  }
}
