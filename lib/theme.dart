import 'package:flutter/material.dart';

import 'models/player.dart';

/// Palette sombre « nuit de bluff » utilisée par toute l'application.
abstract final class AppColors {
  static const background = Color(0xFF120E23);
  static const surface = Color(0xFF1E1838);
  static const surfaceHigh = Color(0xFF2A2150);
  static const primary = Color(0xFF9D7BFF);
  static const civilian = Color(0xFF4CC9A4);
  static const undercover = Color(0xFFFF7A6B);
  static const mrWhite = Color(0xFFEDEDF5);
  static const muted = Color(0xFF9A93BD);
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.dark,
  ).copyWith(
    surface: AppColors.background,
    primary: AppColors.primary,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        foregroundColor: AppColors.mrWhite,
        side: const BorderSide(color: AppColors.surfaceHigh, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    ),
  );
}

/// Couleur associée à chaque rôle, pour les révélations.
Color roleColor(Role role) => switch (role) {
      Role.civilian => AppColors.civilian,
      Role.undercover => AppColors.undercover,
      Role.mrWhite => AppColors.mrWhite,
    };

/// Fond dégradé commun à tous les écrans.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1B1240), AppColors.background],
        ),
      ),
      child: child,
    );
  }
}
