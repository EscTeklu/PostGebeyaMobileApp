import 'package:flutter/material.dart';
import 'package:nopcommerce_mobile/features/app/animation/animation_screen.dart';
import 'package:nopcommerce_mobile/features/app/animation/splash_animation_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key, this.apiVersion});

  final String? apiVersion;

  @override
  Widget build(BuildContext context) {
    const Color accentColor = Color(0xFF2C2E7B);
    return Material(
      color: accentColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/bottom_logo.png', width: 220),
        ],
      ),
    );
  }
}
/*
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: <Widget>[
          const Scaffold(body: SplashAnimationScreen()),
          IgnorePointer(
            child: AnimationScreen(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }
}
*/
