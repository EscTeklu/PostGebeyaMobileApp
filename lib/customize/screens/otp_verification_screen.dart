import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:nopcommerce_mobile/customize/services/api_service.dart';
import 'package:nopcommerce_mobile/features/app/home/presentation/home_screen.dart';
import 'package:nopcommerce_mobile/features/authentication/data/auth_repository.dart';
import 'package:nopcommerce_mobile/features/authentication/domain/nop_customer.dart';
import 'package:nopcommerce_mobile/features/customer/presentation/account/account_providers.dart';
import 'package:nopcommerce_mobile/router/route_utils.dart';
import 'package:nopcommerce_mobile/utils/base_nop_state.dart';
import 'package:nopcommerce_mobile/utils/memory_storage.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nopcommerce_mobile/features/authentication/presentation/auth_providers.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  final VoidCallback? onSignedIn;
  const OtpVerificationScreen({required this.phoneNumber, super.key, this.onSignedIn});

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {

  final TextEditingController _otpController = TextEditingController();
  final ApiService _apiService = ApiService();
  String _errorMessage = '';
  bool _isLoading = false;

  static Future Function({String? token, int? customerId, String? otp})?
  onTokenOTPChanged;
  //
  //late final VoidCallback? onSignedIn;
  //
  late final NopCustomer? currentUser;
  static final _authState = MemoryStorage<NopCustomer?>(null);
  Stream<NopCustomer?> authStateChanges() => _authState.stream;
  NopCustomer? get currentCustomer => _authState.value;
  final _node = FocusScopeNode();

  @override
  void dispose() {
    //TextEditingControllers should be always disposed
    _node.dispose();
    super.dispose();
  }

  void _verifyOtp() async {
    if (_otpController.text.length != 6) {
      setState(() {
        _errorMessage = 'Enter a valid 6-digit OTP';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final controller = ref.read(loginControllerProvider.notifier);
      final response = await _apiService.verifyOtp(widget.phoneNumber, _otpController.text);
      if (response['success']) {
        const storage = FlutterSecureStorage();
        await storage.write(key: "user_phone", value: widget.phoneNumber);

        /*if (response['token'] == null) {
          _authState.value = null;
          await storage.delete(key: "user_id");
          await storage.delete(key: "user_email");
        } else {
          //response['userId'] ??= int.parse(await storage.read(key: "user_id") ?? "0");
          //response['email'] ??= await storage.read(key: "user_email");
          if(_authState.value != null)
            {
              _authState.value = null;
              await storage.delete(key: "user_id");
              await storage.delete(key: "user_email");
            }

          final nopCustomer = NopCustomer(
              uid: response['userId'], token: response['token'], email: response['email'], isGuest: false);

          currentUser = nopCustomer;
          _authState.value = nopCustomer;
          print("TOKEN : $currentUser");


          await storage.write(key: "user_id", value: nopCustomer.uid.toString());
          await storage.write(key: "user_email", value: nopCustomer.email);

          var val = await controller.submitOTP(response['token'], response['email'], response['userId']);
          //if(val)
          if(val && _authState.value?.uid == response['userId'])
            {
              if (mounted) {
                setState(() {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      ref.refresh(customerInfoProvider);
                      context.pushNamed(Routes.home.name);
                    }
                  });
                });
              }
            }*/

          final controller = ref.read(loginControllerProvider.notifier);
          await controller
              //.submitOTP(response['token'], response['email'], response['userId'])
              .submit(response['email'], _otpController.text.toString())
              .then(
                (value) => {
              if (value)
                {
                  ref.refresh(customerInfoProvider),
                  widget.onSignedIn?.call()
                  //context.pushNamed(Routes.home.name)
                },
            },
          );


      } else {
        if (mounted) {
          setState(() {
            _errorMessage = response['error'] ?? 'Invalid OTP';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
    /*try {
      final response = await _apiService.verifyOtp(widget.phoneNumber, _otpController.text);
      if (response['success']) {
        const storage = FlutterSecureStorage();
        await storage.write(key: "user_phone", value: widget.phoneNumber);

        final controller = ref.read(loginControllerProvider.notifier);
        await controller
            .submitOTP(response['token'], response['email'], response['userId'])
            .then(
              (value) => {
                if (context.mounted) {

                  ref.refresh(customerInfoProvider),
                  context.pushNamed(Routes.home.name),
                },

          },
        );
      } else {
        setState(() {
          _errorMessage = response['error'] ?? 'Invalid OTP';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }*/
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateChangesProvider).value;

    ref.listen<BaseNopState>(
      accountControllerProvider,
          (_, state) => state.showAlertDialogOnError(context),
    );
    final state = ref.watch(accountControllerProvider);
    print("TOKEN4 : $user");
    final defaultPinTheme = PinTheme(
      width: 48,
      height: 48,
      textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.primary),
        borderRadius: BorderRadius.circular(8),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP', style: TextStyle(color: Colors.white),),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Enter OTP sent to ${widget.phoneNumber}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ).animate().fadeIn(duration: 500.ms),
            const SizedBox(height: 24),
            Center(
              child: Pinput(
                controller: _otpController,
                length: 6,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                separatorBuilder: (index) => const SizedBox(width: 8),
                showCursor: true,
                onCompleted: (pin) => _verifyOtp(),
                hapticFeedbackType: HapticFeedbackType.lightImpact,
              ).animate().slideY(begin: 0.2, end: 0, duration: 500.ms),
            ),

            const SizedBox(height: 16),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _verifyOtp,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Verify OTP',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
        ),
      ),
    );
  }
}