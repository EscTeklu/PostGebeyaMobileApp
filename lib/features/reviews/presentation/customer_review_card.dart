import 'package:flutter/material.dart';
import 'package:frontend_api/frontend_api.dart';
import 'package:go_router/go_router.dart';
import 'package:nopcommerce_mobile/common_widgets/product_rating.dart';
import 'package:nopcommerce_mobile/l10n/app_localizations_context.dart';
import 'package:nopcommerce_mobile/router/route_utils.dart';

const _blue = Color(0xFF2C2E7B);

class CustomerProductReviewCard extends StatelessWidget {
  const CustomerProductReviewCard(this.review, {super.key});
  final CustomerProductReviewModelDto review;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + rating row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  review.title ?? '',
                  style: const TextStyle(
                    color: _blue,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              ProductRating(
                initRating: review.rating?.floorToDouble() ?? 0.0,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Review text
          if (review.reviewText?.isNotEmpty ?? false) ...[
            Text(
              review.reviewText!,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Divider
          Divider(color: Colors.grey.shade200, height: 1),
          const SizedBox(height: 10),

          // For product + date row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.locale!.reviews_for,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    GestureDetector(
                      onTap: () => context.pushNamed(
                        Routes.product.name,
                        pathParameters: {
                          'id': review.productId.toString(),
                        },
                      ),
                      child: Text(
                        review.productName ?? '',
                        style: const TextStyle(
                          color: _blue,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    context.locale!.reviews_date,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    review.writtenOnStr ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
