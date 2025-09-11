import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_api/frontend_api.dart';
import 'package:go_router/go_router.dart';
import 'package:nopcommerce_mobile/common_widgets/async_value.dart';
import 'package:nopcommerce_mobile/common_widgets/custom_filled_button.dart';
import 'package:nopcommerce_mobile/common_widgets/custom_outlined_button.dart';
import 'package:nopcommerce_mobile/common_widgets/responsive_scrollable.dart';
import 'package:nopcommerce_mobile/common_widgets/text_link.dart';
import 'package:nopcommerce_mobile/constants/global_variables.dart';
import 'package:nopcommerce_mobile/customize/screens/payment_webview_screen.dart';
import 'package:nopcommerce_mobile/customize/services/payment_service.dart';
import 'package:nopcommerce_mobile/features/address/presentation/address_card.dart';
import 'package:nopcommerce_mobile/features/app/scaffold_messenger_extansion.dart';
import 'package:nopcommerce_mobile/features/app/theme/custom_color_scheme.dart';
import 'package:nopcommerce_mobile/features/authentication/presentation/auth_providers.dart';
import 'package:nopcommerce_mobile/features/cart/presentation/cart_providers.dart';
import 'package:nopcommerce_mobile/features/customer/presentation/account/account_providers.dart';
import 'package:nopcommerce_mobile/features/customer/presentation/account/web_info.dart';
import 'package:nopcommerce_mobile/features/orders/presentation/orders_providers.dart';
import 'package:nopcommerce_mobile/l10n/app_localizations_context.dart';
import 'package:nopcommerce_mobile/router/route_utils.dart';
import 'package:nopcommerce_mobile/utils/base_nop_state.dart';
import 'package:nopcommerce_mobile/utils/common_utility.dart';
import 'package:nopcommerce_mobile/utils/date_format_provider.dart';

class OrderDetailsScreen extends ConsumerWidget {
  final int orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<BaseNopState>(
      orderControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );

    ref.listen<BaseNopState>(
      downloadControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );

    var orderValue = ref.watch(orderDetailsProvider(orderId));

    return AsyncValueWidget<OrderDetailsModelDto?>(
      value: orderValue,
      data:
          (order) => OrderDetailsContents(
            orderId: orderId,
            order: order ?? OrderDetailsModelDto(),
          ),
    );
  }
}

class OrderDetailsContents extends ConsumerStatefulWidget {
  final int orderId;

  const OrderDetailsContents({
    super.key,
    this.onSave,
    required this.order,
    required this.orderId,
  });

  final VoidCallback? onSave;
  final OrderDetailsModelDto order;

