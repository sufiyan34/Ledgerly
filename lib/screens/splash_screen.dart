import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoTranslation;
  double _progress = 0.0;
  int _stateIndex = 0;

  final List<String> _states = [
    "Initializing Core",
    "Securing Vault",
    "Fetching Ledgers",
    "Frozen Light Active",
    "Ready",
  ];

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _logoTranslation = Tween<double>(begin: 0.0, end: -12.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    _runProgress();
  }

  void _runProgress() {
    const duration = Duration(milliseconds: 700);
    Timer.periodic(duration, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _progress += 0.22;
        if (_progress > 1.0) _progress = 1.0;

        _stateIndex = (_progress * (_states.length - 1)).round();
        if (_stateIndex >= _states.length) {
          _stateIndex = _states.length - 1;
        }

        if (_progress >= 1.0) {
          timer.cancel();
          _navigateNext();
        }
      });
    });
  }

  void _navigateNext() {
    final appState = Provider.of<AppState>(context, listen: false);
    if (!appState.hasSeenOnboarding) {
      Navigator.pushReplacementNamed(context, '/onboarding');
    } else if (!appState.isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/auth');
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withOpacity(0.06),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.tertiary.withOpacity(0.06),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          // Main Content
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),
                  // Animated Floating Logo
                  AnimatedBuilder(
                    animation: _logoTranslation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _logoTranslation.value),
                        child: child,
                      );
                    },
                    child: GlassCard(
                      borderRadius: 30.0,
                      hasGlow: true,
                      bgOpacity: 0.5,
                      borderOpacity: 0.15,
                      child: Container(
                        width: 120,
                        height: 120,
                        alignment: Alignment.center,
                        child: Text(
                          'L',
                          style: TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primary,
                            shadows: [
                              Shadow(color: AppTheme.primary, blurRadius: 15),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // App Name
                  Text(
                    'Ledgerly',
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 36,
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'FINANCIAL CLARITY REDEFINED',
                    style: textTheme.labelMedium?.copyWith(
                      color: AppTheme.onSurfaceVariant.withOpacity(0.5),
                    ),
                  ),
                  const Spacer(flex: 2),
                  // Loading Indicator
                  const SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 3.0,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primary,
                      ),
                      backgroundColor: Color(0x117DD3FC),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // State Logger
                  Text(
                    _states[_stateIndex].toUpperCase(),
                    style: textTheme.labelMedium?.copyWith(
                      color: AppTheme.primary.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Subtle Progress Bar
                  SizedBox(
                    width: 100,
                    height: 2,
                    child: LinearProgressIndicator(
                      value: _progress,
                      color: AppTheme.primary.withOpacity(0.6),
                      backgroundColor: AppTheme.surfaceContainer,
                    ),
                  ),
                  const Spacer(flex: 3),
                  // Footer security tag
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.security,
                        size: 14,
                        color: AppTheme.onSurfaceVariant.withOpacity(0.3),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'ENCRYPTED',
                        style: textTheme.labelMedium?.copyWith(
                          fontSize: 9,
                          color: AppTheme.onSurfaceVariant.withOpacity(0.3),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Icon(
                        Icons.cloud_done,
                        size: 14,
                        color: AppTheme.onSurfaceVariant.withOpacity(0.3),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'SYNCED',
                        style: textTheme.labelMedium?.copyWith(
                          fontSize: 9,
                          color: AppTheme.onSurfaceVariant.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
