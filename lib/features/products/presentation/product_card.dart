import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_api/frontend_api.dart';
import 'package:go_router/go_router.dart';
import 'package:nopcommerce_mobile/common_widgets/custom_image.dart';
import 'package:nopcommerce_mobile/customize/models/product_model.dart';
import 'package:nopcommerce_mobile/features/app/scaffold_messenger_extansion.dart';
import 'package:nopcommerce_mobile/features/cart/domain/cart_item.dart';
import 'package:nopcommerce_mobile/features/cart/presentation/add_to_card/add_to_cart_controller.dart';
import 'package:nopcommerce_mobile/l10n/app_localizations_context.dart';
import 'package:nopcommerce_mobile/router/route_utils.dart';
import 'package:nopcommerce_mobile/utils/async_value_ui.dart';

class ProductCard extends ConsumerStatefulWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.onPressed,
    this.width,
  });

  final ProductOverviewModelDto product;
  final VoidCallback? onPressed;
  final double? width;

  @override
  ConsumerState<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<ProductCard> {
  bool _isLoading = false;

  static const _blue = Color(0xFF2C2E7B);
  static const _orange = Color(0xFFF5AD00);

  Future<void> addToCart() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final response = await ref
          .read(addToCartControllerProvider.notifier)
          .addCartItemFromCatalog(widget.product.id!, ShoppingCartType.shoppingCart);
      if (!mounted) return;
      if (response?.success ?? false) {
        showInSnackBar(context, context.locale!.product_add_to_card, color: Colors.green);
      } else {
        context.pushNamed(Routes.product.name,
            pathParameters: {'id': widget.product.id.toString()});
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<CartItem>>(
      addToCartControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );
    var cardwidth = widget.width ?? MediaQuery.of(context).size.width / 2;

    return SizedBox(
      width: cardwidth,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF2F4FF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0x4D2C2E7B),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2C2E7B).withValues(alpha: 0.18),
              blurRadius: 16,
              spreadRadius: 0,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 4,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(14),
            splashColor: const Color(0xFF2C2E7B).withValues(alpha: 0.08),
            highlightColor: const Color(0xFF2C2E7B).withValues(alpha: 0.04),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image area
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 1.0,
                    child: Container(
                      color: const Color(0xFFF7F8FA),
                      child: CustomImage(
                        url: widget.product.pictureModels?.first.imageUrl ?? '',
                      ),
                    ),
                  ),
                  // NEW badge
                  if (widget.product.markAsNew ?? false)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: _blue,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          context.locale!.product_new_product_label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  // SALE badge
                  if (widget.product.productPrice?.oldPrice != null)
                    Positioned(
                      top: (widget.product.markAsNew ?? false) ? 28 : 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: _orange,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Text(
                          'SALE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  // Wishlist icon
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      child: const Icon(Icons.favorite_border, size: 15, color: Color(0xffEC692F)),
                    ),
                  ),
                ],
              ),
              // Info area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name ?? '',
                        style: const TextStyle(
                          color: Color(0xFF1A1A2E),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      ProductCardPrice(product: widget.product),
                      const Spacer(),
                      if (!(widget.product.productPrice?.disableBuyButton ?? false))
                        SizedBox(
                          width: double.infinity,
                          height: 32,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : addToCart,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _orange,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: _orange.withValues(alpha: 0.6),
                              padding: EdgeInsets.zero,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.shopping_cart_outlined, size: 13),
                                      SizedBox(width: 4),
                                      Text('Add to Cart', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  }
}

class ProductCardPrice extends StatelessWidget {
  const ProductCardPrice({super.key, required this.product});

  /// Product
  final ProductOverviewModelDto product;

