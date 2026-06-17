import 'package:flutter/material.dart';

import '../core/constants/app_dimens.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../data/app_content.dart';
import 'lift_card.dart';

/// Base card chrome — a static "specimen" surface resting at e2 (via LiftCard).
class _Tile extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const _Tile({
    required this.child,
    this.padding = const EdgeInsets.all(AppDimens.lg),
  });

  @override
  Widget build(BuildContext context) {
    return LiftCard(interactive: false, padding: padding, child: child);
  }
}

/// Rounded icon tile used inside cards; tints gold when its card is hovered.
class IconBadge extends StatelessWidget {
  final IconData icon;
  final double size;
  final bool gold;
  const IconBadge(this.icon, {super.key, this.size = 26, this.gold = false});

  @override
  Widget build(BuildContext context) {
    final c = gold ? AppColors.gold : AppColors.primaryGreen;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          c.withValues(alpha: 0.14),
          (gold ? AppColors.goldSoft : AppColors.softGreen)
              .withValues(alpha: gold ? 0.45 : 0.20),
        ]),
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      ),
      child: Icon(icon, color: c, size: size),
    );
  }
}

/// Headline trust badge — fills its grid cell.
class TrustPill extends StatelessWidget {
  final InfoItem item;
  const TrustPill({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return _Tile(
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.md, vertical: AppDimens.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppDimens.radiusSm),
            ),
            child: Icon(item.icon, size: 20, color: AppColors.primaryGreen),
          ),
          const SizedBox(width: AppDimens.sm + 4),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: brand.textPrimary)),
                Text(item.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: brand.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Feature / why-choose / storage card. Fills cell height; specimen-lifts on
/// hover with a gold icon tint.
class InfoCard extends StatelessWidget {
  final InfoItem item;
  const InfoCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return LiftCard(
      padding: const EdgeInsets.all(AppDimens.lg),
      builder: (context, hovered) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(item.icon, gold: hovered),
          const SizedBox(height: AppDimens.md),
          Text(item.title,
              style: AppTextStyles.h3
                  .copyWith(color: brand.textPrimary, fontSize: 18)),
          const SizedBox(height: AppDimens.sm),
          Text(item.subtitle,
              style:
                  AppTextStyles.bodyMedium.copyWith(color: brand.textSecondary)),
        ],
      ),
    );
  }
}

/// "Ways to enjoy" card.
class UsageCard extends StatelessWidget {
  final UsageItem item;
  const UsageCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return _Tile(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.mintTint,
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            ),
            child: Text(item.emoji, style: const TextStyle(fontSize: 26)),
          ),
          const SizedBox(height: AppDimens.md),
          Text(item.title,
              style: AppTextStyles.h3
                  .copyWith(color: brand.textPrimary, fontSize: 16)),
          const SizedBox(height: AppDimens.xs + 2),
          Text(item.description,
              style: AppTextStyles.bodySmall
                  .copyWith(color: brand.textSecondary)),
        ],
      ),
    );
  }
}

/// Recipe card with numbered ingredient chips.
class RecipeCard extends StatelessWidget {
  final RecipeItem item;
  const RecipeCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return _Tile(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(item.emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: AppDimens.sm),
              Expanded(
                child: Text(item.title,
                    style: AppTextStyles.h3
                        .copyWith(color: brand.textPrimary, fontSize: 18)),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.md),
          Wrap(
            spacing: AppDimens.sm,
            runSpacing: AppDimens.sm,
            children: item.ingredients
                .map((i) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: brand.cardSoft,
                        borderRadius:
                            BorderRadius.circular(AppDimens.radiusPill),
                      ),
                      child: Text(i,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: brand.textSecondary)),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

/// Customer testimonial card with star rating. Quote grows to fill height so
/// the author block sits flush at the bottom of every card.
class TestimonialCard extends StatelessWidget {
  final Testimonial item;
  const TestimonialCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return _Tile(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(
              5,
              (i) => Icon(
                i < item.rating
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                size: 20,
                color: AppColors.gold,
              ),
            ),
          ),
          const SizedBox(height: AppDimens.md),
          Expanded(
            child: Text('“${item.quote}”',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: brand.textPrimary, height: 1.6)),
          ),
          const SizedBox(height: AppDimens.md),
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor:
                    AppColors.primaryGreen.withValues(alpha: 0.12),
                child: Text(item.name.characters.first,
                    style: AppTextStyles.button
                        .copyWith(color: AppColors.primaryGreen)),
              ),
              const SizedBox(width: AppDimens.sm + 2),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                      style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: brand.textPrimary)),
                  Text(item.role,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: brand.textSecondary)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
