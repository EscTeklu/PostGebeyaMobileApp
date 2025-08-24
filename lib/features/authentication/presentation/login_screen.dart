import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nopcommerce_mobile/common_widgets/custom_filled_button.dart';
import 'package:nopcommerce_mobile/common_widgets/custom_text_form_field.dart';
import 'package:nopcommerce_mobile/common_widgets/text_link.dart';
import 'package:nopcommerce_mobile/constants/global_variables.dart';
import 'package:nopcommerce_mobile/features/app/scaffold_messenger_extansion.dart';
import 'package:nopcommerce_mobile/features/authentication/presentation/auth_providers.dart';
import 'package:nopcommerce_mobile/features/customer/presentation/account/account_providers.dart';
import 'package:nopcommerce_mobile/features/shared/settings.dart';
import 'package:nopcommerce_mobile/l10n/app_localizations_context.dart';
import 'package:nopcommerce_mobile/router/route_utils.dart';
import 'package:nopcommerce_mobile/utils/async_value_ui.dart';
//import 'package:animate_do/animate_do.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoginContents();
  }
}

/// A widget for email & password authentication
class LoginContents extends ConsumerStatefulWidget {
  const LoginContents({super.key, this.onSignedIn});
  final VoidCallback? onSignedIn;

  @override
  ConsumerState<LoginContents> createState() => _LoginContentsState();
}

class _LoginContentsState extends ConsumerState<LoginContents> {
  static const Color accentColor = Color(0xFF2C2E7B);
  final _formKey = GlobalKey<FormState>();
  final _node = FocusScopeNode();

  String email = '';
  String password = '';

  var _submitted = false;

  @override
  void dispose() {
    //TextEditingControllers should be always disposed
    _node.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitted = true);
    // only submit the form if validation passes
    _formKey.currentState!.save();
    if (_formKey.currentState!.validate()) {
      final controller = ref.read(loginControllerProvider.notifier);
      await controller
          .submit(email, password)
          .then(
            (value) => {
              if (value)
                {ref.refresh(customerInfoProvider), widget.onSignedIn?.call()},
            },
          );
    } else {
      showInSnackBar(context, context.locale!.global_fix_error);
    }
  }

  void _emailEditingComplete() {
    _node.nextFocus();
  }

  void _passwordEditingComplete() {
    _submit();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue>(
      loginControllerProvider.select((state) => state.value),
      (_, state) => state.showAlertDialogOnError(context),
    );
    final state = ref.watch(loginControllerProvider);

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/bg5.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: GlobalVariables.backgroundColor,
        appBar: AppBar(
          backgroundColor: GlobalVariables.accentColor,
          title: Text(
            context.locale!.auth_login,
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SingleChildScrollView(
          child: FocusScope(
            node: _node,
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/background.png'),
                        fit: BoxFit.fill,
                      ),
                    ),
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                          left: 30,
                          width: 80,
                          height: 200,
                          child: /* FadeInUp(
                          duration: Duration(seconds: 1),
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/light-1.png'),
                              ),
                            ),
                          ),
                        ) */ Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/light-1.png'),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 140,
                          width: 80,
                          height: 150,
                          child: /* FadeInUp(
                          duration: Duration(milliseconds: 1200),
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/light-2.png'),
                              ),
                            ),
                          ),
                        ) */ Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/light-2.png'),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 40,
                          top: 40,
                          width: 80,
                          height: 150,
                          child: /* FadeInUp(
                          duration: Duration(milliseconds: 1300),
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/clock.png'),
                              ),
                            ),
                          ),
                        ) */ Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/clock.png'),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          child: /* FadeInUp(
                          duration: Duration(milliseconds: 1600),
                          child: Container(
                            margin: EdgeInsets.only(top: 50),
                            child: Center(
                              child: Text(
                                "Login",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ) */ Container(
                            margin: EdgeInsets.only(top: 50),
                            child: Center(
                              child: Text(
                                "Login",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(30.0),
                    child: Column(
                      children: <Widget>[
                        /* FadeInUp(
                        duration: Duration(milliseconds: 1400),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromRGBO(225, 95, 27, .3),
                                blurRadius: 20,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                ),
                                child: CustomerTextFormField(
                                  context.locale!.auth_email,
                                  value: email,
                                  (value) => email = value ?? '',
                                  onEditingComplete:
                                      () => _emailEditingComplete(),
                                  enabled: !state.isLoading,
                                  isEmail: true,
                                  submitted: _submitted,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                ),
                                child: CustomerTextFormField(
                                  context.locale!.auth_password,
                                  value: password,
                                  (value) => password = value ?? '',
                                  onEditingComplete:
                                      () => _passwordEditingComplete(),
                                  enabled: !state.isLoading,
                                  submitted: _submitted,
                                  obscureText: true,
                                  minLength: AppSettings.passwordMinLength,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ) */
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromRGBO(
                                    225, 95, 27, 0.00784313725490196),
                                blurRadius: 20,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                ),
                                child: CustomerTextFormField(
                                  context.locale!.auth_email,
                                  value: email,
                                  (value) => email = value ?? '',
                                  onEditingComplete:
                                      () => _emailEditingComplete(),
                                  enabled: !state.isLoading,
                                  isEmail: true,
                                  submitted: _submitted,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                ),
                                child: CustomerTextFormField(
                                  context.locale!.auth_password,
                                  value: password,
                                  (value) => password = value ?? '',
                                  onEditingComplete:
                                      () => _passwordEditingComplete(),
                                  enabled: !state.isLoading,
                                  submitted: _submitted,
                                  obscureText: true,
                                  minLength: AppSettings.passwordMinLength,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 30),
                        /* FadeInUp(
                        duration: Duration(milliseconds: 1900),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                              colors: [accentColor, accentColor],
                            ),
                          ),
                          child: Center(
                            child: CustomFilledButton(
                              text: context.locale!.auth_login,
                              isLoading: state.isLoading,
                              onPressed:
                                  state.isLoading ? null : () => _submit(),
                            ),
                          ),
                        ),
                      ) */
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                              colors: [accentColor, accentColor],
                            ),
                          ),
                          child: Center(
                            child: CustomFilledButton(
                              text: context.locale!.auth_login,
                              isLoading: state.isLoading,
                              onPressed:
                                  state.isLoading ? null : () => _submit(),
                            ),
                          ),
                        ),
                        SizedBox(height: 40),
                        /* FadeInUp(
                        duration: Duration(milliseconds: 2000),
                        child: TextLink(
                          label: context.locale!.auth_forgot_password,
                          onTap:
                              () => {
                                context.pushNamed(Routes.forgotPassword.name),
                              },
                          textStyle: Theme.of(
                            context,
                          ).textTheme.titleMedium!.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ) */
                        TextLink(
                          label: context.locale!.auth_forgot_password,
                          onTap:
                              () => {
                                context.pushNamed(Routes.forgotPassword.name),
                              },
                          textStyle: Theme.of(
                            context,
                          ).textTheme.titleMedium!.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
