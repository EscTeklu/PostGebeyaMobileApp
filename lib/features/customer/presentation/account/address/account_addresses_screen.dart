import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_api/frontend_api.dart';
import 'package:go_router/go_router.dart';
import 'package:nopcommerce_mobile/common_widgets/async_value.dart';
import 'package:nopcommerce_mobile/common_widgets/items_not_found.dart';
import 'package:nopcommerce_mobile/features/address/presentation/address_card.dart';
import 'package:nopcommerce_mobile/features/address/presentation/address_providers.dart';
import 'package:nopcommerce_mobile/features/customer/presentation/account/account_providers.dart';
import 'package:nopcommerce_mobile/l10n/app_localizations_context.dart';
import 'package:nopcommerce_mobile/router/route_utils.dart';
import 'package:nopcommerce_mobile/utils/async_value_ui.dart';

const _blue = Color(0xFF2C2E7B);
const _orange = Color(0xFFF5AD00);
const _bg = Color(0xFFF4F5FB);

class AccountAddressesScreen extends ConsumerWidget {
  const AccountAddressesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerInfo = ref.watch(customerAddressesProvider);

    return AsyncValueWidget<CustomerAddressListModelDto?>(
      value: customerInfo,
      data: (customer) => AccountAddressesContents(
        customerAddresses: customer ?? CustomerAddressListModelDto(),
      ),
    );
  }
}

class AccountAddressesContents extends ConsumerWidget {
  const AccountAddressesContents({super.key, required this.customerAddresses});

  final CustomerAddressListModelDto customerAddresses;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countAddresses = customerAddresses.addresses?.length ?? 0;

    ref.listen<AsyncValue>(
      deleteAddressControllerProvider.select((state) => state.value),
      (_, state) => state.showAlertDialogOnError(context),
    );

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _blue,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.locale!.account_address,
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 72),
        child: FloatingActionButton.extended(
          backgroundColor: _orange,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_location_alt_rounded),
          label: Text(
            context.locale!.account_address_button_add,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          onPressed: () => context.goNamed(
            Routes.createUpdateAddress.name,
            pathParameters: {'id': '0'},
          ),
        ),
      ),
      body: countAddresses > 0
          ? ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
              itemCount: countAddresses,
              itemBuilder: (context, index) => _AddressItem(
                address: customerAddresses.addresses![index],
              ),
            )
          : Column(
              children: [
                ItemsNotFound(text: context.locale!.account_address_no_found),
              ],
            ),
    );
  }
}

class _AddressItem extends StatelessWidget {
  const _AddressItem({required this.address});
  final dynamic address;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
        child: AddressCard(address: address),
      ),
    );
  }
}
