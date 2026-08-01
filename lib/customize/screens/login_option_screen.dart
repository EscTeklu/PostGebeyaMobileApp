import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nopcommerce_mobile/features/authentication/presentation/login_screen.dart';

class LoginOptionScreen extends StatelessWidget {
  const LoginOptionScreen({super.key});

  static const _blue = Color(0xFF2C2E7B);
  static const _orange = Color(0xFFF5AD00);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── Blue gradient top section ────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.48,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2C2E7B), Color(0xFF3F42A8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Image.asset(
                      'assets/bottom_logo.png',
                      height: 72,
                      fit: BoxFit.contain,
                    )
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .scale(
                          begin: const Offset(0.85, 0.85),
                          end: const Offset(1, 1),
                          duration: 600.ms,
                          curve: Curves.easeOutBack,
                        ),
                    const SizedBox(height: 24),
                    const Text(
                      'Welcome!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 500.ms, delay: 200.ms)
                        .slideY(
                          begin: 0.2,
                          end: 0,
                          duration: 500.ms,
                          delay: 200.ms,
                        ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to start shopping',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 15,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 500.ms, delay: 300.ms),
                  ],
                ),
              ),
            ),
          ),

          // ── White options card ───────────────────────────────────────
          Positioned(
            top: size.height * 0.42,
            left: 24,
            right: 24,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: _blue.withValues(alpha: 0.1),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'GET STARTED',
                    style: TextStyle(
                      color: _blue,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Login with email button
                  SizedBox(
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                      ),
                      icon: const Icon(Icons.email_outlined, size: 20),
                      label: const Text(
                        'Login with Email',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _blue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 400.ms)
                      .slideY(begin: 0.2, end: 0, duration: 400.ms, delay: 400.ms),

                  const SizedBox(height: 12),

                  // Create account button
                  SizedBox(
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                      ),
                      icon: const Icon(Icons.person_add_outlined, size: 20),
                      label: const Text(
                        'Create Account',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _blue,
                        side: const BorderSide(color: _blue, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 500.ms)
                      .slideY(begin: 0.2, end: 0, duration: 400.ms, delay: 500.ms),

                  const SizedBox(height: 20),

                  // Divider with OR
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade200)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade200)),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Continue as guest
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Continue browsing as guest',
                      style: TextStyle(
                        color: _orange,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 600.ms),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 500.ms, delay: 350.ms)
                .slideY(begin: 0.1, end: 0, duration: 500.ms, delay: 350.ms),
          ),
        ],
      ),
    );
  }
}
