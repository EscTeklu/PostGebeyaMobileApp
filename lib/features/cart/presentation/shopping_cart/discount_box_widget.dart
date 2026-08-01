import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nopcommerce_mobile/features/app/scaffold_messenger_extansion.dart';
import 'package:nopcommerce_mobile/features/cart/domain/shopping_cart.dart';
import 'package:nopcommerce_mobile/features/cart/presentation/cart_providers.dart';
import 'package:nopcommerce_mobile/frontend_api/lib/frontend_api.dart';
import 'package:nopcommerce_mobile/l10n/app_localizations_context.dart';
import 'package:nopcommerce_mobile/utils/async_value_ui.dart';

class DiscountBox extends ConsumerStatefulWidget {
  const DiscountBox({super.key, this.discountBox});

  final DiscountBoxModelDto? discountBox;

  @override
  ConsumerState<DiscountBox> createState() => _DiscountBoxState();
}

class _DiscountBoxState extends ConsumerState<DiscountBox> {
  static const _blue = Color(0xFF2C2E7B);
  static const _orange = Color(0xFFF5AD00);

  String enteredCouponCode = '';
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<String?> _apply() async {
    final response = await ref
        .read(shoppingCartControllerProvider.notifier)
        .applyDiscountCoupon(enteredCouponCode);
    return response?.messages?.first;
  }

  Future<String?> _remove(DiscountInfoModelDto? item) async {
    final response = await ref
        .read(shoppingCartControllerProvider.notifier)
        .removeDiscountCoupon(item!.id!);
    return response?.messages?.first;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<ShoppingCart>>(
      shoppingCartControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );

    final state = ref.watch(shoppingCartControllerProvider);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _blue.withValues(alpha: 0.07),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.local_offer_rounded,
                    color: _orange,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'PROMO CODE',
                  style: TextStyle(
                    color: _blue,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Input row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    enabled: !state.isLoading,
                    onChanged: (v) => setState(() => enteredCouponCode = v),
                    textInputAction: TextInputAction.done,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: context.locale!.cart_discount_enter_code,
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 13,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF4F5FB),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: _blue),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _orange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                    ),
                    onPressed: state.isLoading
                        ? null
                        : () => _apply().then((value) {
                              if ((value?.isNotEmpty ?? false) &&
                                  context.mounted) {
                                showInSnackBar(context, value!);
                              }
                            }),
                    child: state.isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            context.locale!.global_button_apply,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                  ),
                ),
              ],
            ),

            // Applied coupons
            if (widget.discountBox?.appliedDiscountsWithCodes?.isNotEmpty ==
                true) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: widget.discountBox!.appliedDiscountsWithCodes!
                    .map(
                      (item) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 14,
                              color: Colors.green.shade600,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              item.couponCode ?? '',
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: state.isLoading
                                  ? null
                                  : () => _remove(item).then((value) {
                                        if ((value?.isNotEmpty ?? false) &&
                                            context.mounted) {
                                          showInSnackBar(context, value!);
                                        }
                                      }),
                              child: Icon(
                                Icons.close_rounded,
                                size: 14,
                                color: Colors.green.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
