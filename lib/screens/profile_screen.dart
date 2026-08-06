import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_dimens.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../data/models/address.dart';
import '../data/models/review.dart';
import '../data/models/user_profile.dart';
import '../data/review_repository.dart';
import '../data/user_repository.dart';
import '../state/auth_controller.dart';
import '../utils/format.dart';
import '../widgets/address_form.dart';
import '../widgets/app_buttons.dart';
import '../widgets/page_scaffold.dart';
import '../widgets/product_reviews.dart';
import '../widgets/section.dart';
import '../widgets/star_rating.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _editProfile(BuildContext context, UserProfile profile) async {
    final user = AuthController.instance.user;
    // The credential used to sign in is the identity and can't be changed here.
    final emailLocked = (user?.email ?? '').trim().isNotEmpty;
    final phoneLocked = (user?.phoneNumber ?? '').trim().isNotEmpty;

    final updated = await showDialog<UserProfile>(
      context: context,
      builder: (ctx) => _EditProfileDialog(
        profile: profile,
        emailLocked: emailLocked,
        phoneLocked: phoneLocked,
      ),
    );
    if (updated == null) return;
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
      ambient: true,
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
                Text('My Reviews',
                    style: AppTextStyles.h3
                        .copyWith(color: brand.textPrimary, fontSize: 18)),
                const SizedBox(height: AppDimens.sm),
                _MyReviews(uid: profile.uid),
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
                const SizedBox(height: 6),
                _contactLine(brand, Icons.phone_outlined, profile.phone,
                    'Add phone number'),
                const SizedBox(height: 2),
                _contactLine(brand, Icons.mail_outline_rounded, profile.email,
                    'Add email address'),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Edit profile',
            onPressed: () => _editProfile(context, profile),
            icon: const Icon(Icons.edit_outlined, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _contactLine(
      BrandColors brand, IconData icon, String value, String emptyHint) {
    final has = value.isNotEmpty;
    return Row(
      children: [
        Icon(icon,
            size: 14,
            color: has ? brand.textSecondary : AppColors.primaryGreen),
        const SizedBox(width: 6),
        Flexible(
          child: Text(has ? value : emptyHint,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(
                  color: has ? brand.textSecondary : AppColors.primaryGreen,
                  fontWeight: has ? FontWeight.w400 : FontWeight.w600)),
        ),
      ],
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

/// Editable name / email / phone. The credential used to sign in (email or
/// phone) is shown but locked.
class _EditProfileDialog extends StatefulWidget {
  final UserProfile profile;
  final bool emailLocked;
  final bool phoneLocked;
  const _EditProfileDialog({
    required this.profile,
    required this.emailLocked,
    required this.phoneLocked,
  });

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name =
      TextEditingController(text: widget.profile.name);
  late final TextEditingController _email =
      TextEditingController(text: widget.profile.email);
  late final TextEditingController _phone =
      TextEditingController(text: widget.profile.phone);

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  String? _validateEmail(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return null; // optional
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s);
    return ok ? null : 'Enter a valid email address';
  }

  String? _validatePhone(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return null; // optional
    final digits = s.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.length >= 7 ? null : 'Enter a valid phone number';
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final updated = widget.profile.copyWith(
      name: _name.text.trim(),
      // Locked fields keep their existing (sign-in) value.
      email: widget.emailLocked ? widget.profile.email : _email.text.trim(),
      phone: widget.phoneLocked ? widget.profile.phone : _phone.text.trim(),
    );
    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit profile'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: AppDimens.md),
              TextFormField(
                controller: _email,
                enabled: !widget.emailLocked,
                readOnly: widget.emailLocked,
                keyboardType: TextInputType.emailAddress,
                validator: widget.emailLocked ? null : _validateEmail,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.mail_outline_rounded),
                  helperText:
                      widget.emailLocked ? 'Used to sign in — can’t be changed' : null,
                ),
              ),
              const SizedBox(height: AppDimens.md),
              TextFormField(
                controller: _phone,
                enabled: !widget.phoneLocked,
                readOnly: widget.phoneLocked,
                keyboardType: TextInputType.phone,
                validator: widget.phoneLocked ? null : _validatePhone,
                decoration: InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  helperText:
                      widget.phoneLocked ? 'Used to sign in — can’t be changed' : null,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}

/// The signed-in customer's own reviews, shown on their profile.
class _MyReviews extends StatelessWidget {
  final String uid;
  const _MyReviews({required this.uid});

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return StreamBuilder<List<Review>>(
      stream: ReviewRepository.instance.forUser(uid),
      builder: (context, snap) {
        final reviews = snap.data ?? const <Review>[];
        if (reviews.isEmpty) {
          return Text('You haven’t reviewed any products yet.',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: brand.textSecondary));
        }
        return Column(
          children: reviews.map((r) {
            return Container(
              margin: const EdgeInsets.only(bottom: AppDimens.sm),
              padding: const EdgeInsets.all(AppDimens.md),
              decoration: BoxDecoration(
                color: brand.card,
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                border: Border.all(color: brand.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                            r.productName.isEmpty
                                ? 'Product'
                                : r.productName,
                            style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: brand.textPrimary)),
                      ),
                      if (r.hidden)
                        Text('Hidden by admin',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.berry)),
                      SizedBox(
                        height: 28,
                        width: 28,
                        child: PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          tooltip: 'Manage review',
                          icon: const Icon(Icons.more_vert_rounded, size: 18),
                          onSelected: (v) {
                            if (v == 'edit') {
                              showProductReviewDialog(
                                context,
                                reviewId: r.id,
                                productId: r.productId,
                                productName: r.productName.isEmpty
                                    ? 'Product'
                                    : r.productName,
                                uid: r.uid,
                                userName: r.userName,
                                orderId: r.orderId,
                              );
                            } else if (v == 'delete') {
                              confirmDeleteReview(context, r.id);
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(
                                value: 'delete', child: Text('Delete')),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  StarRating(r.rating.toDouble(), size: 15),
                  if (r.text.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(r.text,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: brand.textSecondary)),
                  ],
                  if (r.hasReply) ...[
                    const SizedBox(height: AppDimens.sm),
                    Text('Rootaura replied: ${r.adminReply}',
                        style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primaryGreen,
                            fontStyle: FontStyle.italic)),
                  ],
                  if (r.createdAt != null) ...[
                    const SizedBox(height: 4),
                    Text(Format.date(r.createdAt!),
                        style: AppTextStyles.bodySmall
                            .copyWith(color: brand.textSecondary)),
                  ],
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
