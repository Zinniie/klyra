import 'package:flutter/material.dart';

// ── Brand Colours ──────────────────────────────────────────────
class KlyraColors {
  KlyraColors._();

  static const navy        = Color(0xFF0D1B2A);
  static const navyMid     = Color(0xFF1A2F45);
  static const teal        = Color(0xFF1D9E75);
  static const tealLight   = Color(0xFFE1F5EE);
  static const tealMid     = Color(0xFF5DCAA5);
  static const amber       = Color(0xFFBA7517);
  static const amberLight  = Color(0xFFFAEEDA);
  static const coral       = Color(0xFFD85A30);
  static const coralLight  = Color(0xFFFAECE7);
  static const slate       = Color(0xFF3C4A5C);
  static const muted       = Color(0xFF6B7A8D);
  static const surface     = Color(0xFFF7F9FB);
  static const white       = Color(0xFFFFFFFF);
  static const error       = Color(0xFFD32F2F);
  static const success     = Color(0xFF1D9E75);
  static const warning     = Color(0xFFBA7517);
}

// ── Text Styles ────────────────────────────────────────────────
class KlyraTextStyles {
  KlyraTextStyles._();

  static const _display = 'Fraunces';
  static const _body    = 'DMSans';

  static TextStyle displayLarge  = const TextStyle(fontFamily: _display, fontSize: 40, fontWeight: FontWeight.w300, letterSpacing: -0.5, color: KlyraColors.navy);
  static TextStyle displayMedium = const TextStyle(fontFamily: _display, fontSize: 32, fontWeight: FontWeight.w300, letterSpacing: -0.3, color: KlyraColors.navy);
  static TextStyle displaySmall  = const TextStyle(fontFamily: _display, fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: -0.2, color: KlyraColors.navy);

  static TextStyle headlineLarge  = const TextStyle(fontFamily: _body, fontSize: 22, fontWeight: FontWeight.w700, color: KlyraColors.navy);
  static TextStyle headlineMedium = const TextStyle(fontFamily: _body, fontSize: 18, fontWeight: FontWeight.w600, color: KlyraColors.navy);
  static TextStyle headlineSmall  = const TextStyle(fontFamily: _body, fontSize: 16, fontWeight: FontWeight.w600, color: KlyraColors.navy);

  static TextStyle bodyLarge  = const TextStyle(fontFamily: _body, fontSize: 16, fontWeight: FontWeight.w400, color: KlyraColors.slate, height: 1.6);
  static TextStyle bodyMedium = const TextStyle(fontFamily: _body, fontSize: 14, fontWeight: FontWeight.w400, color: KlyraColors.slate, height: 1.6);
  static TextStyle bodySmall  = const TextStyle(fontFamily: _body, fontSize: 12, fontWeight: FontWeight.w400, color: KlyraColors.muted);

  static TextStyle labelLarge  = const TextStyle(fontFamily: _body, fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1, color: KlyraColors.navy);
  static TextStyle labelMedium = const TextStyle(fontFamily: _body, fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.08, color: KlyraColors.muted);
  static TextStyle labelSmall  = const TextStyle(fontFamily: _body, fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.06, color: KlyraColors.muted);

  static TextStyle amountLarge  = const TextStyle(fontFamily: _display, fontSize: 48, fontWeight: FontWeight.w600, letterSpacing: -1, color: KlyraColors.navy);
  static TextStyle amountMedium = const TextStyle(fontFamily: _display, fontSize: 32, fontWeight: FontWeight.w600, letterSpacing: -0.5, color: KlyraColors.navy);
  static TextStyle amountSmall  = const TextStyle(fontFamily: _display, fontSize: 20, fontWeight: FontWeight.w600, color: KlyraColors.navy);
}

// ── Theme ──────────────────────────────────────────────────────
class KlyraTheme {
  KlyraTheme._();

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary:        KlyraColors.teal,
      onPrimary:      KlyraColors.white,
      secondary:      KlyraColors.navy,
      onSecondary:    KlyraColors.white,
      surface:        KlyraColors.surface,
      onSurface:      KlyraColors.navy,
      error:          KlyraColors.error,
    ),
    scaffoldBackgroundColor: KlyraColors.surface,
    fontFamily: 'DMSans',
    appBarTheme: const AppBarTheme(
      backgroundColor: KlyraColors.white,
      foregroundColor: KlyraColors.navy,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'DMSans', fontSize: 18,
        fontWeight: FontWeight.w600, color: KlyraColors.navy,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: KlyraColors.teal,
        foregroundColor: KlyraColors.white,
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontFamily: 'DMSans', fontSize: 16, fontWeight: FontWeight.w600,
        ),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: KlyraColors.navy,
        minimumSize: const Size(double.infinity, 54),
        side: const BorderSide(color: KlyraColors.navy, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontFamily: 'DMSans', fontSize: 16, fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: KlyraColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: KlyraColors.teal, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: KlyraColors.error),
      ),
      labelStyle: const TextStyle(color: KlyraColors.muted, fontFamily: 'DMSans'),
      hintStyle: const TextStyle(color: KlyraColors.muted, fontFamily: 'DMSans'),
    ),
    cardTheme: CardTheme(
      color: KlyraColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: KlyraColors.navy.withOpacity(0.08)),
      ),
      margin: EdgeInsets.zero,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFEDF2F7),
      thickness: 1,
      space: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: KlyraColors.white,
      selectedItemColor: KlyraColors.teal,
      unselectedItemColor: KlyraColors.muted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: TextStyle(fontFamily: 'DMSans', fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontFamily: 'DMSans', fontSize: 11),
    ),
  );
}

// ── App Constants ──────────────────────────────────────────────
class KlyraConstants {
  KlyraConstants._();

  static const appName        = 'Klyra';
  static const appTagline     = 'Your money, simplified.';
  static const supportEmail   = 'support@klyra.app';
  static const privacyUrl     = 'https://klyra.app/privacy';
  static const termsUrl       = 'https://klyra.app/terms';

  // Stripe
  static const stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: 'pk_test_REPLACE_ME',
  );

  // Firebase Collections
  static const usersCollection        = 'users';
  static const transactionsCollection = 'transactions';
  static const cardsCollection        = 'cards';
  static const notificationsCollection = 'notifications';

  // Hive Boxes
  static const sessionBox     = 'session';
  static const prefsBox       = 'prefs';
  static const cacheBox       = 'cache';

  // Durations
  static const animFast   = Duration(milliseconds: 200);
  static const animNormal = Duration(milliseconds: 350);
  static const animSlow   = Duration(milliseconds: 500);

  // Limits
  static const maxTransferAmount  = 50000.0;
  static const minTransferAmount  = 1.0;
  static const pinLength          = 6;
  static const otpLength          = 6;
  static const maxRecentTx        = 20;
}

// ── Spacing ────────────────────────────────────────────────────
class KlyraSpacing {
  KlyraSpacing._();

  static const xs   = 4.0;
  static const sm   = 8.0;
  static const md   = 16.0;
  static const lg   = 24.0;
  static const xl   = 32.0;
  static const xxl  = 48.0;
  static const xxxl = 64.0;

  static const pageHorizontal = 20.0;
  static const pageVertical   = 24.0;
  static const cardPadding    = 20.0;
  static const sectionGap     = 32.0;
}
