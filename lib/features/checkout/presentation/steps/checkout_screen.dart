import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nopcommerce_mobile/features/app/scaffold_messenger_extansion.dart';
import 'package:nopcommerce_mobile/features/cart/presentation/cart_providers.dart';
import 'package:nopcommerce_mobile/features/checkout/presentation/checkout_providers.dart';
import 'package:nopcommerce_mobile/features/checkout/presentation/steps/address/billing_address_form.dart';
import 'package:nopcommerce_mobile/features/checkout/presentation/steps/confirm/confirm_widget.dart';
import 'package:nopcommerce_mobile/features/checkout/presentation/steps/payment/payment_widget.dart';
import 'package:nopcommerce_mobile/features/checkout/presentation/steps/shipping/shipping_widget.dart';
import 'package:nopcommerce_mobile/l10n/app_localizations_context.dart';
import 'package:nopcommerce_mobile/router/route_utils.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  static const _blue = Color(0xFF2C2E7B);

  int _currentStep = 0;
  bool _isValid = true;
  bool _useBillingAddressAsShippingAddress = false;

  Future<void> _submit(bool? isValid) async {
    if (isValid == false) {
      setState(() => _isValid = false);
      showInSnackBar(context, context.locale!.global_fix_error);
    } else {
      setState(() => _isValid = true);
    }
  }

  void continued() {
    if (_isValid && _currentStep < 3) {
      setState(() => _currentStep += 1);
      if (_currentStep == 3) {
        ref.invalidate(confirmOrder);
      }
    }
  }

  List<String> get _stepLabels => [
        context.locale!.checkout_steps_billing,
        context.locale!.checkout_steps_shipping,
        context.locale!.checkout_steps_payment,
        context.locale!.checkout_steps_confirm,
      ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentStep == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _currentStep > 0) {
          setState(() => _currentStep -= 1);
        }
      },
      child: Scaffold(
      backgroundColor: const Color(0xFFF4F5FB),
      appBar: AppBar(
        backgroundColor: _blue,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.locale!.checkout,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() => _currentStep -= 1);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: Column(
        children: [
          // ── Custom step indicator ────────────────────────────────────
          _StepIndicator(
            currentStep: _currentStep,
            labels: _stepLabels,
            onTap: (step) {
              if (step <= _currentStep) {
                setState(() => _currentStep = step);
              }
            },
          ),

          // ── Step content ─────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                16, 16, 16,
                MediaQuery.of(context).padding.bottom + 16,
              ),
              child: _stepContent(),
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _stepContent() {
    switch (_currentStep) {
      case 0:
        return BillingAddressForm(
          onStepContinue: continued,
          onSave: (isValid, useBillingAddressAsShippingAddress) {
            _submit(isValid);
            if (isValid ?? false) {
              setState(() {
                _useBillingAddressAsShippingAddress =
                    useBillingAddressAsShippingAddress;
              });
            }
          },
        );
      case 1:
        return ShippingForm(
          onStepContinue: continued,
          useBillingAddressAsShippingAddress:
              _useBillingAddressAsShippingAddress,
        );
      case 2:
        return PaymentForm(onStepContinue: continued);
      case 3:
        return ConfirmForm(
          onSave: (orderId, redirectToMethod) {
            if (redirectToMethod == 'Completed') {
              context.goNamed(
                Routes.orderDetails.name,
                pathParameters: {'id': orderId.toString()},
              );
              ref
                  .refresh(shoppingCartFutureProvider.future)
                  .whenComplete(
                    () => ref.refresh(shoppingCartTotalsProvider.future),
                  );
            }
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.currentStep,
    required this.labels,
    required this.onTap,
  });

  static const _blue = Color(0xFF2C2E7B);
  static const _orange = Color(0xFFF5AD00);

  final int currentStep;
  final List<String> labels;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _blue,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Row(
        children: List.generate(labels.length * 2 - 1, (i) {
          if (i.isOdd) {
            // Connector line
            final stepIndex = i ~/ 2;
            final completed = currentStep > stepIndex;
            return Expanded(
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  color: completed
                      ? _orange.withValues(alpha: 0.8)
                      : Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            );
          }

          final stepIndex = i ~/ 2;
          final isActive = stepIndex == currentStep;
          final isCompleted = stepIndex < currentStep;
          final isTappable = stepIndex <= currentStep;

          return GestureDetector(
            onTap: isTappable ? () => onTap(stepIndex) : null,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Circle
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: isActive ? 44 : 36,
                  height: isActive ? 44 : 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive
                        ? _orange
                        : isCompleted
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.15),
                    border: isCompleted
                        ? Border.all(color: _orange, width: 2)
                        : null,
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: _orange.withValues(alpha: 0.5),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check_rounded,
                            size: 18, color: _orange)
                        : Text(
                            '${stepIndex + 1}',
                            style: TextStyle(
                              color: isActive ? Colors.white : Colors.white60,
                              fontSize: isActive ? 16 : 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 6),
                // Label
                Text(
                  labels[stepIndex],
                  style: TextStyle(
                    color: isActive
                        ? Colors.white
                        : isCompleted
                            ? Colors.white.withValues(alpha: 0.85)
                            : Colors.white.withValues(alpha: 0.45),
                    fontSize: 11,
                    fontWeight:
                        isActive ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
