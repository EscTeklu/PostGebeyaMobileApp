import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nopcommerce_mobile/features/app/scaffold_messenger_extansion.dart';
import 'package:nopcommerce_mobile/features/checkout/presentation/checkout_providers.dart';
import 'package:nopcommerce_mobile/frontend_api/lib/frontend_api.dart';
import 'package:nopcommerce_mobile/l10n/app_localizations_context.dart';

class ShippingMethodsFormContents extends ConsumerStatefulWidget {
  const ShippingMethodsFormContents({
    super.key,
    required this.shippingMethodResponse,
    required this.onStepContinue,
  });

  final ShippingMethodResponse shippingMethodResponse;
  final VoidCallback onStepContinue;

  @override
  ConsumerState<ShippingMethodsFormContents> createState() =>
      _ShippingMethodsFormState();
}

class _ShippingMethodsFormState
    extends ConsumerState<ShippingMethodsFormContents> {
  static const _blue = Color(0xFF2C2E7B);
  static const _orange = Color(0xFFF5AD00);

  final _node = FocusScopeNode();
  String? _selectedItem;

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.shippingMethodResponse.model != null) {
      for (var m in widget.shippingMethodResponse.model!.shippingMethods!) {
        if (m.selected ?? false) {
          _selectedItem =
              '${m.name ?? ''}___${m.shippingRateComputationMethodSystemName ?? ''}';
        }
      }
    }
  }

  Future<void> _submit() async {
    if (_selectedItem == null || _selectedItem!.isEmpty) {
      showInSnackBar(context,
          context.locale!.checkout_steps_shipping_not_selected);
      return;
    }
    final controller = ref.read(checkoutControllerProvider.notifier);
    await controller.setShippingMethod(_selectedItem!).then((value) {
      if (value?.redirectToMethod == 'PaymentMethod') {
        widget.onStepContinue();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(checkoutControllerProvider);

    // No shipping required
    if (widget.shippingMethodResponse.model == null &&
        widget.shippingMethodResponse.redirectToMethod == 'PaymentMethod') {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
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
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_circle_rounded,
                      color: Colors.green.shade500, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.locale!.checkout_steps_shipping_not_required,
                    style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _ContinueButton(
              isLoading: state.isLoading, onPressed: widget.onStepContinue),
        ],
      );
    }

    final methods =
        widget.shippingMethodResponse.model?.shippingMethods ?? <ShippingMethodModelDto>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
                      child: const Icon(Icons.directions_car_rounded,
                          color: _blue, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      context.locale!.checkout_steps_shipping_method_title
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

              if (methods.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    context.locale!.checkout_steps_shipping_not_available,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: methods.map((item) {
                      final value =
                          '${item.name ?? ''}___${item.shippingRateComputationMethodSystemName ?? ''}';
                      final isSelected = _selectedItem == value;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedItem = value),
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
                              Expanded(
                                child: Text(
                                  item.name ?? '',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _blue,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? _orange.withValues(alpha: 0.15)
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  item.fee ?? '',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isSelected
                                        ? _orange
                                        : Colors.grey.shade600,
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
        _ContinueButton(isLoading: state.isLoading, onPressed: _submit),
      ],
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                  Text('Continue',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 16)),
                ],
              ),
      ),
    );
  }
}
