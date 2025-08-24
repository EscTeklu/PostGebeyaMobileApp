import 'package:flutter/material.dart';
import 'package:nopcommerce_mobile/features/app/animation/animation_screen.dart';
import 'package:nopcommerce_mobile/features/app/animation/splash_animation_screen.dart';

/* class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key, this.apiVersion});

  final String? apiVersion;

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
} */

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
