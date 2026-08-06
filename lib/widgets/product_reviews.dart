import 'package:flutter/material.dart';

import '../core/constants/app_dimens.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../data/models/review.dart';
import '../data/review_repository.dart';
import '../state/auth_controller.dart';
import '../utils/format.dart';
import 'star_rating.dart';

/// Ratings & reviews block for the product detail page: average summary and the
/// visible reviews with any admin replies. Customers write reviews from their
/// orders; here they can edit/delete their own reviews inline.
class ProductReviews extends StatelessWidget {
  final String productId;
  final String productName;
  const ProductReviews(
      {super.key, required this.productId, required this.productName});

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return StreamBuilder<List<Review>>(
      stream: ReviewRepository.instance.forProduct(productId),
      builder: (context, snap) {
        final all = snap.data ?? const <Review>[];
        final visible = all.where((r) => !r.hidden).toList();
        final avg = visible.isEmpty
            ? 0.0
            : visible.fold<int>(0, (s, r) => s + r.rating) / visible.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ratings & Reviews',
                style: AppTextStyles.h2.copyWith(color: brand.textPrimary)),
            const SizedBox(height: AppDimens.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(visible.isEmpty ? '—' : avg.toStringAsFixed(1),
                    style: AppTextStyles.h1
                        .copyWith(color: brand.textPrimary, fontSize: 40)),
                const SizedBox(width: AppDimens.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StarRating(avg, size: 20),
                    const SizedBox(height: 2),
                    Text(
                        visible.isEmpty
                            ? 'No reviews yet'
                            : '${visible.length} review${visible.length == 1 ? '' : 's'}',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: brand.textSecondary)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppDimens.lg),
            if (visible.isEmpty)
              Text('Be the first to review this product.',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: brand.textSecondary))
            else
              ...visible.map((r) => _ReviewTile(review: r)),
          ],
        );
      },
    );
  }
}

/// Opens the write/edit review dialog for a specific order + product. Pass
/// [reviewId] when editing an existing review; otherwise it's derived from the
/// order + product (one review per product per order).
Future<void> showProductReviewDialog(
  BuildContext context, {
  required String productId,
  required String productName,
  required String uid,
  required String userName,
  required String orderId,
  String? reviewId,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _ReviewDialog(
      reviewId: reviewId ?? Review.docId(orderId, productId),
      productId: productId,
      productName: productName,
      uid: uid,
      userName: userName.trim().isEmpty ? 'Customer' : userName.trim(),
      orderId: orderId,
    ),
  );
}

/// Confirms and deletes a review the current user owns.
Future<void> confirmDeleteReview(BuildContext context, String reviewId) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete your review?'),
      content: const Text('This removes your rating and review for good.'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel')),
        FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.berry),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete')),
      ],
    ),
  );
  if (ok != true) return;
  try {
    await ReviewRepository.instance.deleteMine(reviewId);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your review was deleted.')));
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not delete: $e')));
    }
  }
}

class _ReviewTile extends StatelessWidget {
  final Review review;
  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final auth = AuthController.instance;
    final isMine = auth.isSignedIn && auth.user!.uid == review.uid;
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.md),
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
                    review.userName.isEmpty ? 'Customer' : review.userName,
                    style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: brand.textPrimary)),
              ),
              if (review.createdAt != null)
                Text(Format.date(review.createdAt!),
                    style: AppTextStyles.bodySmall
                        .copyWith(color: brand.textSecondary)),
              if (isMine)
                SizedBox(
                  height: 28,
                  width: 28,
                  child: PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    tooltip: 'Manage your review',
                    icon: const Icon(Icons.more_vert_rounded, size: 18),
                    onSelected: (v) {
                      if (v == 'edit') {
                        showProductReviewDialog(
                          context,
                          reviewId: review.id,
                          productId: review.productId,
                          productName: review.productName,
                          uid: review.uid,
                          userName: review.userName,
                          orderId: review.orderId,
                        );
                      } else if (v == 'delete') {
                        confirmDeleteReview(context, review.id);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          StarRating(review.rating.toDouble(), size: 16),
          if (review.text.isNotEmpty) ...[
            const SizedBox(height: AppDimens.sm),
            Text(review.text,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: brand.textSecondary)),
          ],
          if (review.hasReply) ...[
            const SizedBox(height: AppDimens.md),
            Container(
              padding: const EdgeInsets.all(AppDimens.sm + 2),
              decoration: BoxDecoration(
                color: brand.cardSoft,
                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                border: Border(
                    left: BorderSide(color: AppColors.primaryGreen, width: 3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Response from Rootaura',
                      style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(review.adminReply!,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: brand.textPrimary)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReviewDialog extends StatefulWidget {
  final String reviewId;
  final String productId;
  final String productName;
  final String uid;
  final String userName;
  final String orderId;
  const _ReviewDialog({
    required this.reviewId,
    required this.productId,
    required this.productName,
    required this.uid,
    required this.userName,
    required this.orderId,
  });

  @override
  State<_ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<_ReviewDialog> {
  int _rating = 0;
  final _text = TextEditingController();
  bool _saving = false;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    // Prefill this order+product's existing review, if any.
    ReviewRepository.instance.byId(widget.reviewId).then((existing) {
      if (existing != null && mounted) {
        setState(() {
          _rating = existing.rating;
          _text.text = existing.text;
          _editing = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete your review?'),
        content: const Text('This removes your rating and review for good.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.berry),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _saving = true);
    try {
      await ReviewRepository.instance.deleteMine(widget.reviewId);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Your review was deleted.')));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not delete: $e')));
      }
    }
  }

  Future<void> _submit() async {
    if (_rating < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please pick a star rating.')));
      return;
    }
    setState(() => _saving = true);
    try {
      await ReviewRepository.instance.submit(Review(
        id: widget.reviewId,
        productId: widget.productId,
        productName: widget.productName,
        orderId: widget.orderId,
        uid: widget.uid,
        userName: widget.userName,
        rating: _rating,
        text: _text.text.trim(),
      ));
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thanks for your review!')));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not submit review: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_editing ? 'Edit review' : 'Write a review'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.productName, style: AppTextStyles.bodySmall),
          const SizedBox(height: AppDimens.sm),
          Center(
            child: StarInput(
                value: _rating, onChanged: (v) => setState(() => _rating = v)),
          ),
          const SizedBox(height: AppDimens.md),
          TextField(
            controller: _text,
            minLines: 3,
            maxLines: 5,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Share your experience (optional)',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        if (_editing)
          TextButton(
            onPressed: _saving ? null : _delete,
            style: TextButton.styleFrom(foregroundColor: AppColors.berry),
            child: const Text('Delete'),
          ),
        TextButton(
            onPressed: _saving ? null : () => Navigator.pop(context),
            child: const Text('Cancel')),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: Text(_saving ? 'Saving…' : 'Submit'),
        ),
      ],
    );
  }
}
