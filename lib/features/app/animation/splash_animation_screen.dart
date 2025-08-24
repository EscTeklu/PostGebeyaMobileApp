import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nopcommerce_mobile/router/route_utils.dart';

class SplashAnimationScreen extends StatefulWidget {
  const SplashAnimationScreen({super.key});

  @override
  State<SplashAnimationScreen> createState() => _SplashAnimationScreenState();
}

class _SplashAnimationScreenState extends State<SplashAnimationScreen>
    with TickerProviderStateMixin {
  late AnimationController _imageController;
  late AnimationController _textController;
  late Animation<double> _fadeImage;
  late Animation<double> _scaleImage;
  late Animation<double> _fadeText;
  late Animation<Offset> _slideText;

  @override
  void initState() {
    super.initState();

    _imageController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );
    _fadeImage = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _imageController, curve: Curves.easeIn));
    _scaleImage = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _imageController, curve: Curves.decelerate),
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeText = Tween<double>(begin: 0.0, end: 1.0).animate(_textController);
    _slideText = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    _imageController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _textController.forward();
    });

    Timer(const Duration(seconds: 6), () {
      context.pushReplacementNamed(Routes.home.name);
      /* GoRoute(
        path: '/home',
        name: Routes.home.name,
        pageBuilder:
            (context, state) => NoTransitionPage(
              key: state.pageKey,
              restorationId: state.pageKey.value,
              child: const HomePageScreen(),
            ),
      ); */
      //return MaterialApp.router();
    });
  }

  @override
  void dispose() {
    _imageController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color accentColor = Color(0xFF2C2E7B);
    return Scaffold(
      backgroundColor: accentColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _fadeImage,
              child: ScaleTransition(
                scale: _scaleImage,
                child: Image.asset('assets/bottom_logo.png', width: 220),
              ),
            ),
            const SizedBox(height: 24),
            /* SlideTransition(
              position: _slideText,
              child: FadeTransition(
                opacity: _fadeText,
                child: const Text(
                  'እንኳን ደህና መጡ',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Colors.deepPurple,
                    fontFamily:
                        'NotoSansEthiopic', // make sure this font supports Amharic
                  ),
                ),
              ),
            ), */
          ],
        ),
      ),
    );
  }
}
