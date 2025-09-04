import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_api/frontend_api.dart';
import 'package:go_router/go_router.dart';
import 'package:nopcommerce_mobile/common_widgets/quantity_selector_widget.dart';
import 'package:nopcommerce_mobile/constants/global_variables.dart';
import 'package:nopcommerce_mobile/customize/widgets/checkout/checkout_modal.dart';
import 'package:nopcommerce_mobile/features/app/repository_provider.dart';
import 'package:nopcommerce_mobile/features/app/scaffold_messenger_extansion.dart';
import 'package:nopcommerce_mobile/features/authentication/domain/nop_customer.dart';
import 'package:nopcommerce_mobile/features/authentication/presentation/auth_providers.dart';
import 'package:nopcommerce_mobile/features/cart/presentation/add_to_card/add_to_cart_controller.dart';
import 'package:nopcommerce_mobile/features/customer/data/customer_repository.dart';
import 'package:nopcommerce_mobile/l10n/app_localizations_context.dart';
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
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addToCartControllerProvider);
    final customerRepository =
    ref.watch(getRepositoryProvider(() => CustomerRepository()));
    late NopCustomer? user = ref.watch(authStateChangesProvider).value;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (product.addToCart?.minimumQuantityNotification?.isNotEmpty ??
              false)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(product.addToCart?.minimumQuantityNotification ?? ""),
                ],
              ),
            ),
          /* Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if ((product.displayBackInStockSubscription ?? false) == false)
                  Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: QuantitySelector(
                      quantity: state.value?.quantity ??
                          product.addToCart!.enteredQuantity!,
                      addToCart: product.addToCart,
                      onChanged: state.isLoading
                          ? null
                          : (quantity) => ref
                              .read(addToCartControllerProvider.notifier)
                              .updateQuantity(quantity),
                    ),
                  ),
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: AddToCartWidget(
                      addToCart: addToCart,
                    ),
                  ),
                ),
              ],
            ),
          ), */
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if ((product.displayBackInStockSubscription ?? false) == false)
                  Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: QuantitySelector(
                      quantity:
                          state.value?.quantity ??
                          product.addToCart!.enteredQuantity!,
                      addToCart: product.addToCart,
                      onChanged:
                          state.isLoading
                              ? null
                              : (quantity) => ref
                                  .read(addToCartControllerProvider.notifier)
                                  .updateQuantity(quantity),
                    ),
                  ),
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: ElevatedButton(
                      onPressed: addToCart,
                      style: ElevatedButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        backgroundColor: GlobalVariables.accentColor,
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Add to Cart',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ), // You can set a base font size
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: ElevatedButton(
                      onPressed: () async {
                        //final user = ref.watch(authStateChangesProvider);
                        print(isGuest);
                          if(isGuest){
                            showInSnackBar(context,"Is GUEST");
                            final controller =
                            ref.read(addToCartControllerProvider.notifier);
                            await controller
                                .addCartItemFromProduct(
                              product.id!,
                              product.addToCart?.enteredQuantity,
                              ShoppingCartType.shoppingCart,
                            )
                                .then(
                                  (addProductToCartResponse) => {

                                //_fetchProductAttributes(),
                              },
                            );
                            showDialog(
                              context: context,
                              builder: (_) => const CheckoutModal(),
                            );
                          }
                        else{
                          showInSnackBar(context,"Not GUEST");
                          final controller =
                          ref.read(addToCartControllerProvider.notifier);
                          await controller
                              .addCartItemFromProduct(
                            product.id!,
                            product.addToCart?.enteredQuantity,
                            ShoppingCartType.shoppingCart,
                          )
                              .then(
                                (addProductToCartResponse) => {
                              showInSnackBar(
                                context,
                                (addProductToCartResponse?.success ?? false)
                                    ? 'Success'
                                    : addProductToCartResponse?.errors
                                    .toString() ??
                                    "",
                                color: (addProductToCartResponse?.success ??
                                    false)
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              (addProductToCartResponse?.success ?? true)
                                  ? context.pushNamed(Routes.checkout.name)
                                  : ''
                              //_fetchProductAttributes(),
                            },
                          );
                        }

                        /**/


                        /*final user = ref.watch(authStateChangesProvider).value;
                        final controller = ref.read(
                          addToCartControllerProvider.notifier,
                        );
                        (user?.isGuest ?? true)
                            ? showDialog(
                          context: context,
                          builder: (_) => const CheckoutModal(),
                        )
                            : await controller
                            .addCartItemFromProduct(
                              product.id!,
                              product.addToCart?.enteredQuantity,
                              ShoppingCartType.shoppingCart,
                            )
                            .then(
                              (addProductToCartResponse) => {
                                showInSnackBar(
                                  context,
                                  (addProductToCartResponse?.success ?? false)
                                      ? context.locale!.product_add_to_card
                                      : addProductToCartResponse?.errors
                                              .toString() ??
                                          "",
                                  color:
                                      (addProductToCartResponse?.success ??
                                              false)
                                          ? Colors.green
                                          : Colors.red,
                                ),
                                (addProductToCartResponse?.success ?? true)
                                    ? context.pushNamed(Routes.checkout.name)
                                    : '',
                                //_fetchProductAttributes(),
                              },
                            );*/
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GlobalVariables.secondaryColor,
                      ),
                      child: const Text(
                        'Buy Now',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_api/frontend_api.dart';
import 'package:nopcommerce_mobile/common_widgets/quantity_selector_widget.dart';
import 'package:nopcommerce_mobile/features/cart/presentation/add_to_card/add_to_cart_widget.dart';
import 'package:nopcommerce_mobile/features/cart/presentation/add_to_card/add_to_cart_controller.dart';

class ProductBottomBar extends ConsumerWidget {
  const ProductBottomBar({
    super.key,
    required this.product,
    required this.addToCart,
  });
  final ProductDetailsModelDto product;
  final Function() addToCart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addToCartControllerProvider);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color:
                Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (product.addToCart?.minimumQuantityNotification?.isNotEmpty ??
              false)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(product.addToCart?.minimumQuantityNotification ?? ""),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if ((product.displayBackInStockSubscription ?? false) == false)
                  Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: QuantitySelector(
                      quantity: state.value?.quantity ??
                          product.addToCart!.enteredQuantity!,
                      addToCart: product.addToCart,
                      onChanged: state.isLoading
                          ? null
                          : (quantity) => ref
                              .read(addToCartControllerProvider.notifier)
                              .updateQuantity(quantity),
                    ),
                  ),
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: AddToCartWidget(
                      addToCart: addToCart,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} */
