import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/constants/app_dimens.dart';
import '../core/constants/app_durations.dart';
import '../core/theme/app_colors.dart';

/// Swipeable product image gallery with tappable dot indicators and (optionally)
/// prev/next arrows. Reused on the product card (fixed [height]) and the product
/// detail page (square [aspectRatio]).
class ImageCarousel extends StatefulWidget {
  final List<String> imageUrls;

  /// Fixed pixel height — use inside the equal-height grid (avoids the
  /// IntrinsicHeight + AspectRatio conflict). When null, [aspectRatio] is used.
  final double? height;
  final double aspectRatio;
  final BorderRadius? borderRadius;
  final bool showArrows;
  final EdgeInsets padding;

  /// Appetising fruit illustration shown when there are no photos / one fails.
  final String? fallbackAsset;

  const ImageCarousel({
    super.key,
    required this.imageUrls,
    this.height,
    this.aspectRatio = 1,
    this.borderRadius,
    this.showArrows = true,
    this.padding = const EdgeInsets.all(AppDimens.xl),
    this.fallbackAsset,
  });

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  final _controller = PageController();
  int _index = 0;
  bool _hovered = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _go(int i) {
    final n = widget.imageUrls.length;
    if (n == 0) return;
    _controller.animateToPage((i + n) % n,
        duration: AppDurations.medium, curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final urls = widget.imageUrls;
    final radius =
        widget.borderRadius ?? BorderRadius.circular(AppDimens.radiusXl);
    final multi = urls.length > 1;

    final inner = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.mintTint.withValues(alpha: 0.6),
            AppColors.goldSoft.withValues(alpha: 0.35),
          ],
        ),
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (urls.isEmpty)
              Padding(padding: widget.padding, child: _fallback())
            else
              PageView.builder(
                controller: _controller,
                itemCount: urls.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (c, i) => Padding(
                  padding: widget.padding,
                  child: AnimatedScale(
                    duration: AppDurations.medium,
                    scale: _hovered ? 1.04 : 1.0,
                    child: CachedNetworkImage(
                      imageUrl: urls[i],
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                      placeholder: (c, _) => const Center(
                          child: SizedBox(
                              width: 24,
                              height: 24,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2))),
                      errorWidget: (context, url, error) {
                        debugPrint('IMAGE ERROR: $error');
                        debugPrint('URL: $url');
                        return _fallback();
                      },
                    ),
                  ),
                ),
              ),
            if (multi && widget.showArrows && _hovered) ...[
              Positioned(
                  left: 6, child: _arrow(Icons.chevron_left_rounded, -1)),
              Positioned(
                  right: 6, child: _arrow(Icons.chevron_right_rounded, 1)),
            ],
            if (multi)
              Positioned(
                bottom: AppDimens.sm + 2,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(urls.length, (i) {
                    final active = i == _index;
                    return GestureDetector(
                      onTap: () => _go(i),
                      child: AnimatedContainer(
                        duration: AppDurations.fast,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: active ? 18 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.primaryGreen
                              : brand.textSecondary.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );

    return ClipRRect(
      borderRadius: radius,
      child: widget.height != null
          ? SizedBox(height: widget.height, width: double.infinity, child: inner)
          : AspectRatio(aspectRatio: widget.aspectRatio, child: inner),
    );
  }

  Widget _fallback() {
    if (widget.fallbackAsset != null) {
      return SvgPicture.asset(widget.fallbackAsset!, fit: BoxFit.contain);
    }
    return Icon(Icons.eco_rounded,
        size: 64, color: AppColors.primaryGreen.withValues(alpha: 0.4));
  }

  Widget _arrow(IconData icon, int dir) {
    return Material(
      color: Colors.white.withValues(alpha: 0.9),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => _go(_index + dir),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 20, color: AppColors.darkGreen),
        ),
      ),
    );
  }
}
