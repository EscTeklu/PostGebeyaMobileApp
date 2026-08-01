import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nopcommerce_mobile/features/app/splash_ready_notifier.dart';
import 'package:nopcommerce_mobile/features/products/presentation/catalog/catalog_providers.dart';
import 'package:nopcommerce_mobile/features/products/presentation/product_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key, this.apiVersion});

  final String? apiVersion;

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _taglineController;
  late AnimationController _dotsController;

  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<double> _taglineFade;
  late Animation<Offset> _taglineSlide;
  late Animation<double> _dotsFade;

  @override
  void initState() {
    super.initState();

    // Logo: fade + scale over 800ms
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.80, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    // Tagline: slide up + fade, starts 400ms after logo
    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeOut),
    );
    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeOut),
    );

    // Dots loader: fades in after tagline
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _dotsFade = Tween<double>(begin: 0.0, end: 1.0).animate(_dotsController);

    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _taglineController.forward();
      }
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _dotsController.forward();
      }
    });

    // Prefetch all home screen data and signal the router when ready.
    // Navigation is blocked until BOTH the minimum display time elapses
    // and all API calls complete (or 15 s timeout for slow networks).
    Future<void> safe(Future<dynamic> f) =>
        f.then((_) => null).catchError((_) => null);

    Future.wait([
      Future.delayed(const Duration(seconds: 2)),
      safe(ref.read(homePageProductsListFutureProvider.future)),
      safe(ref.read(categoriesListFutureProvider.future)),
      safe(ref.read(mostSoldProductsListFutureProvider.future)),
      safe(ref.read(newProductsListFutureProvider.future)),
      safe(ref.read(discountProductsListFutureProvider.future)),
      safe(ref.read(categoryProductMapProvider.future)),
    ])
        .timeout(const Duration(seconds: 15), onTimeout: () => [])
        .then((_) {
      if (mounted) {
        ref.read(splashReadyNotifierProvider).setReady();
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _taglineController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2C2E7B), Color(0xFF1E2060)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),

              // ── Logo ────────────────────────────────────────────────────
              FadeTransition(
                opacity: _logoFade,
                child: ScaleTransition(
                  scale: _logoScale,
                  child: Image.asset(
                    'assets/bottom_logo.png',
                    width: 200,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Tagline ─────────────────────────────────────────────────
              SlideTransition(
                position: _taglineSlide,
                child: FadeTransition(
                  opacity: _taglineFade,
                  child: Column(
                    children: [
                      Text(
                        'Your Ethiopian Marketplace',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.70),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 3),

              // ── Loading dots + version ────────────────────────────────
              FadeTransition(
                opacity: _dotsFade,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Column(
                    children: [
                      _PulsingDots(),
                      const SizedBox(height: 16),
                      if (widget.apiVersion != null)
                        Text(
                          'v${widget.apiVersion}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.30),
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Three pulsing dots that animate in sequence
class _PulsingDots extends StatefulWidget {
  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots>
    with TickerProviderStateMixin {
  final List<AnimationController> _controllers = [];
  final List<Animation<double>> _anims = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 3; i++) {
      final ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 700),
      );
      _controllers.add(ctrl);
      _anims.add(
        Tween<double>(begin: 0.3, end: 1.0).animate(
          CurvedAnimation(parent: ctrl, curve: Curves.easeInOut),
        ),
      );
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          ctrl.repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: FadeTransition(
            opacity: _anims[i],
            child: Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      }),
    );
  }
}
