import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/pin_setup_screen.dart';
import '../../features/auth/screens/biometric_setup_screen.dart';
import '../../features/home/screens/main_shell.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/transactions/screens/transaction_detail_screen.dart';
import '../../features/transactions/screens/send_money_screen.dart';
import '../../features/transactions/screens/top_up_screen.dart';
import '../../features/transactions/screens/transaction_history_screen.dart';
import '../../features/cards/screens/cards_screen.dart';
import '../../features/cards/screens/add_card_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/security_settings_screen.dart';
import '../../features/profile/screens/notifications_screen.dart';
import '../../core/models/models.dart';

// ── Route Names ────────────────────────────────────────────────
class KlyraRoutes {
  KlyraRoutes._();

  static const splash          = '/';
  static const onboarding      = '/onboarding';
  static const login           = '/login';
  static const register        = '/register';
  static const pinSetup        = '/pin-setup';
  static const biometricSetup  = '/biometric-setup';
  static const home            = '/home';
  static const sendMoney       = '/send';
  static const topUp           = '/top-up';
  static const txHistory       = '/transactions';
  static const txDetail        = '/transactions/:id';
  static const cards           = '/cards';
  static const addCard         = '/cards/add';
  static const profile         = '/profile';
  static const security        = '/profile/security';
  static const notifications   = '/notifications';
}

// ── Router Refresh Listenable ──────────────────────────────────
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

// ── Router Factory ─────────────────────────────────────────────
GoRouter createRouter(AuthBloc authBloc, ChangeNotifier refreshListenable) {
  return GoRouter(
    initialLocation: KlyraRoutes.splash,
    debugLogDiagnostics: true,
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final authState = authBloc.state;
      final isAuth    = authState is AuthAuthenticated;
      final isLoading = authState is AuthLoading || authState is AuthInitial;

      final onAuthPage = state.matchedLocation == KlyraRoutes.login ||
                         state.matchedLocation == KlyraRoutes.register ||
                         state.matchedLocation == KlyraRoutes.onboarding ||
                         state.matchedLocation == KlyraRoutes.splash;

      if (isLoading && !onAuthPage) return KlyraRoutes.splash;
      if (!isAuth && !isLoading && !onAuthPage) return KlyraRoutes.login;
      if (isAuth && onAuthPage)   return KlyraRoutes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: KlyraRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: KlyraRoutes.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: KlyraRoutes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: KlyraRoutes.register,
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: KlyraRoutes.pinSetup,
        builder: (_, state) {
          final isChange = state.uri.queryParameters['change'] == 'true';
          return PinSetupScreen(isChangingPin: isChange);
        },
      ),
      GoRoute(
        path: KlyraRoutes.biometricSetup,
        builder: (_, __) => const BiometricSetupScreen(),
      ),

      // ── Shell (bottom nav) ─────────────────────────────────
      ShellRoute(
        builder: (_, __, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: KlyraRoutes.home,
            builder: (_, __) => const HomeScreen(),
          ),
          GoRoute(
            path: KlyraRoutes.txHistory,
            builder: (_, __) => const TransactionHistoryScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, state) {
                  final tx = state.extra as KlyraTransaction?;
                  final id = state.pathParameters['id']!;
                  return TransactionDetailScreen(transactionId: id, transaction: tx);
                },
              ),
            ],
          ),
          GoRoute(
            path: KlyraRoutes.cards,
            builder: (_, __) => const CardsScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (_, __) => const AddCardScreen(),
              ),
            ],
          ),
          GoRoute(
            path: KlyraRoutes.profile,
            builder: (_, __) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'security',
                builder: (_, __) => const SecuritySettingsScreen(),
              ),
            ],
          ),
          GoRoute(
            path: KlyraRoutes.notifications,
            builder: (_, __) => const NotificationsScreen(),
          ),
        ],
      ),

      // ── Modals / Full-screen flows ─────────────────────────
      GoRoute(
        path: KlyraRoutes.sendMoney,
        builder: (_, state) {
          final recipient = state.extra as KlyraUser?;
          return SendMoneyScreen(prefilledRecipient: recipient);
        },
      ),
      GoRoute(
        path: KlyraRoutes.topUp,
        builder: (_, __) => const TopUpScreen(),
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
  );
}
