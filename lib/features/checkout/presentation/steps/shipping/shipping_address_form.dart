import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nopcommerce_mobile/features/checkout/presentation/checkout_providers.dart';
import 'package:nopcommerce_mobile/features/checkout/presentation/steps/address/address_widget.dart';
import 'package:nopcommerce_mobile/features/checkout/presentation/steps/address/new_address.dart';
import 'package:nopcommerce_mobile/frontend_api/lib/frontend_api.dart';
import 'package:nopcommerce_mobile/l10n/app_localizations_context.dart';

class ShippingFormContents extends ConsumerStatefulWidget with AddressWidget {
  const ShippingFormContents({super.key, required this.addresses});

  final CheckoutShippingAddressModelDtoBuilder addresses;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ShippingFormContentsState();
}

class _ShippingFormContentsState extends ConsumerState<ShippingFormContents> {
  static const _blue = Color(0xFF2C2E7B);

  final _node = FocusScopeNode();
  AddressModelDto? curentItem;

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      curentItem = widget.addresses.existingAddresses.isNotEmpty
          ? widget.addresses.existingAddresses.last
          : null;
    });
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.addresses.existingAddresses.last !=
            widget.addresses.existingAddresses.last &&
        curentItem == null) {
      setState(() {
        curentItem = widget.addresses.existingAddresses.last;
      });
    }
  }

  Future<void> _submit() async {
    if (curentItem != null) {
      final controller = ref.read(checkoutControllerProvider.notifier);
      await controller.setShippingAddress(curentItem?.id ?? 0);
    } else {
      showDialog(
        context: context,
        builder: (context) => const NewAddress(
          isBilingAddress: false,
          useBillingAddressAsShippingAddress: false,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
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
                  child: const Icon(Icons.local_shipping_rounded,
                      color: _blue, size: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  context.locale!.checkout_steps_shipping_address_title
                      .toUpperCase(),
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
          // Dropdown
          Padding(
            padding: const EdgeInsets.all(16),
            child: widget.getAddressDropdown(
              context: context,
              addressess: widget.addresses.existingAddresses,
              curentItem: curentItem,
              onChange: (value) {
                setState(() => curentItem = value as AddressModelDto?);
                _submit();
              },
            ),
          ),
        ],
      ),
    );
  }
}
