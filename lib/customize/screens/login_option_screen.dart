import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nopcommerce_mobile/constants/global_variables.dart';
import 'package:nopcommerce_mobile/customize/screens/phone_input_screen.dart';
import 'package:nopcommerce_mobile/features/authentication/presentation/login_screen.dart';

class LoginOptionScreen extends StatelessWidget {
  const LoginOptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: GlobalVariables.backgroundColor,
      appBar: AppBar(
        title: const Text('Choose Login Option', style: TextStyle(
          color: Colors.white
        ),),
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
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/bg5.jpg', // Replace with your image path
              fit: BoxFit.cover,
            ),
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /*Text(
                        'Choose Login Method',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ).animate().fadeIn(duration: 500.ms),
                      const SizedBox(height: 24),*/
                      ElevatedButton.icon(
                        onPressed: () {
                          //navigate to EmailLoginScreen
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                        icon: const Icon(Icons.email, color: Colors.white,),
                        label: const Text('Login with Email', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF2C2E7B),
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => PhoneInputScreen()),
                          );
                        },
                        icon: const Icon(Icons.phone, color: Colors.white),
                        label: const Text('Login with Phone Number', style: TextStyle(color: Colors.white),),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Color(0xFF2C2E7B),
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: Theme.of(context).colorScheme.primary),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ).animate().fadeIn(duration: 500.ms, delay: 400.ms),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      )
    );
  }
}