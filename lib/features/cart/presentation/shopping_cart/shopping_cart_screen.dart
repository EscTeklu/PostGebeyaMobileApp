import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_api/frontend_api.dart';
import 'package:go_router/go_router.dart';
import 'package:nopcommerce_mobile/common_widgets/async_value.dart';
import 'package:nopcommerce_mobile/common_widgets/placeholder_container.dart';
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

  static const _blue = Color(0xFF2C2E7B);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.refresh(shoppingCartFutureProvider.future).then(
      (value) => {
        if (value?.items?.isNotEmpty ?? false)
          {ref.refresh(shoppingCartTotalsProvider.future)},
      },
    );
    ref.listen<AsyncValue<ShoppingCart>>(
      shoppingCartControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FB),
      appBar: AppBar(
        backgroundColor: _blue,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.locale!.cart,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () {
              ref.refresh(shoppingCartFutureProvider.future).then(
                (value) => {
                  if (value?.items?.isNotEmpty ?? false)
                    {ref.refresh(shoppingCartTotalsProvider.future)},
                },
              );
            },
          ),
        ],
      ),
      body: AppSettings.enableShoppingCart
          ? Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                final cartValue = ref.watch(shoppingCartFutureProvider);
                return AsyncValueWidget<ShoppingCartModelDto?>(
                  value: cartValue,
                  data: (cart) => RefreshIndicator(
                    color: _blue,
                    onRefresh: () {
                      return ref
                          .refresh(shoppingCartFutureProvider.future)
                          .whenComplete(
                            () => ref.refresh(shoppingCartTotalsProvider.future),
                          );
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
    );
  }
}
