import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' as https;
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:nopcommerce_mobile/constants/global_variables.dart';
import 'package:nopcommerce_mobile/router/route_utils.dart';

import 'package:nopcommerce_mobile/customize/services/api_service.dart';

class TelebirrPayPage extends ConsumerStatefulWidget {
  final String amount;
  final String orderId;
  const TelebirrPayPage({super.key, required this.amount, required this.orderId});

  @override
  _TelebirrPayPageState createState() => _TelebirrPayPageState();
}

class _TelebirrPayPageState extends ConsumerState<TelebirrPayPage> {
  final id = 0;
  final TextEditingController _phoneController = TextEditingController();
  final ApiService _apiService = ApiService();
  String _errorMessage = '';
  bool _isLoading = false;
  String _completePhoneNumber = '';
  Timer? _countdownTimer;
  int _timeLeft = 6;
  //int orderId = ;
  final String _message = '';
  bool _showOtpSection = false;

  void checkStatus() {
    _timeLeft = 6;
    _countdownTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (_timeLeft <= 0) {
        timer.cancel();
        setState(() {
          //_message = "Session Expired!";
        });
        //Navigator.pushReplacementNamed(context, "/checkout/completed");
        context.pushNamed(
          Routes.orderDetails.name,
          pathParameters: {'id': widget.orderId.toString()},
        );
      } else {
        try {
          final response = await https.get(
            Uri.parse("https://postgebeya.ethio.post/api/telebirr/check?orderId=${widget.orderId}"),
          );
          final data = jsonDecode(response.body);
          if (data['status'] == 'Paid') {
            timer.cancel();
            context.pushNamed(
              Routes.orderDetails.name,
              pathParameters: {'id': widget.orderId.toString()},
            );
            //Navigator.pushReplacementNamed(context, "/checkout/completed");
          }
        } catch (_) {
          setState(() {
            //_message = "Error on Status Check.";
          });
        }
      }
      _timeLeft--;
    });
  }
  void _sendOtp() async {
    /*
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data Response : $confirmOrderResponse'))
    );*/
    if (_completePhoneNumber.isEmpty) {
      setState(() {
        _errorMessage =  'Please enter a valid phone number';
      });
      return;
    }

    setState(() {
      _showOtpSection = true;
      _isLoading = true;
      _errorMessage = '';
    });

    try {

      var headers = {
        'Content-Type': 'application/json',
        'Cookie': '.Nop.Antiforgery=CfDJ8IgHxkBpFB5BtdroSfw1lc2-fmElPoqWg6skBpRcwo5guWq3dltsVTt4ycSYxs96-WMZP2qWbO8D2lS3fJehvx2H7Pvlelj8vMKY1wWL1dFEYdMT2krcvVfOntR7ui0q-40E3xuZeYxmKBhlVTt4hgA; .Nop.Culture=c%3Den-US%7Cuic%3Den-US; .Nop.Customer=16f34caa-ac46-4ce8-bba3-9b8c4c8fa6d7'
      };
      var request = https.Request('POST', Uri.parse('https://postgebeya.ethio.post/api/telebirr/pay'));
      request.body = json.encode({
        "PhoneNumber": _completePhoneNumber,
        "Amount": widget.amount,
        "OrderId": widget.orderId
      });
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        print(await response.stream.bytesToString());
        checkStatus();
      }
      else {
        print(response.reasonPhrase);
      }

      /*final responseb = await _apiService.sendOtp(_completePhoneNumber);
      if (responseb['success']) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationScreen(phoneNumber: _completePhoneNumber),
          ),
        );
      } else {
        setState(() {
          _errorMessage = response['error'] ?? 'Failed to send OTP';
        });
      }*/
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: GlobalVariables.backgroundColor,
        appBar: AppBar(
          title: Text(' ', style: TextStyle(
              color: Colors.white
          ),),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.primary,
          leading: IconButton(
            icon: const Icon(
              Icons.close,
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  /*Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context), // Closes the modal
                    ),
                  ),
                  const SizedBox(height: 5),*/
                  if (!_showOtpSection) ...[
                  IntlPhoneField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      labelStyle: TextStyle(backgroundColor: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                    ),
                    initialCountryCode: 'ET',
                    onChanged: (phone) {
                      setState(() {
                        _completePhoneNumber = phone.completeNumber;
                        _errorMessage = '';
                      });
                    },
                    onCountryChanged: (country) {
                      setState(() {
                        _errorMessage = '';
                      });
                    },
                    validator: (phone) {
                      if (phone == null || !phone.isValidNumber()) {
                        return 'Invalid phone number';
                      }
                      return null;
                    },
                  ).animate().slideY(begin: 0.2, end: 0, duration: 500.ms),
                  const SizedBox(height: 16),

                  ElevatedButton.icon(
                    onPressed: _sendOtp,
                    icon: const Icon(Icons.wallet_rounded, color: Colors.white,),
                    label: const Text('Pay Now ', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2C2E7B),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        _errorMessage,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    ).animate().fadeIn(duration: 300.ms),
                  ],
                  if (_showOtpSection) ...[
                    Padding(padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: const <Widget>[
                        CircularProgressIndicator(),
                        SizedBox(height: 16.0),
                        Text(
                          'Waiting for PIN Confirmation ....',
                          style: TextStyle(fontSize: 20.0),
                        ),
                      ],
                    ),
                    )

                    /*const SizedBox(height: 20),
                    const CircularProgressIndicator(),
                    const SizedBox(height: 10),
                    const Text("Waiting for Payment Confirmation ...."),*/
                  ],
                ],
              ),
            ),
          ],
        )
    );
  }
}
/*class TelebirrPayPage extends StatefulWidget {
  final String orderId;
  final double amount;

  const TelebirrPayPage({Key? key, required this.orderId, required this.amount})
      : super(key: key);

  @override
  _TelebirrPayPageState createState() => _TelebirrPayPageState();
}

class _TelebirrPayPageState extends State<TelebirrPayPage> {
  final TextEditingController _phoneController = TextEditingController();
  String _errorMessage = '';
  String _message = '';
  bool _showOtpSection = false;
  Timer? _countdownTimer;
  int _timeLeft = 6;

  Future<void> sendOtp() async {
    final phone = _phoneController.text.trim();

    if (phone.isEmpty || phone.length < 9) {
      setState(() {
        _errorMessage = "Invalid phone number.";
      });
      return;
    }
    setState(() {
      _errorMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse("https://postgebeya.ethio.post/api/telebirr/pay"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "PhoneNumber": phone,
          "Amount": widget.amount,
          "OrderId": widget.orderId,
        }),
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        setState(() {
          _showOtpSection = true;
        });
        checkStatus();
      } else {
        setState(() {
          _message = data['msg'] ?? "Payment failed.";
        });
      }
    } catch (e) {
      setState(() {
        _message = "Error on Push Payment.";
      });
    }
  }

  void checkStatus() {
    _timeLeft = 6;
    _countdownTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (_timeLeft <= 0) {
        timer.cancel();
        setState(() {
          _message = "Session Expired!";
        });
        Navigator.pushReplacementNamed(context, "/checkout/completed");
      } else {
        try {
          final response = await http.get(
            Uri.parse("https://postgebeya.ethio.post/api/telebirr/check?orderId=${widget.orderId}"),
          );
          final data = jsonDecode(response.body);
          if (data['status'] == 'Paid') {
            timer.cancel();
            Navigator.pushReplacementNamed(context, "/checkout/completed");
          }
        } catch (_) {
          setState(() {
            _message = "Error on Status Check.";
          });
        }
      }
      _timeLeft--;
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Telebirr Payment")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (!_showOtpSection) ...[
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: "Enter Phone Number",
                  errorText: _errorMessage.isEmpty ? null : _errorMessage,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: sendOtp,
                child: const Text("Pay Now"),
              ),
            ],
            if (_showOtpSection) ...[
              const SizedBox(height: 20),
              const CircularProgressIndicator(),
              const SizedBox(height: 10),
              const Text("Waiting for Payment Confirmation ...."),
            ],
            const SizedBox(height: 20),
            Text(
              _message,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}*/

