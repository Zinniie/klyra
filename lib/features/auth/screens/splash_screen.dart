import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/router.dart';
import '../../../core/theme/app_theme.dart';
import '../bloc/auth_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _timerDone = false;
  AuthState? _pendingState;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _timerDone = true);
      if (_pendingState != null) _navigate(_pendingState!);
    });
  }

  void _navigate(AuthState state) {
    if (state is AuthAuthenticated) {
      context.go(KlyraRoutes.home);
    } else if (state is AuthUnauthenticated || state is AuthError) {
      context.go(KlyraRoutes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated ||
            state is AuthUnauthenticated ||
            state is AuthError) {
          if (_timerDone) {
            _navigate(state);
          } else {
            _pendingState = state;
          }
        }
      },
      child: const Scaffold(
        backgroundColor: KlyraColors.navy,
        body: Center(
          child: Text(
            KlyraConstants.appName,
            style: TextStyle(
              fontFamily: 'Fraunces',
              fontSize: 40,
              fontWeight: FontWeight.w300,
              color: KlyraColors.white,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}
