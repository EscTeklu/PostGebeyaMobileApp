import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_api/frontend_api.dart';
import 'package:go_router/go_router.dart';
import 'package:nopcommerce_mobile/common_widgets/custom_outlined_button.dart';
import 'package:nopcommerce_mobile/l10n/app_localizations_context.dart';
import 'package:nopcommerce_mobile/router/route_utils.dart';
import 'package:nopcommerce_mobile/utils/common_utility.dart';
import 'package:nopcommerce_mobile/utils/date_format_provider.dart';

class OrderCard extends ConsumerWidget {
  const OrderCard({super.key, required this.order});

  final CustomerOrderDetailsModelDto order;

  static Color getStatusColor(String? status, ColorScheme colorScheme) {
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
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;//added
    final dateTimeProvider = ref.watch(dateTimeFormatterProvider);

    Widget offset = const SizedBox(height: 3);

    String createdOn =
        order.createdOn != null
            ? dateTimeProvider.format(order.createdOn!)
            : context.locale!.account_orders_details_create_date_undefined;

    final items = <Widget>[
      /*Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            context.locale!.account_orders_details_number.format([
              order.customOrderNumber,
            ]),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: printOrderStatus(
              order.orderStatus,
              Theme.of(context).textTheme.labelLarge,
            ),
          ),
        ],
      ),*/
      const SizedBox(height: 10),
      offset,
      Row(
        children: <Widget>[
          Text(context.locale!.account_orders_details_create_date),
          Text(
            createdOn,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
      offset,
      Row(
        children: <Widget>[
          Text(context.locale!.account_orders_details_order_total),
          Text(
            order.orderTotal.toString(),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      offset,
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (order.isReturnRequestAllowed ?? false)
            CustomOutlinedButton(
              text: context.locale!.account_orders_details_return_items,
              onPressed:
                  () => {
                    context.pushNamed(
                      Routes.returnRequest.name,
                      pathParameters: {'id': order.id.toString()},
                    ),
                  },
            ),
          /*const SizedBox(width: 10),
          CustomTonalButton(
            onPressed:
                () => {
                  context.pushNamed(
                    Routes.orderDetails.name,
                    pathParameters: {'id': order.id.toString()},
                  ),
                },
            text: context.locale!.account_orders_details_button,
          ),*/
        ],
      ),
    ];

    return /*Card(
      elevation: Theme.of(context).cardTheme.elevation,
      shape: Theme.of(context).cardTheme.shape,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items,
        ),
      ),
    )*/
      Card(
        margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
        elevation: 2,
        child: ExpansionTile(
          initiallyExpanded: false,
          leading: Icon(
            Icons.shopping_bag_outlined,
            color: getStatusColor(order.orderStatus, colorScheme),
          ),
          title: Text(
            context.locale!.account_orders_details_number.format([
              order.customOrderNumber,
            ]),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items,
          ),
          trailing: Chip(
            label: SelectableText(
              onTap: (){
                context.pushNamed(
                  Routes.orderDetails.name,
                  pathParameters: {'id': order.id.toString()},
                );
              },
              order.orderStatus!,
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                color: getStatusColor(order.orderStatus, colorScheme),
              ),
            ),
            backgroundColor:
            getStatusColor(order.orderStatus, colorScheme).withOpacity(0.1),
            side: BorderSide(
              color: getStatusColor(order.orderStatus, colorScheme),
              width: 1,
            ),
          ),

        ),
      );
  }

  Widget printOrderStatus(ordersStatus, labelStyle) {
    Color backgroundColor = Colors.grey;
    const double opacity = 0.35;

    switch (ordersStatus) {
      case 'Pending':
        backgroundColor = Colors.grey.withOpacity(opacity);
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

    return ActionChip(
      label: Text(ordersStatus, style: labelStyle),
      padding: const EdgeInsets.all(1),
      backgroundColor: backgroundColor,
      side: BorderSide.none,
      onPressed: (() {}),
    );
  }
}
//
class OrderCardO extends StatelessWidget {
  final CustomerOrderDetailsModelDto order;
  const OrderCardO({super.key, required this.order});

  static Color getStatusColor(String? status, ColorScheme colorScheme) {
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

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color statusColor = getStatusColor(order.orderStatus, colorScheme);
    final bool canRepay =
        order.orderStatus == 'Pending' || order.orderStatus == 'Cancelled';
    final ButtonStyle? elevatedButtonStyle = Theme.of(
      context,
    ).elevatedButtonTheme.style;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2,
      child: ExpansionTile(
        initiallyExpanded: false,
        leading: Icon(
          Icons.shopping_bag_outlined,
          color: getStatusColor(order.orderStatus, colorScheme),
        ),
        title: Text(
          'Order #${order.id.toString().substring(4)}', // Display a shorter ID
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Total: \$${order.orderTotal.toString()}',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            Text(
              'Date: ${order.createdOn?.toLocal().toString().split(' ')[0]}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: Chip(
          label: SelectableText(
            onTap: (){
              context.pushNamed(
                Routes.orderDetails.name,
                pathParameters: {'id': order.id.toString()},
              );
            },
            order.orderStatus!,
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
              color: getStatusColor(order.orderStatus, colorScheme),
            ),
          ),
          backgroundColor:
          getStatusColor(order.orderStatus, colorScheme).withOpacity(0.1),
          side: BorderSide(
            color: getStatusColor(order.orderStatus, colorScheme),
            width: 0.5,
          ),
        ),
        /*children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Items:',
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ...order.items
                    .map<Widget>(
                      (OrderItem item) => Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4.0),
                          child: Image.network(
                            item.itemImageUrl,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (
                                BuildContext context,
                                Object error,
                                StackTrace? stackTrace,
                                ) {
                              return Container(
                                width: 40,
                                height: 40,
                                color: Colors.grey.shade100,
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.grey.shade400,
                                  size: 20,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${item.quantity} x ${item.productName}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        Text(
                          '\$${(item.productPrice * item.quantity).toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                )
                    .toList(),
                const Divider(height: 24),
                // Tracking Information
                OrderTrackingInfo(order: order),
                if (order.status == 'Pending') ...<Widget>[
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        orderProvider.markOrderAsPaid(order.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Order ${order.id.substring(4)} marked as Paid!'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.payment),
                      label: const Text('Mark as Paid'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],*/
      ),
    );
  }
}
