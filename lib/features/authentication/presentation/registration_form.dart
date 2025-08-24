import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class RegistrationApp extends StatelessWidget {
  const RegistrationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registration Form',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const RegistrationForm(),
    );
  }
}

class RegistrationForm extends StatefulWidget {
  const RegistrationForm({super.key});

  @override
  RegistrationFormState createState() => RegistrationFormState();
}

class RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();

  // Form field controllers
  final _emailController = TextEditingController();
  final _confirmEmailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _companyController = TextEditingController();
  final _streetAddressController = TextEditingController();
  final _streetAddress2Controller = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _countyController = TextEditingController();
  final _phoneController = TextEditingController();
  final _faxController = TextEditingController();
  final _vatNumberController = TextEditingController();
  final _referralCodeController = TextEditingController();

  // Form field values
  String? _gender;
  int? _dateOfBirthDay;
  int? _dateOfBirthMonth;
  int? _dateOfBirthYear;
  String? _countryId;
  String? _stateProvinceId;
  String? _timeZoneId;
  bool _newsletter = false;
  bool _acceptPrivacyPolicy = false;
  bool _gdprConsentAccepted = false;
  bool _marketingOptIn = false;
  String? _preferredDeliveryMethod;

  // Sample data for dropdowns
  final List<String> genderOptions = ['M', 'F', 'Other'];
  final List<String> countryOptions = ['1']; // Assuming '1' is Ethiopia
  final List<String> stateOptions = ['1']; // Assuming '1' is a valid state
  final List<String> timeZoneOptions = ['E. Africa Standard Time'];
  final List<String> deliveryOptions = ['Courier', 'Postal Box'];

  // Dio instance
  final Dio _dio = Dio();

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _acceptPrivacyPolicy && _gdprConsentAccepted) {
      final url = 'https://ethiopostmall.africom.et/api-frontend/Customer/Register';
      final headers = {
        'accept': 'application/json',
        'Authorization': 'eCJCgwPuhc3pwdW1uqet+jnpJ9pFdZrkwlUFzZkeb3A',
        'Content-Type': 'application/json-patch+json',
      };

      final body = {
        "model": {
          "email": _emailController.text,
          "entering_email_twice": true,
          "confirm_email": _confirmEmailController.text,
          "usernames_enabled": true,
          "username": _usernameController.text,
          "check_username_availability_enabled": true,
          "password": _passwordController.text,
          "confirm_password": _confirmPasswordController.text,
          "gender_enabled": true,
          "gender": _gender,
          "first_name_enabled": true,
          "first_name": _firstNameController.text,
          "first_name_required": true,
          "last_name_enabled": true,
          "last_name": _lastNameController.text,
          "last_name_required": true,
          "date_of_birth_enabled": true,
          "date_of_birth_day": _dateOfBirthDay,
          "date_of_birth_month": _dateOfBirthMonth,
          "date_of_birth_year": _dateOfBirthYear,
          "date_of_birth_required": true,
          "company_enabled": true,
          "company_required": true,
          "company": _companyController.text,
          "street_address_enabled": true,
          "street_address_required": true,
          "street_address": _streetAddressController.text,
          "street_address2_enabled": true,
          "street_address2_required": true,
          "street_address2": _streetAddress2Controller.text,
          "zip_postal_code_enabled": true,
          "zip_postal_code_required": true,
          "zip_postal_code": _zipCodeController.text,
          "city_enabled": true,
          "city_required": true,
          "city": _cityController.text,
          "county_enabled": true,
          "county_required": true,
          "county": _countyController.text,
          "country_enabled": true,
          "country_required": true,
          "country_id": int.parse(_countryId ?? '1'),
          "state_province_enabled": true,
          "state_province_required": true,
          "state_province_id": int.parse(_stateProvinceId ?? '1'),
          "phone_enabled": true,
          "phone_required": true,
          "phone": _phoneController.text,
          "fax_enabled": true,
          "fax_required": true,
          "fax": _faxController.text,
          "newsletter_enabled": true,
          "newsletter": _newsletter,
          "accept_privacy_policy_enabled": true,
          "accept_privacy_policy_popup": true,
          "time_zone_id": _timeZoneId,
          "allow_customers_to_set_time_zone": true,
          "vat_number": _vatNumberController.text,
          "display_vat_number": true,
          "honeypot_enabled": true,
          "display_captcha": true,
          "gdpr_consents": [
            {
              "message": "I agree to terms",
              "is_required": true,
              "required_message": "Consent required",
              "accepted": _gdprConsentAccepted,
              "id": 1
            }
          ],
          "customer_attributes": [
            {
              "name": "Preferred Delivery Method",
              "is_required": true,
              "attribute_control_type": "DropdownList",
              "values": [
                {"name": "Courier", "is_pre_selected": _preferredDeliveryMethod == 'Courier', "id": 1},
                {"name": "Postal Box", "is_pre_selected": _preferredDeliveryMethod == 'Postal Box', "id": 2}
              ],
              "id": 10
            }
          ]
        },
        "form": {
          "PreferredDeliveryMethod": _preferredDeliveryMethod,
          "MarketingOptIn": _marketingOptIn.toString(),
          "ReferralCode": _referralCodeController.text
        }
      };

      try {
        final response = await _dio.post(
          url,
          options: Options(headers: headers),
          data: body,
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration failed: ${response.statusCode}')),
          );
        }
      } on DioException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
    }
  }

  @override
  void dispose() {
    // Dispose controllers
    _emailController.dispose();
    _confirmEmailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _companyController.dispose();
    _streetAddressController.dispose();
    _streetAddress2Controller.dispose();
    _zipCodeController.dispose();
    _cityController.dispose();
    _countyController.dispose();
    _phoneController.dispose();
    _faxController.dispose();
    _vatNumberController.dispose();
    _referralCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registration Form')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email *'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              // Confirm Email
              TextFormField(
                controller: _confirmEmailController,
                decoration: const InputDecoration(labelText: 'Confirm Email *'),
                validator: (value) {
                  if (value != _emailController.text) {
                    return 'Emails do not match';
                  }
                  return null;
                },
              ),
              // Username
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username *'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              // Password
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password *'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
              ),
              // Confirm Password
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(labelText: 'Confirm Password *'),
                obscureText: true,
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              // Gender
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Gender'),
                value: _gender,
                items: genderOptions
                    .map((gender) => DropdownMenuItem(
                  value: gender,
                  child: Text(gender),
                ))
                    .toList(),
                onChanged: (value) => setState(() => _gender = value),
              ),
              // First Name
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name *'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),
              // Last Name
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name *'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
              ),
              // Date of Birth
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      decoration: const InputDecoration(labelText: 'Day *'),
                      value: _dateOfBirthDay,
                      items: List.generate(31, (index) => index + 1)
                          .map((day) => DropdownMenuItem(
                        value: day,
                        child: Text(day.toString()),
                      ))
                          .toList(),
                      onChanged: (value) => setState(() => _dateOfBirthDay = value),
                      validator: (value) => value == null ? 'Please select a day' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      decoration: const InputDecoration(labelText: 'Month *'),
                      value: _dateOfBirthMonth,
                      items: List.generate(12, (index) => index + 1)
                          .map((month) => DropdownMenuItem(
                        value: month,
                        child: Text(month.toString()),
                      ))
                          .toList(),
                      onChanged: (value) => setState(() => _dateOfBirthMonth = value),
                      validator: (value) => value == null ? 'Please select a month' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      decoration: const InputDecoration(labelText: 'Year *'),
                      value: _dateOfBirthYear,
                      items: List.generate(100, (index) => DateTime.now().year - index)
                          .map((year) => DropdownMenuItem(
                        value: year,
                        child: Text(year.toString()),
                      ))
                          .toList(),
                      onChanged: (value) => setState(() => _dateOfBirthYear = value),
                      validator: (value) => value == null ? 'Please select a year' : null,
                    ),
                  ),
                ],
              ),
              // Company
              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(labelText: 'Company *'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your company';
                  }
                  return null;
                },
              ),
              // Street Address
              TextFormField(
                controller: _streetAddressController,
                decoration: const InputDecoration(labelText: 'Street Address *'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your street address';
                  }
                  return null;
                },
              ),
              // Street Address 2
              TextFormField(
                controller: _streetAddress2Controller,
                decoration: const InputDecoration(labelText: 'Street Address 2 *'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your street address 2';
                  }
                  return null;
                },
              ),
              // Zip Code
              TextFormField(
                controller: _zipCodeController,
                decoration: const InputDecoration(labelText: 'Zip / Postal Code *'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your zip code';
                  }
                  return null;
                },
              ),
              // City
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'City *'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your city';
                  }
                  return null;
                },
              ),
              // County
              TextFormField(
                controller: _countyController,
                decoration: const InputDecoration(labelText: 'County *'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your county';
                  }
                  return null;
                },
              ),
              // Country
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Country *'),
                value: _countryId,
                items: countryOptions
                    .map((country) => DropdownMenuItem(
                  value: country,
                  child: Text(country),
                ))
                    .toList(),
                onChanged: (value) => setState(() => _countryId = value),
                validator: (value) => value == null ? 'Please select a country' : null,
              ),
              // State/Province
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'State / Province *'),
                value: _stateProvinceId,
                items: stateOptions
                    .map((state) => DropdownMenuItem(
                  value: state,
                  child: Text(state),
                ))
                    .toList(),
                onChanged: (value) => setState(() => _stateProvinceId = value),
                validator: (value) => value == null ? 'Please select a state' : null,
              ),
              // Phone
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone *'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              // Fax
              TextFormField(
                controller: _faxController,
                decoration: const InputDecoration(labelText: 'Fax *'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your fax number';
                  }
                  return null;
                },
              ),
              // VAT Number
              TextFormField(
                controller: _vatNumberController,
                decoration: const InputDecoration(labelText: 'VAT Number'),
              ),
              // Time Zone
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Time Zone'),
                value: _timeZoneId,
                items: timeZoneOptions
                    .map((tz) => DropdownMenuItem(
                  value: tz,
                  child: Text(tz),
                ))
                    .toList(),
                onChanged: (value) => setState(() => _timeZoneId = value),
              ),
              // Preferred Delivery Method
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Preferred Delivery Method *'),
                value: _preferredDeliveryMethod,
                items: deliveryOptions
                    .map((method) => DropdownMenuItem(
                  value: method,
                  child: Text(method),
                ))
                    .toList(),
                onChanged: (value) => setState(() => _preferredDeliveryMethod = value),
                validator: (value) => value == null ? 'Please select a delivery method' : null,
              ),
              // Referral Code
              TextFormField(
                controller: _referralCodeController,
                decoration: const InputDecoration(labelText: 'Referral Code'),
              ),
              // Newsletter
              CheckboxListTile(
                title: const Text('Subscribe to newsletter'),
                value: _newsletter,
                onChanged: (value) => setState(() => _newsletter = value ?? false),
              ),
              // Marketing Opt-In
              CheckboxListTile(
                title: const Text('Marketing Opt-In'),
                value: _marketingOptIn,
                onChanged: (value) => setState(() => _marketingOptIn = value ?? false),
              ),
              // Privacy Policy
              CheckboxListTile(
                title: const Text('Accept Privacy Policy *'),
                value: _acceptPrivacyPolicy,
                onChanged: (value) => setState(() => _acceptPrivacyPolicy = value ?? false),
                subtitle: !_acceptPrivacyPolicy
                    ? const Text(
                  'You must accept the privacy policy',
                  style: TextStyle(color: Colors.red),
                )
                    : null,
              ),
              // GDPR Consent
              CheckboxListTile(
                title: const Text('GDPR Consent *'),
                value: _gdprConsentAccepted,
                onChanged: (value) => setState(() => _gdprConsentAccepted = value ?? false),
                subtitle: !_gdprConsentAccepted
                    ? const Text(
                  'You must accept GDPR consent',
                  style: TextStyle(color: Colors.red),
                )
                    : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}