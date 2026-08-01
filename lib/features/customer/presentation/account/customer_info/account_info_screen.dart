import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_api/frontend_api.dart';
import 'package:intl/intl.dart';
import 'package:nopcommerce_mobile/common_widgets/async_value.dart';
import 'package:nopcommerce_mobile/common_widgets/custom_text_form_field.dart';
import 'package:nopcommerce_mobile/common_widgets/responsive_scrollable.dart';
import 'package:nopcommerce_mobile/features/app/scaffold_messenger_extansion.dart';
import 'package:nopcommerce_mobile/features/customer/presentation/account/account_providers.dart';
import 'package:nopcommerce_mobile/features/customer/presentation/account/customer_info/gender_widget.dart';
import 'package:nopcommerce_mobile/l10n/app_localizations_context.dart';
import 'package:nopcommerce_mobile/utils/async_value_ui.dart';
import 'package:nopcommerce_mobile/utils/date_format_provider.dart';

const _blue = Color(0xFF2C2E7B);
const _orange = Color(0xFFF5AD00);
const _bg = Color(0xFFF4F5FB);

class AccountInfoScreen extends ConsumerWidget {
  static var genderKey = const Key('Gender');

  const AccountInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerInfo = ref.watch(customerInfoProvider);

    return AsyncValueWidget<CustomerInfoModelDto?>(
      value: customerInfo,
      data: (customer) => AccountInfoContents(
        customerInfo: customer?.toBuilder() ?? CustomerInfoModelDtoBuilder(),
      ),
    );
  }
}

class AccountInfoContents extends ConsumerStatefulWidget {
  const AccountInfoContents({
    super.key,
    this.onSave,
    required this.customerInfo,
  });
  final VoidCallback? onSave;
  final CustomerInfoModelDtoBuilder customerInfo;

  @override
  ConsumerState<AccountInfoContents> createState() => _AccountInfoState();
}

class _AccountInfoState extends ConsumerState<AccountInfoContents> {
  final _genderController = TextEditingController();
  final _dateInput = TextEditingController();

  _AccountInfoState();

  final _formKey = GlobalKey<FormState>();
  final _node = FocusScopeNode();

  var _submitted = false;

  DateTime? selectedDate;

  CustomerInfoModelDtoBuilder customerInfo = CustomerInfoModelDtoBuilder();

  @override
  void didChangeDependencies() {
    final dateProvider = ref.watch(dateFormatterProvider);
    if ((widget.customerInfo.dateOfBirthYear != null) &&
        (widget.customerInfo.dateOfBirthMonth != null) &&
        (widget.customerInfo.dateOfBirthDay != null)) {
      selectedDate = DateTime.utc(
        widget.customerInfo.dateOfBirthYear!,
        widget.customerInfo.dateOfBirthMonth!,
        widget.customerInfo.dateOfBirthDay!,
      );
      _dateInput.text = dateProvider.format(selectedDate!);
    } else {
      selectedDate = null;
      _dateInput.text = "";
    }

    super.didChangeDependencies();
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
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2025),
      helpText: context.locale!.account_info_personal_date_birth,
      fieldLabelText: context.locale!.account_info_personal_date_birth,
      errorFormatText: context.locale!.app_is_not_valid_date,
      errorInvalidText: context.locale!.app_is_not_valid_date_range,
      confirmText: context.locale!.app_ok,
      cancelText: context.locale!.app_cancel,
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        _dateInput.text = dateProvider.format(pickedDate);