  @override
  ConsumerState<OrderDetailsContents> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends ConsumerState<OrderDetailsContents> {
  _OrderDetailsState();
  Widget offset = const SizedBox(height: 5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalVariables.backgroundColor,
      appBar: AppBar(
        backgroundColor: GlobalVariables.accentColor,
        title: Text(
          context.locale!.account_orders_details,
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ResponsiveScrollable(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: getItems(context),
        ),
      ),
    );
  }

  List<Widget> getItems(BuildContext context) {
    var items = <Widget>[];

    fillBaseData(items, context);
    fillProducts(items, context);
    fillCheckoutAttributes(items, context);
    fillBillingAddress(items, context);
    fillPaymentInfo(items, context);
    fillShippingAddress(items, context);
    fillShippingInfo(items, context);

    if (!(widget.order.shipments?.isEmpty ?? true)) {
      fillShipments(items, context);
    }

    fillTotals(items, context);

    final state = ref.watch(orderControllerProvider);

    if ((widget.order.isReOrderAllowed ?? false) ||
        (widget.order.isReturnRequestAllowed ?? false)) {
      /*items.add(
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.order.isReturnRequestAllowed ?? false) ...[
                CustomOutlinedButton(
                  text: context.locale!.account_orders_details_return_items,
                  onPressed:
                      () => {
                        context.pushNamed(
                          Routes.returnRequest.name,
                          pathParameters: {'id': widget.orderId.toString()},
                        ),
                      },
                ),
                const SizedBox(width: 10),
              ],
              if (widget.order.isReOrderAllowed ?? false)
                CustomFilledButton(
                  text: context.locale!.account_orders_details_reorder,
                  isBigButton: true,
                  isLoading: state.isLoading,
                  onPressed: _reOrder,
                ),
            ],
          ),
        ),
      );*/
      items.add(
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                /*if (widget.order.shipments!.first.trackingNumber != null)
                  TextButton.icon(
                    onPressed: () {

                    },
                    icon: const Icon(Icons.local_shipping_rounded, color: Colors.white,),
                    label: const Text('Track Order'),
                    style: TextButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),*/
                if (widget.order.paymentMethodStatus == "Pending")
                  Padding(
                    padding: const EdgeInsets.only(left: 2.0),
                    child: TextButton.icon(
                      onPressed: _rePay,
                      icon: const Icon(Icons.payment_rounded, color: Colors.white,),
                      label:  Text('Re-Pay', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),),
                      style: TextButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ),

                if (widget.order.isReOrderAllowed ?? false)
                  Padding(
                    padding: const EdgeInsets.only(left: 2.0),
                    child: ElevatedButton.icon(
                      onPressed: _reOrder,
                      icon: const Icon(Icons.replay_rounded, color: Colors.white,),
                      label: Text(context.locale!.account_orders_details_reorder, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          )
      );
    }

    return items;
  }

  Widget sectionHeader(String header) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Text(
        header,
        style: Theme.of(
          context,
        ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget cardLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 5),
      child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
    );
  }

  Widget cardValue(String value) {
    return SelectableText(
      value,
      style: Theme.of(
        context,
      ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
    );
  }

  void fillShipments(List<Widget> items, BuildContext context) {
    if (widget.order.shipments?.isEmpty ?? true) {
      return;
    }

    items.add(sectionHeader(context.locale!.account_orders_details_shipments));
    for (var shipment in widget.order.shipments!) {
      items.add(getShipmentInfo(shipment, context));
    }
  }

  void fillProducts(List<Widget> items, BuildContext context) {
    items.add(
      sectionHeader(
        '${widget.order.items!.length} ${context.locale!.account_orders_details_products}',
      ),
    );
    items.add(offset);

    for (var product in widget.order.items!) {
      items.add(getProductInfo(product, context));
    }
  }

  void fillCheckoutAttributes(List<Widget> items, BuildContext context) {
    items.add(offset);
    items.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [Text(widget.order.checkoutAttributeInfo ?? "")],
      ),
    );
  }

  void fillTotals(List<Widget> items, BuildContext context) {
    var rowNameStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );

    var rowValueStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      color: Theme.of(context).colorScheme.onSurface,
    );

    var sizeBoxSpace = const Divider();

