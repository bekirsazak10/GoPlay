import 'package:flutter/material.dart';

/// Marka adı buradan değiştirilebilir.
/// GoTrendy adı kullanılamazsa false yaparak GoPlay gösterilebilir.
const bool useGoTrendyName = true;
const String appName = useGoTrendyName ? 'GoTrendy' : 'GoPlay';

void main() {
  runApp(const GoTrendyApp());
}

class GoTrendyApp extends StatelessWidget {
  const GoTrendyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF050505),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _idleController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.16)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 58,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.16, end: 0.94)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.94, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 22,
      ),
    ]).animate(_entranceController);

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.48, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.42),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOutBack,
      ),
    );

    _entranceController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        _idleController.repeat(reverse: true);
      }
    });

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _idleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF101010),
                Color(0xFF050505),
                Color(0xFF000000),
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _idleController,
                    builder: (context, child) {
                      final idleScale = 1.0 + (_idleController.value * 0.025);
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: Transform.scale(
                              scale: idleScale,
                              child: child,
                            ),
                          ),
                        ),
                      );
                    },
                    child: Text(
                      appName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFF5F5F5),
                        fontSize: 46,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.8,
                        height: 1.0,
                        shadows: [
                          Shadow(
                            color: Color(0x55FFFFFF),
                            blurRadius: 18,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: const Text(
                      'HOŞ GELDİNİZ',
                      style: TextStyle(
                        color: Color(0xFFBDBDBD),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 5.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
