import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:frontend_api/frontend_api.dart';
import 'package:nopcommerce_mobile/common_widgets/custom_outlined_button.dart';
import 'package:nopcommerce_mobile/customize/widgets/video_player.dart';
import 'package:nopcommerce_mobile/features/app/scaffold_messenger_extansion.dart';
import 'package:nopcommerce_mobile/features/authentication/presentation/auth_providers.dart';
import 'package:nopcommerce_mobile/features/cart/presentation/add_to_card/add_to_cart_controller.dart';
import 'package:nopcommerce_mobile/features/cart/presentation/cart_providers.dart';
import 'package:nopcommerce_mobile/features/customer/presentation/account/account_providers.dart';
import 'package:nopcommerce_mobile/features/products/presentation/product/delivery_info.dart';
import 'package:nopcommerce_mobile/features/products/presentation/product/gift_card_info.dart';
import 'package:nopcommerce_mobile/features/products/presentation/product/product_attribute/product_attribute_builder.dart';
import 'package:nopcommerce_mobile/features/products/presentation/product/product_bottom_bar.dart';
import 'package:nopcommerce_mobile/features/products/presentation/product/product_manufacturers.dart';
import 'package:nopcommerce_mobile/features/products/presentation/product/product_picture_galery.dart';
import 'package:nopcommerce_mobile/features/products/presentation/product/product_price.dart';
import 'package:nopcommerce_mobile/features/products/presentation/product/product_review_overview.dart';
import 'package:nopcommerce_mobile/features/products/presentation/product/product_specification_attributes.dart';
import 'package:nopcommerce_mobile/features/products/presentation/product/product_subscription.dart';
import 'package:nopcommerce_mobile/features/products/presentation/product/product_tags.dart';
import 'package:nopcommerce_mobile/features/products/presentation/product/product_tier_prices.dart';
import 'package:nopcommerce_mobile/features/products/presentation/product/rental_info.dart';
import 'package:nopcommerce_mobile/features/products/presentation/product/stock_availability.dart';
import 'package:nopcommerce_mobile/features/products/presentation/product_providers.dart';
import 'package:nopcommerce_mobile/features/products/presentation/products_line.dart';
import 'package:nopcommerce_mobile/l10n/app_localizations_context.dart';
import 'package:nopcommerce_mobile/utils/async_value_ui.dart';

class ProductDetailsSimple extends ConsumerStatefulWidget {
  const ProductDetailsSimple({super.key, required this.product});
  final ProductDetailsModelDto product;

  @override
  ConsumerState<ProductDetailsSimple> createState() =>
      _ProductDetailsSimpleState();
}

class _ProductDetailsSimpleState extends ConsumerState<ProductDetailsSimple> {
  static const _blue = Color(0xFF2C2E7B);
  static const _orange = Color(0xFFF5AD00);

  final _enterPriceController = TextEditingController();

  Map<String, String> productChangedAttributes = {};
  List<ProductDetailsAttributeModelDtoBuilder> productAttributes = [];
  Map<
    ProductDetailsAttributeModelDtoBuilder,
    List<ProductAttributeValueModelDtoBuilder>?
  >
  attributeValues = {};
  String? price = '';
  String? basePricePangv = '';
  String? stockAvailability = '';
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();

    final wishlistController = ref.read(wishlistControllerProvider.notifier);
    wishlistController.getWishlist().whenComplete(() {
      final int wishlistItem = wishlistController.getItemByProductId(
        widget.product.id!,
      );
      setState(() {
        isFavorite = wishlistItem > 0;
      });
    });

