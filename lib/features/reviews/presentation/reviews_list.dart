import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_api/frontend_api.dart';
import 'package:nopcommerce_mobile/features/reviews/presentation/review_card.dart';
import 'package:nopcommerce_mobile/features/reviews/presentation/review_providers.dart';

class ProductReviewsList extends ConsumerWidget {
  const ProductReviewsList({super.key, required this.reviews});
  final ProductReviewsModelDto reviews;

  static const _blue = Color(0xFF2C2E7B);
  static const _orange = Color(0xFFF5AD00);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BuiltList<ProductReviewModelDto>? reviewsList = reviews.items;
    final count = reviewsList?.length ?? 0;

    return RefreshIndicator(
      color: _blue,
      onRefresh: () =>
          ref.refresh(reviewProvider(reviews.productId).future),
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.of(context).padding.bottom + 16,
        ),
        itemCount: count + 1,
        itemBuilder: (context, index) {
          // Summary header
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(
                      color: _orange,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$count ${count == 1 ? 'Review' : 'Reviews'}',
                    style: const TextStyle(
                      color: _blue,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            );
          }
          return ProductReviewCard(reviewsList![index - 1]);
        },
      ),
    );
  }
}
