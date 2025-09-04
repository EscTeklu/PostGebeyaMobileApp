import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nopcommerce_mobile/common_widgets/async_value.dart';
import 'package:nopcommerce_mobile/common_widgets/custom_filled_button.dart';
import 'package:nopcommerce_mobile/constants/app_constants.dart';
import 'package:nopcommerce_mobile/customize/screens/payment_webview_screen.dart';
import 'package:nopcommerce_mobile/customize/services/payment_service.dart';
import 'package:nopcommerce_mobile/customize/widgets/checkout/section_price_row.dart';
import 'package:nopcommerce_mobile/features/address/presentation/address_card.dart';
import 'package:nopcommerce_mobile/features/authentication/presentation/auth_providers.dart';
import 'package:nopcommerce_mobile/features/cart/presentation/cart_providers.dart';
import 'package:nopcommerce_mobile/features/cart/presentation/shopping_cart/checkout_attribute/checkout_attribute_builder.dart';
import 'package:nopcommerce_mobile/features/cart/presentation/shopping_cart/shopping_cart_item.dart';
import 'package:nopcommerce_mobile/features/checkout/presentation/checkout_providers.dart';
import 'package:nopcommerce_mobile/frontend_api/lib/frontend_api.dart';
import 'package:nopcommerce_mobile/l10n/app_localizations_context.dart';
import 'package:nopcommerce_mobile/router/route_utils.dart';
import 'package:nopcommerce_mobile/utils/common_utility.dart';

class ConfirmForm extends ConsumerWidget {
  const ConfirmForm({this.onSave, super.key});

  final void Function(int? orderId, String? redirectToMethod)? onSave;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final confirmData = ref.watch(confirmOrder);

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: AsyncValueWidget<CheckoutConfirmModelDto?>(
              value: confirmData,
              data:
                  (model) => ConfirmFormContents(
                    confirm: (model ?? CheckoutConfirmModelDto()).toBuilder(),
                    onSave: onSave,
                  ),
            ),
          ),
        ],
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
  final _node = FocusScopeNode();
  AddressModelDto? curentItem;
  final dio = Dio();
  final now = DateTime.now();
  final random = Random();
  late var paymentMethod = '';
  //
   // Replace with your Nop URL/ngrok
  //final TransactionHistoryService historyService = TransactionHistoryService();
  bool processing = false;
  String _msg = "";
  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }
  Future<void> _submit() async {
    final authRepository = ref.watch(authRepositoryProvider);

    String? authToken = authRepository.currentCustomer?.token;
    //print(authToken);
    //
    final controller = ref.read(checkoutControllerProvider.notifier);
    await controller.confirm().then((confirmOrderResponse) async {
      if (confirmOrderResponse != null) {
        print("================== CONFIRM RESPONSE  ==================: $confirmOrderResponse");

        if ((confirmOrderResponse.redirectToMethod ?? '') != '') {
          widget.onSave?.call(
            confirmOrderResponse.id,
            confirmOrderResponse.redirectToMethod,
          );
          //
          if(paymentMethod == 'ETHIOSWITCH')
          {
            setState(() {
              processing = true;
              _msg = "Creating payment session...";
            });
            final PaymentService paymentService = PaymentService(authToken!);
            final resp = await paymentService.createPayment(
                confirmOrderResponse.id.toString());
            setState(() {
              processing = false;
            });
            if (!mounted) return;
            if (resp.success && resp.paymentUrl.isNotEmpty) {
              final result = await showDialog(
                context: context,
                builder:
                    (context) =>
                    PaymentWebViewScreen(url: resp.paymentUrl,
                        orderId: resp.orderId,
                        paymentService: paymentService),
              );
              if (result == true) {
                setState(() {
                  _msg = "Payment successful.";
                });
                ref.refresh(shoppingCartFutureProvider.future).then(
                      (value) =>
                  {
                    if (value?.items?.isNotEmpty ?? false)
                      {
                        ref.refresh(shoppingCartTotalsProvider.future),
                      }
                  },
                );

                context.goNamed(
                  Routes.orderDetails.name,
                  pathParameters: {'id': confirmOrderResponse.id.toString()},
                );
              } else {
                setState(() {
                  _msg = "Payment not completed.";
                });
                ref.refresh(shoppingCartFutureProvider.future).then(
                      (value) =>
                  {
                    if (value?.items?.isNotEmpty ?? false)
                      {
                        ref.refresh(shoppingCartTotalsProvider.future),
                      }
                  },
                );
                context.goNamed(
                  Routes.orderDetails.name,
                  pathParameters: {'id': confirmOrderResponse.id.toString()},
                );
              }
            } else {
              setState(() {
                _msg = "System Failure";
              });
              setState(() {
                processing = false;
              });
            }
          }
        }
      }
      else {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartTotals = ref.watch(shoppingCartTotalsProvider);
    //var orderTotal = widget.confirm.orderTotals.orderTotal;
    //
    final orderData = widget.confirm.shoppingCart.orderReviewData;
    final state = ref.watch(checkoutControllerProvider);
    paymentMethod = orderData.paymentMethod!;
    List<CheckoutAttributeModelDtoBuilder> checkoutAttributes = [];
    Map<
      CheckoutAttributeModelDtoBuilder,
      List<CheckoutAttributeValueModelDtoBuilder>?
    >
    attributeValues = {};

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

    return Container(
      decoration: ShapeDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                context.locale!.checkout_steps_confirm_billing_address,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          AddressCard(
            address: orderData.billingAddress.build(),
            isEditable: false,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                (orderData.selectedPickupInStore ?? false)
                    ? context
                        .locale!
                        .checkout_steps_confirm_pickup_point_address
                    : context.locale!.checkout_steps_confirm_shipping_address,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          AddressCard(address: addressBuilder.build(), isEditable: false),
          Card(
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Text(
                  context.locale!.checkout_steps_confirm_shipping_method.format(
                    [orderData.shippingMethod ?? ''],
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
          ),
          Card(
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Text(
                  context.locale!.checkout_steps_confirm_payment_method.format([
                    orderData.paymentMethod ?? '',
                  ]),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
          ),
          Column(
            children:
                widget.confirm.shoppingCart.items.build().map((item) {
                  return ShoppingCartItem(
                    item: item,
                    isEditable: false,
                    itemIndex: 0,
                  );
                }).toList(),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CheckoutAttributeBuilder().buildAttributes(
              context,
              () {},
              checkoutAttributes,
              attributeValues,
              true,
            ),
          ),
          //const ShoppingCartTotals(),
          Card(
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    SectionPriceRow(label: 'Sub-Total', value: cartTotals.value!.subTotal ?? ''),
                    SectionPriceRow(
                        label: 'Shipping',
                        value: (cartTotals.value!.shipping?.isNotEmpty ?? false)
                            ? cartTotals.value!.shipping ?? ""
                            : context.locale!.cart_total_calc_during_checkout,
                        valueColor: Colors.black),
                    const SectionPriceRow(label: 'Tax', value: '\$0.00'),
                    SectionPriceRow(
                        label: 'Total', value: cartTotals.value!.orderTotal?? "", isBold: true),
                  ],
                ),
              ),
            ),
          ),


          /*Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomFilledButton(
              isLoading: state.isLoading,
              text: context.locale!.checkout_steps_confirm_button,
              onPressed: _submit,
            ),
          ),*/

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              icon: const Icon(Icons.payment),
              onPressed: processing ? null : _submit,
              label: Text(processing? "Please Wait..." : context.locale!.checkout_steps_confirm_button),
            ),
          ),
          const SizedBox(height: 4),
          Text(_msg),
        ],
      ),
    );
  }
}
