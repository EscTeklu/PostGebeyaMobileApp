import 'package:built_collection/built_collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_api/frontend_api.dart';
import 'package:go_router/go_router.dart';
import 'package:nopcommerce_mobile/common_widgets/placeholder_container.dart';
import 'package:nopcommerce_mobile/customize/widgets/checkout/checkout_modal.dart';
import 'package:nopcommerce_mobile/features/authentication/presentation/auth_providers.dart';
import 'package:nopcommerce_mobile/features/cart/domain/shopping_cart.dart';
import 'package:nopcommerce_mobile/features/cart/presentation/cart_providers.dart';
import 'package:nopcommerce_mobile/features/cart/presentation/cart_total/shopping_cart_totals.dart';
import 'package:nopcommerce_mobile/features/cart/presentation/shopping_cart/checkout_attribute/checkout_attribute_builder.dart';
import 'package:nopcommerce_mobile/features/cart/presentation/shopping_cart/discount_box_widget.dart';
import 'package:nopcommerce_mobile/features/cart/presentation/shopping_cart/terms_of_service_box.dart';
import 'package:nopcommerce_mobile/l10n/app_localizations_context.dart';
import 'package:nopcommerce_mobile/router/route_utils.dart';
import 'package:nopcommerce_mobile/utils/async_value_ui.dart';

class ShoppingCartBuilder extends ConsumerStatefulWidget {
  const ShoppingCartBuilder({super.key, required this.itemBuilder, this.cart});

  final ShoppingCartModelDto? cart;
  final Widget Function(BuildContext, ShoppingCartItemModelDto, int) itemBuilder;

  @override
  ConsumerState<ShoppingCartBuilder> createState() =>
      _ShoppingCartBuilderState();
}

class _ShoppingCartBuilderState extends ConsumerState<ShoppingCartBuilder> {
  static const _blue = Color(0xFF2C2E7B);
  static const _orange = Color(0xFFF5AD00);

  Map<String, String> checkoutChangedAttributes = {};
  List<CheckoutAttributeModelDtoBuilder> checkoutAttributes = [];
  Map<CheckoutAttributeModelDtoBuilder,
      List<CheckoutAttributeValueModelDtoBuilder>?> attributeValues = {};

  late bool isStartCheckout;

  @override
  void didChangeDependencies() {
    prepareCheckoutAttributes();
    attributeStateChanged();
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    isStartCheckout = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref.refresh(shoppingCartFutureProvider.future).then((value) {
        if (!mounted) {
          return;
        }
        if (value?.items?.isNotEmpty ?? false) {
          ref.invalidate(shoppingCartTotalsProvider);
        }
      });
    });
  }

  void prepareCheckoutAttributes() {
    if (widget.cart?.checkoutAttributes != null) {
      for (var attr in widget.cart!.checkoutAttributes!) {
        checkoutAttributes.add(attr.toBuilder());
        if (attr.attributeControlType == AttributeControlType.checkboxes ||
            attr.attributeControlType ==
                AttributeControlType.readonlyCheckboxes) {
          if (attr.values != null) {
            List<CheckoutAttributeValueModelDtoBuilder> values = [];
            for (var value in attr.values!) {
              values.add(value.toBuilder());
            }
            attributeValues[attr.toBuilder()] = values;
          }
        }
      }
    }
  }

  void attributeStateChanged() => _fetchCheckoutAttributes();

  Future<void> _fetchCheckoutAttributes() async {
    for (var attribute in checkoutAttributes) {
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
        checkoutChangedAttributes['checkout_attribute_${attribute.id}'] =
            attrValues;
      });
    }

    var requestBody = checkoutChangedAttributes.build();
    ref
        .read(shoppingCartControllerProvider.notifier)
        .updateCheckoutAttributes(checkoutChangedAttributes);

    if (requestBody.isNotEmpty) {
      ref.invalidate(shoppingCartTotalsProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<ShoppingCart>>(
      shoppingCartControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );

    final user = ref.watch(authStateChangesProvider).value;

    if (widget.cart?.items?.isEmpty ?? true) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _blue.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: 38,
                color: _blue,
              ),
            ),
            const SizedBox(height: 16),
            PlaceholderContainer(
              message: context.locale!.cart_empty,
              buttonLable: context.locale!.cart_refresh,
              onPressButton: () => ref
                  .refresh(shoppingCartFutureProvider.future)
                  .then(
                    (value) => {
                      if (value?.items?.isNotEmpty ?? false)
                        {ref.refresh(shoppingCartTotalsProvider.future)},
                    },
                  ),
            ),
          ],
        ),
      );
    }

    final ShoppingCartModelDto? cart = widget.cart;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      itemCount: cart!.items!.length + 1,
      itemBuilder: (context, index) {
        if (index != cart.items!.length) {
          return widget.itemBuilder(context, cart.items![index], index);
        }

        // Bottom section
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Checkout attributes
            if (checkoutAttributes.isNotEmpty)
              Container(
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
                  padding: const EdgeInsets.all(16),
                  child: CheckoutAttributeBuilder().buildAttributes(
                    context,
                    attributeStateChanged,
                    checkoutAttributes,
                    attributeValues,
                    false,
                  ),
                ),
              ),

            // Discount code
            if (cart.discountBox?.display ?? false)
              DiscountBox(discountBox: cart.discountBox),

            // Order summary
            ShoppingCartTotals(giftCardBoxDisplay: cart.giftCardBox?.display),

            // Terms of service
            if (cart.termsOfServiceOnShoppingCartPage ?? false) ...[
              const SizedBox(height: 4),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: _blue.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Transform.scale(
                        scale: 0.9,
                        alignment: Alignment.centerLeft,
                        child: Switch(
                          activeColor: _orange,
                          activeTrackColor: _orange.withValues(alpha: 0.3),
                          inactiveThumbColor: Colors.grey.shade400,
                          inactiveTrackColor: Colors.grey.shade200,
                          value: isStartCheckout,
                          onChanged: (val) =>
                              setState(() => isStartCheckout = val),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: RichText(
                          text: TextSpan(
                            text: context.locale!.cart_term_of_service,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13,
                            ),
                            children: [
                              TextSpan(
                                text:
                                    context.locale!.cart_term_of_service_link,
                                style: const TextStyle(
                                  color: _blue,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => showDialog(
                                        context: context,
                                        builder: (_) =>
                                            const TermOfServiceBox(),
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
            ],

            const SizedBox(height: 16),

            // Checkout button
            SizedBox(
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: (cart.termsOfServiceOnShoppingCartPage ??
                              false) &&
                          !isStartCheckout
                      ? Colors.grey.shade300
                      : _orange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: (cart.termsOfServiceOnShoppingCartPage ?? false) &&
                        !isStartCheckout
                    ? null
                    : () => (user?.isGuest ?? true)
                        ? showDialog(
                            context: context,
                            builder: (_) => const CheckoutModal(),
                          )
                        : context.pushNamed(Routes.checkout.name),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_rounded, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      context.locale!.checkout,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 80),
          ],
        );
      },
    );
  }
}
