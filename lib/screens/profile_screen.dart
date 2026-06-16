import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_dimens.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../data/models/address.dart';
import '../data/models/user_profile.dart';
import '../data/user_repository.dart';
import '../state/auth_controller.dart';
import '../widgets/address_form.dart';
import '../widgets/app_buttons.dart';
import '../widgets/page_scaffold.dart';
import '../widgets/section.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _editName(BuildContext context, UserProfile profile) async {
    final controller = TextEditingController(text: profile.name);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Your name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter your name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: const Text('Save')),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    final updated = profile.copyWith(name: name);
    await UserRepository.instance.save(updated);
    AuthController.instance.setProfile(updated);
  }

  Future<void> _addOrEditAddress(BuildContext context, UserProfile profile,
      {Address? existing}) async {
    final addr = await showAddressSheet(context, existing: existing);
    if (addr == null) return;
    final updated = await UserRepository.instance.upsertAddress(profile, addr);
    AuthController.instance.setProfile(updated);
  }

  Future<void> _removeAddress(
      BuildContext context, UserProfile profile, String id) async {
    final updated = await UserRepository.instance.removeAddress(profile, id);
    AuthController.instance.setProfile(updated);
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      body: SectionContainer(
        maxWidth: 720,
        child: ListenableBuilder(
          listenable: AuthController.instance,
          builder: (context, _) {
            final brand = context.brand;
            final profile = AuthController.instance.profile;
            if (profile == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('My Profile',
                        style:
                            AppTextStyles.h1.copyWith(color: brand.textPrimary)),
                    const Spacer(),
                    if (AuthController.instance.isAdmin)
                      SecondaryButton(
                        text: 'Admin',
                        icon: Icons.admin_panel_settings_outlined,
                        dense: true,
                        onPressed: () => context.push(AppRoutes.admin),
                      ),
                  ],
                ),
                const SizedBox(height: AppDimens.lg),
                _profileCard(context, brand, profile),
                const SizedBox(height: AppDimens.xl),
                Row(
                  children: [
                    Text('Saved Addresses',
                        style: AppTextStyles.h3
                            .copyWith(color: brand.textPrimary, fontSize: 18)),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => _addOrEditAddress(context, profile),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.sm),
                if (profile.addresses.isEmpty)
                  Text('No addresses saved yet.',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: brand.textSecondary))
                else
                  ...profile.addresses.map((a) => _addressCard(
                      context, brand, profile, a)),
                const SizedBox(height: AppDimens.xl),
                SecondaryButton(
                  text: 'Sign Out',
                  icon: Icons.logout_rounded,
                  onPressed: () async {
                    await AuthController.instance.signOut();
                    if (context.mounted) context.go(AppRoutes.home);
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _profileCard(
      BuildContext context, BrandColors brand, UserProfile profile) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.lg),
      decoration: BoxDecoration(
        color: brand.card,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: brand.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.12),
            child: Text(
              (profile.name.isNotEmpty ? profile.name : 'R')
                  .characters
                  .first
                  .toUpperCase(),
              style: AppTextStyles.h2.copyWith(color: AppColors.primaryGreen),
            ),
          ),
          const SizedBox(width: AppDimens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profile.name.isNotEmpty ? profile.name : 'Add your name',
                    style: AppTextStyles.h3
                        .copyWith(color: brand.textPrimary, fontSize: 18)),
                const SizedBox(height: 2),
                Text(
                    [profile.phone, profile.email]
                        .where((e) => e.isNotEmpty)
                        .join(' · '),
                    style: AppTextStyles.bodySmall
                        .copyWith(color: brand.textSecondary)),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Edit name',
            onPressed: () => _editName(context, profile),
            icon: const Icon(Icons.edit_outlined, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _addressCard(BuildContext context, BrandColors brand,
      UserProfile profile, Address a) {
    final isDefault = a.id == profile.defaultAddressId;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.sm),
      child: Container(
        padding: const EdgeInsets.all(AppDimens.md),
        decoration: BoxDecoration(
          color: brand.card,
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          border: Border.all(color: brand.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.location_on_outlined,
                color: AppColors.primaryGreen, size: 20),
            const SizedBox(width: AppDimens.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(a.name,
                        style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: brand.textPrimary)),
                    const SizedBox(width: AppDimens.sm),
                    Text(a.label,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: brand.textSecondary)),
                    if (isDefault) ...[
                      const SizedBox(width: AppDimens.sm),
                      Text('Default',
                          style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.w700)),
                    ],
                  ]),
                  const SizedBox(height: 2),
                  Text('${a.oneLine}\n${a.phone}',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: brand.textSecondary)),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (v) async {
                if (v == 'edit') {
                  await _addOrEditAddress(context, profile, existing: a);
                } else if (v == 'default') {
                  final updated = await UserRepository.instance
                      .setDefaultAddress(profile, a.id);
                  AuthController.instance.setProfile(updated);
                } else if (v == 'delete') {
                  await _removeAddress(context, profile, a.id);
                }
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                if (!isDefault)
                  const PopupMenuItem(
                      value: 'default', child: Text('Set as default')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