  @override
  Widget build(BuildContext context) {
    if (product.productPrice != null) {
      final productPrice = product.productPrice!;
      final isRental = productPrice.isRental ?? false;
      final isGrouded = product.productType == ProductType.groupedProduct;

      if (productPrice.price != null) {
        String price = productPrice.price!;
        String priceBeforeText = '';
        String priceValue = '';
        String priceAfterText = '';

        if (isRental || isGrouded) {
          int spaceIndex = price.indexOf(" ");

          if (spaceIndex > 0) {
            if (isRental) {
              priceValue = price.substring(0, spaceIndex);
              priceAfterText = price.substring(spaceIndex + 1);
            } else if (isGrouded) {
              priceBeforeText = price.substring(0, spaceIndex);
              priceValue = price.substring(spaceIndex + 1);
            }
          }
        } else {
          priceValue = price;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (productPrice.oldPrice != null)
              Text(
                productPrice.oldPrice!,
                style: const TextStyle(
                  color: Color(0xFF595959),
                  fontSize: 11,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: Color(0xFF595959),
                ),
                maxLines: 1,
              ),
            if (priceBeforeText.isNotEmpty)
              Text(
                priceBeforeText,
                style: const TextStyle(color: Color(0xFF595959), fontSize: 11),
                maxLines: 1,
              ),
            if (priceValue.isNotEmpty)
              Text(
                priceValue,
                style: TextStyle(
                  color: const Color(0xFF2C2E7B),
                  fontWeight: FontWeight.bold,
                  fontSize: priceValue.length > 7 ? 12 : 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            if (priceAfterText.isNotEmpty)
              Text(
                priceAfterText,
                style: const TextStyle(color: Color(0xFF595959), fontSize: 11),
                maxLines: 1,
              ),
          ],
        );
      } else {
        return const SizedBox.shrink();
      }
    } else {
      return const SizedBox.shrink();
    }
  }
}
// Card for Product model (used in filter sections: Bestsellers, Newest, etc.)
class ProductCard2 extends ConsumerStatefulWidget {
  const ProductCard2({
    super.key,
    required this.product,
    this.onPressed,
    this.width,
  });

  final Product product;
  final VoidCallback? onPressed;
  final double? width;

  @override
  ConsumerState<ProductCard2> createState() => _ProductCard2State();
}

class _ProductCard2State extends ConsumerState<ProductCard2> {
  bool _isLoading = false;

  static const _blue = Color(0xFF2C2E7B);
  static const _orange = Color(0xFFF5AD00);

  Future<void> addToCart() async {
    if (_isLoading) {
      return;
    }
    setState(() => _isLoading = true);
    try {
      final response = await ref
          .read(addToCartControllerProvider.notifier)
          .addCartItemFromCatalog(widget.product.id, ShoppingCartType.shoppingCart);
      if (!mounted) {
        return;
      }
      if (response?.success ?? false) {
        showInSnackBar(context, context.locale!.product_add_to_card, color: Colors.green);
      } else {
        context.pushNamed(Routes.product.name,
            pathParameters: {'id': widget.product.id.toString()});
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<CartItem>>(
      addToCartControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );

    final cardWidth = widget.width ?? MediaQuery.of(context).size.width / 2;
    final price = widget.product.productPrice;
    final imageUrl = widget.product.pictureModels.isNotEmpty
        ? widget.product.pictureModels.first.imageUrl
        : '';

    return SizedBox(
      width: cardWidth,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF2F4FF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x4D2C2E7B), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: _blue.withValues(alpha: 0.18),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(14),
            splashColor: _blue.withValues(alpha: 0.08),
            highlightColor: _blue.withValues(alpha: 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image area
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 1.0,
                      child: Container(
                        color: const Color(0xFFF7F8FA),
                        child: CustomImage(url: imageUrl),
                      ),
                    ),
                    if (widget.product.markAsNew)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: _blue,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            context.locale!.product_new_product_label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    if (price.oldPrice != null)
                      Positioned(
                        top: widget.product.markAsNew ? 28 : 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: _orange,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Text(
                            'SALE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                        ),
                        child: const Icon(Icons.favorite_border, size: 15, color: Color(0xffEC692F)),
                      ),
                    ),
                  ],
                ),
                // Info area
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.name,
                          style: const TextStyle(
                            color: Color(0xFF1A1A2E),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (price.oldPrice != null)
                          Text(
                            price.oldPrice!,
                            style: const TextStyle(
                              color: Color(0xFF595959),
                              fontSize: 11,
                              decoration: TextDecoration.lineThrough,
                              decorationColor: Color(0xFF595959),
                            ),
                            maxLines: 1,
                          ),
                        if (price.price != null)
                          Text(
                            price.price!,
                            style: TextStyle(
                              color: _blue,
                              fontWeight: FontWeight.bold,
                              fontSize: (price.price?.length ?? 0) > 7 ? 12 : 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const Spacer(),
                        if (!price.disableBuyButton)
                          SizedBox(
                            width: double.infinity,
                            height: 32,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : addToCart,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _orange,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: _orange.withValues(alpha: 0.6),
                                padding: EdgeInsets.zero,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.shopping_cart_outlined, size: 13),
                                        SizedBox(width: 4),
                                        Text('Add to Cart',
                                            style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700)),
                                      ],
                                    ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}