import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:frontend_api/frontend_api.dart';
import 'package:go_router/go_router.dart';
import 'package:nopcommerce_mobile/common_widgets/custom_image.dart';
import 'package:nopcommerce_mobile/common_widgets/quantity_selector_widget.dart';
import 'package:nopcommerce_mobile/features/cart/presentation/cart_providers.dart';
import 'package:nopcommerce_mobile/router/route_utils.dart';

class ShoppingCartItem extends StatelessWidget {
  const ShoppingCartItem({
    super.key,
    required this.item,
    required this.itemIndex,
    required this.isEditable,
  });

  final ShoppingCartItemModelDto item;
  final int itemIndex;
  final bool isEditable;

  static const _blue = Color(0xFF2C2E7B);
  static const _orange = Color(0xFFF5AD00);

  @override
  Widget build(BuildContext context) {
    String warnings = '';
    if (item.warnings?.isNotEmpty ?? false) {
      item.warnings?.forEach((e) => warnings = '$warnings$e\n');
      warnings = warnings.trimRight();
    }

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
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            GestureDetector(
              onTap: () => context.goNamed(
                Routes.product.name,
                pathParameters: {'id': item.productId.toString()},
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 88,
                  height: 88,
                  child: CustomImage(
                    url: item.picture?.imageUrl ?? '',
                    fit: BoxFit.cover,
                    width: 88,
                    height: 88,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name row + delete
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => context.goNamed(
                            Routes.product.name,
                            pathParameters: {'id': item.productId.toString()},
                          ),
                          child: Text(
                            item.productName ?? '',
                            style: const TextStyle(
                              color: _blue,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      if (isEditable) ...[
                        const SizedBox(width: 6),
                        RemoveItemWidget(item: item, itemIndex: itemIndex),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),

                  // SKU
                  if (item.sku?.isNotEmpty ?? false)
                    Text(
                      'SKU: ${item.sku}',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                      ),
                    ),

                  // Unit price
                  if (item.unitPrice?.isNotEmpty ?? false) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.unitPrice ?? '',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],

                  // Attributes / rental info
                  if (item.attributeInfo?.isNotEmpty ?? false) ...[
                    const SizedBox(height: 4),
                    HtmlWidget(
                      item.attributeInfo ?? '',
                      textStyle: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                  if (item.rentalInfo?.isNotEmpty ?? false) ...[
                    const SizedBox(height: 4),
                    HtmlWidget(
                      item.rentalInfo ?? '',
                      textStyle: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),

                  // Quantity + subtotal row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      isEditable
                          ? EditItemWidget(item: item, itemIndex: itemIndex)
                          : Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF4F5FB),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Qty: ${item.quantity}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _blue,
                                ),
                              ),
                            ),
                      const Spacer(),
                      Text(
                        item.subTotal ?? '',
                        style: const TextStyle(
                          color: _orange,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),

                  // Warnings
                  if (warnings.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        warnings,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 11,
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
  }
}

class EditItemWidget extends ConsumerWidget {
  const EditItemWidget({
    super.key,
    required this.item,
    required this.itemIndex,
  });

  final ShoppingCartItemModelDto item;
  final int itemIndex;

  static Key deleteKey(int index) => Key('delete-$index');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(shoppingCartControllerProvider);
    return QuantitySelector(
      quantity: item.quantity ?? 0,
      shoppingCartItem: item,
      itemIndex: itemIndex,
      onChanged: state.isLoading
          ? null
          : (quantity) => ref
              .read(shoppingCartControllerProvider.notifier)
              .updateItemQuantity(item.id!, quantity),
    );
  }
}

class RemoveItemWidget extends ConsumerWidget {
  const RemoveItemWidget({
    super.key,
    required this.item,
    required this.itemIndex,
  });

  final ShoppingCartItemModelDto item;
  final int itemIndex;

  static Key deleteKey(int index) => Key('delete-$index');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(shoppingCartControllerProvider);
    return GestureDetector(
      key: deleteKey(itemIndex),
      onTap: state.isLoading
          ? null
          : () => ref
              .read(shoppingCartControllerProvider.notifier)
              .removeItemById(item.id!),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.close_rounded,
          size: 16,
          color: Colors.red.shade400,
        ),
      ),
    );
  }
}