/// Data model for managing the payment process state.
/// Implemented as a singleton to make payment data static and globally accessible.
class PaymentData extends ChangeNotifier {
  // Private static instance for the singleton pattern.
  static final PaymentData _instance = PaymentData._internal();

  // Public getter to access the singleton instance.
  static PaymentData get instance => _instance;

  // Private constructor to prevent direct instantiation.
  PaymentData._internal();

  String _phoneNumber = '';
  bool _isLoading = false;
  bool _isConfirmed = false;
  String? _errorMessage;

  String get phoneNumber => _phoneNumber;
  bool get isLoading => _isLoading;
  bool get isConfirmed => _isConfirmed;
  String? get errorMessage => _errorMessage;

  /// Updates the phone number and clears any existing error messages.
  void setPhoneNumber(String newNumber) {
    if (_phoneNumber != newNumber) {
      _phoneNumber = newNumber;
      _errorMessage = null; // Clear error when input changes
      notifyListeners();
    }
  }

  /// Initiates the simulated payment process.
  Future<void> initiatePayment() async {
    if (_phoneNumber.isEmpty) {
      _errorMessage = 'Phone number cannot be empty.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _isConfirmed = false;
    _errorMessage = null;
    notifyListeners();

    // Simulate an asynchronous payment processing delay
    await Future.delayed(const Duration(seconds: 3));

    _isLoading = false;
    _isConfirmed = true; // Simulate successful confirmation
    // In a real app, you would check the actual payment result
    notifyListeners();
  }

  /// Resets the payment process state to allow for a new payment.
  void resetState() {
    _phoneNumber = '';
    _isLoading = false;
    _isConfirmed = false;
    _errorMessage = null;
    notifyListeners();
  }
}

/// Screen for handling mobile payments, intended to be shown as a modal.
class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //final PaymentData paymentData = context.watch<PaymentData>();
    //final TextEditingController _phoneController = TextEditingController();
    String errorMessage = '';
    bool isLoading = true;
    bool isConfirmed = true;
    String completePhoneNumber = '';

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context), // Closes the modal
              ),
            ),
            /*const Text(
              'Enter recipient\'s phone number to send payment:',
              style: TextStyle(fontSize: 18.0),
            ),*/
            /*IntlPhoneField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                labelStyle: TextStyle(backgroundColor: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              initialCountryCode: 'ET',
              onChanged: (phone) {
                *//*setState(() {
                  _completePhoneNumber = phone.completeNumber;
                  _errorMessage = '';
                });*//*
              },
              onCountryChanged: (country) {
                *//*setState(() {
                  _errorMessage = '';
                });*//*
              },
              validator: (phone) {
                if (phone == null || !phone.isValidNumber()) {
                  return 'Invalid phone number';
                }
                return null;
              },
            ).animate().slideY(begin: 0.2, end: 0, duration: 500.ms),
            const SizedBox(height: 14.0),
            ElevatedButton(
              onPressed: (){

              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: const Text(
                'Send Payment',
                style: TextStyle(fontSize: 18.0),
              ),
            ),*/
            const SizedBox(height: 16.0),
            /*TextFormField(
              // Recreates widget when phoneNumber changes to update initialValue
              key: ValueKey<String>(paymentData.phoneNumber),
              initialValue: paymentData.phoneNumber,
              keyboardType: TextInputType.phone,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: 'e.g., 0123456789',
                border: OutlineInputBorder(),
              ),
              onChanged: (String value) => paymentData.setPhoneNumber(value),
            ),
            if (paymentData.errorMessage != null) ...<Widget>[
              const SizedBox(height: 8.0),
              Text(
                paymentData.errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 14.0),
              ),
            ],
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: paymentData.isLoading || paymentData.phoneNumber.isEmpty
                  ? null
                  : () => paymentData.initiatePayment(),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: const Text(
                'Send Payment',
                style: TextStyle(fontSize: 18.0),
              ),
            ),
            const SizedBox(height: 24.0),*/
            if (isLoading)
              Column(
                children: const <Widget>[
                  CircularProgressIndicator(),
                  SizedBox(height: 16.0),
                  Text(
                    'Processing payment, please wait...',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ],
              )
            else if (isConfirmed)
              Column(
                children: <Widget>[
                  const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 60.0,
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    'Payment Confirmed!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  ElevatedButton(
                    onPressed: (){},
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                    ),
                    child: const Text('Make Another Payment'),
                  ),
                ],
              ),
            const Spacer(), // Pushes content to the top
          ],
        ),
      ),
    );
  }
}
