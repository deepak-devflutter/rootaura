import 'package:flutter/material.dart';

import '../../core/constants/app_dimens.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/review.dart';
import '../../data/review_repository.dart';
import '../../utils/format.dart';
import '../../widgets/star_rating.dart';

class AdminReviewsTab extends StatefulWidget {
  const AdminReviewsTab({super.key});

  @override
  State<AdminReviewsTab> createState() => _AdminReviewsTabState();
}

class _AdminReviewsTabState extends State<AdminReviewsTab> {
  static const _pageSize = 20;
  int _limit = _pageSize;
  bool _hiddenOnly = false;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Reviews',
                style: AppTextStyles.h3
                    .copyWith(color: brand.textPrimary, fontSize: 18)),
            const Spacer(),
            FilterChip(
              label: const Text('Hidden only'),
              selected: _hiddenOnly,
              onSelected: (v) => setState(() => _hiddenOnly = v),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.md),
        StreamBuilder<List<Review>>(
          stream: ReviewRepository.instance.streamAll(limit: _limit),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(AppDimens.xxl),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final all = snap.data ?? const <Review>[];
            final list =
                _hiddenOnly ? all.where((r) => r.hidden).toList() : all;
            if (list.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(AppDimens.xl),
                child: Text('No reviews here.',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: brand.textSecondary)),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...list.map((r) => _AdminReviewCard(review: r)),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimens.md),
                    child: all.length >= _limit
                        ? OutlinedButton.icon(
                            onPressed: () =>
                                setState(() => _limit += _pageSize),
                            icon: const Icon(Icons.expand_more_rounded, size: 18),
                            label: const Text('Load more'),
                          )
                        : Text('${all.length} reviews',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: brand.textSecondary)),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _AdminReviewCard extends StatefulWidget {
  final Review review;
  const _AdminReviewCard({required this.review});

  @override
  State<_AdminReviewCard> createState() => _AdminReviewCardState();
}

class _AdminReviewCardState extends State<_AdminReviewCard> {
  late final _reply =
      TextEditingController(text: widget.review.adminReply ?? '');
  bool _busy = false;

  @override
  void dispose() {
    _reply.dispose();
    super.dispose();
  }

  void _toast(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> _run(Future<void> Function() action, String ok) async {
    setState(() => _busy = true);
    try {
      await action();
      _toast(ok);
    } catch (e) {
      _toast('Failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final r = widget.review;
    final repo = ReviewRepository.instance;
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.md),
      padding: const EdgeInsets.all(AppDimens.md),
      decoration: BoxDecoration(
        color: brand.card,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(
            color: r.hidden ? AppColors.berry.withValues(alpha: 0.5) : brand.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                    '${r.productName.isEmpty ? r.productId : r.productName} · ${r.userName.isEmpty ? 'Customer' : r.userName}',
                    style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700, color: brand.textPrimary)),
              ),
              if (r.hidden)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.berry.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppDimens.radiusPill),
                  ),
                  child: Text('Hidden',
                      style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.berry,
                          fontWeight: FontWeight.w700,
                          fontSize: 11)),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              StarRating(r.rating.toDouble(), size: 15),
              const SizedBox(width: AppDimens.sm),
              if (r.createdAt != null)
                Text(Format.date(r.createdAt!),
                    style: AppTextStyles.bodySmall
                        .copyWith(color: brand.textSecondary)),
            ],
          ),
          if (r.text.isNotEmpty) ...[
            const SizedBox(height: AppDimens.sm),
            Text(r.text,
                style: AppTextStyles.bodySmall
                    .copyWith(color: brand.textPrimary)),
          ],
          const SizedBox(height: AppDimens.sm),
          TextField(
            controller: _reply,
            minLines: 1,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Reply publicly (like Google reviews)…',
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
              ),
            ),
          ),
          const SizedBox(height: AppDimens.sm),
          Wrap(
            spacing: AppDimens.sm,
            children: [
              TextButton.icon(
                onPressed: _busy
                    ? null
                    : () => _run(() => repo.reply(r.id, _reply.text.trim()),
                        'Reply saved.'),
                icon: const Icon(Icons.reply_rounded, size: 18),
                label: const Text('Save reply'),
              ),
              TextButton.icon(
                onPressed: _busy
                    ? null
                    : () => _run(() => repo.setHidden(r.id, !r.hidden),
                        r.hidden ? 'Review shown.' : 'Review hidden.'),
                icon: Icon(
                    r.hidden
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 18),
                label: Text(r.hidden ? 'Show' : 'Hide'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
