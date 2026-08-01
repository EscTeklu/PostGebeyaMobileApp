import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nopcommerce_mobile/common_widgets/async_value.dart';
import 'package:nopcommerce_mobile/common_widgets/items_not_found.dart';
import 'package:nopcommerce_mobile/features/customer/presentation/account/account_providers.dart';
import 'package:nopcommerce_mobile/features/customer/presentation/account/return_requests/return_request_card.dart';
import 'package:nopcommerce_mobile/frontend_api/lib/frontend_api.dart';
import 'package:nopcommerce_mobile/l10n/app_localizations_context.dart';

const _blue = Color(0xFF2C2E7B);
const _bg = Color(0xFFF4F5FB);

class AccountReturnRequestsScreen extends ConsumerWidget {
  const AccountReturnRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final returnRequests = ref.watch(customerReturnRequestsProvider);

    return AsyncValueWidget<CustomerReturnRequestsModelDto?>(
      value: returnRequests,
      data: (returnRequests) => AccountReturnRequestsContents(
        customerReturnRequests:
            returnRequests ?? CustomerReturnRequestsModelDto(),
      ),
    );
  }
}

class AccountReturnRequestsContents extends ConsumerWidget {
  const AccountReturnRequestsContents({
    super.key,
    required this.customerReturnRequests,
  });

  final CustomerReturnRequestsModelDto customerReturnRequests;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countReturnRequests = customerReturnRequests.items?.length ?? 0;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _blue,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.locale!.account_return_requests,
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
      body: countReturnRequests > 0
          ? ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              itemCount: countReturnRequests,
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
                  child: ReturnRequestCard(
                    returnRequest: customerReturnRequests.items![index],
                  ),
                ),
              ),
            )
          : ItemsNotFound(
              text: context.locale!.account_return_requests_no_found,
            ),
    );
  }
}
