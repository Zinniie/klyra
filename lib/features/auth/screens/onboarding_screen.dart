import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/router.dart';
import '../../../core/theme/app_theme.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KlyraColors.navy,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(KlyraSpacing.pageHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              const Text(
                'Your money,\nsimplified.',
                style: TextStyle(
                  fontFamily: 'Fraunces',
                  fontSize: 40,
                  fontWeight: FontWeight.w300,
                  color: KlyraColors.white,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: KlyraSpacing.md),
              Text(
                'Send, receive, and manage money, all in one place.',
                style: KlyraTextStyles.bodyLarge.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: KlyraSpacing.xl),
              ElevatedButton(
                onPressed: () => context.go(KlyraRoutes.register),
                child: const Text('Get Started'),
              ),
              const SizedBox(height: KlyraSpacing.sm),
              OutlinedButton(
                onPressed: () => context.go(KlyraRoutes.login),
                style: OutlinedButton.styleFrom(
                  foregroundColor: KlyraColors.white,
                  side: const BorderSide(color: Colors.white30),
                ),
                child: const Text('Sign In'),
              ),
              const SizedBox(height: KlyraSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
