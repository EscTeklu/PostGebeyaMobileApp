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

  int get _currentIndex => _locationToTabIndex(widget.goRouterState.uri.path);

  int _locationToTabIndex(String location) {
    final index = tabs.indexWhere((t) => location.startsWith(t));
    return index < 0 ? 0 : index;
  }

  void _onItemTapped(BuildContext context, int tabIndex) {
    if (tabIndex != _currentIndex) {
      context.go(tabs[tabIndex]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartItemsCount = ref.watch(cartItemsCountProvider);

    final items = [
      TabItem(
        icon: Icons.home,
        title: context.locale!.app_base_menu_home,
      ),
      TabItem(
        icon: Icons.category,
        title: context.locale!.app_base_menu_catalog,
      ),
      TabItem(
        icon: Icons.shopping_cart,
        count: cartItemsCount > 0
            ? Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2.9),
                  child: Text(
                    cartItemsCount.toString(),
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ),
              )
            : null,
        title: context.locale!.app_base_menu_cart,
      ),
      TabItem(
        icon: Icons.account_circle,
        title: context.locale!.app_base_menu_account,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Extra bottom padding so every page's scroll view / SafeArea
          // automatically clears the floating navbar (bar ~61 px + 20 px gap).
          MediaQuery(
            data: MediaQuery.of(context).copyWith(
              padding: MediaQuery.of(context).padding.copyWith(
                bottom: MediaQuery.of(context).padding.bottom + 68,
              ),
            ),
            child: widget.child,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 32),
                BottomBarInspiredOutside(
                  items: items,
                  backgroundColor: const Color(0xFF2C2E7B),
                  color: Colors.white60,
                  colorSelected: Colors.white,
                  height: 36,
                  iconSize: 18,
                  elevation: 8,
                  padTop: 6,
                  padbottom: 2,
                  titleStyle: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  indexSelected: _currentIndex,
                  onTap: (index) => _onItemTapped(context, index),
                  itemStyle: ItemStyle.circle,
                  countStyle: CountStyle(background: Colors.red),
                  chipStyle: ChipStyle(
                    notchSmoothness: NotchSmoothness.verySmoothEdge,
                    background: const Color(0xFFF5AD00),
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