    if (widget.product.productAttributes != null) {
      for (var attr in widget.product.productAttributes!) {
        productAttributes.add(attr.toBuilder());

        if (attr.attributeControlType == AttributeControlType.checkboxes ||
            attr.attributeControlType ==
                AttributeControlType.readonlyCheckboxes) {
          if (attr.values != null) {
            List<ProductAttributeValueModelDtoBuilder> values = [];
            for (var value in attr.values!) {
              values.add(value.toBuilder());
            }
            attributeValues[attr.toBuilder()] = values;
          }
        }
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      attributeStateChanged();
    });
  }

  @override
  void dispose() {
    _enterPriceController.dispose();
    super.dispose();
  }

  void attributeStateChanged() async {
    _fetchProductAttributes();
  }

  void addToCart() async {
    _addToCart(ShoppingCartType.shoppingCart);
  }

  void addToWishlist() async {
    _addToCart(ShoppingCartType.wishlist);
  }

  Future<void> _addToCart(ShoppingCartType cartType) async {
    final controller = ref.read(addToCartControllerProvider.notifier);

    if (cartType == ShoppingCartType.wishlist) {
      final wishlistController = ref.read(wishlistControllerProvider.notifier);
      final int wishlistItem = wishlistController.getItemByProductId(
        widget.product.id!,
      );
      if (wishlistItem > 0) {
        wishlistController.removeItemById(wishlistItem).whenComplete(() {
          wishlistController.getWishlist().whenComplete(() {
            setState(() => isFavorite = false);
          });
        });
      } else {
        await controller
            .addCartItemFromProduct(
              widget.product.id!,
              widget.product.addToCart?.enteredQuantity,
              cartType,
            )
            .then((addProductToCartResponse) {
          if (mounted) {
            showInSnackBar(
              context,
              (addProductToCartResponse?.success ?? false)
                  ? context.locale!.product_add_to_wishlist
                  : addProductToCartResponse?.errors.toString() ?? '',
              color: (addProductToCartResponse?.success ?? false)
                  ? Colors.green
                  : Colors.red,
            );
          }
          if (addProductToCartResponse?.success ?? false) {
            wishlistController.getWishlist().whenComplete(() {
              setState(() => isFavorite = true);
            });
          }
          _fetchProductAttributes();
        });
      }
    }

    if (cartType == ShoppingCartType.shoppingCart) {
      await controller
          .addCartItemFromProduct(
            widget.product.id!,
            widget.product.addToCart?.enteredQuantity,
            cartType,
          )
          .then((addProductToCartResponse) {
        if (mounted) {
          showInSnackBar(
            context,
            (addProductToCartResponse?.success ?? false)
                ? context.locale!.product_add_to_card
                : addProductToCartResponse?.errors.toString() ?? '',
            color: (addProductToCartResponse?.success ?? false)
                ? Colors.green
                : Colors.red,
          );
        }
        _fetchProductAttributes();
      });
    }
  }

  Future<void> _fetchProductAttributes() async {
    for (var attribute in productAttributes) {
      List<String> valuesId = [];
      String attrValues = '';
      if (attribute.attributeControlType == AttributeControlType.checkboxes ||
          attribute.attributeControlType ==
              AttributeControlType.readonlyCheckboxes) {
        valuesId.clear();
        var key = attributeValues.keys
            .where((element) => element.id == attribute.id)
            .first;
        if (attributeValues.containsKey(key)) {
          for (var value in attributeValues[key]!) {
            if (value.isPreSelected ?? false) {
              valuesId.add('${value.id}');
            }
          }
          attrValues = valuesId.join(',');
        }
      } else {
        if (attribute.defaultValue != null) {
          attrValues = attribute.defaultValue ?? '';
        } else {
          attribute.values.build().forEach((v) {
            if (v.isPreSelected ?? false) {
              attrValues = v.id.toString();
            }
          });
        }
      }
      setState(() {
        productChangedAttributes['product_attribute_${attribute.id}'] =
            attrValues;
      });
    }

    if (productChangedAttributes.isNotEmpty) {
      final addToCartController = ref.read(
        addToCartControllerProvider.notifier,
      );
      addToCartController.updateAttr(productChangedAttributes);
    }

    var requestBody = productChangedAttributes.build();

    if (requestBody.isNotEmpty) {
      final controller = ref.read(productAttributesControllerProvider.notifier);
      final response = await controller.changeProductAttributes(
        widget.product.id!,
        true,
        false,
        requestBody,
      );
      setState(() {
        price = response?.price;
        basePricePangv = response?.basePricePangv;
        stockAvailability = response?.stockAvailability;
      });
    }
  }

  String extractYoutubeId(String embedUrl) {
    final uri = Uri.parse(embedUrl);
    final segments = uri.pathSegments;
    if (segments.length >= 2 && segments[0] == 'embed') {
      return segments[1].split('?').first;
    }
    throw const FormatException('Invalid YouTube embed URL');
  }

  String thumbnailUrl(String videoId) =>
      'https://img.youtube.com/vi/$videoId/hqdefault.jpg';

  String getThumbNail(String url) {
    if (url.isEmpty) {
      return '';
    }
    try {
      final videoId = extractYoutubeId(url);
      return thumbnailUrl(videoId);
    } catch (_) {
      return '';
    }
  }

  // ── Section card helper ──────────────────────────────────────────────────
  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _blue.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF4F5FB),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _orange,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
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

  Widget _infoRow({required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            color: _blue,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue>(
      productAttributesControllerProvider.select((state) => state.value),
      (_, state) => state.showAlertDialogOnError(context),
    );

    final relatedProductsListValue = ref.watch(
      relatedProductsListProvider(widget.product.id!),
    );
    final user = ref.watch(authStateChangesProvider);

    return Stack(
      children: [
        ListView(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 120,
          ),
          children: [
            // ── Image gallery ────────────────────────────────────────────
            if ((widget.product.pictureModels?.length ?? 0) > 0)
              ProductPictureGalery(
                pictureModels: widget.product.pictureModels!,
                showAddToWishlistButton:
                    !(widget.product.addToCart?.disableWishlistButton ?? false),
                isFavorite: isFavorite,
                addToWishlistEvent: addToWishlist,
              ),

            // ── Main info card ───────────────────────────────────────────
            Container(
              transform: Matrix4.translationValues(0.0, -24.0, 0.0),
              decoration: const BoxDecoration(
                color: Color(0xFFF4F5FB),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Product name + rating + SKU
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SelectableText(
                          widget.product.name ?? '',
                          style: const TextStyle(
                            color: _blue,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            if (widget.product.id != null &&
                                widget.product.productReviewOverview != null)
                              Flexible(
                                child: ProductReviewOverview(
                                  productId: widget.product.id!,
                                  productReviewOverview:
                                      widget.product.productReviewOverview!,
                                ),
                              ),
                            const Spacer(),
                            if ((widget.product.showSku ?? false) &&
                                (widget.product.sku?.isNotEmpty ?? false))
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: Colors.grey.shade200),
                                ),
                                child: Text(
                                  'SKU: ${widget.product.sku}',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Price + stock card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: _blue.withValues(alpha: 0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (widget.product.productPrice != null &&
                              !(widget.product.productPrice?.hidePrices ??
                                  false) &&
                              !(widget.product.addToCart?.customerEntersPrice ??
                                  false))
                            Expanded(
                              child: ProductPrice(
                                productPrice: widget.product.productPrice!,
                                updatedPrice: price,
                                updatedBasePricePangv: basePricePangv,
                              ),
                            )
                          else if (widget.product.addToCart
                                  ?.customerEntersPrice ??
                              false)
                            Expanded(
                              child: Text(
                                context.locale!.product_enter_price,
                                style: const TextStyle(
                                  color: _blue,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            )
                          else
                            const Expanded(child: SizedBox.shrink()),
                          if (widget.product.stockAvailability?.isNotEmpty ??
                              false)
                            StockAvailability(
                              stockAvailability:
                                  widget.product.stockAvailability!,
                              stockAvailabilityState: stockAvailability,
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Customer enters price input
                  if (widget.product.addToCart?.customerEntersPrice ?? false)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: Colors.grey.shade200),
                            ),
                            child: TextFormField(
                              key: UniqueKey(),
                              controller: _enterPriceController,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (_) => null,
                              autocorrect: false,
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: context.locale!.product_enter_price,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                              ),
                              onChanged: (_) => ref
                                  .read(addToCartControllerProvider.notifier)
                                  .updateEnteredPrice(
                                      _enterPriceController.text),
                            ),
                          ),
                          if (widget.product.addToCart
                                  ?.customerEnteredPriceRange
                                  ?.isNotEmpty ??
                              false)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                widget.product.addToCart!
                                    .customerEnteredPriceRange!,
                                style: TextStyle(
                                  color: Colors.red.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 14),

                  // Free shipping badge
                  if (widget.product.isFreeShipping ?? false)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                      child: DeliveryInfo(alignment: Alignment.centerLeft),
                    ),

                  // Short description
                  if (widget.product.shortDescription?.isNotEmpty ?? false)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                      child: Text(
                        widget.product.shortDescription!,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),
                    ),

                  // Back in stock subscription
                  if (widget.product.displayBackInStockSubscription ?? false)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: ProductSubscription(
                          productId: widget.product.id!),
                    ),

                  // Tier prices
                  if (widget.product.tierPrices?.isNotEmpty ?? false)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: _sectionCard(
                        title: 'BULK PRICING',
                        child: ProductTierPrices(
                            tierPrices: widget.product.tierPrices!),
                      ),
                    ),

                  // Manufacturers
                  if (widget.product.productManufacturers?.isNotEmpty ?? false)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: ProductManufacturers(
                        productManufacturers:
                            widget.product.productManufacturers!,
                      ),
                    ),

                  // Vendor
                  if (widget.product.vendorModel != null &&
                      (widget.product.vendorModel!.name?.isNotEmpty ?? false) &&
                      (widget.product.showVendor ?? false))
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: _infoRow(
                        label: context.locale!.product_vendor,
                        value: widget.product.vendorModel!.name!,
                      ),
                    ),

                  // Rental info
                  if (widget.product.isRental ?? false)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: RentalInfo(
                        product: widget.product,
                        attributeStateChanged: attributeStateChanged,
                        productChangedAttributes: productChangedAttributes,
                      ),
                    ),

                  // Product attributes
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      productAttributes.isEmpty ? 0 : 12,
                    ),
                    child: productAttributes.isEmpty
                        ? ProductAttributeBuilder().buildProductAttributes(
                            context,
                            attributeStateChanged,
                            productAttributes,
                            attributeValues,
                          )
                        : _sectionCard(
                            title: 'OPTIONS',
                            child: ProductAttributeBuilder()
                                .buildProductAttributes(
                              context,
                              attributeStateChanged,
                              productAttributes,
                              attributeValues,
                            ),
                          ),
                  ),

                  // Delivery date
                  if (widget.product.deliveryDate?.isNotEmpty ?? false)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _blue.withValues(alpha: 0.07),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.local_shipping_outlined,
                                    size: 14, color: _blue),
                                const SizedBox(width: 6),
                                Text(
                                  widget.product.deliveryDate ?? '',
                                  style: const TextStyle(
                                    color: _blue,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Sample download
                  if (widget.product.hasSampleDownload ?? false)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: Center(
                        child: CustomOutlinedButton(
                          text: context.locale!.product_sample_download,
                          icon: Icons.download_sharp,
                          onPressed: () =>
                              downladSample(ref, widget.product),
                        ),
                      ),
                    ),

                  // Part number
                  if ((widget.product.showManufacturerPartNumber ?? false) &&
                      (widget.product.manufacturerPartNumber?.isNotEmpty ??
                          false))
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                      child: _infoRow(
                        label:
                            context.locale!.product_manufacturer_part_number,
                        value: widget.product.manufacturerPartNumber ?? '',
                      ),
                    ),

                  // GTIN
                  if ((widget.product.showGtin ?? false) &&
                      (widget.product.gtin?.isNotEmpty ?? false))
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                      child: _infoRow(
                        label: context.locale!.product_gtin,
                        value: widget.product.gtin ?? '',
                      ),
                    ),

                  // Full description
                  if (widget.product.fullDescription?.isNotEmpty ?? false)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                      child: _sectionCard(
                        title: 'DESCRIPTION',
                        child: HtmlWidget(
                          widget.product.fullDescription ?? '',
                          textStyle: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ),

                  // Gift card
                  if (widget.product.giftCard?.isGiftCard ?? false)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: GiftCardInfo(product: widget.product),
                    ),

                  // Specification attributes
                  if (widget.product.productSpecificationModel?.groups?.first
                          .attributes?.isNotEmpty ??
                      false)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: _sectionCard(
                        title: 'SPECIFICATIONS',
                        child: ProductSpecificationAttributes(
                          groups: widget
                              .product.productSpecificationModel!.groups!,
                        ),
                      ),
                    ),

                  // Product tags
                  if (widget.product.productTags?.isNotEmpty ?? false)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: _sectionCard(
                        title: 'TAGS',
                        child: ProductTags(
                            productTags: widget.product.productTags!),
                      ),
                    ),

                  // Video
                  if (widget.product.videoModels?.isNotEmpty ?? false)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: _sectionCard(
                        title: 'PRODUCT VIDEO',
                        child: GestureDetector(
                          onTap: () {
                            showGeneralDialog(
                              context: context,
                              barrierDismissible: true,
                              barrierLabel:
                                  MaterialLocalizations.of(context)
                                      .modalBarrierDismissLabel,
                              barrierColor: Colors.black54,
                              transitionDuration:
                                  const Duration(milliseconds: 200),
                              pageBuilder: (_, __, ___) {
                                final w =
                                    MediaQuery.of(context).size.width * 0.9;
                                final h =
                                    MediaQuery.of(context).size.height * 0.4;
                                return Center(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: Container(
                                      width: w,
                                      height: h,
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius:
                                            BorderRadius.circular(16),
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                      child: WebViewYouTube(
                                        embedUrl: widget.product.videoModels!
                                            .first.videoUrl
                                            .toString(),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              transitionBuilder: (_, anim, __, child) =>
                                  ScaleTransition(
                                scale: CurvedAnimation(
                                    parent: anim,
                                    curve: Curves.easeOutBack),
                                child: child,
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.network(
                                  getThumbNail(widget.product.videoModels!
                                      .first.videoUrl!),
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.55),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 36,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Related products
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 0, 20),
                    child: ProductsLine(
                      valueObj: relatedProductsListValue,
                      title: context.locale!.product_related_products,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // ── Bottom bar overlay ───────────────────────────────────────────
        if (!(widget.product.addToCart?.disableBuyButton ?? false))
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              children: [
                Expanded(
                  child: ProductBottomBar(
                    product: widget.product,
                    addToCart: addToCart,
                    isGuest: user.value?.isGuest ?? true,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> downladSample(
      WidgetRef ref, ProductDetailsModelDto product) async {
    final contrloller = ref.read(downloadControllerProvider.notifier);
    await contrloller.downloadSample(product.id!).then((value) {
      if (value == null || !mounted) {
        return;
      }
      showInSnackBar(
        context,
        value
            ? context.locale!.account_downloadable_products_message_completed
            : context.locale!.account_downloadable_products_message_failed,
      );
    });
  }
}
