import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nopcommerce_mobile/features/app/scaffold_messenger_extansion.dart';
import 'package:nopcommerce_mobile/features/checkout/presentation/checkout_providers.dart';
import 'package:nopcommerce_mobile/frontend_api/lib/frontend_api.dart';
import 'package:nopcommerce_mobile/l10n/app_localizations_context.dart';

class PickupPointsFormContents extends ConsumerStatefulWidget {
  const PickupPointsFormContents({
    super.key,
    required this.pickupPoints,
    required this.onStepContinue,
  });

  final CheckoutPickupPointsModelDto pickupPoints;
  final VoidCallback onStepContinue;

  @override
  ConsumerState<PickupPointsFormContents> createState() =>
      _PickupPointsFormState();
}

class _PickupPointsFormState extends ConsumerState<PickupPointsFormContents> {
  static const _blue = Color(0xFF2C2E7B);
  static const _orange = Color(0xFFF5AD00);

  final _node = FocusScopeNode();
  String? _selectedItem;
  bool _isExpanded = true;

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.pickupPoints.pickupPoints?.isNotEmpty ?? false) {
      final p = widget.pickupPoints.pickupPoints!.first;
      _selectedItem = '${p.id ?? ''}___${p.providerSystemName ?? ''}';
    }
  }

  Future<void> _submit() async {
    if (_selectedItem == null || _selectedItem!.isEmpty) {
      showInSnackBar(
          context,
          context.locale!
              .checkout_steps_shipping_pickup_points_not_selected);
      return;
    }
    final controller = ref.read(checkoutControllerProvider.notifier);
    await controller.setPickupPoint(_selectedItem!).then((value) {
      if (value?.redirectToMethod == 'PaymentMethod') {
        widget.onStepContinue();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(checkoutControllerProvider);
    final points = widget.pickupPoints.pickupPoints?.toList() ?? <CheckoutPickupPointModelDto>[];

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
                      child: const Icon(Icons.store_rounded,
                          color: _blue, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      context.locale!
                          .checkout_steps_shipping_pickup_points_title
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

              if (points.isEmpty)
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
                    children: [
                      // Collapsed summary — tap to re-expand
                      if (!_isExpanded && _selectedItem != null) ...[
                        GestureDetector(
                          onTap: () => setState(() => _isExpanded = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: _blue.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: _blue.withValues(alpha: 0.35),
                                  width: 1.5),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.store_rounded,
                                    color: _blue, size: 18),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    () {
                                      final sel = points.firstWhere(
                                        (p) =>
                                            '${p.id ?? ''}___${p.providerSystemName ?? ''}' ==
                                            _selectedItem,
                                        orElse: () => points.first,
                                      );
                                      return [
                                        sel.name,
                                        sel.address,
                                        sel.city
                                      ]
                                          .where(
                                              (s) => s?.isNotEmpty ?? false)
                                          .join(', ');
                                    }(),
                                    style: const TextStyle(
                                        color: _blue,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(Icons.keyboard_arrow_down_rounded,
                                    color: _blue, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                      // Expanded list
                      if (_isExpanded)
                        ...points.map((item) {
                          final value =
                              '${item.id ?? ''}___${item.providerSystemName ?? ''}';
                          final isSelected = _selectedItem == value;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedItem = value;
                                _isExpanded = false;
                              });
                              _submit();
                            },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(14),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Custom radio
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: AnimatedContainer(
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
                              ),
                              const SizedBox(width: 12),
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
                                            : FontWeight.w500,
                                      ),
                                    ),
                                    if ((item.address?.isNotEmpty ?? false) ||
                                        (item.city?.isNotEmpty ?? false)) ...[
                                      const SizedBox(height: 3),
                                      Text(
                                        [
                                          item.address,
                                          item.city,
                                          item.countryName,
                                        ]
                                            .where((s) => s?.isNotEmpty ?? false)
                                            .join(', '),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                    if (item.pickupFee?.isNotEmpty ?? false) ...[
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? _orange.withValues(alpha: 0.15)
                                              : Colors.grey.shade100,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          item.pickupFee ?? '',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isSelected
                                                ? _orange
                                                : Colors.grey.shade600,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                          );
                        }),
                    ],
                  ),
                ),
            ],
          ),
        ),
        if (state.isLoading) ...[
          const SizedBox(height: 16),
          const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Color(0xFF2C2E7B),
            ),
          ),
        ],
      ],
    );
  }
}
