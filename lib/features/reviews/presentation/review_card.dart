import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_api/frontend_api.dart';
import 'package:nopcommerce_mobile/common_widgets/custom_image.dart';
import 'package:nopcommerce_mobile/features/app/scaffold_messenger_extansion.dart';
import 'package:nopcommerce_mobile/features/reviews/presentation/review_providers.dart';
import 'package:nopcommerce_mobile/l10n/app_localizations_context.dart';
import 'package:nopcommerce_mobile/utils/async_value_ui.dart';

class ProductReviewCard extends ConsumerStatefulWidget {
  const ProductReviewCard(this.review, {super.key});
  final ProductReviewModelDto review;

  @override
  ConsumerState<ProductReviewCard> createState() => _ProductReviewCardState();
}

class _ProductReviewCardState extends ConsumerState<ProductReviewCard> {
  static const _blue = Color(0xFF2C2E7B);
  static const _orange = Color(0xFFF5AD00);

  late int _totalYes;
  late int _totalNo;

  @override
  void initState() {
    super.initState();
    _totalYes = widget.review.helpfulness?.helpfulYesTotal ?? 0;
    _totalNo = widget.review.helpfulness?.helpfulNoTotal ?? 0;
  }

  Future<void> _setHelpfulness(bool wasHelpful) async {
    final controller = ref.read(reviewControllerProvider.notifier);
    await controller
        .setProductReviewHelpfulness(widget.review.id!, wasHelpful)
        .then((response) {
      setState(() {
        _totalYes = response?.totalYes ?? 0;
        _totalNo = response?.totalNo ?? 0;
      });
      if (mounted) {
        showInSnackBar(
          context,
          response?.result ?? context.locale!.global_message_save,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue>(
      reviewControllerProvider.select((state) => state.value),
      (_, state) => state.showAlertDialogOnError(context),
    );

    final avatarUrl = widget.review.customerAvatarUrl ?? '';
    final name = widget.review.customerName ?? '';
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final rating = widget.review.rating?.floorToDouble() ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _blue.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header: avatar + name + rating ──────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _blue.withValues(alpha: 0.1),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: avatarUrl.isNotEmpty
                      ? CustomImage(url: avatarUrl, fit: BoxFit.cover)
                      : Center(
                          child: Text(
                            initials,
                            style: const TextStyle(
                              color: _blue,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 12),

                // Name + rating
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(
                                color: _blue,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Star rating
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(5, (i) {
                              return Icon(
                                i < rating
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                color: _orange,
                                size: 16,
                              );
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      // Date
                      Text(
                        widget.review.writtenOnStr ?? '',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ── Review title ─────────────────────────────────────────────
            if (widget.review.title?.isNotEmpty ?? false) ...[
              const SizedBox(height: 12),
              Text(
                widget.review.title!,
                style: const TextStyle(
                  color: _blue,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],

            // ── Review text ──────────────────────────────────────────────
            if (widget.review.reviewText?.isNotEmpty ?? false) ...[
              const SizedBox(height: 6),
              Text(
                widget.review.reviewText!,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],

            const SizedBox(height: 12),
            Divider(color: Colors.grey.shade100, height: 1),
            const SizedBox(height: 12),

            // ── Helpfulness row ──────────────────────────────────────────
            Row(
              children: [
                Text(
                  context.locale!.reviews_helpful,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const Spacer(),
                // Yes button
                GestureDetector(
                  onTap: () => _setHelpfulness(true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.thumb_up_alt_outlined,
                            size: 14, color: Colors.green.shade600),
                        const SizedBox(width: 4),
                        Text(
                          '$_totalYes',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // No button
                GestureDetector(
                  onTap: () => _setHelpfulness(false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.thumb_down_alt_outlined,
                            size: 14, color: Colors.red.shade400),
                        const SizedBox(width: 4),
                        Text(
                          '$_totalNo',
                          style: TextStyle(
                            color: Colors.red.shade500,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