    items.add(offset);
    items.add(
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.locale!.account_orders_details_subtotal,
                    style: rowNameStyle,
                  ),
                  const Spacer(),
                  Text(widget.order.orderSubtotal!, style: rowValueStyle),
                ],
              ),
            ),
            sizeBoxSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.locale!.account_orders_details_shipping,
                  style: rowNameStyle,
                ),
                const Spacer(),
                Text(widget.order.orderShipping!, style: rowValueStyle),
              ],
            ),
            sizeBoxSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.locale!.account_orders_details_tax,
                  style: rowNameStyle,
                ),
                const Spacer(),
                Text(widget.order.tax!, style: rowValueStyle),
              ],
            ),
            sizeBoxSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    context.locale!.account_orders_details_total,
                    style: rowNameStyle,
                  ),
                ),
                Flexible(
                  child: Text(
                    widget.order.orderTotal!,
                    style: rowValueStyle!.copyWith(fontSize: 30),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget printOrderStatus(ordersStatus) {
    Color backgroundColor = Colors.grey;
    const double opacity = 0.35;

    switch (ordersStatus) {
      case 'Pending':
        backgroundColor = Colors.orange.shade600.withOpacity(opacity);
            //Colors.grey.withOpacity(opacity);
        break;
      case 'Processing':
        backgroundColor = Colors.orange.withOpacity(opacity);
        break;
      case 'Complete':
        backgroundColor = Colors.green.withOpacity(opacity);
        break;
      case 'Cancelled':
        backgroundColor = Colors.red.withOpacity(opacity);
        break;
    }

    return InputChip(
      label: Text(ordersStatus),
      backgroundColor: backgroundColor,
      side: BorderSide.none,
      onPressed: (() {}),
    );
  }

  String formatDate(DateTime date) {
    final dateTimeProvider = ref.watch(dateTimeFormatterProvider);
    return dateTimeProvider.format(widget.order.createdOn!);
  }

  void fillBaseData(List<Widget> items, BuildContext context) {
    CustomColors? customColors = Theme.of(context).extension<CustomColors>()!;

    items.add(
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SelectableText(
              context.locale!.account_orders_details_number.format([
                widget.order.customOrderNumber,
              ]),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            if (widget.order.orderStatus != null)
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 6),
                child: printOrderStatus(widget.order.orderStatus),
              ),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: widget.order.id != null
                    ? () {
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true, // Allows full height
                    builder: (BuildContext bc) {
                      final ColorScheme modalColorScheme = Theme.of(
                        context,
                      ).colorScheme;
                      return FractionallySizedBox(
                        heightFactor:
                        0.9, // Takes 90% of screen height
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: modalColorScheme.surface,
                                borderRadius:
                                const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                      0.05,
                                    ),
                                    blurRadius: 4,
                                    offset: const Offset(0, -2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    'Track Order #${widget.order.id.toString()}',
                                    style: Theme.of(bc)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                      fontWeight:
                                      FontWeight.bold,
                                      color: modalColorScheme
                                          .onSurface,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close_rounded,
                                    ),
                                    onPressed: () =>
                                        Navigator.pop(bc),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: OrderTrackingBodyContent(
                                orderId: widget.orderId.toString(), order: widget.order,

                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
                    : null,
                icon: const Icon(Icons.local_shipping_rounded, color: Colors.white,),
                label: const Text('Track Order'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  textStyle: Theme.of(
                    context,
                  ).elevatedButtonTheme.style?.textStyle
                      ?.resolve({})
                      ?.copyWith(fontSize: 12),
                  shape: Theme.of(
                    context,
                  ).elevatedButtonTheme.style?.shape?.resolve({}),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                ),
              ),
            )
          ],
        ),
      ),
    );

    final state = ref.watch(downloadControllerProvider);

    items.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /*if (widget.order.shipments!.first.trackingNumber != null)
              SelectableText(
                onTap: (){
                  showDialog(
                    context: context,
                    builder:
                        (context) => WebInfo(
                      urlWeb:
                      'https://www.dev.africom.et/tracking/track?trackingNumber=${widget.order.shipments!.first.trackingNumber}&trackingType=Domestic',
                    ),
                  );
                },
                "${context.locale!.account_orders_details_tracking_number} ${widget.order.shipments!.first.trackingNumber}",
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w600),
              ),
              offset,*/
              if (widget.order.createdOn != null)
                Row(
                  children: [
                    Text(
                      context.locale!.account_orders_details_create_date,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: customColors.subTextColor,
                      ),
                    ),
                    SelectableText(
                      formatDate(widget.order.createdOn!),
                      style: Theme.of(context).textTheme.titleMedium!,
                    ),
                  ],
                ),
              offset,
              Row(
                children: [
                  Text(
                    context.locale!.account_orders_details_order_total,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: customColors.subTextColor,
                    ),
                  ),
                  SelectableText(
                    widget.order.orderTotal ?? '',
                    style: Theme.of(context).textTheme.titleMedium!,
                  ),
                ],
              ),
            ],
          ),
          /*CustomOutlinedButton(
            text: context.locale!.account_orders_details_button_pdf_invoice,
            onPressed: _downloadInvoice,
            isLoading: state.isLoading,
          ),*/
        ],
      ),
    );
  }

  void fillBillingAddress(List<Widget> items, BuildContext context) {
    items.add(
      sectionHeader(context.locale!.account_orders_details_billing_address),
    );
    items.add(offset);
    items.add(
      AddressCard(
        address: widget.order.billingAddress ?? AddressModelDto(),
        isEditable: false,
      ),
    );
  }

  void fillPaymentInfo(List<Widget> items, BuildContext context) {
    items.add(
      sectionHeader(context.locale!.account_orders_details_payment_info),
    );
    items.add(offset);
    items.add(
      Card(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.order.paymentMethod != null) ...[
                  Row(
                    children: [
                      cardLabel(
                        context.locale!.account_orders_details_payment_method,
                      ),
                      cardValue(widget.order.paymentMethod!),
                    ],
                  ),
                  offset,
                ],
                if (widget.order.paymentMethodStatus != null) ...[
                  Row(
                    children: [
                      cardLabel(
                        context.locale!.account_orders_details_payment_status,
                      ),
                      cardValue(widget.order.paymentMethodStatus!),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void fillShippingAddress(List<Widget> items, BuildContext context) {
    if (widget.order.pickupInStore ?? false) {
      items.add(
        sectionHeader(
          context.locale!.account_orders_details_pickup_point_address,
        ),
      );
      var addressBuilder = widget.order.pickupAddress!.toBuilder();
      addressBuilder.streetAddressEnabled =
          addressBuilder.cityEnabled =
              addressBuilder.countryEnabled =
                  addressBuilder.countyEnabled =
                      addressBuilder.stateProvinceEnabled =
                          addressBuilder.zipPostalCodeEnabled = true;
      items.add(offset);
      items.add(
        AddressCard(address: addressBuilder.build(), isEditable: false),
      );
    } else {
      items.add(
        sectionHeader(context.locale!.account_orders_details_shipping_address),
      );
      items.add(offset);
      items.add(
        AddressCard(
          address: widget.order.shippingAddress ?? AddressModelDto(),
          isEditable: false,
        ),
      );
    }
  }

  void fillShippingInfo(List<Widget> items, BuildContext context) {
    items.add(
      sectionHeader(context.locale!.account_orders_details_shipping_info),
    );
    items.add(
      Card(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.order.shippingMethod != null) ...[
                  Row(
                    children: [
                      cardLabel(
                        context.locale!.account_orders_details_shipping_method,
                      ),
                      cardValue(widget.order.shippingMethod!),
                    ],
                  ),
                  offset,
                ],
                if (widget.order.shippingStatus != null) ...[
                  Row(
                    children: [
                      cardLabel(
                        context.locale!.account_orders_details_shipping_status,
                      ),
                      cardValue(widget.order.shippingStatus!),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getShipmentInfo(ShipmentBriefModelDto shipment, BuildContext context) {
    var items = <Widget>[];
    items.add(
      Text(
        "${context.locale!.account_orders_details_shipment_number}${shipment.id}",
        style: Theme.of(context).textTheme.bodyMedium!,
      ),
    );
    items.add(offset);
    if (shipment.trackingNumber?.isNotEmpty ?? false) {
      items.add(
          SelectableText(
            onTap: (){
              showDialog(
                context: context,
                builder:
                    (context) => WebInfo(
                  urlWeb:
                  'https://www.dev.africom.et/tracking/track?trackingNumber=${shipment.trackingNumber}&trackingType=Domestic',
                ),
              );
            },
            "${context.locale!.account_orders_details_tracking_number} ${shipment.trackingNumber}",
            style: Theme.of(
              context,
            ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w600),
          )
        /*GestureDetector(
          onTap: (){
            showDialog(
              context: context,
              builder:
                  (context) => WebInfo(
                urlWeb:
                'https://www.ethiopostmall.africom.et/tracking/track?trackingNumber=${shipment.trackingNumber}&trackingType=Domestic',
              ),
            );
          },
          child: Text(
            "${context.locale!.account_orders_details_tracking_number} ${shipment.trackingNumber}",
          )
        )*/
      );
      items.add(offset);
    }

    if (widget.order.pickupAddress != null &&
        shipment.readyForPickupDate != null) {
      items.add(
        Row(
          children: [
            cardLabel(
              context.locale!.account_orders_details_date_ready_for_pickup,
            ),
            cardValue(formatDate(shipment.readyForPickupDate!)),
          ],
        ),
      );
      items.add(offset);
    } else {
      if (shipment.shippedDate != null) {
        items.add(
          Row(
            children: [
              cardLabel(context.locale!.account_orders_details_date_shipped),
              cardValue(formatDate(shipment.shippedDate!)),
            ],
          ),
        );
        items.add(offset);
      }
    }

    if (shipment.deliveryDate != null) {
      items.add(
        Row(
          children: [
            cardLabel(context.locale!.account_orders_details_date_delivered),
            cardValue(formatDate(shipment.deliveryDate!)),
          ],
        ),
      );
    }

    return Card(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items,
          ),
        ),
      ),
    );
  }

  Card getProductInfo(OrderItemModelDto product, BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              children: [
                if (product.productName?.isNotEmpty ?? false)
                  Flexible(
                    flex: 3,
                    fit: FlexFit.tight,
                    child: TextLink(
                      label: product.productName ?? "",
                      onTap:
                          () => {
                            context.pushNamed(
                              Routes.product.name,
                              pathParameters: {
                                'id': product.productId.toString(),
                              },
                            ),
                          },
                    ),
                  ),
                const Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: SizedBox.shrink(),
                ),
                Flexible(
                  flex: 2,
                  fit: FlexFit.tight,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${product.quantity} × ${product.unitPrice}',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  "${context.locale!.account_orders_details_sku} ${product.sku}",
                ),
                const Spacer(),
                Text(
                  "${context.locale!.account_orders_details_total} ${product.subTotal}",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future _rePay() async {
    final authRepository = ref.watch(authRepositoryProvider);

    String? authToken = authRepository.currentCustomer?.token;
    //
    if(widget.order.paymentMethod == 'ETHIOSWITCH')
    {

      final PaymentService paymentService = PaymentService(authToken!);
      final resp = await paymentService.createPayment(
          widget.order.id.toString());

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
          ref.refresh(shoppingCartFutureProvider.future).then(
                (value) =>
            {
              ref.refresh(shoppingCartTotalsProvider.future),
              if (value?.items?.isNotEmpty ?? false)
                {
                  ref.refresh(shoppingCartTotalsProvider.future),
                }
            },
          );

          context.goNamed(
            Routes.orderDetails.name,
            pathParameters: {'id': widget.order.id.toString()},
          );
        } else {

          ref.refresh(shoppingCartFutureProvider.future).then(
                (value) =>
            {
              ref.refresh(shoppingCartTotalsProvider.future),
              if (value?.items?.isNotEmpty ?? false)
                {
                  ref.refresh(shoppingCartTotalsProvider.future),
                }
            },
          );
          context.replaceNamed(
            Routes.orderDetails.name,
            pathParameters: {'id': widget.order.id.toString()},
          );
        }
      } else {

      }
    }
  }
  Future _reOrder() async {
    final contrloller = ref.read(orderControllerProvider.notifier);
    await contrloller
        .reOrder(widget.orderId)
        .whenComplete(
          () async => await contrloller.updateShoppingCart().whenComplete(() {
            if (mounted) {
              context.goNamed(Routes.cart.name);
            }
          }),
        );
  }

  Future _downloadInvoice() async {
    final contrloller = ref.read(downloadControllerProvider.notifier);

    await contrloller.downloadPdfInvoice(widget.orderId).then((value) {
      if (mounted) {
        showInSnackBar(
          context,
          (value ?? false)
              ? context
                  .locale!
                  .account_orders_details_pdf_invoice_download_completed
              : context
                  .locale!
                  .account_orders_details_pdf_invoice_download_failed,
        );
      }
    });
  }
}
//
// Widget containing the core tracking UI, reusable for both full-screen and modal
class OrderTrackingBodyContent extends StatefulWidget {
  final String orderId;
  final OrderDetailsModelDto order;

  const OrderTrackingBodyContent({super.key, required this.orderId, required this.order});

  @override
  State<OrderTrackingBodyContent> createState() =>
      _OrderTrackingBodyContentState();
}

class _OrderTrackingBodyContentState extends State<OrderTrackingBodyContent> {
  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildTrackingSummary(colorScheme),
          const SizedBox(height: 24),
          Text(
            'Tracking History',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _buildTrackingTimeline(),
        ],
      ),
    );
  }

  Widget _buildTrackingSummary(ColorScheme colorScheme) {
    Color getStatusColor(String status, ColorScheme colorScheme) {
      switch (status) {
        case 'Pending':
          return Colors.orange.shade600;
        case 'Delivered':
          return Colors.green.shade600;
        case 'Cancelled':
          return colorScheme.error;
        case 'Paid':
          return colorScheme.primary;
        case 'Shipped':
          return Colors.purple.shade600;
        case 'Out for Delivery':
          return Colors.teal.shade600;
        default:
          return Colors.grey.shade600;
      }
    }
    return Card(
      elevation: Theme.of(context).cardTheme.elevation,
      shape: Theme.of(context).cardTheme.shape,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Order ID: ${widget.orderId.toString()}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            if(widget.order.shipments!.isNotEmpty)
            Text(
              'Tracking ID: ${widget.order.shipments?.first.trackingNumber ?? 'N/A'}',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const Divider(height: 24),
            Row(
              children: <Widget>[
                Icon(
                  Icons.location_on_rounded,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                if(widget.order.shipments!.isNotEmpty)
                Expanded(
                  child: Text(
                    'Current Location: ${widget.order.shippingStatus ?? 'Unknown'}',
                    style: TextStyle(
                      fontSize: 15,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Icon(
                  Icons.calendar_month_rounded,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                if(widget.order.shipments!.isNotEmpty)
                Expanded(
                  child: Text(
                    'Estimated Delivery: ${widget.order.shipments?.first.deliveryDate ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 15,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Icon(
                  Icons.info_outline_rounded,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Order Status: ${widget.order.orderStatus}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: getStatusColor('Pending', colorScheme),
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

  Widget _buildTrackingTimeline() {
    List<TrackingEvent> trackingEvents = [
      TrackingEvent(
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 12)),
        status: 'Order Placed',
        location: 'Online',
      ),
      TrackingEvent(
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 8)),
        status: 'Processing at Warehouse',
        location: 'Main Hub, AA',
      ),
      TrackingEvent(
        timestamp: DateTime.now().subtract(const Duration(hours: 10)),
        status: 'Out for Delivery',
        location: 'Local Delivery Hub, AA',
      ),
      TrackingEvent(
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        status: 'Delivered',
        location: 'Recipient Address',
      ),
    ];
    /*trackingEvents.add(TrackingEvent(
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 12)),
      status: 'Order Placed',
      location: 'Online',
    ));*/
    // Check if there are no events
    if (trackingEvents.isEmpty) {
      return Center(
        child: Text(
          'No tracking events available.',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      );
    }
    // Sort events by timestamp (earliest to latest)
    trackingEvents.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: trackingEvents.length,
      itemBuilder: (BuildContext context, int index) {
        final TrackingEvent event = trackingEvents[index];
        final bool isLast = index == trackingEvents.length - 1;
        final bool isFirst = index == 0;
        final Color timelineColor = Theme.of(context).colorScheme.primary.withOpacity(0.6);

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Container(
                    width: 2.0,
                    height: isFirst ? 0 : 20.0,
                    color: timelineColor,
                  ),
                  Icon(
                    _getTrackingIcon(event.status),
                    color: isLast ? Theme.of(context).colorScheme.primary : timelineColor,
                    size: 26,
                  ),
                  if (!isLast)
                    Expanded(child: Container(width: 2.0, color: timelineColor)),
                ],
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        event.status,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDateTime(event.timestamp),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                      if (event.location != null)
                        Text(
                          event.location!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getTrackingIcon(String status) {
    switch (status) {
      case 'Order Placed':
        return Icons.assignment_turned_in_rounded;
      case 'Processing at Warehouse':
        return Icons.warehouse_rounded;
      case 'Shipped':
        return Icons.local_shipping_rounded;
      case 'Out for Delivery':
        return Icons.delivery_dining_rounded;
      case 'Delivered':
        return Icons.check_circle_rounded;
      case 'Cancellation Requested':
        return Icons.cancel_rounded;
      case 'Cancelled':
        return Icons.close_rounded;
      case 'Paid':
        return Icons.payment_rounded;
      default:
        return Icons.circle_rounded;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} ${_formatTime(dateTime)}';
  }

  String _formatTime(DateTime dateTime) {
    final String hour = dateTime.hour.toString().padLeft(2, '0');
    final String minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
class TrackingEvent {
  final DateTime timestamp;
  final String status;
  final String? location;

  TrackingEvent({
    required this.timestamp,
    required this.status,
    this.location,
  });

  factory TrackingEvent.fromMap(Map<String, dynamic> map) {
    return TrackingEvent(
      timestamp: DateTime.parse(map['timestamp'] as String),
      status: map['status'] as String,
      location: map['location'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      'location': location,
    };
  }
}
