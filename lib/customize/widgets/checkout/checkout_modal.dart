import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nopcommerce_mobile/constants/app_constants.dart';
import 'package:nopcommerce_mobile/features/customer/presentation/account/web_info.dart';
import 'package:nopcommerce_mobile/router/route_utils.dart';
import 'package:nopcommerce_mobile/features/authentication/presentation/auth_providers.dart';

class CheckoutModal extends ConsumerStatefulWidget {
  const CheckoutModal({super.key});



  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CheckoutModalState();
}

class _CheckoutModalState extends ConsumerState<CheckoutModal> {
 // const CheckoutModal({super.key});

  Future<void> _submit(BuildContext context) async {
    final authRepository = ref.watch(authRepositoryProvider);

    String? authToken = authRepository.currentCustomer?.token;
    print(authToken);

    final result = await  showDialog(
      context: context,
      builder:
          (context) => WebInfo(urlWeb: "${AppConstants.storeUrl}onepagecheckout#opc-billing"),
    );
    if (result == true) {
      //ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment completed')));
      Navigator.of(context).pop();
      context.pushNamed(Routes.home.name);

    } else {
      //ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment not completed')));
      Navigator.of(context).pop();
      context.pushNamed(Routes.home.name);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'How would you like to proceed?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Login or Create an Account for faster checkout, order tracking, and more.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: () => _submit(context),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Continue as Guest'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.pushNamed(Routes.register.name);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Register'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.pushNamed(Routes.login.name);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Log in', style: TextStyle(fontSize: 14)),
                ),
              ],
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Material(
              color: Colors.grey.shade200,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => Navigator.of(context).pop(),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.close, size: 20, color: Colors.grey),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
