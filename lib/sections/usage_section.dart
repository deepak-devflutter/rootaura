import 'package:flutter/material.dart';

import '../core/constants/app_dimens.dart';
import '../core/constants/app_durations.dart';
import '../core/constants/app_strings.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_motion.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/responsive.dart';
import '../data/app_content.dart';
import '../widgets/scroll_reveal.dart';
import '../widgets/section.dart';

class UsageSection extends StatelessWidget {
  const UsageSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    return SectionContainer(
      background: context.brand.sectionAlt,
      child: Column(
        children: [
          const SectionHeader(
            eyebrow: AppStrings.usageEyebrow,
            title: AppStrings.usageTitle,
            subtitle: AppStrings.usageSubtitle,
          ),
          const SizedBox(height: AppDimens.xxl),
          ScrollReveal(
            child: isDesktop
                ? const _ExpandingPanels(AppContent.usages)
                : Column(
                    children: AppContent.usages
                        .map((u) => Padding(
                              padding:
                                  const EdgeInsets.only(bottom: AppDimens.md),
                              child: _UsageCard(item: u),
                            ))
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Desktop: a row of dish photos where the hovered/active panel expands to
/// reveal its title + description; the rest stay slim with just an icon.
class _ExpandingPanels extends StatefulWidget {
  final List<UsageItem> items;
  const _ExpandingPanels(this.items);

  @override
  State<_ExpandingPanels> createState() => _ExpandingPanelsState();
}

class _ExpandingPanelsState extends State<_ExpandingPanels> {
  int _active = 0;
  static const double _height = 440;
  static const double _gap = AppDimens.sm + 4;

  @override
  Widget build(BuildContext context) {
    final n = widget.items.length;
    return LayoutBuilder(
      builder: (context, c) {
        final totalWeight = 7 + (n - 1);
        final availW = c.maxWidth - (n - 1) * _gap;
        double widthFor(int i) =>
            availW * ((i == _active ? 7 : 1) / totalWeight);

        final children = <Widget>[];
        var left = 0.0;
        for (var i = 0; i < n; i++) {
          final w = widthFor(i);
          children.add(
            AnimatedPositioned(
              duration: AppDurations.page,
              curve: AppCurves.entrance,
              left: left,
              width: w,
              top: 0,
              height: _height,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                onEnter: (_) => setState(() => _active = i),
                child: GestureDetector(
                  onTap: () => setState(() => _active = i),
                  child: _panel(widget.items[i], i == _active),
                ),
              ),
            ),
          );
          left += w + _gap;
        }
        return SizedBox(
          width: c.maxWidth,
          height: _height,
          child: Stack(clipBehavior: Clip.hardEdge, children: children),
        );
      },
    );
  }

  Widget _panel(UsageItem item, bool active) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
              color: active ? AppColors.gold : Colors.transparent, width: 2),
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(item.image, fit: BoxFit.cover, alignment: Alignment.center),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xCC0A0A08)],
                  stops: [0.45, 1.0],
                ),
              ),
            ),
            Positioned(
              left: AppDimens.md,
              right: AppDimens.md,
              bottom: AppDimens.lg,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _iconBadge(item.icon),
                  const SizedBox(width: AppDimens.sm + 4),
                  Expanded(
                    child: AnimatedOpacity(
                      duration: AppDurations.hover,
                      opacity: active ? 1 : 0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: AppTextStyles.fraunces,
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              )),
                          const SizedBox(height: 2),
                          Text(item.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.white.withValues(alpha: 0.85))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconBadge(IconData icon) => Container(
        width: 46,
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      );
}

/// Mobile: a full-width image card showing the dish, icon, title & description.
class _UsageCard extends StatelessWidget {
  final UsageItem item;
  const _UsageCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      child: SizedBox(
        height: 180,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(item.image, fit: BoxFit.cover),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xCC0A0A08)],
                  stops: [0.35, 1.0],
                ),
              ),
            ),
            Positioned(
              left: AppDimens.md,
              right: AppDimens.md,
              bottom: AppDimens.md,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: Colors.white.withValues(alpha: 0.35)),
                    ),
                    child: Icon(item.icon, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: AppDimens.sm + 2),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(item.title,
                            style: const TextStyle(
                              fontFamily: AppTextStyles.fraunces,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            )),
                        const SizedBox(height: 2),
                        Text(item.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.white.withValues(alpha: 0.85))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
