import 'dart:ui';
import 'package:flutter/material.dart';

class AppTheme {
  // Frozen Light theme colors
  static const Color background = Color(0xFF0A0E1A);
  static const Color surface = Color(0xFF0F1524);
  static const Color surfaceDim = Color(0xFF0F1524);
  static const Color surfaceContainer = Color(0xFF141C2E);
  static const Color surfaceContainerHigh = Color(0xFF1A2438);
  static const Color surfaceContainerHighest = Color(0xFF202C42);

  static const Color primary = Color(0xFF7DD3FC); // Ice Blue
  static const Color primaryContainer = Color(0xFF0E4D6E);
  static const Color onPrimary = Color(0xFF001F2E);
  static const Color primaryFixedDim = Color(0xFF7DD3FC);
  static const Color primaryFixed = Color(0xFFC8EAFF);

  static const Color secondary = Color(0xFF88B4CC);
  static const Color secondaryContainer = Color(0xFF1A3A4E);
  static const Color onSecondary = Color(0xFF001F2E);

  static const Color tertiary = Color(0xFFC8A0F0); // Lavender/Purple
  static const Color tertiaryContainer = Color(0xFF3D2060);

  static const Color error = Color(0xFFFF6B6B);
  static const Color errorContainer = Color(0xFF3D1414);

  static const Color onBackground = Color(0xFFE0E8F0);
  static const Color onSurface = Color(0xFFE0E8F0);
  static const Color onSurfaceVariant = Color(0xFFA0B4C4);
  static const Color outline = Color(0xFF4A6070);
  static const Color outlineVariant = Color(0xFF2A3A48);

  // Background radial and linear gradients
  static Gradient get backgroundGradient => const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0C1326), Color(0xFF070A14)],
  );

  static Gradient get primaryGradient => const LinearGradient(
    colors: [Color(0xFF7DD3FC), Color(0xFFC8A0F0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        primaryContainer: primaryContainer,
        onPrimary: onPrimary,
        secondary: secondary,
        secondaryContainer: secondaryContainer,
        onSecondary: onSecondary,
        tertiary: tertiary,
        tertiaryContainer: tertiaryContainer,
        error: error,
        errorContainer: errorContainer,
        surface: surface,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
        background: background,
        onBackground: onBackground,
        outline: outline,
        outlineVariant: outlineVariant,
      ),
      fontFamily: 'Inter',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: onSurface,
          letterSpacing: -1.0,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: onSurface,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: onSurface,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: onSurface,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: onSurfaceVariant,
        ),
        labelLarge: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: primary,
          letterSpacing: 1.0,
        ),
        labelMedium: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: onSurfaceVariant,
          letterSpacing: 1.5,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: onSurface),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: onSurface,
          letterSpacing: -0.5,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: primary,
        unselectedItemColor: onSurfaceVariant,
        elevation: 0,
      ),
    );
  }
}

// Glassmorphism Frosted Container Widget
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double borderOpacity;
  final double bgOpacity;
  final bool hasGlow;

  const GlassCard({
    Key? key,
    required this.child,
    this.padding,
    this.borderRadius = 24.0,
    this.borderOpacity = 0.1,
    this.bgOpacity = 0.6,
    this.hasGlow = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: hasGlow
            ? [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.06),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
          child: Container(
            padding: padding ?? const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surface.withOpacity(bgOpacity),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: AppTheme.primary.withOpacity(borderOpacity),
                width: 1.0,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
