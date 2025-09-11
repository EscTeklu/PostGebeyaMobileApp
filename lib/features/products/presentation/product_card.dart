import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_api/frontend_api.dart';
import 'package:go_router/go_router.dart';
import 'package:nopcommerce_mobile/common_widgets/custom_image.dart';
import 'package:nopcommerce_mobile/common_widgets/custom_icon_button.dart';
import 'package:nopcommerce_mobile/constants/global_variables.dart';
import 'package:nopcommerce_mobile/customize/models/product.dart';
import 'package:nopcommerce_mobile/features/app/scaffold_messenger_extansion.dart';
import 'package:nopcommerce_mobile/features/app/theme/custom_color_scheme.dart';
import 'package:nopcommerce_mobile/features/cart/domain/cart_item.dart';
import 'package:nopcommerce_mobile/features/cart/presentation/add_to_card/add_to_cart_controller.dart';
import 'package:nopcommerce_mobile/l10n/app_localizations_context.dart';
import 'package:nopcommerce_mobile/router/route_utils.dart';
import 'package:nopcommerce_mobile/themes/nopCommerce/dist/styledictionary/flutter/style_dictionary.dart';
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
  void addToCart() async {
    _addToCart(ShoppingCartType.shoppingCart);
  }

  void _addToCart(ShoppingCartType cartType) async {
    await ref
        .read(addToCartControllerProvider.notifier)
        .addCartItemFromCatalog(widget.product.id!, cartType)
        .then(
          (addProductToCartResponse) => {
            if ((addProductToCartResponse?.success ?? false) && mounted)
              {
                showInSnackBar(
                  context,
                  (cartType == ShoppingCartType.shoppingCart
                      ? context.locale!.product_add_to_card
                      : context.locale!.product_add_to_wishlist),
                  color: Colors.green,
                ),
              }
            else if (mounted)
              {
                context.pushNamed(
                  Routes.product.name,
                  pathParameters: {'id': widget.product.id.toString()},
                ),
              },
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<CartItem>>(
      addToCartControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );
    //final
    final state = ref.watch(addToCartControllerProvider);
    //print(widget.product.videoModels?.isNotEmpty);
    const double borderRadius = 12;
    var cardwidth = widget.width ?? MediaQuery.of(context).size.width / 2;

    var productPicture = Stack(
      children: [
        CustomImage(url: widget.product.pictureModels?.first.imageUrl ?? ""),
        if (widget.product.markAsNew ?? false) ...[
          Container(
            margin: const EdgeInsets.fromLTRB(8, 8, 0, 0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.tertiaryContainer,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withOpacity(0.6),
                  offset: const Offset(1, 1),
                  blurRadius: 0.5,
                ),
              ],
              borderRadius: const BorderRadius.all(Radius.circular(5)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
              child: Text(
                context.locale!.product_new_product_label,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onTertiaryContainer,
                ),
              ),
            ),
          ),
        ],
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.favorite_outline_sharp, color: Color(0xffEC692F)),
          ),
        ),
      ],
    );

    return SizedBox(
      width: cardwidth,
      child: Card(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: StyleDictionary.mdSysColorPrimary.withOpacity(0.1),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: widget.onPressed,
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  Expanded(
                    flex: 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(borderRadius),
                      child: Container(
                        color: Colors.white,
                        child: productPicture,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Star Rating
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: GlobalVariables.secondaryColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        ((widget.product.reviewOverviewModel?.totalReviews ??
                                        0) >
                                    0
                                ? ((widget
                                            .product
                                            .reviewOverviewModel
                                            ?.ratingSum ??
                                        0) /
                                    (widget
                                            .product
                                            .reviewOverviewModel
                                            ?.totalReviews ??
                                        1))
                                : 0.0)
                            .toStringAsPrecision(2),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 4),
                      /* Text(
                        ("(123)"),
                        style: Theme.of(context).textTheme.bodySmall,
                      ), */
                    ],
                  ),

                  // Product Name
                  Text(
                    widget.product.name ?? '',
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  //bahu added
                  Text(
                    widget.product.videoModels?.first.videoUrl ?? '',
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  // Price and Add to Cart Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        flex: 2,
                        child: ProductCardPrice(product: widget.product),
                      ),
                      if (!(widget.product.productPrice?.disableBuyButton ??
                          false))
                        Flexible(
                          flex: 1,
                          child: CustomIconButton(
                            filled: true,
                            icon: const Icon(Icons.shopping_cart, size: 18),
                            onPressed: state.isLoading ? null : addToCart,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
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
      CustomColors? myColors = Theme.of(context).extension<CustomColors>()!;

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
          children: [
            if (productPrice.oldPrice != null)
              Wrap(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      productPrice.oldPrice!,
                      style: TextStyle(
                        color: Color(0xff595959),
                        fontSize: 14,
                        decoration: TextDecoration.lineThrough,
                      ),
                      maxLines: 1,
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            if (priceBeforeText.isNotEmpty)
              Wrap(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      priceBeforeText,
                      style: TextStyle(
                        color: GlobalVariables.secondaryColor,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            if (priceValue.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  priceValue,
                  style: TextStyle(
                    color: GlobalVariables.secondaryColor,
                    fontWeight: FontWeight.w300,
                    fontSize: priceValue.length > 7 ? 17 : 20,
                  ),
                  maxLines: 2,
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.fade,
                ),
              ),
            if (priceAfterText.isNotEmpty)
              Wrap(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      priceAfterText,
                      style: TextStyle(
                        color: GlobalVariables.secondaryColor,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
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
//for card2
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
  void addToCart() async {
    _addToCart(ShoppingCartType.shoppingCart);
  }

  void _addToCart(ShoppingCartType cartType) async {
    await ref
        .read(addToCartControllerProvider.notifier)
        .addCartItemFromCatalog(widget.product.id, cartType)
        .then(
          (addProductToCartResponse) => {
        if ((addProductToCartResponse?.success ?? false) && mounted)
          {
            showInSnackBar(
              context,
              (cartType == ShoppingCartType.shoppingCart
                  ? context.locale!.product_add_to_card
                  : context.locale!.product_add_to_wishlist),
              color: Colors.green,
            ),
          }
        else if (mounted)
          {
            context.pushNamed(
              Routes.product.name,
              pathParameters: {'id': widget.product.id.toString()},
            ),
          },
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<CartItem>>(
      addToCartControllerProvider,
          (_, state) => state.showAlertDialogOnError(context),
    );

    final state = ref.watch(addToCartControllerProvider);

    const double borderRadius = 12;
    var cardwidth = widget.width ?? MediaQuery.of(context).size.width / 2;

    var productPicture = Stack(
      children: [
        CustomImage(url: widget.product.defaultPictureUrl ?? ""),
        /*if (widget.product.markAsNew ?? false) ...[
          Container(
            margin: const EdgeInsets.fromLTRB(8, 8, 0, 0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.tertiaryContainer,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withOpacity(0.6),
                  offset: const Offset(1, 1),
                  blurRadius: 0.5,
                ),
              ],
              borderRadius: const BorderRadius.all(Radius.circular(5)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
              child: Text(
                context.locale!.product_new_product_label,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onTertiaryContainer,
                ),
              ),
            ),
          ),
        ],*/
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.favorite_outline_sharp, color: Color(0xffEC692F)),
          ),
        ),
      ],
    );

    return SizedBox(
      width: cardwidth,
      child: Card(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: StyleDictionary.mdSysColorPrimary.withOpacity(0.1),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: widget.onPressed,
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  Expanded(
                    flex: 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(borderRadius),
                      child: Container(
                        color: Colors.white,
                        child: productPicture,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Star Rating
                  /*Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: GlobalVariables.secondaryColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        ((widget.product.reviewOverviewModel?.totalReviews ??
                            0) >
                            0
                            ? ((widget
                            .product
                            .reviewOverviewModel
                            ?.ratingSum ??
                            0) /
                            (widget
                                .product
                                .reviewOverviewModel
                                ?.totalReviews ??
                                1))
                            : 0.0)
                            .toStringAsPrecision(2),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 4),
                      *//* Text(
                        ("(123)"),
                        style: Theme.of(context).textTheme.bodySmall,
                      ), *//*
                    ],
                  ),*/

                  // Product Name
                  Text(
                    widget.product.name ?? '',
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),

                  // Price and Add to Cart Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        flex: 2,
                        child: ProductCard2Price(product: widget.product),
                      ),
                      //if (!(widget.product.productPrice?.disableBuyButton ??
                         // false))
                        Flexible(
                          flex: 1,
                          child: CustomIconButton(
                            filled: true,
                            icon: const Icon(Icons.shopping_cart, size: 18),
                            onPressed: state.isLoading ? null : addToCart,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
//
/* class ProductCard extends ConsumerStatefulWidget {
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
  void addToCart() async {
    _addToCart(ShoppingCartType.shoppingCart);
  }

  void _addToCart(ShoppingCartType cartType) async {
    await ref
        .read(addToCartControllerProvider.notifier)
        .addCartItemFromCatalog(widget.product.id!, cartType)
        .then(
          (addProductToCartResponse) => {
            if ((addProductToCartResponse?.success ?? false) && mounted)
              {
                showInSnackBar(
                  context,
                  (cartType == ShoppingCartType.shoppingCart
                      ? context.locale!.product_add_to_card
                      : context.locale!.product_add_to_wishlist),
                  color: Colors.green,
                ),
              }
            else if (mounted)
              {
                context.pushNamed(
                  Routes.product.name,
                  pathParameters: {'id': widget.product.id.toString()},
                ),
              },
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<CartItem>>(
      addToCartControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );

    final state = ref.watch(addToCartControllerProvider);

    const double borderRadius = 12;
    var cardwidth = widget.width ?? MediaQuery.of(context).size.width / 2;

    var productPicture = Stack(
      children: [
        CustomImage(url: widget.product.pictureModels?.first.imageUrl ?? ""),
        if (widget.product.markAsNew ?? false) ...[
          Container(
            margin: const EdgeInsets.fromLTRB(4, 4, 0, 0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.tertiaryContainer,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withOpacity(0.6),
                  offset: const Offset(1, 1),
                  blurRadius: 0.5,
                ),
              ],
              borderRadius: const BorderRadius.all(Radius.circular(5)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
              child: Text(
                context.locale!.product_new_product_label,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onTertiaryContainer,
                ),
              ),
            ),
          ),
        ],
      ],
    );

    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: SizedBox(
        width: cardwidth,
        child: Card(
          child: InkWell(
            onTap: widget.onPressed,
            child: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: FittedBox(fit: BoxFit.fill, child: productPicture),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.fromLTRB(5, 5, 10, 0),
                    child: Text(
                      widget.product.name!,
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ProductRating(
                            initRating:
                                (widget
                                                .product
                                                .reviewOverviewModel
                                                ?.totalReviews ??
                                            0) >
                                        0
                                    ? ((widget
                                                .product
                                                .reviewOverviewModel
                                                ?.ratingSum ??
                                            0) /
                                        (widget
                                                .product
                                                .reviewOverviewModel
                                                ?.totalReviews ??
                                            1))
                                    : 0.0,
                          ),
                          Text(
                            ((widget
                                                .product
                                                .reviewOverviewModel
                                                ?.totalReviews ??
                                            0) >
                                        0
                                    ? ((widget
                                                .product
                                                .reviewOverviewModel
                                                ?.ratingSum ??
                                            0) /
                                        (widget
                                                .product
                                                .reviewOverviewModel
                                                ?.totalReviews ??
                                            0))
                                    : 0.0)
                                .toStringAsPrecision(2),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Flexible(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(5, 0, 15, 0),
                          child: ProductCardPrice(product: widget.product),
                        ),
                      ),
                      if (!(widget.product.productPrice?.disableBuyButton ??
                          false))
                        Flexible(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                            child: CustomIconButton(
                              filled: true,
                              icon: const Icon(Icons.shopping_cart),
                              onPressed: state.isLoading ? null : addToCart,
                            ),
                          ),
                        ),
                    ],
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


} */
class ProductCard2Price extends StatelessWidget {
  const ProductCard2Price({super.key, required this.product});

  /// Product
  final Product product;

  @override
  Widget build(BuildContext context) {
    CustomColors? myColors = Theme.of(context).extension<CustomColors>()!;

    final productPrice = product.price;
    //final isRental = productPrice.isRental ?? false;
    //final isGrouded = product.productType == ProductType.groupedProduct;

    String price = productPrice.toString();
    String priceBeforeText = '';
    String priceValue = '';
    String priceAfterText = '';



    return Column(
      children: [
        Wrap(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                productPrice.toString(),
                style: TextStyle(
                  color: myColors.subTextColor,
                  fontSize: 12,
                  decoration: TextDecoration.lineThrough,
                ),
                maxLines: 1,
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
        if (priceBeforeText.isNotEmpty)
          Wrap(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  priceBeforeText,
                  style: TextStyle(
                    color: myColors.subTextColor,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
        if (priceValue.isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              priceValue,
              style: Theme
                  .of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: priceValue.length > 7 ? 12 : 15,
              ),
              maxLines: 2,
              textAlign: TextAlign.left,
              overflow: TextOverflow.fade,
            ),
          ),
        if (priceAfterText.isNotEmpty)
          Wrap(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  priceAfterText,
                  style: TextStyle(
                    color: myColors.subTextColor,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
      ],
    );
      }
}