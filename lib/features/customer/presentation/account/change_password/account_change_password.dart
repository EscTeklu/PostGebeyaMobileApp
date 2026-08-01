import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nopcommerce_mobile/common_widgets/custom_text_form_field.dart';
import 'package:nopcommerce_mobile/common_widgets/responsive_scrollable.dart';
import 'package:nopcommerce_mobile/features/app/scaffold_messenger_extansion.dart';
import 'package:nopcommerce_mobile/features/customer/presentation/account/account_providers.dart';
import 'package:nopcommerce_mobile/features/customer/presentation/account/change_password/change_password_controller.dart';
import 'package:nopcommerce_mobile/features/shared/settings.dart';
import 'package:nopcommerce_mobile/l10n/app_localizations_context.dart';
import 'package:nopcommerce_mobile/utils/async_value_ui.dart';
import 'package:nopcommerce_mobile/utils/base_nop_state.dart';

const _blue = Color(0xFF2C2E7B);
const _orange = Color(0xFFF5AD00);
const _bg = Color(0xFFF4F5FB);

class AccountChangePassword extends StatelessWidget {
  const AccountChangePassword({super.key});

  @override
  Widget build(BuildContext context) {
    return const ChangePasswordContents();
  }
}

class ChangePasswordContents extends ConsumerStatefulWidget {
  const ChangePasswordContents({super.key, this.onSignedIn});
  final VoidCallback? onSignedIn;

  @override
  ConsumerState<ChangePasswordContents> createState() =>
      _ChangePasswordContentsState();
}

class _ChangePasswordContentsState
    extends ConsumerState<ChangePasswordContents> {
  final _formKey = GlobalKey<FormState>();
  final _node = FocusScopeNode();

  String oldPassword = '';
  String newPassword = '';
  String confirmPassword = '';

  var _submitted = false;

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  Future<void> _submit(BaseNopState state) async {
    setState(() => _submitted = true);
    ChangePasswordController controller;
    _formKey.currentState!.save();
    if (newPassword != confirmPassword) {
      showInSnackBar(context, context.locale!.global_passwords_mismatch);
      return;
    }

    if (_formKey.currentState!.validate()) {
      controller = ref.read(changePasswordControllerProvider.notifier);
      await controller
          .submit(oldPassword, newPassword, confirmPassword)
          .then(
            (value) => {
              if (value)
                {
                  oldPassword = newPassword = confirmPassword = '',
                  if (mounted)
                    showInSnackBar(
                      context,
                      context.locale!.account_change_password_changed,
                    ),
                }
              else
                setState(() => _submitted = false),
            },
          );
    } else {
      showInSnackBar(context, context.locale!.global_fix_error);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue>(
      changePasswordControllerProvider.select((state) => state.value),
      (_, state) => state.showAlertDialogOnError(context),
    );
    final state = ref.watch(changePasswordControllerProvider);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _blue,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.locale!.account_change_password,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ),
      body: ResponsiveScrollable(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FocusScope(
            node: _node,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header banner
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2C2E7B), Color(0xFF3F42A8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.lock_outline_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Change Password',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Keep your account secure',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Form card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: _blue.withValues(alpha: 0.07),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Section header
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 16,
                              decoration: BoxDecoration(
                                color: _orange,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              context.locale!.account_change_password
                                  .toUpperCase(),
                              style: const TextStyle(
                                color: _blue,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        CustomerTextFormField(
                          context.locale!.account_change_password_old,
                          value: oldPassword,
                          (value) => oldPassword = value ?? '',
                          enabled: !state.isLoading,
                          submitted: !_submitted,
                          obscureText: true,
                          required: true,
                          minLength: AppSettings.passwordMinLength,
                        ),
                        const SizedBox(height: 12),
                        CustomerTextFormField(
                          context.locale!.account_change_password_new,
                          value: newPassword,
                          (value) => newPassword = value ?? '',
                          enabled: !state.isLoading,
                          submitted: !_submitted,
                          obscureText: true,
                          required: true,
                          minLength: AppSettings.passwordMinLength,
                        ),
                        const SizedBox(height: 12),
                        CustomerTextFormField(
                          context.locale!.account_change_password_confirm,
                          value: confirmPassword,
                          (value) => confirmPassword = value ?? '',
                          enabled: !state.isLoading,
                          submitted: !_submitted,
                          obscureText: true,
                          required: true,
                          minLength: AppSettings.passwordMinLength,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _blue,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: state.isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.lock_reset_rounded, size: 20),
                            label: Text(
                              context.locale!.account_change_password_button,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            onPressed:
                                state.isLoading ? null : () => _submit(state),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
