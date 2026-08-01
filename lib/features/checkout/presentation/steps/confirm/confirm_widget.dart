import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as https;
import 'package:nopcommerce_mobile/common_widgets/async_value.dart';
import 'package:nopcommerce_mobile/constants/app_constants.dart';
import 'package:nopcommerce_mobile/customize/screens/payment_webview_screen.dart';
import 'package:nopcommerce_mobile/customize/screens/web_secure_payment.dart';
import 'package:nopcommerce_mobile/customize/services/payment_service.dart';
import 'package:nopcommerce_mobile/customize/widgets/checkout/section_price_row.dart';
import 'package:nopcommerce_mobile/features/address/presentation/address_card.dart';
import 'package:nopcommerce_mobile/features/authentication/presentation/auth_providers.dart';
import 'package:nopcommerce_mobile/features/cart/domain/shopping_cart.dart';
import 'package:nopcommerce_mobile/features/cart/presentation/cart_providers.dart';
import 'package:nopcommerce_mobile/features/cart/presentation/shopping_cart/checkout_attribute/checkout_attribute_builder.dart';
import 'package:nopcommerce_mobile/features/cart/presentation/shopping_cart/shopping_cart_item.dart';
import 'package:nopcommerce_mobile/features/checkout/presentation/checkout_providers.dart';
import 'package:nopcommerce_mobile/frontend_api/lib/frontend_api.dart';
import 'package:nopcommerce_mobile/l10n/app_localizations_context.dart';
import 'package:nopcommerce_mobile/router/route_utils.dart';
import 'package:nopcommerce_mobile/utils/async_value_ui.dart';

class ConfirmForm extends ConsumerWidget {
  const ConfirmForm({this.onSave, super.key});

  final void Function(int? orderId, String? redirectToMethod)? onSave;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final confirmData = ref.watch(confirmOrder);

    return AsyncValueWidget<CheckoutConfirmModelDto?>(
      value: confirmData,
      data: (model) => ConfirmFormContents(
        confirm: (model ?? CheckoutConfirmModelDto()).toBuilder(),
        onSave: onSave,
      ),
    );
  }
}

class ConfirmFormContents extends ConsumerStatefulWidget {
  const ConfirmFormContents({super.key, this.onSave, required this.confirm});

  final CheckoutConfirmModelDtoBuilder confirm;
  final void Function(int? orderId, String? redirectToMethod)? onSave;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ConfirmFormContentsState();
}

class _ConfirmFormContentsState extends ConsumerState<ConfirmFormContents> {
  static const _blue = Color(0xFF2C2E7B);
  static const _orange = Color(0xFFF5AD00);

  final _node = FocusScopeNode();
  final dio = Dio();
  final now = DateTime.now();
  final random = Random();
  late var paymentMethod = '';
  bool processing = false;
  String _msg = '';

  Timer? _countdownTimer;
  int _timeLeft = 6;

