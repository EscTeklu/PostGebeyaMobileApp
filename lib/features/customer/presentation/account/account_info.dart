import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_api/frontend_api.dart';
import 'package:go_router/go_router.dart';
import 'package:nopcommerce_mobile/common_widgets/async_value.dart';
import 'package:nopcommerce_mobile/constants/app_constants.dart';
import 'package:nopcommerce_mobile/customize/profile/settings_panel.dart';
import 'package:nopcommerce_mobile/features/authentication/domain/nop_customer.dart';
import 'package:nopcommerce_mobile/features/customer/presentation/account/account_providers.dart';
import 'package:nopcommerce_mobile/features/customer/presentation/account/components/base_customer_info.dart';
import 'package:nopcommerce_mobile/features/customer/presentation/account/web_info.dart';
import 'package:nopcommerce_mobile/features/shared/settings.dart';
import 'package:nopcommerce_mobile/l10n/app_localizations_context.dart';
import 'package:nopcommerce_mobile/router/route_utils.dart';

class AccountInfo extends ConsumerWidget {
  final NopCustomer? currentUser;
  const AccountInfo({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerInfo = ref.watch(customerInfoProvider);
    final gdprTools = ref.watch(gdprToolsProvider);
    //BAHU ADDED
    final panelItems = [
      if (!(currentUser?.isGuest ?? true))
        {
          'icon': Icons.person_outline_outlined,
          'label': context.locale!.account_menu_customer_info,
          'press': () => {context.pushNamed(Routes.accountInfo.name)},
        },
      if (!(currentUser?.isGuest ?? true))
        {
          'icon': Icons.home_outlined,
          'label': context.locale!.account_menu_addresses,
          'press': () => {context.pushNamed(Routes.accountAddresses.name)},
        },
      if (!(currentUser?.isGuest ?? true))
        {
          'icon': Icons.list_alt_outlined,
          'label': context.locale!.account_menu_orders,
          'press': () => {context.pushNamed(Routes.accountOrders.name)},
        },
      if (!(currentUser?.isGuest ?? true))
        {
          'icon': Icons.undo_outlined,
          'label': context.locale!.account_menu_return_requests,
          'press': () => {context.pushNamed(Routes.accountReturnRequests.name)},
        },
      if (!(currentUser?.isGuest ?? true))
        if (AppSettings.rewardPointsEnabled)
          {
            'icon': Icons.control_point_duplicate_outlined,
            'label': context.locale!.account_menu_reward_points,
            'press': () => {context.pushNamed(Routes.accountRewardPoints.name)},
          },
      if (!(currentUser?.isGuest ?? true))
        {
          'icon': Icons.reviews_outlined,
          'label': context.locale!.account_menu_my_product_reviews,
          'press': () => {context.pushNamed(Routes.accountProductReviews.name)},
        },
      if (!(currentUser?.isGuest ?? true))
        {
          'icon': Icons.password_outlined,
          'label': context.locale!.account_menu_change_password,
          'press': () => {context.pushNamed(Routes.accountChangePassword.name)},
        },
      if (AppSettings.enableWishlist)
        {
          'icon': Icons.favorite,
          'label': context.locale!.account_wishlist,
          'press': () => {context.pushNamed(Routes.wishlist.name)},
        },
    ];

    final panelAccount = [
      {
        'icon': Icons.settings_outlined,
        'label': context.locale!.settings,
        'press': () => {context.pushNamed(Routes.settings.name)},
      },
      {
        'icon': Icons.contact_mail_outlined,
        'label': context.locale!.contact_us,
        'press': () => {context.pushNamed(Routes.contactUs.name)},
      },
      {
        'icon': Icons.info_outlined,
        'label': 'About Us',
        'press':
            () => {
              showDialog(
                context: context,
                builder:
                    (context) => WebInfo(
                      urlWeb: '${AppConstants.storeUrl}about-us',
                    ),
              ),
            },
      },
      {
        'icon': Icons.privacy_tip_outlined,
        'label': 'Privacy Policy',
        'press':
            () => {
              showDialog(
                context: context,
                builder:
                    (context) => WebInfo(
                      urlWeb:
                          '${AppConstants.storeUrl}privacy-notice',
                    ),
              ),
            },
      },
    ];
    //

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          if (!(currentUser?.isGuest ?? true)) ...[
            //const SizedBox(height: 20),
            //const ProfileHeader(),
            AsyncValueWidget<CustomerInfoModelDto?>(
              value: customerInfo,
              data:
                  (customer) => BaseCustomerInfo(
                    customerInfo: customer ?? CustomerInfoModelDto(),
                  ),
            ) /**/,
          ],
          SettingsPanel(title: ' ', items: panelItems),
          SettingsPanel(title: ' ', items: panelAccount),
        ],
      ),
    );
  }
}
