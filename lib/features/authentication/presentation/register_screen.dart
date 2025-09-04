import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nopcommerce_mobile/common_widgets/async_value.dart';
import 'package:nopcommerce_mobile/common_widgets/custom_filled_button.dart';
import 'package:nopcommerce_mobile/common_widgets/custom_switch.dart';
import 'package:nopcommerce_mobile/common_widgets/custom_text_form_field.dart';
import 'package:nopcommerce_mobile/common_widgets/responsive_scrollable.dart';
import 'package:nopcommerce_mobile/constants/global_variables.dart';
import 'package:nopcommerce_mobile/features/app/scaffold_messenger_extansion.dart';
import 'package:nopcommerce_mobile/features/authentication/presentation/auth_providers.dart';
import 'package:nopcommerce_mobile/features/address/presentation/country_providers.dart';
import 'package:nopcommerce_mobile/features/cart/presentation/cart_providers.dart';
import 'package:nopcommerce_mobile/features/customer/presentation/account/account_providers.dart';
import 'package:nopcommerce_mobile/features/customer/presentation/account/customer_info/gender_widget.dart';
import 'package:nopcommerce_mobile/features/shared/settings.dart';
import 'package:nopcommerce_mobile/frontend_api/lib/frontend_api.dart';
import 'package:nopcommerce_mobile/l10n/app_localizations_context.dart';
import 'package:nopcommerce_mobile/router/route_utils.dart';
import 'package:nopcommerce_mobile/utils/async_value_ui.dart';
import 'package:nopcommerce_mobile/utils/date_format_provider.dart';

class RegisterScreen extends ConsumerWidget {
  const RegisterScreen({super.key});

  static var genderKey = const Key('Gender');
  static const passwordKey = Key('password');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registerInfo = ref.watch(registerInfoProvider);

    return AsyncValueWidget<RegisterModelDto?>(
      value: registerInfo,
      data:
          (register) => RegisterInfoContents(
            registerInfo: register?.toBuilder() ?? RegisterModelDtoBuilder(),
          ),
    );
  }
}

class RegisterInfoContents extends ConsumerStatefulWidget {
  const RegisterInfoContents({
    super.key,
    this.onSave,
    required this.registerInfo,
  });

  final VoidCallback? onSave;
  final RegisterModelDtoBuilder registerInfo;

  @override
  ConsumerState<RegisterInfoContents> createState() => _RegisterInfoState();
}

class _RegisterInfoState extends ConsumerState<RegisterInfoContents> {
  final _genderController = TextEditingController();
  final _dateInput = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _node = FocusScopeNode();

  var _submitted = false;
  List<StateProvinceModelDtoBuilder>? availableStates;

  DateTime selectedDate = DateTime.now();

  RegisterModelDtoBuilder registerInfo = RegisterModelDtoBuilder();

  @override
  void dispose() {
    _node.dispose();
    _genderController.dispose();
    _dateInput.dispose();

    super.dispose();
  }

  void _selectDate(BuildContext context) async {
    final dateProvider = ref.watch(dateFormatterProvider);
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1950),
      lastDate: DateTime(2025),
      helpText: context.locale!.auth_date_of_birth,
      fieldLabelText: context.locale!.auth_date_of_birth,
      errorFormatText: context.locale!.app_is_not_valid_date,
      errorInvalidText: context.locale!.app_is_not_valid_date_range,
      confirmText: context.locale!.app_ok,
      cancelText: context.locale!.app_cancel,
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        _dateInput.text = dateProvider.format(pickedDate);

        registerInfo.dateOfBirthDay = pickedDate.day;
        registerInfo.dateOfBirthMonth = pickedDate.month;
        registerInfo.dateOfBirthYear = pickedDate.year;
      });
    }
  }
