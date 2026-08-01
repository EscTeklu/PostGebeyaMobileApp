import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nopcommerce_mobile/common_widgets/async_value.dart';
import 'package:nopcommerce_mobile/features/cart/presentation/cart_providers.dart';
import 'package:nopcommerce_mobile/features/customer/presentation/account/account_providers.dart';
import 'package:nopcommerce_mobile/features/customer/presentation/account/wishlist/wishlist_builder.dart';
import 'package:nopcommerce_mobile/features/customer/presentation/account/wishlist/wishlist_item.dart';
import 'package:nopcommerce_mobile/frontend_api/lib/frontend_api.dart';
import 'package:nopcommerce_mobile/l10n/app_localizations_context.dart';
import 'package:nopcommerce_mobile/router/route_utils.dart';

const _blue = Color(0xFF2C2E7B);
const _orange = Color(0xFFF5AD00);
const _bg = Color(0xFFF4F5FB);

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlist = ref.watch(wishlistProvider);
    final state = ref.watch(wishlistControllerProvider);
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _blue,
        elevation: 0,
        title: Text(
          context.locale!.account_wishlist,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 16,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        scrolledUnderElevation: 0,
      ),
      body: AsyncValueWidget<WishlistModelDto?>(
        value: wishlist,
        data: (wishlist) => RefreshIndicator(
          onRefresh: () => ref.refresh(wishlistProvider.future),
          color: _orange,
          child: WishlistBuilder(
            wishlist: wishlist,
            itemBuilder: (_, item, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: WishlistItem(
                item: item,
                itemIndex: index,
                isEditable: wishlist?.isEditable ?? true,
              ),
            ),
            widgetBuilder: (_) => Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: state.isLoading ? Colors.grey.shade300 : _orange,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: state.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.shopping_cart_outlined, size: 20),
                  label: Text(
                    context.locale!.account_wishlist_add_all,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onPressed: state.isLoading
                      ? null
                      : () {
                          ref
                              .read(wishlistControllerProvider.notifier)
                              .addAllItemToCart()
                              .whenComplete(
                                () async => await ref
                                    .refresh(shoppingCartFutureProvider.future)
                                    .whenComplete(
                                      () => ref
                                          .refresh(
                                            shoppingCartTotalsProvider.future,
                                          )
                                          .whenComplete(() {
                                            if (context.mounted) {
                                              context.goNamed(Routes.cart.name);
                                            }
                                          }),
                                    ),
                              );
                        },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