        customerInfo.dateOfBirthDay = pickedDate.day;
        customerInfo.dateOfBirthMonth = pickedDate.month;
        customerInfo.dateOfBirthYear = pickedDate.year;
      });
    }
  }

  Future<void> _submit() async {
    setState(() => _submitted = true);
    _formKey.currentState!.save();
    widget.customerInfo.gender = _genderController.text;

    if (_formKey.currentState!.validate()) {
      final controller = ref.read(customerInfControllerProvider.notifier);

      await controller.submit(widget.customerInfo).then(
        (value) => {
          if (!value)
            {setState(() => _submitted = false)}
          else
            {
              if (mounted)
                showInSnackBar(context, context.locale!.global_message_save),
              ref.refresh(customerInfoProvider),
            },
        },
      );
    } else {
      showInSnackBar(context, context.locale!.global_fix_error);
    }
  }

  void _editingComplete() {
    _node.nextFocus();
  }

  @override
  void initState() {
    customerInfo = widget.customerInfo;
    super.initState();
  }

  Widget _sectionHeader(String title) {
    return Row(
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
          title.toUpperCase(),
          style: const TextStyle(
            color: _blue,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _sectionCard({required String title, required List<Widget> fields}) {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _sectionHeader(title),
            const SizedBox(height: 16),
            ...fields,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue>(
      customerInfControllerProvider.select((state) => state.value),
      (_, state) => state.showAlertDialogOnError(context),
    );

    final dateProvider = ref.watch(dateFormatterProvider);
    const gap = SizedBox(height: 12);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _blue,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.locale!.account_info,
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
                  // Personal Details Card
                  _sectionCard(
                    title: context.locale!.account_info_personal,
                    fields: _buildPersonalFields(gap, dateProvider),
                  ),
                  const SizedBox(height: 16),

                  // Company Details Card
                  if ((widget.customerInfo.companyEnabled ?? false) ||
                      (widget.customerInfo.displayVatNumber ?? false))
                    _sectionCard(
                      title: context.locale!.account_info_company,
                      fields: _buildCompanyFields(gap),
                    ),
                  if ((widget.customerInfo.companyEnabled ?? false) ||
                      (widget.customerInfo.displayVatNumber ?? false))
                    const SizedBox(height: 16),

                  // Contact Information Card
                  if ((widget.customerInfo.phoneEnabled ?? false) ||
                      (widget.customerInfo.faxEnabled ?? false))
                    _sectionCard(
                      title: context.locale!.account_info_contact,
                      fields: _buildContactFields(gap),
                    ),
                  if ((widget.customerInfo.phoneEnabled ?? false) ||
                      (widget.customerInfo.faxEnabled ?? false))
                    const SizedBox(height: 16),

                  // Save Button
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _blue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => _submit(),
                      child: Text(
                        context.locale!.global_button_save,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
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

  List<Widget> _buildPersonalFields(SizedBox gap, DateFormat dateProvider) {
    final fields = <Widget>[];

    _genderController.text = customerInfo.gender ?? '';

    if (customerInfo.genderEnabled ?? false) {
      fields.add(
        GenderWidget(
          key: AccountInfoScreen.genderKey,
          controller: _genderController,
        ),
      );
      fields.add(gap);
    }

    if (customerInfo.firstNameEnabled ?? false) {
      fields.add(
        CustomerTextFormField(
          context.locale!.account_info_personal_first_name,
          (value) => customerInfo.firstName = value,
          value: customerInfo.firstName,
          submitted: !_submitted,
          required: customerInfo.firstNameRequired ?? false,
          minLength: 3,
          onEditingComplete: () => _editingComplete(),
        ),
      );
      fields.add(gap);
    }

    if (customerInfo.lastNameEnabled ?? false) {
      fields.add(
        CustomerTextFormField(
          context.locale!.account_info_personal_last_name,
          (value) => customerInfo.lastName = value,
          value: customerInfo.lastName,
          submitted: !_submitted,
          required: customerInfo.lastNameRequired ?? false,
          minLength: 3,
          onEditingComplete: () => _editingComplete(),
        ),
      );
      fields.add(gap);
    }

    if (customerInfo.usernamesEnabled ?? false) {
      fields.add(
        CustomerTextFormField(
          context.locale!.account_info_personal_username,
          (value) => customerInfo.username = value,
          value: customerInfo.username,
          submitted: !_submitted,
          required: true,
          onEditingComplete: () => _editingComplete(),
        ),
      );
      fields.add(gap);
    }

    fields.add(
      CustomerTextFormField(
        context.locale!.account_info_personal_email,
        (value) => customerInfo.email = value,
        isEmail: true,
        value: customerInfo.email,
        submitted: !_submitted,
        required: true,
        onEditingComplete: () => _editingComplete(),
      ),
    );
    fields.add(gap);

    if (customerInfo.dateOfBirthEnabled ?? false) {
      fields.add(
        CustomerTextFormField(
          context.locale!.account_info_personal_date_birth,
          (value) => {},
          value: _dateInput.text,
          submitted: !_submitted,
          controller: _dateInput,
          onTap: () => _selectDate(context),
          required: customerInfo.dateOfBirthRequired ?? false,
          minLength: 3,
          isDate: true,
          onEditingComplete: () => _editingComplete(),
        ),
      );
      fields.add(gap);
    }

    fields.add(
      Text(
        context.locale!.global_required,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade500,
        ),
      ),
    );

    return fields;
  }

  List<Widget> _buildCompanyFields(SizedBox gap) {
    final fields = <Widget>[];

    if (customerInfo.companyEnabled ?? false) {
      fields.add(
        CustomerTextFormField(
          context.locale!.account_info_company_name,
          (value) => customerInfo.company = value,
          value: customerInfo.company,
          submitted: !_submitted,
          required: customerInfo.companyRequired ?? false,
          onEditingComplete: () => _editingComplete(),
        ),
      );
      fields.add(gap);
    }

    if (customerInfo.displayVatNumber ?? false) {
      fields.add(
        CustomerTextFormField(
          context.locale!.account_info_company_vat,
          (value) => customerInfo.vatNumber = value,
          value: customerInfo.vatNumber,
          submitted: !_submitted,
          onEditingComplete: () => _editingComplete(),
        ),
      );
      if (customerInfo.vatNumberStatusNote != null) {
        fields.add(
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              customerInfo.vatNumberStatusNote!,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
        );
      }
      fields.add(gap);
    }

    if (widget.customerInfo.companyRequired ?? false) {
      fields.add(
        Text(
          context.locale!.global_required,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
      );
    }

    return fields;
  }

  List<Widget> _buildContactFields(SizedBox gap) {
    final fields = <Widget>[];

    if (customerInfo.phoneEnabled ?? false) {
      fields.add(
        CustomerTextFormField(
          context.locale!.account_info_contact_phone,
          (value) => customerInfo.phone = value,
          value: customerInfo.phone,
          submitted: !_submitted,
          required: customerInfo.phoneRequired ?? false,
          onEditingComplete: () => _editingComplete(),
        ),
      );
      fields.add(gap);
    }

    if (customerInfo.faxEnabled ?? false) {
      fields.add(
        CustomerTextFormField(
          context.locale!.account_info_contact_fax,
          (value) => customerInfo.fax = value,
          value: customerInfo.fax,
          submitted: !_submitted,
          required: customerInfo.faxRequired ?? false,
          onEditingComplete: () => _editingComplete(),
        ),
      );
      fields.add(gap);
    }

    if ((widget.customerInfo.phoneRequired ?? false) ||
        (widget.customerInfo.faxRequired ?? false)) {
      fields.add(
        Text(
          context.locale!.global_required,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
      );
    }

    return fields;
  }
}
