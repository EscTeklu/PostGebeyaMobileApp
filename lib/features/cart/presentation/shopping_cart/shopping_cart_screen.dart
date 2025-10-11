import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_api/frontend_api.dart';
import 'package:go_router/go_router.dart';
import 'package:nopcommerce_mobile/common_widgets/async_value.dart';
import 'package:nopcommerce_mobile/common_widgets/placeholder_container.dart';
import 'package:nopcommerce_mobile/constants/global_variables.dart';
import 'package:nopcommerce_mobile/features/cart/domain/shopping_cart.dart';
import 'package:nopcommerce_mobile/features/cart/presentation/cart_providers.dart';
import 'package:nopcommerce_mobile/features/cart/presentation/shopping_cart/shopping_cart_item.dart';
import 'package:nopcommerce_mobile/features/cart/presentation/shopping_cart/shopping_cart_item_builder.dart';
import 'package:nopcommerce_mobile/features/shared/settings.dart';
import 'package:nopcommerce_mobile/l10n/app_localizations_context.dart';
import 'package:nopcommerce_mobile/router/route_utils.dart';
import 'package:nopcommerce_mobile/utils/async_value_ui.dart';

class ShoppingCartScreen extends ConsumerWidget {
  const ShoppingCartScreen({super.key});

  final Color accentColor = const Color(0xFF2C2E7B);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.refresh(shoppingCartFutureProvider.future).then(
          (value) => {
        if (value?.items?.isNotEmpty ?? false)
          {
            ref.refresh(shoppingCartTotalsProvider.future),
          }
      },
    );
    ref.listen<AsyncValue<ShoppingCart>>(
      shoppingCartControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );

    return Scaffold(
      backgroundColor: GlobalVariables.backgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(1),
              child: Image.asset(
                'assets/bottom_logo.png',
                height: 40,
                width: 100,
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 60),
              child: Text(
                context.locale!.cart,
                style: TextStyle(color: Colors.white),
              ),
            ),

          ],
        ),
        backgroundColor: accentColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white,),
            onPressed: () {
              ref.refresh(shoppingCartFutureProvider.future).then(
                    (value) => {
                  if (value?.items?.isNotEmpty ?? false)
                    {
                      ref.refresh(shoppingCartTotalsProvider.future),
                    }
                },
              );
            },
          )
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/bg5.jpg', // Replace with your image path
              fit: BoxFit.cover,
            ),
          ),
          AppSettings.enableShoppingCart
              ? Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              final cartValue = ref.watch(shoppingCartFutureProvider);
              return AsyncValueWidget<ShoppingCartModelDto?>(
                value: cartValue,
                data: (cart) => RefreshIndicator(
                  onRefresh: () {
                    return ref
                        .refresh(shoppingCartFutureProvider.future)
                        .whenComplete(() =>
                        ref.refresh(shoppingCartTotalsProvider.future));
                  },
                  child: ShoppingCartBuilder(
                    cart: cart,
                    itemBuilder: (_, item, index) => ShoppingCartItem(
                      item: item,
                      itemIndex: index,
                      isEditable: cart?.isEditable ?? true,
                    ),
                  ),
                ),
              );
            },
          )
              : PlaceholderContainer(
            message: context.locale!.cart_disabled,
            buttonLable: context.locale!.app_continue_shopping,
            onPressButton: () => context.goNamed(Routes.catalog.name),
          ),
        ],
      )
    );
  }
}
