import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:go_router/go_router.dart';
import 'package:nopcommerce_mobile/common_widgets/custom_image.dart';
import 'package:nopcommerce_mobile/features/customer/presentation/account/account_providers.dart';
import 'package:nopcommerce_mobile/frontend_api/lib/frontend_api.dart';
import 'package:nopcommerce_mobile/l10n/app_localizations_context.dart';
import 'package:nopcommerce_mobile/router/route_utils.dart';
import 'package:nopcommerce_mobile/utils/common_utility.dart';

const _blue = Color(0xFF2C2E7B);
const _orange = Color(0xFFF5AD00);

class WishlistItem extends StatelessWidget {
  const WishlistItem({
    super.key,
    required this.item,
    required this.itemIndex,
    required this.isEditable,
  });

  final WishlistShoppingCartItemModelDto item;
  final int itemIndex;
  final bool isEditable;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: _blue.withAlpha(18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 80,
                height: 80,
                child: CustomImage(
                  url: item.picture?.fullSizeImageUrl ??
                      item.picture?.imageUrl ??
                      '',
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Product info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + delete button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => context.pushNamed(
                            Routes.product.name,
                            pathParameters: {
                              'id': item.productId.toString(),
                            },
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
                      RemoveItemWidget(item: item, itemIndex: itemIndex),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // SKU
                  if (item.sku?.isNotEmpty ?? false) ...[
                    Text(
                      context.locale!.cart_item_sku.format([item.sku]),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],

                  // Price
                  if (item.unitPrice?.isNotEmpty ?? false)
                    Text(
                      item.unitPrice!,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _orange,
                      ),
                    ),

                  // Quantity
                  if (item.quantity != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      context.locale!.cart_item_quantity.format([item.quantity]),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],

                  // Attributes / rental info
                  if (item.attributeInfo?.isNotEmpty ?? false) ...[
                    const SizedBox(height: 4),
                    HtmlWidget(
                      item.attributeInfo!,
                      textStyle: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                  if (item.rentalInfo?.isNotEmpty ?? false) ...[
                    const SizedBox(height: 4),
                    HtmlWidget(
                      item.rentalInfo!,
                      textStyle: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],

                  // Add to cart button
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: AddItemWidget(item: item, itemIndex: itemIndex),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RemoveItemWidget extends ConsumerWidget {
  const RemoveItemWidget({
    super.key,
    required this.item,
    required this.itemIndex,
  });
  final WishlistShoppingCartItemModelDto item;
  final int itemIndex;

  static Key deleteKey(int index) => Key('delete-$index');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(wishlistControllerProvider);
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton(
        padding: EdgeInsets.zero,
        key: deleteKey(itemIndex),
        icon: Icon(
          Icons.delete_outline_rounded,
          size: 20,
          color: Colors.red.shade300,
        ),
        onPressed: state.isLoading
            ? null
            : () => ref
                .read(wishlistControllerProvider.notifier)
                .removeItemById(item.id!),
      ),
    );
  }
}

class AddItemWidget extends ConsumerWidget {
  const AddItemWidget({super.key, required this.item, required this.itemIndex});
  final WishlistShoppingCartItemModelDto item;
  final int itemIndex;

  static Key addKey(int index) => Key('add-$index');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(wishlistControllerProvider);
    return SizedBox(
      height: 34,
      child: ElevatedButton.icon(
        key: addKey(itemIndex),
        style: ElevatedButton.styleFrom(
          backgroundColor: state.isLoading ? Colors.grey.shade200 : _orange,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        icon: const Icon(Icons.shopping_cart_outlined, size: 16),
        label: Text(
          context.locale!.cart_add_to,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
        onPressed: state.isLoading
            ? null
            : () => ref
                .read(wishlistControllerProvider.notifier)
                .addItemToCartById(item.id!),
      ),
    );
  }
}
