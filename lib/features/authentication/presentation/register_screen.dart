import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nopcommerce_mobile/common_widgets/async_value.dart';
import 'package:nopcommerce_mobile/common_widgets/custom_switch.dart';
import 'package:nopcommerce_mobile/common_widgets/custom_text_form_field.dart';
import 'package:nopcommerce_mobile/common_widgets/responsive_scrollable.dart';
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
      data: (register) => RegisterInfoContents(
        registerInfo: register?.toBuilder() ?? RegisterModelDtoBuilder(),
      ),
    );
  }
}

class RegisterInfoContents extends ConsumerStatefulWidget {
  const RegisterInfoContents({super.key, this.onSave, required this.registerInfo});
  final VoidCallback? onSave;
  final RegisterModelDtoBuilder registerInfo;

  @override
  ConsumerState<RegisterInfoContents> createState() => _RegisterInfoState();
}

class _RegisterInfoState extends ConsumerState<RegisterInfoContents> {
  static const _blue = Color(0xFF2C2E7B);
  static const _orange = Color(0xFFF5AD00);

  final _genderController = TextEditingController();
  final _dateInput = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _node = FocusScopeNode();

  var _submitted = false;
  List<StateProvinceModelDtoBuilder>? availableStates;
  DateTime selectedDate = DateTime.now();
  RegisterModelDtoBuilder registerInfo = RegisterModelDtoBuilder();

  @override
  void initState() {
    registerInfo = widget.registerInfo;
    super.initState();
  }

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

