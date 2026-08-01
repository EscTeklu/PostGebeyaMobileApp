import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nopcommerce_mobile/common_widgets/async_value.dart';
import 'package:nopcommerce_mobile/features/checkout/presentation/checkout_providers.dart';
import 'package:nopcommerce_mobile/features/checkout/presentation/steps/address/address_widget.dart';
import 'package:nopcommerce_mobile/features/checkout/presentation/steps/address/new_address.dart';
import 'package:nopcommerce_mobile/frontend_api/lib/frontend_api.dart';
import 'package:nopcommerce_mobile/l10n/app_localizations_context.dart';
import 'package:nopcommerce_mobile/utils/async_value_ui.dart';

class BillingAddressForm extends ConsumerWidget {
  const BillingAddressForm({
    required this.onStepContinue,
    this.onSave,
    super.key,
  });

  final VoidCallback onStepContinue;
  final void Function(bool? isValid, bool useBillingAddressAsShippingAddress)?
      onSave;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billingAddressData = ref.watch(billingAddress);

    return AsyncValueWidget<CheckoutBillingAddressModelDto?>(
      value: billingAddressData,
      data: (addresses) => BillingAddressFormContents(
        onStepContinue: onStepContinue,
        onSave: onSave,
        addresses: (addresses ?? CheckoutBillingAddressModelDto()).toBuilder(),
      ),
    );
  }
}

class BillingAddressFormContents extends ConsumerStatefulWidget
    with AddressWidget {
  const BillingAddressFormContents({
    super.key,
    required this.addresses,
    required this.onStepContinue,
    this.onSave,
  });

  final CheckoutBillingAddressModelDtoBuilder addresses;
  final VoidCallback onStepContinue;
  final void Function(bool? isValid, bool useBillingAddressAsShippingAddress)?
      onSave;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BillingAddressFormContentsState();
}

class _BillingAddressFormContentsState
    extends ConsumerState<BillingAddressFormContents> {
  static const _blue = Color(0xFF2C2E7B);

  final _node = FocusScopeNode();
  AddressModelDto? curentItem;
  late bool useBillingAddressAsShippingAddress;

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    useBillingAddressAsShippingAddress =
        widget.addresses.shipToSameAddress ?? false;
    curentItem = widget.addresses.existingAddresses.isNotEmpty
        ? widget.addresses.existingAddresses.last
        : null;
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
      await controller
          .setBillingAddress(
            curentItem?.id ?? 0,
            useBillingAddressAsShippingAddress,
          )
          .then((value) =>
              widget.onSave?.call(value, useBillingAddressAsShippingAddress));
      widget.onStepContinue();
    } else {
      showDialog(
        context: context,
        builder: (context) => NewAddress(
          isBilingAddress: true,
          useBillingAddressAsShippingAddress: useBillingAddressAsShippingAddress,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue>(
      checkoutControllerProvider.select((state) => state.value),
      (_, state) => state.showAlertDialogOnError(context),
    );

    final state = ref.watch(checkoutControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Address card ─────────────────────────────────────────────
        _CheckoutCard(
          icon: Icons.location_on_rounded,
          title: context.locale!.checkout_steps_billing_address_title,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Ship to same address toggle
              if (widget.addresses.shipToSameAddressAllowed ?? false) ...[
                GestureDetector(
                  onTap: () => setState(() =>
                      useBillingAddressAsShippingAddress =
                          !useBillingAddressAsShippingAddress),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: useBillingAddressAsShippingAddress
                          ? _blue.withValues(alpha: 0.06)
                          : const Color(0xFFF4F5FB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: useBillingAddressAsShippingAddress
                            ? _blue.withValues(alpha: 0.3)
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: useBillingAddressAsShippingAddress
                                ? _blue
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: useBillingAddressAsShippingAddress
                                  ? _blue
                                  : Colors.grey.shade400,
                              width: 2,
                            ),
                          ),
                          child: useBillingAddressAsShippingAddress
                              ? const Icon(Icons.check_rounded,
                                  size: 14, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            context.locale!
                                .checkout_steps_billing_ship_same_address,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Address dropdown
              widget.getAddressDropdown(
                context: context,
                addressess: widget.addresses.existingAddresses,
                curentItem: curentItem,
                onChange: (value) {
                  setState(() => curentItem = value as AddressModelDto?);
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Continue button ──────────────────────────────────────────
        _ContinueButton(
          isLoading: state.isLoading,
          onPressed: _submit,
        ),
      ],
    );
  }
}

// ── Shared helpers ─────────────────────────────────────────────────────────

class _CheckoutCard extends StatelessWidget {
  const _CheckoutCard({
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

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({required this.onPressed, this.isLoading = false});

  static const _orange = Color(0xFFF5AD00);

  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _orange,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.white),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_forward_rounded, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Continue',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ],
              ),
      ),
    );
  }
}
