import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_api/frontend_api.dart';
import 'package:go_router/go_router.dart';
import 'package:nopcommerce_mobile/common_widgets/quantity_selector_widget.dart';
import 'package:nopcommerce_mobile/customize/widgets/checkout/checkout_modal.dart';
import 'package:nopcommerce_mobile/features/app/scaffold_messenger_extansion.dart';
import 'package:nopcommerce_mobile/features/cart/presentation/add_to_card/add_to_cart_controller.dart';
import 'package:nopcommerce_mobile/router/route_utils.dart';

class ProductBottomBar extends ConsumerWidget {
  const ProductBottomBar({
    super.key,
    required this.product,
    required this.addToCart,
    required this.isGuest,
  });

  final ProductDetailsModelDto product;
  final Function() addToCart;
  final bool isGuest;

  static const _blue = Color(0xFF2C2E7B);
  static const _orange = Color(0xFFF5AD00);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addToCartControllerProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x1A2C2E7B),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (product.addToCart?.minimumQuantityNotification?.isNotEmpty ??
              false)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Text(
                  product.addToCart?.minimumQuantityNotification ?? '',
                  style: TextStyle(
                    color: Colors.orange.shade800,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          Row(
            children: [
              if (!(product.displayBackInStockSubscription ?? false)) ...[
                QuantitySelector(
                  quantity: state.value?.quantity ??
                      product.addToCart!.enteredQuantity!,
                  addToCart: product.addToCart,
                  onChanged: state.isLoading
                      ? null
                      : (quantity) => ref
                          .read(addToCartControllerProvider.notifier)
                          .updateQuantity(quantity),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: state.isLoading ? null : addToCart,
                  icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                  label: const Text('Add to Cart'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _blue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _blue.withValues(alpha: 0.4),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: state.isLoading
                      ? null
                      : () async {
                          final controller =
                              ref.read(addToCartControllerProvider.notifier);
                          await controller
                              .addCartItemFromProduct(
                            product.id!,
                            product.addToCart?.enteredQuantity,
                            ShoppingCartType.shoppingCart,
                          )
                              .then((response) {
                            if (!context.mounted) {
                              return;
                            }
                            if (isGuest) {
                              showDialog(
                                context: context,
                                builder: (_) => const CheckoutModal(),
                              );
                            } else {
                              showInSnackBar(
                                context,
                                (response?.success ?? false)
                                    ? 'Added to cart!'
                                    : response?.errors.toString() ?? '',
                                color: (response?.success ?? false)
                                    ? Colors.green
                                    : Colors.red,
                              );
                              if ((response?.success ?? false) &&
                                  context.mounted) {
                                context.pushNamed(Routes.checkout.name);
                              }
                            }
                          });
                        },
                  icon: const Icon(Icons.flash_on_rounded, size: 18),
                  label: const Text('Buy Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _orange,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _orange.withValues(alpha: 0.4),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
