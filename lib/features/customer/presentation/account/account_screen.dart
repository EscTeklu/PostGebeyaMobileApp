import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nopcommerce_mobile/common_widgets/alert_dialogs.dart';
import 'package:nopcommerce_mobile/features/authentication/domain/nop_customer.dart';
import 'package:nopcommerce_mobile/features/authentication/presentation/auth_providers.dart';
import 'package:nopcommerce_mobile/features/customer/presentation/account/account_info.dart';
import 'package:nopcommerce_mobile/features/customer/presentation/account/account_providers.dart';
import 'package:nopcommerce_mobile/l10n/app_localizations_context.dart';
import 'package:nopcommerce_mobile/router/route_utils.dart';
import 'package:nopcommerce_mobile/utils/base_nop_state.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  static const _blue = Color(0xFF2C2E7B);
  static const _orange = Color(0xFFF5AD00);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateChangesProvider).value;

    ref.listen<BaseNopState>(
      accountControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );
    final state = ref.watch(accountControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FB),
      appBar: AppBar(
        backgroundColor: _blue,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.locale!.account,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: 0.3,
          ),
        ),
      ),
      body: ListView(
        children: [
          AccountInfo(currentUser: user),
          const SizedBox(height: 16),
          _AuthButton(user: user, state: state, ref: ref),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _AuthButton extends ConsumerWidget {
  final NopCustomer? user;
  final BaseNopState state;
  final WidgetRef ref;

  const _AuthButton({
    required this.user,
    required this.state,
    required this.ref,
  });

  @override
  Widget build(BuildContext context, WidgetRef r) {
    final isGuest = user?.isGuest ?? true;

    if (isGuest) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C2E7B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                onPressed: () => context.pushNamed(Routes.login.name),
                child: Text(
                  context.locale!.auth_login,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2C2E7B),
                  side: const BorderSide(color: Color(0xFF2C2E7B), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => context.pushNamed(Routes.register.name),
                child: Text(
                  context.locale!.auth_register,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red.shade600,
            side: BorderSide(color: Colors.red.shade400, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          icon: const Icon(Icons.logout_rounded, size: 18),
          label: Text(
            context.locale!.auth_logout,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          onPressed: state.isLoading
              ? null
              : () async {
                  final logout = await showAlertDialog(
                    context: context,
                    title: context.locale!.auth_are_you_sure,
                    cancelActionText: context.locale!.app_cancel,
                    defaultActionText: context.locale!.auth_logout,
                  );
                  if (logout ?? false) {
                    ref.read(accountControllerProvider.notifier).logOut();
                  }
                },
        ),
      ),
    );
  }
}
