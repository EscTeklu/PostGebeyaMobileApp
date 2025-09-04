import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:awesome_bottom_bar/chip_style.dart';
import 'package:awesome_bottom_bar/tab_item.dart';
import 'package:awesome_bottom_bar/widgets/inspired/inspired.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nopcommerce_mobile/features/app/home/presentation/cart_icon_badge.dart';
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
          padding: EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: const EdgeInsets.all(2.5),
            child: Text(cartItemsCount.toString() ?? '0',
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Colors.white),
            ),
          ),
        ),
        title: context.locale!.app_base_menu_cart,
      ),
      TabItem(
        icon: Icons.account_circle,
        title: context.locale!.app_base_menu_account,
      ),
    ];
    Color bground = const Color(0xFF2C2E7B);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomBarInspiredOutside(
        items: items,
        backgroundColor: bground,
        color: Colors.white,
        colorSelected: Colors.white,
        height: 36,
        iconSize: 20,
        indexSelected: _currentIndex,
        onTap: (index) => _onItemTapped(context, index),
        itemStyle: ItemStyle.circle,
        countStyle: CountStyle(background: Colors.red),
        chipStyle: ChipStyle(notchSmoothness: NotchSmoothness.verySmoothEdge, background: const Color(0xFF2C2E7B)),
      ),
      /*BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Color(0xFF2c2e7b),
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: context.locale!.app_base_menu_home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.category),
            label: context.locale!.app_base_menu_catalog,
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Center(child: Icon(Icons.shopping_cart)),
                if (cartItemsCount > 0)
                  Positioned(
                    top: 4.0,
                    right: 15.0,
                    child: ShoppingCartIconBadge(itemsCount: cartItemsCount),
                  ),
              ],
            ),
            label: context.locale!.app_base_menu_cart,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: context.locale!.app_base_menu_account,
          ),
        ],
        onTap: (index) => _onItemTapped(context, index),
      ),*/
    );
  }
}