  @override
  void dispose() {
    _node.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void checkStatus(String orderId) {
    _timeLeft = 6;
    _countdownTimer =
        Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (_timeLeft <= 0) {
        timer.cancel();
        context.pushNamed(Routes.orderDetails.name,
            pathParameters: {'id': orderId});
      } else {
        try {
          final response = await https.get(
            Uri.parse(
                'https://postgebeya.ethio.post/api/telebirr/check?orderId=$orderId'),
          );
          final data = jsonDecode(response.body);
          if (data['status'] == 'Paid') {
            timer.cancel();
            context.pushNamed(Routes.orderDetails.name,
                pathParameters: {'id': orderId});
          }
        } catch (_) {}
      }
      _timeLeft--;
    });
  }

  Future<void> _submit() async {
    final authRepository = ref.watch(authRepositoryProvider);
    String? authToken = authRepository.currentCustomer?.token;

    final controller = ref.read(checkoutControllerProvider.notifier);
    await controller.confirm().then((confirmOrderResponse) async {
      if (confirmOrderResponse != null) {
        if ((confirmOrderResponse.redirectToMethod ?? '') != '') {
          widget.onSave?.call(
              confirmOrderResponse.id, confirmOrderResponse.redirectToMethod);

          if (paymentMethod == 'EthSwitch') {
            setState(() {
              processing = true;
              _msg = 'Creating payment session...';
            });
            final paymentService = PaymentService(authToken!);
            final resp = await paymentService
                .createPayment(confirmOrderResponse.id.toString());
            setState(() => processing = false);
            if (!mounted) return;
            if (resp.success && resp.paymentUrl.isNotEmpty) {
              final result = await showDialog(
                context: context,
                builder: (context) => WebSecurePayment(
                    urlWeb: resp.paymentUrl,
                    orderId: resp.orderId,
                    paymentService: paymentService),
              );
              _refreshCart();
              if (result == true) {
                setState(() => _msg = 'Payment successful.');
                context.goNamed(Routes.orderDetails.name,
                    pathParameters: {
                      'id': confirmOrderResponse.id.toString()
                    });
              } else {
                setState(() => _msg = 'Payment not completed.');
                context.replaceNamed(Routes.orderDetails.name,
                    pathParameters: {
                      'id': confirmOrderResponse.id.toString()
                    });
              }
            } else {
              setState(() {
                _msg = 'System Failure';
                processing = false;
              });
            }
          }

          if (paymentMethod == 'telebirr') {
            setState(() {
              processing = true;
              _msg = 'Processing payment...';
            });
            _refreshCart();
            checkStatus(confirmOrderResponse.id.toString());
          }

          if (paymentMethod == 'Cybersource') {
            final paymentService = PaymentService(authToken!);
            final id = confirmOrderResponse.id.toString();
            final uri = Uri.parse(
                '${AppConstants.storeUrl}paymentcybersource/pay?orderId=$id');
            final result = await showDialog(
              context: context,
              builder: (context) => CybersourcePayment(
                  urlWeb: uri.toString(),
                  orderId: id,
                  paymentService: paymentService),
            );
            _refreshCart();
            if (result == true) {
              setState(() => _msg = 'Payment successful.');
              context.goNamed(Routes.orderDetails.name,
                  pathParameters: {'id': id});
            } else {
              setState(() => _msg = 'Payment not completed.');
              context.replaceNamed(Routes.orderDetails.name,
                  pathParameters: {'id': id});
            }
          }
        }
      } else {
        Navigator.of(context).pop();
      }
    });
  }

  void _refreshCart() {
    ref.refresh(shoppingCartFutureProvider.future).then(
      (value) => {
        ref.refresh(shoppingCartTotalsProvider.future),
        if (value?.items?.isNotEmpty ?? false)
          {ref.refresh(shoppingCartTotalsProvider.future)},
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.refresh(shoppingCartFutureProvider.future).then(
      (value) => {
        if (value?.items?.isNotEmpty ?? false)
          {ref.refresh(shoppingCartTotalsProvider.future)},
      },
    );
    ref.listen<AsyncValue<ShoppingCart>>(
      shoppingCartControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );

    final cartTotals = ref.watch(shoppingCartTotalsProvider);
    final orderData = widget.confirm.shoppingCart.orderReviewData;
    final state = ref.watch(checkoutControllerProvider);
    paymentMethod = orderData.paymentMethod ?? '';

    List<CheckoutAttributeModelDtoBuilder> checkoutAttributes = [];
    Map<CheckoutAttributeModelDtoBuilder,
        List<CheckoutAttributeValueModelDtoBuilder>?> attributeValues = {};
    widget.confirm.shoppingCart.checkoutAttributes.build().forEach((attr) {
      checkoutAttributes.add(attr.toBuilder());
    });

    var addressBuilder = orderData.shippingAddress;
    if (orderData.selectedPickupInStore ?? false) {
      addressBuilder = orderData.pickupAddress;
      addressBuilder.streetAddressEnabled =
          addressBuilder.cityEnabled =
              addressBuilder.countryEnabled =
                  addressBuilder.countyEnabled =
                      addressBuilder.stateProvinceEnabled =
                          addressBuilder.zipPostalCodeEnabled = true;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Billing address ──────────────────────────────────────────
        _SectionCard(
          icon: Icons.location_on_rounded,
          title: context.locale!.checkout_steps_confirm_billing_address,
          child: AddressCard(
            address: orderData.billingAddress.build(),
            isEditable: false,
          ),
        ),
        const SizedBox(height: 12),

        // ── Shipping / pickup address ────────────────────────────────
        _SectionCard(
          icon: Icons.local_shipping_rounded,
          title: (orderData.selectedPickupInStore ?? false)
              ? context.locale!.checkout_steps_confirm_pickup_point_address
              : context.locale!.checkout_steps_confirm_shipping_address,
          child: AddressCard(
              address: addressBuilder.build(), isEditable: false),
        ),
        const SizedBox(height: 12),

        // ── Shipping & payment method info ───────────────────────────
        Container(
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
              children: [
                _InfoRow(
                  icon: Icons.directions_car_rounded,
                  label: 'Shipping',
                  value: orderData.shippingMethod ?? '',
                ),
                const Divider(height: 20),
                _InfoRow(
                  icon: Icons.payment_rounded,
                  label: 'Payment',
                  value: orderData.paymentMethod ?? '',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // ── Items ────────────────────────────────────────────────────
        _SectionCard(
          icon: Icons.shopping_bag_rounded,
          title: 'ORDER ITEMS',
          child: Column(
            children: widget.confirm.shoppingCart.items.build().map((item) {
              return ShoppingCartItem(
                  item: item, isEditable: false, itemIndex: 0);
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),

        // ── Checkout attributes ──────────────────────────────────────
        if (checkoutAttributes.isNotEmpty) ...[
          _SectionCard(
            icon: Icons.tune_rounded,
            title: 'OPTIONS',
            child: CheckoutAttributeBuilder().buildAttributes(
              context,
              () {},
              checkoutAttributes,
              attributeValues,
              true,
            ),
          ),
          const SizedBox(height: 12),
        ],

        // ── Order totals ─────────────────────────────────────────────
        Container(
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
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                decoration: const BoxDecoration(
                  color: Color(0xFFF4F5FB),
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16)),
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
                      child: const Icon(Icons.receipt_long_rounded,
                          color: _blue, size: 16),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'ORDER TOTAL',
                      style: TextStyle(
                        color: _blue,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SectionPriceRow(
                      label: 'Sub-Total',
                      value: cartTotals.value?.subTotal ?? '',
                    ),
                    SectionPriceRow(
                      label: 'Shipping',
                      value: (cartTotals.value?.shipping?.isNotEmpty ?? false)
                          ? cartTotals.value!.shipping!
                          : context.locale!.cart_total_calc_during_checkout,
                      valueColor: Colors.black,
                    ),
                    if (cartTotals.value?.displayTax ?? false)
                      SectionPriceRow(
                        label: 'Tax',
                        value: cartTotals.value?.tax ?? '',
                      ),
                    // Total row highlighted
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: _blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700)),
                          Text(
                            (cartTotals.value?.orderTotal?.isNotEmpty ?? false)
                                ? cartTotals.value!.orderTotal!
                                : '',
                            style: const TextStyle(
                                color: _orange,
                                fontSize: 17,
                                fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ── Status message ───────────────────────────────────────────
        if (_msg.isNotEmpty)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _msg.contains('successful')
                  ? Colors.green.shade50
                  : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _msg.contains('successful')
                    ? Colors.green.shade200
                    : Colors.orange.shade200,
              ),
            ),
            child: Text(
              _msg,
              style: TextStyle(
                color: _msg.contains('successful')
                    ? Colors.green.shade700
                    : Colors.orange.shade700,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        if (_msg.isNotEmpty) const SizedBox(height: 12),

        // ── Confirm / Pay button ─────────────────────────────────────
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _orange,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: (processing || state.isLoading) ? null : _submit,
            child: (processing || state.isLoading)
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        processing ? 'Please Wait...' : 'Processing...',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock_rounded, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        context.locale!.checkout_steps_confirm_button,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

// ── Shared helpers ──────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  static const _blue = Color(0xFF2C2E7B);

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
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
                  child: Icon(icon, color: _blue, size: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    color: _blue,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  static const _blue = Color(0xFF2C2E7B);

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _blue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: _blue, size: 15),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 11,
                    fontWeight: FontWeight.w500)),
            Text(value,
                style: const TextStyle(
                    color: _blue,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}
