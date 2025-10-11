import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:awesome_bottom_bar/widgets/inspired/inspired.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nopcommerce_mobile/features/cart/application/cart_service.dart';
import 'package:nopcommerce_mobile/l10n/app_localizations_context.dart';

class ScaffoldWithBottomNavBar extends ConsumerStatefulWidget {
  const ScaffoldWithBottomNavBar({
    super.key,
    required this.child,
    required this.goRouterState,
  });
  final Widget child;
  final GoRouterState goRouterState;

  @override
  ConsumerState<ScaffoldWithBottomNavBar> createState() =>
      _ScaffoldWithBottomNavBarState();
}

class _ScaffoldWithBottomNavBarState
    extends ConsumerState<ScaffoldWithBottomNavBar> {
  static final tabs = ['/home', '/catalog', '/cart', '/account'];

  // getter that computes the current index from the current location,
  int get _currentIndex => _locationToTabIndex(widget.goRouterState.uri.path);

  int _locationToTabIndex(String location) {
    final index = tabs.indexWhere((t) => location.startsWith(t));
    // if index not found (-1), return 0
    return index < 0 ? 0 : index;
  }

  // callback used to navigate to the desired tab
  void _onItemTapped(BuildContext context, int tabIndex) {
    if (tabIndex != _currentIndex) {
      // go to the initial location of the selected tab (by index)
      context.go(tabs[tabIndex]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartItemsCount = ref.watch(cartItemsCountProvider);
    List<TabItem> items = [
      TabItem(
        icon: Icons.home,
        title: context.locale!.app_base_menu_home,
      ),
      TabItem(
        icon: Icons.category,
        title: context.locale!.app_base_menu_catalog,
      ),
      TabItem(
        icon: Icons.shopping_cart,/*Stack(
          children: [
            const Center(child: Icon(Icons.shopping_cart)),
            if (cartItemsCount > 0)
              Positioned(
                top: 4.0,
                right: 15.0,
                child: ShoppingCartIconBadge(itemsCount: cartItemsCount),
              ),
          ],
        ),*/
        count: Container(
          padding: EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: const EdgeInsets.all(2.9),
            child: Text(cartItemsCount.toString() ?? '0',
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Colors.white),
            ),
          ),
        ),
        title: context.locale!.app_base_menu_cart,
      ),
      /*TabItem(
        icon: Icons.receipt_long_rounded,
        title: 'Orders',
      ),*/
      TabItem(
        icon: Icons.account_circle,
        title: context.locale!.app_base_menu_account,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: widget.child,
      bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(bottom: 0),
         child:  BottomBarInspiredOutside(
        items: items,
        backgroundColor: const Color(0xFF2C2E7B),
        color: Colors.white,
        colorSelected: Colors.white,
        height: 42,
        iconSize: 22,
        elevation: 0,
        padTop: 8,
        padbottom: 8,
        titleStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
        indexSelected: _currentIndex,
        onTap: (index) => _onItemTapped(context, index),
        itemStyle: ItemStyle.circle,
        countStyle: CountStyle(background: Colors.red),
        chipStyle: ChipStyle( notchSmoothness: NotchSmoothness.verySmoothEdge, background: const Color(0xFF2C2E7B)),
      )),

    );
  }
}
