import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_api/frontend_api.dart';
import 'package:go_router/go_router.dart';
import 'package:nopcommerce_mobile/common_widgets/async_value.dart';
import 'package:nopcommerce_mobile/common_widgets/items_not_found.dart';
import 'package:nopcommerce_mobile/features/app/scaffold_messenger_extansion.dart';
import 'package:nopcommerce_mobile/features/reviews/presentation/review_providers.dart';
import 'package:nopcommerce_mobile/features/reviews/presentation/reviews_list.dart';
import 'package:nopcommerce_mobile/l10n/app_localizations_context.dart';
import 'package:nopcommerce_mobile/router/route_utils.dart';

class ProductReviewScreen extends ConsumerWidget {
  const ProductReviewScreen({super.key, required this.productId});

  final int productId;
  static const writeReviewKey = Key('write-review');

  static const _blue = Color(0xFF2C2E7B);
  static const _orange = Color(0xFFF5AD00);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allowReviewValue = ref.watch(allowReviewProvider(productId));

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FB),
      appBar: AppBar(
        backgroundColor: _blue,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          context.locale!.reviews_title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 18),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        actions: [
          AsyncValueWidget<BuiltList<String>?>(
            value: allowReviewValue,
            data: (errors) => Container(
              margin:
                  const EdgeInsets.only(right: 12, top: 8, bottom: 8),
              decoration: BoxDecoration(
                color: _orange.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                key: writeReviewKey,
                icon: const Icon(Icons.rate_review_rounded,
                    color: Colors.white, size: 20),
                onPressed: () => (errors?.isNotEmpty ?? true)
                    ? showInSnackBar(context, errors![0])
                    : context.goNamed(
                        Routes.addReview.name,
                        pathParameters: {'id': productId.toString()},
                      ),
              ),
            ),
          ),
        ],
      ),
      body: Consumer(
        builder: (context, ref, _) {
          final reviewValue = ref.watch(reviewProvider(productId));

          return AsyncValueWidget<ProductReviewsModelDto?>(
            value: reviewValue,
            data: (review) => review?.items?.isEmpty ?? true
                ? ItemsNotFound(
                    text: context.locale!.reviews_no_found,
                  )
                : ProductReviewsList(reviews: review!),
          );
        },
      ),
    );
  }
}
