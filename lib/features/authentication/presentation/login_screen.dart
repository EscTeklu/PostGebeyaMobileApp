import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nopcommerce_mobile/common_widgets/custom_text_form_field.dart';
import 'package:nopcommerce_mobile/features/app/scaffold_messenger_extansion.dart';
import 'package:nopcommerce_mobile/features/authentication/presentation/auth_providers.dart';
import 'package:nopcommerce_mobile/features/customer/presentation/account/account_providers.dart';
import 'package:nopcommerce_mobile/features/shared/settings.dart';
import 'package:nopcommerce_mobile/l10n/app_localizations_context.dart';
import 'package:nopcommerce_mobile/router/route_utils.dart';
import 'package:nopcommerce_mobile/utils/async_value_ui.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoginContents();
  }
}

class LoginContents extends ConsumerStatefulWidget {
  const LoginContents({super.key, this.onSignedIn});
  final VoidCallback? onSignedIn;

  @override
  ConsumerState<LoginContents> createState() => _LoginContentsState();
}

class _LoginContentsState extends ConsumerState<LoginContents> {
  static const _blue = Color(0xFF2C2E7B);
  static const _orange = Color(0xFFF5AD00);

  final _formKey = GlobalKey<FormState>();
  final _node = FocusScopeNode();

  String email = '';
  String password = '';
  var _submitted = false;

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitted = true);
    _formKey.currentState!.save();
    if (_formKey.currentState!.validate()) {
      final controller = ref.read(loginControllerProvider.notifier);
      await controller.submit(email, password).then((value) {
        if (value) {
          ref.invalidate(customerInfoProvider);
          widget.onSignedIn?.call();
        }
      });
    } else {
      showInSnackBar(context, context.locale!.global_fix_error);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue>(
      loginControllerProvider.select((state) => state.value),
      (_, state) => state.showAlertDialogOnError(context),
    );
    final state = ref.watch(loginControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FB),
      appBar: AppBar(
        backgroundColor: _blue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Gradient header ────────────────────────────────────────
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2C2E7B), Color(0xFF3F42A8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 36),
              child: Column(
                children: [
                  // Logo
                  Image.asset(
                    'assets/bottom_logo.png',
                    height: 52,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Welcome Back!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sign in to continue shopping',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Form card ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _blue.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: FocusScope(
                  node: _node,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Section label
                        const Text(
                          'SIGN IN',
                          style: TextStyle(
                            color: _blue,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Email field
                        CustomerTextFormField(
                          context.locale!.auth_email,
                          value: email,
                          (value) => email = value ?? '',
                          onEditingComplete: () => _node.nextFocus(),
                          enabled: !state.isLoading,
                          isEmail: true,
                          submitted: _submitted,
                        ),
                        const SizedBox(height: 12),

                        // Password field
                        CustomerTextFormField(
                          context.locale!.auth_password,
                          value: password,
                          (value) => password = value ?? '',
                          onEditingComplete: () => _submit(),
                          enabled: !state.isLoading,
                          submitted: _submitted,
                          obscureText: true,
                          minLength: AppSettings.passwordMinLength,
                        ),
                        const SizedBox(height: 8),

                        // Forgot password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () =>
                                context.pushNamed(Routes.forgotPassword.name),
                            style: TextButton.styleFrom(
                              foregroundColor: _blue,
                              padding: EdgeInsets.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              context.locale!.auth_forgot_password,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Sign in button
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _orange,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed:
                                state.isLoading ? null : () => _submit(),
                            child: state.isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    context.locale!.auth_login,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Register link ──────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account? ",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.pushNamed(Routes.register.name),
                  child: const Text(
                    'Register',
                    style: TextStyle(
                      color: _blue,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
