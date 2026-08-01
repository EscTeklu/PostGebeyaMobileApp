import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_api/frontend_api.dart';
import 'package:go_router/go_router.dart';
import 'package:nopcommerce_mobile/common_widgets/custom_text_form_field.dart';
import 'package:nopcommerce_mobile/features/app/scaffold_messenger_extansion.dart';
import 'package:nopcommerce_mobile/features/reviews/presentation/review_providers.dart';
import 'package:nopcommerce_mobile/l10n/app_localizations_context.dart';
import 'package:nopcommerce_mobile/router/route_utils.dart';
import 'package:nopcommerce_mobile/utils/async_value_ui.dart';

class AddReviewScreen extends StatelessWidget {
  final AddProductReviewModelDtoBuilder review =
      AddProductReviewModelDtoBuilder();

  AddReviewScreen({super.key, required this.productId});

  final int productId;

  static const _blue = Color(0xFF2C2E7B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FB),
      appBar: AppBar(
        backgroundColor: _blue,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          context.locale!.reviews_add_title,
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
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          16,
          20,
          16,
          MediaQuery.of(context).padding.bottom + 20,
        ),
        child: AddReviewForm(productId: productId, review: review),
      ),
    );
  }
}

class AddReviewForm extends ConsumerStatefulWidget {
  final AddProductReviewModelDtoBuilder review;
  final int productId;

  const AddReviewForm({
    super.key,
    required this.productId,
    required this.review,
  });

  @override
  ConsumerState<AddReviewForm> createState() => _AddReviewFormState();
}

class _AddReviewFormState extends ConsumerState<AddReviewForm> {
  static const _blue = Color(0xFF2C2E7B);
  static const _orange = Color(0xFFF5AD00);

  double _rating = 5;
  bool _submitted = false;
  final _formKey = GlobalKey<FormState>();

  static const _ratingLabels = [
    'Terrible',
    'Poor',
    'Average',
    'Good',
    'Excellent',
  ];

  Future<void> _submitReview() async {
    setState(() => _submitted = true);
    _formKey.currentState!.save();

    if (_formKey.currentState!.validate()) {
      final controller = ref.read(addReviewControllerProvider.notifier);
      widget.review.rating = _rating.round();

      await controller.submit(widget.productId, widget.review).then((value) {
        if (!value) {
          setState(() => _submitted = false);
        } else if (mounted) {
          showInSnackBar(context, context.locale!.global_message_save);
          ref.invalidate(reviewProvider(widget.productId));
          context.goNamed(
            Routes.review.name,
            pathParameters: {'id': widget.productId.toString()},
          );
        }
      });
    } else {
      showInSnackBar(context, context.locale!.global_fix_error);
    }
  }

  Widget _sectionHeader(String title) {
    return Row(
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
          title,
          style: const TextStyle(
            color: _blue,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue>(
      addReviewControllerProvider.select((state) => state.value),
      (_, state) => state.showAlertDialogOnError(context),
    );

    final state = ref.watch(addReviewControllerProvider);
    final ratingLabel = _ratingLabels[(_rating.round() - 1).clamp(0, 4)];

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Star rating card ───────────────────────────────────────────
          Container(
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
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _sectionHeader('YOUR RATING'),
                const SizedBox(height: 20),
                RatingBar.builder(
                  itemSize: 46,
                  initialRating: _rating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  itemCount: 5,
                  glow: false,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4),
                  itemBuilder: (context, _) =>
                      const Icon(Icons.star_rounded, color: _orange),
                  unratedColor: Color(0xFFDDDDDD),
                  onRatingUpdate: (rating) {
                    setState(() {
                      _formKey.currentState!.save();
                      _rating = rating;
                    });
                  },
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 6),
                  decoration: BoxDecoration(
                    color: _orange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    ratingLabel,
                    style: const TextStyle(
                      color: _orange,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── Review form card ───────────────────────────────────────────
          Container(
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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader('WRITE YOUR REVIEW'),
                const SizedBox(height: 20),

                // Title field
                CustomerTextFormField(
                  context.locale!.reviews_add_your_title,
                  (value) => widget.review.title = value,
                  required: true,
                  value: widget.review.title,
                  submitted: _submitted,
                  enabled: !state.isLoading,
                ),
                const SizedBox(height: 14),

                // Review text field
                CustomerTextFormField(
                  context.locale!.reviews_add_your_text,
                  (value) => widget.review.reviewText = value,
                  required: true,
                  maxLines: 6,
                  submitted: _submitted,
                  value: widget.review.reviewText,
                  enabled: !state.isLoading,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Submit button ──────────────────────────────────────────────
          SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed: (state.isLoading || _rating == 0)
                  ? null
                  : _submitReview,
              icon: state.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send_rounded, size: 20),
              label: Text(
                context.locale!.reviews_add_submit,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _orange,
                foregroundColor: Colors.white,
                disabledBackgroundColor: _orange.withValues(alpha: 0.4),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
