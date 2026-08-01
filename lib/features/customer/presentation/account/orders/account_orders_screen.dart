import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_api/frontend_api.dart';
import 'package:nopcommerce_mobile/common_widgets/async_value.dart';
import 'package:nopcommerce_mobile/common_widgets/items_not_found.dart';
import 'package:nopcommerce_mobile/features/customer/presentation/account/account_providers.dart';
import 'package:nopcommerce_mobile/features/orders/presentation/order_card.dart';
import 'package:nopcommerce_mobile/l10n/app_localizations_context.dart';

const _blue = Color(0xFF2C2E7B);
const _bg = Color(0xFFF4F5FB);

class AccountOrdersScreen extends ConsumerWidget {
  const AccountOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerInfo = ref.watch(customerOrdersProvider);

    return AsyncValueWidget<CustomerOrderListModelDto?>(
      value: customerInfo,
      data: (customer) => AccountOrdersContents(
        customerOrders: customer ?? CustomerOrderListModelDto(),
      ),
    );
  }
}

class AccountOrdersContents extends ConsumerWidget {
  const AccountOrdersContents({super.key, required this.customerOrders});

  final CustomerOrderListModelDto customerOrders;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countOrders = customerOrders.orders?.length ?? 0;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _blue,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.locale!.account_orders,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ),
      body: countOrders > 0
          ? ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              itemCount: countOrders,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: _blue.withValues(alpha: 0.07),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: OrderCard(order: customerOrders.orders![index]),
                ),
              ),
            )
          : ItemsNotFound(text: context.locale!.account_orders_no_found),
    );
  }
}
