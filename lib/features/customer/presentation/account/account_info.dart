import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_api/frontend_api.dart';
import 'package:go_router/go_router.dart';
import 'package:nopcommerce_mobile/common_widgets/async_value.dart';
import 'package:nopcommerce_mobile/constants/app_constants.dart';
import 'package:nopcommerce_mobile/features/authentication/domain/nop_customer.dart';
import 'package:nopcommerce_mobile/features/customer/presentation/account/account_providers.dart';
import 'package:nopcommerce_mobile/features/customer/presentation/account/post_info.dart';
import 'package:nopcommerce_mobile/features/shared/settings.dart';
import 'package:nopcommerce_mobile/l10n/app_localizations_context.dart';
import 'package:nopcommerce_mobile/router/route_utils.dart';

class AccountInfo extends ConsumerWidget {
  final NopCustomer? currentUser;
  const AccountInfo({super.key, required this.currentUser});

  static const _blue = Color(0xFF2C2E7B);
  static const _orange = Color(0xFFF5AD00);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerInfo = ref.watch(customerInfoProvider);
    final isGuest = currentUser?.isGuest ?? true;

    final accountItems = [
      if (!isGuest) ...[
        _MenuItem(Icons.person_outline_rounded, context.locale!.account_menu_customer_info,
            () => context.pushNamed(Routes.accountInfo.name)),
        _MenuItem(Icons.location_on_outlined, context.locale!.account_menu_addresses,
            () => context.pushNamed(Routes.accountAddresses.name)),
        _MenuItem(Icons.receipt_long_outlined, context.locale!.account_menu_orders,
            () => context.pushNamed(Routes.accountOrders.name)),
        _MenuItem(Icons.assignment_return_outlined, context.locale!.account_menu_return_requests,
            () => context.pushNamed(Routes.accountReturnRequests.name)),
        if (AppSettings.rewardPointsEnabled)
          _MenuItem(Icons.stars_rounded, context.locale!.account_menu_reward_points,
              () => context.pushNamed(Routes.accountRewardPoints.name)),
        _MenuItem(Icons.rate_review_outlined, context.locale!.account_menu_my_product_reviews,
            () => context.pushNamed(Routes.accountProductReviews.name)),
        _MenuItem(Icons.lock_outline_rounded, context.locale!.account_menu_change_password,
            () => context.pushNamed(Routes.accountChangePassword.name)),
      ],
      if (AppSettings.enableWishlist)
        _MenuItem(Icons.favorite_border_rounded, context.locale!.account_wishlist,
            () => context.pushNamed(Routes.wishlist.name)),
    ];

    final generalItems = [
      _MenuItem(Icons.settings_outlined, context.locale!.settings,
          () => context.pushNamed(Routes.settings.name)),
      _MenuItem(Icons.headset_mic_outlined, context.locale!.contact_us,
          () => context.pushNamed(Routes.contactUs.name)),
      _MenuItem(Icons.info_outline_rounded, 'About Us', () {
        showDialog(
          context: context,
          builder: (_) => PostInfo(urlWeb: '${AppConstants.storeUrl}about-us'),
        );
      }),
      _MenuItem(Icons.privacy_tip_outlined, 'Privacy Policy', () {
        showDialog(
          context: context,
          builder: (_) => PostInfo(urlWeb: '${AppConstants.storeUrl}privacy-notice'),
        );
      }),
      _MenuItem(Icons.gavel_rounded, 'Disclaimers', () {
        showDialog(
          context: context,
          builder: (_) => PostInfo(urlWeb: '${AppConstants.storeUrl}disclaimers'),
        );
      }),
      _MenuItem(Icons.help_outline_rounded, 'FAQ', () {
        showDialog(
          context: context,
          builder: (_) => PostInfo(urlWeb: '${AppConstants.storeUrl}faq'),
        );
      }),
      _MenuItem(Icons.assignment_outlined, 'Refund Policy', () {
        showDialog(
          context: context,
          builder: (_) => PostInfo(urlWeb: '${AppConstants.storeUrl}shipping-returns'),
        );
      }),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Profile header ──────────────────────────────────────────────
        AsyncValueWidget<CustomerInfoModelDto?>(
          value: customerInfo,
          data: (customer) => _ProfileHeader(
            isGuest: isGuest,
            customer: customer,
          ),
        ),

        const SizedBox(height: 24),

        // ── My Account section ──────────────────────────────────────────
        if (accountItems.isNotEmpty) ...[
          _SectionLabel('My Account'),
          const SizedBox(height: 8),
          _MenuCard(items: accountItems, iconColor: _blue),
          const SizedBox(height: 20),
        ],

        // ── General section ─────────────────────────────────────────────
        _SectionLabel('General'),
        const SizedBox(height: 8),
        _MenuCard(items: generalItems, iconColor: _orange),
      ],
    );
  }
}

// ── Data class ────────────────────────────────────────────────────────────────

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuItem(this.icon, this.label, this.onTap);
}

// ── Profile header ────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final bool isGuest;
  final CustomerInfoModelDto? customer;

  const _ProfileHeader({required this.isGuest, required this.customer});

  String get _displayName {
    if (isGuest) {
      return 'Guest User';
    }
    final first = customer?.firstName ?? '';
    final last = customer?.lastName ?? '';
    final full = '$first $last'.trim();
    return full.isNotEmpty ? full : (customer?.username ?? 'User');
  }

  String get _initials {
    final name = _displayName;
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2C2E7B), Color(0xFF3F42A8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
      child: Column(
        children: [
          // Avatar circle
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.15),
              border: Border.all(color: const Color(0xFFF5AD00), width: 2.5),
            ),
            child: Center(
              child: Text(
                _initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Name
          Text(
            _displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          // Email
          if (!isGuest && (customer?.email?.isNotEmpty ?? false))
            Text(
              customer!.email!,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            )
          else
            Text(
              'Sign in to access your account',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 13,
              ),
            ),
        ],
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: const Color(0xFFF5AD00),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF2C2E7B),
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Menu card ─────────────────────────────────────────────────────────────────

class _MenuCard extends StatelessWidget {
  final List<_MenuItem> items;
  final Color iconColor;

  const _MenuCard({required this.items, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2C2E7B).withValues(alpha: 0.07),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: List.generate(items.length, (i) {
            final item = items[i];
            final isLast = i == items.length - 1;
            return Column(
              children: [
                InkWell(
                  onTap: item.onTap,
                  borderRadius: BorderRadius.vertical(
                    top: i == 0 ? const Radius.circular(16) : Radius.zero,
                    bottom: isLast ? const Radius.circular(16) : Radius.zero,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 13),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: iconColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Icon(item.icon,
                              color: iconColor, size: 19),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            item.label,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 13,
                          color: Color(0xFFBBBBCC),
                        ),
                      ],
                    ),
                  ),
                ),
                if (!isLast)
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: 68,
                    color: Colors.grey.shade100,
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
