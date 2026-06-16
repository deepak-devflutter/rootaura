import 'package:flutter/material.dart';

import '../../core/constants/app_dimens.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/user_profile.dart';
import '../../data/user_repository.dart';
import 'customer_detail_screen.dart';

enum CustomerFilter { all, admins, discounted, blocked }

extension on CustomerFilter {
  String get label => switch (this) {
        CustomerFilter.all => 'All',
        CustomerFilter.admins => 'Admins',
        CustomerFilter.discounted => 'Discounted',
        CustomerFilter.blocked => 'Blocked',
      };

  bool matches(UserProfile u) => switch (this) {
        CustomerFilter.all => true,
        CustomerFilter.admins => u.isAdmin,
        CustomerFilter.discounted => u.hasDiscount,
        CustomerFilter.blocked => u.blocked,
      };
}

class AdminCustomersTab extends StatefulWidget {
  const AdminCustomersTab({super.key});

  @override
  State<AdminCustomersTab> createState() => _AdminCustomersTabState();
}

class _AdminCustomersTabState extends State<AdminCustomersTab> {
  final _search = TextEditingController();
  String _query = '';
  CustomerFilter _filter = CustomerFilter.all;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _search,
          onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
          decoration: InputDecoration(
            hintText: 'Search by name, phone or email',
            prefixIcon: const Icon(Icons.search_rounded),
            isDense: true,
            filled: true,
            fillColor: brand.cardSoft,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: AppDimens.md),
        StreamBuilder<List<UserProfile>>(
          stream: UserRepository.instance.streamAll(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(AppDimens.xxl),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snap.hasError) {
              return Text('Could not load customers (check admin access).',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.berry));
            }
            final all = snap.data ?? const [];
            int countFor(CustomerFilter f) =>
                all.where(f.matches).length;
            final filtered = all.where((u) {
              if (!_filter.matches(u)) return false;
              if (_query.isEmpty) return true;
              return u.name.toLowerCase().contains(_query) ||
                  u.phone.toLowerCase().contains(_query) ||
                  u.email.toLowerCase().contains(_query);
            }).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppDimens.sm,
                  children: CustomerFilter.values
                      .map((f) => ChoiceChip(
                            label: Text('${f.label} (${countFor(f)})'),
                            selected: _filter == f,
                            onSelected: (_) => setState(() => _filter = f),
                          ))
                      .toList(),
                ),
                const SizedBox(height: AppDimens.md),
                if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(AppDimens.xl),
                    child: Text('No customers here.',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: brand.textSecondary)),
                  )
                else
                  ...filtered.map((u) => _CustomerRow(user: u)),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _CustomerRow extends StatelessWidget {
  final UserProfile user;
  const _CustomerRow({required this.user});

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final u = user;
    final contact = [u.phone, u.email].where((e) => e.isNotEmpty).join(' · ');
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.sm),
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => CustomerDetailScreen(uid: u.uid))),
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(AppDimens.md),
          decoration: BoxDecoration(
            color: brand.card,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(color: brand.border),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor:
                    AppColors.primaryGreen.withValues(alpha: 0.12),
                child: Text(
                  (u.name.isNotEmpty ? u.name : '?')
                      .characters
                      .first
                      .toUpperCase(),
                  style: AppTextStyles.button
                      .copyWith(color: AppColors.primaryGreen),
                ),
              ),
              const SizedBox(width: AppDimens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(u.name.isNotEmpty ? u.name : 'Unnamed customer',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: brand.textPrimary)),
                    if (contact.isNotEmpty)
                      Text(contact,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: brand.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(width: AppDimens.sm),
              Wrap(
                spacing: 4,
                children: [
                  if (u.isAdmin) _tag('Admin', const Color(0xFF4F46E5)),
                  if (u.hasDiscount)
                    _tag('${u.discountPercent.toStringAsFixed(0)}% off',
                        AppColors.primaryGreen),
                  if (u.blocked) _tag('Blocked', AppColors.berry),
                ],
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tag(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        ),
        child: Text(text,
            style: AppTextStyles.bodySmall.copyWith(
                color: color, fontWeight: FontWeight.w700, fontSize: 11)),
      );
}