  Future<void> _submit() async {
    setState(() => _submitted = true);
    _formKey.currentState!.save();
    widget.registerInfo.gender = _genderController.text;

    if (widget.registerInfo.password != widget.registerInfo.confirmPassword) {
      showInSnackBar(context, context.locale!.global_passwords_mismatch);
      return;
    }

    if (_formKey.currentState!.validate()) {
      final controller = ref.read(loginControllerProvider.notifier);
      await controller.register(widget.registerInfo).then((value) {
        if (value) {
          ref.invalidate(customerInfoProvider);
          ref.refresh(shoppingCartFutureProvider.future).whenComplete(
              () => ref.refresh(shoppingCartTotalsProvider.future));
          if (mounted) context.goNamed(Routes.home.name);
        } else {
          setState(() => _submitted = false);
          if (mounted) {
            showInSnackBar(context, context.locale!.global_fix_error);
          }
        }
      });
    } else {
      showInSnackBar(context, context.locale!.global_fix_error);
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Widget _sectionCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _blue.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: _blue, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: _blue,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _field(Widget child) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: child,
      );

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

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FB),
      appBar: AppBar(
        backgroundColor: _blue,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.locale!.auth_register,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ResponsiveScrollable(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          child: FocusScope(
            node: _node,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  // ── Personal details ──────────────────────────────────
                  _sectionCard(
                    title: context.locale!.auth_personal_details,
                    icon: Icons.person_outline_rounded,
                    children: [
                      if (registerInfo.genderEnabled ?? false)
                        _field(GenderWidget(
                          key: RegisterScreen.genderKey,
                          controller: _genderController,
                        )),
                      if (registerInfo.firstNameEnabled ?? false)
                        _field(CustomerTextFormField(
                          context.locale!.auth_first_name,
                          (value) => registerInfo.firstName = value,
                          value: registerInfo.firstName,
                          submitted: !_submitted,
                          required: registerInfo.firstNameRequired ?? false,
                          minLength: 3,
                        )),
                      if (registerInfo.lastNameEnabled ?? false)
                        _field(CustomerTextFormField(
                          context.locale!.auth_last_name,
                          (value) => registerInfo.lastName = value,
                          value: registerInfo.lastName,
                          submitted: !_submitted,
                          required: registerInfo.lastNameRequired ?? false,
                          minLength: 3,
                        )),
                      if (registerInfo.usernamesEnabled ?? false)
                        _field(CustomerTextFormField(
                          context.locale!.auth_username,
                          (value) => registerInfo.username = value,
                          value: registerInfo.username,
                          submitted: !_submitted,
                          required: true,
                        )),
                      _field(CustomerTextFormField(
                        context.locale!.auth_email,
                        (value) => registerInfo.email = value,
                        isEmail: true,
                        value: registerInfo.email,
                        submitted: !_submitted,
                        required: true,
                      )),
                      if (registerInfo.dateOfBirthEnabled ?? false)
                        _field(CustomerTextFormField(
                          context.locale!.auth_date_of_birth,
                          (value) => {},
                          value: _dateInput.text,
                          controller: _dateInput,
                          submitted: !_submitted,
                          required: registerInfo.dateOfBirthRequired ?? false,
                          minLength: 3,
                          isDate: true,
                          onTap: () => _selectDate(context),
                        )),
                    ],
                  ),

                  // ── Company details ───────────────────────────────────
                  if (registerInfo.companyEnabled ?? false)
                    _sectionCard(
                      title: context.locale!.auth_company_details,
                      icon: Icons.business_outlined,
                      children: [
                        _field(CustomerTextFormField(
                          context.locale!.auth_company,
                          (value) => registerInfo.company = value,
                          value: registerInfo.company,
                          submitted: !_submitted,
                          required: registerInfo.companyRequired ?? false,
                        )),
                        if (registerInfo.displayVatNumber ?? false)
                          _field(CustomerTextFormField(
                            context.locale!.auth_vat,
                            (value) => registerInfo.vatNumber = value,
                            value: registerInfo.vatNumber,
                            submitted: !_submitted,
                          )),
                      ],
                    ),

                  // ── Address ───────────────────────────────────────────
                  if ((registerInfo.streetAddressEnabled ?? false) ||
                      (registerInfo.zipPostalCodeEnabled ?? false) ||
                      (registerInfo.streetAddress2Enabled ?? false) ||
                      (registerInfo.countyEnabled ?? false) ||
                      (registerInfo.countryEnabled ?? false) ||
                      (registerInfo.stateProvinceEnabled ?? false))
                    _sectionCard(
                      title: context.locale!.auth_address,
                      icon: Icons.location_on_outlined,
                      children: [
                        if (registerInfo.streetAddressEnabled ?? false)
                          _field(CustomerTextFormField(
                            context.locale!.auth_address_street,
                            (value) => registerInfo.streetAddress = value,
                            value: registerInfo.streetAddress,
                            submitted: !_submitted,
                            required: registerInfo.streetAddressRequired ?? false,
                          )),
                        if (registerInfo.streetAddress2Enabled ?? false)
                          _field(CustomerTextFormField(
                            context.locale!.auth_address_street2,
                            (value) => registerInfo.streetAddress2 = value,
                            value: registerInfo.streetAddress2,
                            submitted: !_submitted,
                            required: registerInfo.streetAddress2Required ?? false,
                          )),
                        if (registerInfo.zipPostalCodeEnabled ?? false)
                          _field(CustomerTextFormField(
                            context.locale!.auth_address_zip,
                            (value) => registerInfo.zipPostalCode = value,
                            value: registerInfo.zipPostalCode,
                            submitted: !_submitted,
                            required: registerInfo.zipPostalCodeRequired ?? false,
                          )),
                        if (registerInfo.countyEnabled ?? false)
                          _field(CustomerTextFormField(
                            context.locale!.auth_address_county,
                            (value) => registerInfo.county = value,
                            value: registerInfo.county,
                            submitted: !_submitted,
                            required: registerInfo.countyRequired ?? false,
                          )),
                        if (registerInfo.countryEnabled ?? false)
                          _field(_StyledDropdown(
                            hint: context.locale!.auth_address_select_country,
                            items: registerInfo.availableCountries.build().map((v) =>
                              DropdownMenuItem<String>(
                                value: v.value,
                                child: Text(v.text ?? ''),
                              )).toList(),
                            value: registerInfo.countryId?.toString(),
                            onChanged: (String? newValue) async {
                              setState(() => registerInfo.countryId = int.parse(newValue!));
                              final controller = ref.read(countryStatesControllerProvider.notifier);
                              final response = await controller.getStates(registerInfo.countryId ?? 0);
                              setState(() {
                                availableStates = response!.map((s) => s.toBuilder()).toList();
                                registerInfo.stateProvinceId = availableStates?.first.id ?? 0;
                              });
                            },
                          )),
                        if ((registerInfo.stateProvinceEnabled ?? false) &&
                            (availableStates?.isNotEmpty ?? false))
                          _field(_StyledDropdown<int>(
                            hint: context.locale!.auth_address_select_state,
                            items: availableStates!.map((v) =>
                              DropdownMenuItem<int>(
                                value: v.id!,
                                child: Text(v.name ?? ''),
                              )).toList(),
                            value: registerInfo.stateProvinceId,
                            onChanged: (int? v) => setState(() => registerInfo.stateProvinceId = v!),
                          )),
                      ],
                    ),

                  // ── Contact info ──────────────────────────────────────
                  if ((registerInfo.phoneEnabled ?? false) ||
                      (registerInfo.faxEnabled ?? false))
                    _sectionCard(
                      title: context.locale!.auth_contact_info,
                      icon: Icons.phone_outlined,
                      children: [
                        if (registerInfo.phoneEnabled ?? false)
                          _field(CustomerTextFormField(
                            context.locale!.auth_contact_info_phone,
                            (value) => registerInfo.phone = value,
                            value: registerInfo.phone,
                            submitted: !_submitted,
                            required: registerInfo.phoneRequired ?? false,
                          )),
                        if (registerInfo.faxEnabled ?? false)
                          _field(CustomerTextFormField(
                            context.locale!.auth_contact_info_fax,
                            (value) => registerInfo.fax = value,
                            value: registerInfo.fax,
                            submitted: !_submitted,
                            required: registerInfo.faxRequired ?? false,
                          )),
                      ],
                    ),

                  // ── Newsletter ────────────────────────────────────────
                  if (registerInfo.newsletterEnabled ?? false)
                    _sectionCard(
                      title: context.locale!.auth_options,
                      icon: Icons.mail_outline_rounded,
                      children: [
                        CustomSwitch(
                          isPreSelected: registerInfo.newsletter ?? false,
                          label: context.locale!.auth_newsletter,
                          onChanged: (value) => setState(() => registerInfo.newsletter = value),
                        ),
                      ],
                    ),

                  // ── Customer attributes ───────────────────────────────
                  if (registerInfo.customerAttributes.isNotEmpty)
                    _sectionCard(
                      title: 'Additional Information',
                      icon: Icons.info_outline_rounded,
                      children: [
                        for (final attr in registerInfo.customerAttributes.build())
                          _field(TextFormField(
                            decoration: InputDecoration(
                              labelText: attr.name ?? '',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            validator: attr.isRequired == true
                                ? (v) => (v?.isEmpty ?? true) ? 'Required' : null
                                : null,
                            initialValue: '',
                          )),
                      ],
                    ),

                  // ── Password ──────────────────────────────────────────
                  _sectionCard(
                    title: context.locale!.auth_password,
                    icon: Icons.lock_outline_rounded,
                    children: [
                      _field(CustomerTextFormField(
                        context.locale!.auth_password,
                        value: registerInfo.password,
                        (value) => registerInfo.password = value ?? '',
                        enabled: !state.isLoading,
                        submitted: !_submitted,
                        obscureText: true,
                        required: true,
                        minLength: passwordMinLength,
                      )),
                      _field(CustomerTextFormField(
                        context.locale!.auth_password_confirm,
                        value: registerInfo.confirmPassword,
                        (value) => registerInfo.confirmPassword = value ?? '',
                        enabled: !state.isLoading,
                        submitted: !_submitted,
                        obscureText: true,
                        required: true,
                        minLength: passwordMinLength,
                      )),
                    ],
                  ),

                  // ── Submit button ─────────────────────────────────────
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
                      onPressed: state.isLoading ? null : () => _submit(),
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
                              context.locale!.auth_register,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Login link ────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () => context.pushNamed(Routes.login.name),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            color: _blue,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
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

// ── Styled dropdown helper ────────────────────────────────────────────────────

class _StyledDropdown<T> extends StatelessWidget {
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final T? value;
  final ValueChanged<T?> onChanged;

  const _StyledDropdown({
    required this.hint,
    required this.items,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          items: items,
          value: value,
          hint: Text(hint, style: TextStyle(color: Colors.grey.shade500)),
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
