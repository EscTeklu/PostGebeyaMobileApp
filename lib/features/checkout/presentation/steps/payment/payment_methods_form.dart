import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nopcommerce_mobile/common_widgets/custom_image.dart';
import 'package:nopcommerce_mobile/features/app/scaffold_messenger_extansion.dart';
import 'package:nopcommerce_mobile/features/checkout/presentation/checkout_providers.dart';
import 'package:nopcommerce_mobile/features/checkout/presentation/steps/payment/payment_info.dart';
import 'package:nopcommerce_mobile/frontend_api/lib/frontend_api.dart';
import 'package:nopcommerce_mobile/l10n/app_localizations_context.dart';

class PaymentMethodsFormContents extends ConsumerStatefulWidget {
  const PaymentMethodsFormContents({
    super.key,
    required this.onStepContinue,
    required this.paymentMethod,
  });

  final CheckoutPaymentMethodModelDtoBuilder paymentMethod;
  final VoidCallback onStepContinue;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PaymentMethodsFormContentsState();
}

class _PaymentMethodsFormContentsState
    extends ConsumerState<PaymentMethodsFormContents> {
  static const _blue = Color(0xFF2C2E7B);
  static const _orange = Color(0xFFF5AD00);

  final _node = FocusScopeNode();
  PaymentMethodModelDto? _selectedItem;

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    widget.paymentMethod.paymentMethods.build().forEach((m) {
      if (m.selected ?? false) {
        _selectedItem = m;
      }
    });
  }

  Future<void> _submit() async {
    if (_selectedItem == null) {
      showInSnackBar(context, 'Please select a payment method');
      return;
    }
    final controller = ref.read(checkoutControllerProvider.notifier);
    await controller
        .setPaymentMethod(
          _selectedItem?.paymentMethodSystemName ?? '',
          widget.paymentMethod.build(),
        )
        .then((value) {
      if (value != null && mounted) {
        showDialog(
          context: context,
          builder: (context) =>
              PaymentInfo(onStepContinue: widget.onStepContinue),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(checkoutControllerProvider);
    final methods = widget.paymentMethod.paymentMethods.build().toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Payment methods card ─────────────────────────────────────
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
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
                      child: const Icon(Icons.payment_rounded,
                          color: _blue, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      context.locale!.checkout_steps_payment_method_title
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

              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: methods.map((item) {
                    final isSelected = _selectedItem == item;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedItem = item),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _blue.withValues(alpha: 0.06)
                              : const Color(0xFFF4F5FB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? _blue.withValues(alpha: 0.4)
                                : Colors.grey.shade200,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Custom radio
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? _orange
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? _orange
                                      : Colors.grey.shade400,
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(Icons.circle,
                                      size: 8, color: Colors.white)
                                  : null,
                            ),
                            const SizedBox(width: 12),

                            // Logo
                            if (item.logoUrl?.isNotEmpty ?? false) ...[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: CustomImage(
                                  url: item.logoUrl ?? '',
                                  width: 44,
                                  height: 28,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(width: 10),
                            ],

                            // Name + fee
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name ?? '',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: _blue,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                  ),
                                  if (item.fee?.isNotEmpty ?? false) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      item.fee ?? '',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _orange.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Selected',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: _orange,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Continue button ──────────────────────────────────────────
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _orange,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: state.isLoading ? null : _submit,
            child: state.isLoading
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
                      Text('Continue',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16)),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
