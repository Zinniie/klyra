import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/router.dart';
import '../../../core/theme/app_theme.dart';
import '../bloc/auth_bloc.dart';

class BiometricSetupScreen extends StatelessWidget {
  const BiometricSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthBiometricSetupDone) context.go(KlyraRoutes.home);
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: KlyraColors.error),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Enable Biometrics')),
        body: Padding(
          padding: const EdgeInsets.all(KlyraSpacing.pageHorizontal),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96, height: 96,
                decoration: const BoxDecoration(
                  color: KlyraColors.tealLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.fingerprint, color: KlyraColors.teal, size: 56),
              ),
              const SizedBox(height: KlyraSpacing.xl),
              Text('Log in with your fingerprint', style: KlyraTextStyles.headlineMedium),
              const SizedBox(height: KlyraSpacing.sm),
              Text(
                'Use your biometrics to access Klyra quickly and securely.',
                style: KlyraTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: KlyraSpacing.xxl),
              ElevatedButton(
                onPressed: () => context.read<AuthBloc>().add(const AuthEnableBiometric()),
                child: const Text('Enable Biometrics'),
              ),
              const SizedBox(height: KlyraSpacing.sm),
              TextButton(
                onPressed: () => context.go(KlyraRoutes.home),
                child: Text(
                  'Skip for now',
                  style: KlyraTextStyles.labelMedium.copyWith(color: KlyraColors.muted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
