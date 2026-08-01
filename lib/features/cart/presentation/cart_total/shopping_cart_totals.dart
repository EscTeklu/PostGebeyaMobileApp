import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_api/frontend_api.dart';
import 'package:nopcommerce_mobile/common_widgets/async_value.dart';
import 'package:nopcommerce_mobile/features/cart/presentation/cart_providers.dart';
import 'package:nopcommerce_mobile/features/cart/presentation/shopping_cart/gift_card_box_widget.dart';
import 'package:nopcommerce_mobile/l10n/app_localizations_context.dart';
import 'package:nopcommerce_mobile/utils/common_utility.dart';

class ShoppingCartTotals extends ConsumerWidget {
  const ShoppingCartTotals({super.key, this.giftCardBoxDisplay});

  final bool? giftCardBoxDisplay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartTotals = ref.watch(shoppingCartTotalsProvider);
    return AsyncValueWidget<OrderTotalsModelDto?>(
      value: cartTotals,
      data: (cartTotals) => CartTotalWidget(
        cartTotals: cartTotals,
        giftCardBoxDisplay: giftCardBoxDisplay,
      ),
    );
  }
}

class CartTotalWidget extends StatelessWidget {
  const CartTotalWidget({
    super.key,
    required this.cartTotals,
    this.giftCardBoxDisplay,
  });

  final OrderTotalsModelDto? cartTotals;
  final bool? giftCardBoxDisplay;

  static const _blue = Color(0xFF2C2E7B);
  static const _orange = Color(0xFFF5AD00);

  @override
  Widget build(BuildContext context) {
    final discountValue =
        (cartTotals?.subTotalDiscount?.isNotEmpty ?? false)
            ? cartTotals?.subTotalDiscount
            : ((cartTotals?.orderTotalDiscount?.isNotEmpty ?? false)
                ? cartTotals?.orderTotalDiscount
                : null);

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
            decoration: const BoxDecoration(
              color: Color(0xFFF4F5FB),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _blue.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    color: _blue,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'ORDER SUMMARY',
                  style: TextStyle(
                    color: _blue,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),

          if (giftCardBoxDisplay ?? false)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: GiftCardBox(giftCardBox: cartTotals?.giftCards),
            ),

          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            child: Column(
              children: [
                _TotalRow(
                  label: context.locale!.cart_total_subtotal,
                  value: cartTotals?.subTotal ?? '',
                ),
                _divider(),
                _TotalRow(
                  label: context.locale!.cart_total_shipping,
                  value: (cartTotals?.shipping?.isNotEmpty ?? false)
                      ? cartTotals!.shipping!
                      : context.locale!.cart_total_calc_during_checkout,
                ),
                if (discountValue?.isNotEmpty ?? false) ...[
                  _divider(),
                  _TotalRow(
                    label: context.locale!.cart_total_discount,
                    value: discountValue ?? '',
                    valueColor: Colors.green.shade600,
                  ),
                ],
                if (cartTotals?.displayTax ?? false) ...[
                  _divider(),
                  _TotalRow(
                    label: context.locale!.cart_total_tax,
                    value: cartTotals?.tax ?? '',
                  ),
                ],
                if ((cartTotals?.redeemedRewardPoints ?? 0) > 0) ...[
                  _divider(),
                  _TotalRow(
                    label: context.locale!.cart_total_reward_points
                        .format([cartTotals?.redeemedRewardPoints ?? 0]),
                    value: cartTotals?.redeemedRewardPointsAmount ?? '',
                    valueColor: Colors.green.shade600,
                  ),
                ],
                if (cartTotals?.paymentMethodAdditionalFee != null) ...[
                  _divider(),
                  _TotalRow(
                    label: context.locale!.cart_total_payment_additional_fee,
                    value: cartTotals?.paymentMethodAdditionalFee ?? '',
                  ),
                ],
                if ((cartTotals?.willEarnRewardPoints ?? 0) != 0) ...[
                  _divider(),
                  _TotalRow(
                    label: context.locale!.cart_total_will_earn_reward_points_title,
                    value: context.locale!.cart_total_will_earn_reward_points
                        .format([cartTotals?.willEarnRewardPoints]),
                  ),
                ],

                // Total row — highlighted
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: _blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        (cartTotals?.orderTotal?.isNotEmpty ?? false)
                            ? cartTotals!.orderTotal!
                            : context.locale!.cart_total_calc_during_checkout,
                        style: const TextStyle(
                          color: _orange,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(height: 16, thickness: 0.8);
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? const Color(0xFF2C2E7B),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.end,
        ),
      ],
    );
  }
}