// Initialize Dio
  //final dio = Dio();
  Future<void> _submit() async {
    // Define the API endpoint
    /*const String url = 'https://ethiopostmall.africom.et/api-frontend/Customer/Register';
    var authToken= 'eCJCgwPuhc3pwdW1uqet+jnpJ9pFdZrkwlUFzZkeb3A';
    // Define headers
    final headers = {
      'Content-Type': 'application/json',
      'User-Agent': 'nopcommerce.flutter/v1',
      'Authorization': 'Bearer $authToken',
    };

    // Define the request payload
    final minimalData = {
      "model": {
        "email": "bahar@example.com",
        "username": "baharengineer",
        "password": "SecurePass123",
        "confirm_password": "SecurePass123",
        "first_name": "Bahar",
        "last_name": "Engineer"
      }
    };

    try {
      // Make the POST request
      final response = await dio.post(
        url,
        options: Options(headers: headers),
        data: minimalData,
      );

      // Handle the response
      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');
    } catch (e) {
      // Handle errors
      print('Error: $e');
    }*/

    setState(() => _submitted = true);
    // only submit the form if validation passes
    _formKey.currentState!.save();
    widget.registerInfo.gender = _genderController.text;

    if (widget.registerInfo.password != widget.registerInfo.confirmPassword) {
      showInSnackBar(context, context.locale!.global_passwords_mismatch);
      return;
    }

    if (_formKey.currentState!.validate()) {
      final controller = ref.read(loginControllerProvider.notifier);

      await controller
          .register(widget.registerInfo)
          .then(
            (value) => {
              if (value)
                {
                  ref.refresh(customerInfoProvider.future),
                  ref
                      .refresh(shoppingCartFutureProvider.future)
                      .whenComplete(
                        () => ref.refresh(shoppingCartTotalsProvider.future),
                      ),
                  if (mounted) context.goNamed(Routes.home.name),
                }
              else
                {
                  setState(() => _submitted = false),
                  if (mounted)
                    showInSnackBar(context, context.locale!.global_fix_error),
                },
            },
          );
    } else {
      showInSnackBar(context, context.locale!.global_fix_error);
    }
  }

  @override
  void initState() {
    registerInfo = widget.registerInfo;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue>(
      countryStatesControllerProvider.select((state) => state.value),
      (_, state) => state.showAlertDialogOnError(context),
    );

    ref.listen<AsyncValue>(
      loginControllerProvider.select((state) => state.value),
      (_, state) => state.showAlertDialogOnError(context),
    );
    final state = ref.watch(loginControllerProvider);
    final passwordMinLength = AppSettings.passwordMinLength;

    _genderController.text = widget.registerInfo.gender ?? '';

    const cardPadding = 15.0;
    final items = <Widget>[];

    items.add(
      Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(cardPadding),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    context.locale!.auth_personal_details,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (registerInfo.genderEnabled ?? false)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: GenderWidget(
                      key: RegisterScreen.genderKey,
                      controller: _genderController,
                    ),
                  ),
                if (registerInfo.firstNameEnabled ?? false)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: CustomerTextFormField(
                      context.locale!.auth_first_name,
                      (value) => registerInfo.firstName = value,
                      value: registerInfo.firstName,
                      submitted: !_submitted,
                      required: registerInfo.firstNameRequired ?? false,
                      minLength: 3,
                    ),
                  ),
                if (registerInfo.lastNameEnabled ?? false)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: CustomerTextFormField(
                      context.locale!.auth_last_name,
                      (value) => registerInfo.lastName = value,
                      value: registerInfo.lastName,
                      submitted: !_submitted,
                      required: registerInfo.lastNameRequired ?? false,
                      minLength: 3,
                    ),
                  ),
                if (registerInfo.usernamesEnabled ?? false)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: CustomerTextFormField(
                      context.locale!.auth_username,
                      (value) => registerInfo.username = value,
                      value: registerInfo.username,
                      submitted: !_submitted,
                      required: true,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: CustomerTextFormField(
                    context.locale!.auth_email,
                    (value) => registerInfo.email = value,
                    isEmail: true,
                    value: registerInfo.email,
                    submitted: !_submitted,
                    required: true,
                  ),
                ),
                /* if (registerInfo.dateOfBirthEnabled ?? false)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: CustomerTextFormField(
                      context.locale!.auth_date_of_birth,
                      (value) => {},
                      value: _dateInput.text,
                      controller: _dateInput,
                      submitted: !_submitted,
                      required: registerInfo.dateOfBirthRequired ?? false,
                      minLength: 3,
                      isDate: true,
                      onTap: () => _selectDate(context),
                    ),
                  ), */
                Container(
                  padding: const EdgeInsets.only(top: 10),
                  alignment: Alignment.centerLeft,
                  child: Text(context.locale!.global_required),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (registerInfo.companyEnabled ?? false) {
      items.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(cardPadding),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      context.locale!.auth_company_details,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  if (registerInfo.companyEnabled ?? false)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: CustomerTextFormField(
                        context.locale!.auth_company,
                        (value) => registerInfo.company = value,
                        value: registerInfo.company,
                        submitted: !_submitted,
                        required: registerInfo.companyRequired ?? false,
                      ),
                    ),
                  if (registerInfo.displayVatNumber ?? false)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: CustomerTextFormField(
                        context.locale!.auth_vat,
                        (value) => registerInfo.vatNumber = value,
                        value: registerInfo.vatNumber,
                        submitted: !_submitted,
                      ),
                    ),
                  if ((widget.registerInfo.companyRequired ?? false))
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(context.locale!.global_required),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if ((registerInfo.streetAddressEnabled ?? false) ||
        (registerInfo.zipPostalCodeEnabled ?? false) ||
        (registerInfo.streetAddress2Enabled ?? false) ||
        (registerInfo.countyEnabled ?? false) ||
        (registerInfo.countryEnabled ?? false) ||
        (registerInfo.stateProvinceEnabled ?? false)) {
      items.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(cardPadding),
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      context.locale!.auth_address,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  if (registerInfo.streetAddressEnabled ?? false)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: CustomerTextFormField(
                        context.locale!.auth_address_street,
                        (value) => registerInfo.streetAddress = value,
                        value: registerInfo.streetAddress,
                        submitted: !_submitted,
                        required: registerInfo.streetAddressRequired ?? false,
                      ),
                    ),
                  if (registerInfo.streetAddress2Enabled ?? false)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: CustomerTextFormField(
                        context.locale!.auth_address_street2,
                        (value) => registerInfo.streetAddress2 = value,
                        value: registerInfo.streetAddress2,
                        submitted: !_submitted,
                        required: registerInfo.streetAddress2Required ?? false,
                      ),
                    ),
                  if (registerInfo.zipPostalCodeEnabled ?? false)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: CustomerTextFormField(
                        context.locale!.auth_address_zip,
                        (value) => registerInfo.zipPostalCode = value,
                        value: registerInfo.zipPostalCode,
                        submitted: !_submitted,
                        required: registerInfo.zipPostalCodeRequired ?? false,
                      ),
                    ),
                  if (registerInfo.countyEnabled ?? false)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: CustomerTextFormField(
                        context.locale!.auth_address_county,
                        (value) => registerInfo.county = value,
                        value: registerInfo.county,
                        submitted: !_submitted,
                        required: registerInfo.countyRequired ?? false,
                      ),
                    ),
                  if (registerInfo.countryEnabled ?? false)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: DropdownButton(
                        isExpanded: true,
                        itemHeight: null,
                        dropdownColor:
                            Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                        elevation: 0,
                        items:
                            registerInfo.availableCountries.build().map((
                              value,
                            ) {
                              return DropdownMenuItem<String>(
                                value: value.value,
                                child: Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [Text(value.text ?? "")],
                                  ),
                                ),
                              );
                            }).toList(),
                        value: registerInfo.countryId?.toString(),
                        hint: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Text(
                            context.locale!.auth_address_select_country,
                          ),
                        ),
                        icon: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.arrow_right),
                        ),
                        style: Theme.of(context).textTheme.bodyLarge,
                        underline: Container(
                          height: 1,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        onChanged: (String? newValue) async {
                          setState(() {
                            registerInfo.countryId = int.parse(newValue!);
                          });

                          final controller = ref.read(
                            countryStatesControllerProvider.notifier,
                          );
                          final response = await controller.getStates(
                            registerInfo.countryId ?? 0,
                          );

                          setState(() {
                            availableStates =
                                response!
                                    .map((state) => state.toBuilder())
                                    .toList();
                            registerInfo.stateProvinceId =
                                availableStates?.first.id ?? 0;
                          });
                        },
                      ),
                    ),
                  if ((registerInfo.stateProvinceEnabled ?? false) &&
                      (availableStates?.isNotEmpty ?? false))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: DropdownButton(
                        isExpanded: true,
                        itemHeight: null,
                        dropdownColor:
                            Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                        elevation: 0,
                        items:
                            availableStates!.map((value) {
                              return DropdownMenuItem<int>(
                                value: value.id!,
                                child: Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [Text(value.name ?? "")],
                                  ),
                                ),
                              );
                            }).toList(),
                        value: registerInfo.stateProvinceId,
                        hint: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Text(
                            context.locale!.auth_address_select_state,
                          ),
                        ),
                        icon: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.arrow_right),
                        ),
                        style: Theme.of(context).textTheme.bodyLarge,
                        underline: Container(
                          height: 1,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        onChanged: (int? value) {
                          setState(() {
                            registerInfo.stateProvinceId = value!;
                          });
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if ((registerInfo.phoneEnabled ?? false) ||
        (registerInfo.faxEnabled ?? false)) {
      items.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(cardPadding),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      context.locale!.auth_contact_info,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  if (registerInfo.phoneEnabled ?? false)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: CustomerTextFormField(
                        context.locale!.auth_contact_info_phone,
                        (value) => registerInfo.phone = value,
                        value: registerInfo.phone,
                        submitted: !_submitted,
                        required: registerInfo.phoneRequired ?? false,
                      ),
                    ),
                  if (registerInfo.faxEnabled ?? false)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: CustomerTextFormField(
                        context.locale!.auth_contact_info_fax,
                        (value) => registerInfo.fax = value,
                        value: registerInfo.fax,
                        submitted: !_submitted,
                        required: registerInfo.faxRequired ?? false,
                      ),
                    ),
                  if ((widget.registerInfo.phoneRequired ?? false) ||
                      (widget.registerInfo.faxRequired ?? false))
                    Container(
                      padding: const EdgeInsets.only(top: 10),
                      alignment: Alignment.centerLeft,
                      child: Text(context.locale!.global_required),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (registerInfo.newsletterEnabled ?? false) {
      items.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(cardPadding),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      context.locale!.auth_options,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  if (registerInfo.newsletterEnabled ?? false)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: CustomSwitch(
                        isPreSelected: registerInfo.newsletter ?? false,
                        label: context.locale!.auth_newsletter,
                        onChanged: (value) {
                          setState(() {
                            registerInfo.newsletter = value;
                          });
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    items.add(
      Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(cardPadding),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    context.locale!.auth_password,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: CustomerTextFormField(
                    context.locale!.auth_password,
                    value: registerInfo.password,
                    (value) => registerInfo.password = value ?? '',
                    enabled: !state.isLoading,
                    submitted: !_submitted,
                    obscureText: true,
                    required: true,
                    minLength: passwordMinLength,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: CustomerTextFormField(
                    context.locale!.auth_password_confirm,
                    value: registerInfo.confirmPassword,
                    (value) => registerInfo.confirmPassword = value ?? '',
                    enabled: !state.isLoading,
                    submitted: !_submitted,
                    obscureText: true,
                    required: true,
                    minLength: passwordMinLength,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    items.add(
      Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: CustomFilledButton(
          text: context.locale!.auth_register,
          isLoading: state.isLoading,
          onPressed: state.isLoading ? null : () => _submit(),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: GlobalVariables.backgroundColor,
      appBar: AppBar(
        backgroundColor: GlobalVariables.accentColor,
        title: Text(
          context.locale!.auth_register,
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
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/bg5.jpg', // Replace with your image path
              fit: BoxFit.cover,
            ),
          ),
          ResponsiveScrollable(
            child: FocusScope(
              node: _node,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: items,
                ),
              ),
            ),
          ),
        ],
      )
    );
  }
}
