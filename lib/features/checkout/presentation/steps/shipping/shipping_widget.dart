import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nopcommerce_mobile/common_widgets/async_value.dart';
import 'package:nopcommerce_mobile/features/checkout/presentation/checkout_providers.dart';
import 'package:nopcommerce_mobile/features/checkout/presentation/steps/shipping/pickup_points_form.dart';
import 'package:nopcommerce_mobile/features/checkout/presentation/steps/shipping/shipping_address_form.dart';
import 'package:nopcommerce_mobile/features/checkout/presentation/steps/shipping/shipping_methods_form.dart';
import 'package:nopcommerce_mobile/frontend_api/lib/frontend_api.dart';
import 'package:nopcommerce_mobile/l10n/app_localizations_context.dart';

class ShippingForm extends ConsumerStatefulWidget {
  const ShippingForm({
    required this.onStepContinue,
    required this.useBillingAddressAsShippingAddress,
    super.key,
  });

  final VoidCallback onStepContinue;
  final bool useBillingAddressAsShippingAddress;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ShippingFormContentsState();
}

class _ShippingFormContentsState extends ConsumerState<ShippingForm> {
  static const _blue = Color(0xFF2C2E7B);
  static const _orange = Color(0xFFF5AD00);

  bool usePickupPoint = false;

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (usePickupPoint && !widget.useBillingAddressAsShippingAddress) {
      setState(() => usePickupPoint = !widget.useBillingAddressAsShippingAddress);
    }
    if (usePickupPoint && widget.useBillingAddressAsShippingAddress) {
      setState(() => usePickupPoint = !usePickupPoint);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shippingAddressData = ref.watch(shippingAddress);
    final shippingMethodsData = ref.watch(shippingMethods);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Pickup point toggle ──────────────────────────────────────
        if (!widget.useBillingAddressAsShippingAddress) ...[
          GestureDetector(
            onTap: () => setState(() => usePickupPoint = !usePickupPoint),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: usePickupPoint
                    ? _blue.withValues(alpha: 0.06)
                    : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: usePickupPoint
                      ? _blue.withValues(alpha: 0.35)
                      : Colors.grey.shade200,
                  width: usePickupPoint ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _blue.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: usePickupPoint
                          ? _orange.withValues(alpha: 0.15)
                          : const Color(0xFFF4F5FB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.store_rounded,
                      color: usePickupPoint ? _orange : Colors.grey.shade500,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.locale!
                          .checkout_steps_shipping_pickup_points_switch,
                      style: TextStyle(
                        fontSize: 14,
                        color: usePickupPoint ? _blue : Colors.grey.shade700,
                        fontWeight: usePickupPoint
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                  // Toggle indicator
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 42,
                    height: 24,
                    decoration: BoxDecoration(
                      color: usePickupPoint ? _orange : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 200),
                      alignment: usePickupPoint
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        width: 20,
                        height: 20,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        // ── Pickup points ────────────────────────────────────────────
        if (usePickupPoint)
          AsyncValueWidget<CheckoutShippingAddressModelDto?>(
            value: shippingAddressData,
            data: (response) => PickupPointsFormContents(
              onStepContinue: widget.onStepContinue,
              pickupPoints: response?.pickupPointsModel ??
                  CheckoutPickupPointsModelDto(),
            ),
          ),

        // ── Shipping address + methods ───────────────────────────────
        if (!usePickupPoint) ...[
          if (!widget.useBillingAddressAsShippingAddress)
            AsyncValueWidget<CheckoutShippingAddressModelDto?>(
              value: shippingAddressData,
              data: (addresses) => ShippingFormContents(
                addresses:
                    (addresses ?? CheckoutShippingAddressModelDto()).toBuilder(),
              ),
            ),
          AsyncValueWidget<ShippingMethodResponse?>(
            value: shippingMethodsData,
            data: (response) => ShippingMethodsFormContents(
              onStepContinue: widget.onStepContinue,
              shippingMethodResponse: response ?? ShippingMethodResponse(),
            ),
          ),
        ],
      ],
    );
  }
}
