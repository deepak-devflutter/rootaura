import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_assets.dart';
import '../core/constants/app_dimens.dart';
import '../core/constants/app_durations.dart';
import '../core/constants/app_strings.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/theme_controller.dart';
import '../core/utils/responsive.dart';
import '../data/app_content.dart';
import '../state/auth_controller.dart';
import '../state/cart_controller.dart';
import 'app_buttons.dart';

/// Sticky top navigation. Transparent over the hero, solid once scrolled.
/// On the home page [onNavTap] scrolls to a section; elsewhere it deep-links
/// back to `/?section=`.
class AppHeader extends StatefulWidget {
  final ScrollController? scrollController;
  final void Function(String anchor)? onNavTap;

  const AppHeader({super.key, this.scrollController, this.onNavTap});

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  bool _solid = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController?.addListener(_onScroll);
    // Sub-pages have no controller → render solid from the start.
    _solid = widget.scrollController == null;
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final solid = (widget.scrollController?.offset ?? 0) > 24;
    if (solid != _solid) setState(() => _solid = solid);
  }

  void _navTo(String anchor) {
    if (widget.onNavTap != null) {
      widget.onNavTap!(anchor);
    } else {
      context.go('${AppRoutes.home}?section=$anchor');
    }
  }

  void _openMobileMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.brand.card,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppDimens.radiusXl)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final link in AppContent.navLinks)
                ListTile(
                  title: Text(link.label, style: AppTextStyles.navItem),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.pop(ctx);
                    _navTo(link.anchor);
                  },
                ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.shopping_cart_outlined),
                title: Text('Cart', style: AppTextStyles.navItem),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push(AppRoutes.cart);
                },
              ),
              ListTile(
                leading: Icon(AuthController.instance.isSignedIn
                    ? Icons.person_outline_rounded
                    : Icons.login_rounded),
                title: Text(
                    AuthController.instance.isSignedIn ? 'My Account' : 'Sign In',
                    style: AppTextStyles.navItem),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push(AuthController.instance.isSignedIn
                      ? AppRoutes.profile
                      : AppRoutes.signIn);
                },
              ),
              const SizedBox(height: AppDimens.sm),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  text: AppStrings.shopNow,
                  icon: Icons.shopping_bag_outlined,
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.push(AppRoutes.products);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final isDesktop = Responsive.isDesktop(context);

    return AnimatedContainer(
      duration: AppDurations.medium,
      height: AppDimens.headerHeight,
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.isMobile(context) ? AppDimens.lg : AppDimens.xxxl,
      ),
      decoration: BoxDecoration(
        color: _solid ? brand.card.withValues(alpha: 0.96) : Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: _solid ? brand.border : Colors.transparent,
          ),
        ),
        boxShadow: _solid
            ? [BoxShadow(color: brand.shadow, blurRadius: 18, offset: const Offset(0, 4))]
            : null,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppDimens.maxContentWidth),
          child: Row(
            children: [
              _logo(),
              const Spacer(),
              if (isDesktop) ..._desktopLinks(brand),
              if (isDesktop) const SizedBox(width: AppDimens.lg),
              _themeToggle(brand),
              const SizedBox(width: AppDimens.xs),
              _AccountButton(brand: brand),
              const SizedBox(width: AppDimens.xs),
              _CartButton(brand: brand),
              if (isDesktop) ...[
                const SizedBox(width: AppDimens.md),
                PrimaryButton(
                  text: AppStrings.shopNow,
                  dense: true,
                  onPressed: () => context.push(AppRoutes.products),
                ),
              ] else ...[
                const SizedBox(width: AppDimens.xs),
                IconButton(
                  onPressed: _openMobileMenu,
                  icon: Icon(Icons.menu_rounded, color: brand.textPrimary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _logo() {
    return InkWell(
      onTap: () => _navTo('home'),
      borderRadius: BorderRadius.circular(AppDimens.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.brandName.toUpperCase(),
              style: AppTextStyles.h3.copyWith(
                color: AppColors.darkGreen,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(width: 4),
            SvgPicture.asset(AppAssets.leaf, width: 18, height: 18),
          ],
        ),
      ),
    );
  }

  List<Widget> _desktopLinks(BrandColors brand) {
    return AppContent.navLinks
        .map((link) => _NavLinkButton(
              label: link.label,
              onTap: () => _navTo(link.anchor),
            ))
        .toList();
  }

  Widget _themeToggle(BrandColors brand) {
    return IconButton(
      tooltip: 'Toggle theme',
      onPressed: ThemeController.toggle,
      icon: Icon(
        ThemeController.isDark
            ? Icons.light_mode_outlined
            : Icons.dark_mode_outlined,
        color: brand.textSecondary,
      ),
    );
  }
}

class _NavLinkButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _NavLinkButton({required this.label, required this.onTap});

  @override
  State<_NavLinkButton> createState() => _NavLinkButtonState();
}

class _NavLinkButtonState extends State<_NavLinkButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: AppTextStyles.navItem.copyWith(
                  color: _hover ? AppColors.primaryGreen : brand.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              AnimatedContainer(
                duration: AppDurations.fast,
                height: 2,
                width: _hover ? 18 : 0,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cart icon with a live item-count badge.
class _CartButton extends StatelessWidget {
  final BrandColors brand;
  const _CartButton({required this.brand});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CartController.instance,
      builder: (context, _) {
        final count = CartController.instance.count;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              tooltip: 'Cart',
              onPressed: () => context.push(AppRoutes.cart),
              icon: Icon(Icons.shopping_cart_outlined,
                  color: brand.textPrimary),
            ),
            if (count > 0)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  constraints:
                      const BoxConstraints(minWidth: 18, minHeight: 18),
                  decoration: const BoxDecoration(
                    color: AppColors.berry,
                    shape: BoxShape.circle,
                  ),
                  child: Text('$count',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Account menu — sign-in when logged out, a popup of account links otherwise.
class _AccountButton extends StatelessWidget {
  final BrandColors brand;
  const _AccountButton({required this.brand});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthController.instance,
      builder: (context, _) {
        final auth = AuthController.instance;
        if (!auth.isSignedIn) {
          return IconButton(
            tooltip: 'Sign in',
            onPressed: () => context.push(AppRoutes.signIn),
            icon: Icon(Icons.person_outline_rounded, color: brand.textPrimary),
          );
        }
        return PopupMenuButton<String>(
          tooltip: 'Account',
          icon: Icon(Icons.account_circle_outlined, color: brand.textPrimary),
          onSelected: (value) {
            switch (value) {
              case 'profile':
                context.push(AppRoutes.profile);
              case 'orders':
                context.push(AppRoutes.orders);
              case 'admin':
                context.push(AppRoutes.admin);
              case 'signout':
                auth.signOut();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'profile', child: Text('My Profile')),
            const PopupMenuItem(value: 'orders', child: Text('My Orders')),
            if (auth.isAdmin)
              const PopupMenuItem(value: 'admin', child: Text('Admin')),
            const PopupMenuDivider(),
            const PopupMenuItem(value: 'signout', child: Text('Sign out')),
          ],
        );
      },
    );
  }
}
