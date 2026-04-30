import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/router.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/bloc/auth_bloc.dart';

class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Security')),
      body: ListView(
        padding: const EdgeInsets.all(KlyraSpacing.pageHorizontal),
        children: [
          _SecurityTile(
            icon: Icons.pin_outlined,
            label: 'Change PIN',
            onTap: () => context.push('${KlyraRoutes.pinSetup}?change=true'),
          ),
          _SecurityTile(
            icon: Icons.fingerprint,
            label: 'Biometric Login',
            onTap: () => context.read<AuthBloc>().add(const AuthEnableBiometric()),
          ),
        ],
      ),
    );
  }
}

class _SecurityTile extends StatelessWidget {
  const _SecurityTile({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String   label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: KlyraColors.navy),
      title: Text(label, style: KlyraTextStyles.labelLarge),
      trailing: const Icon(Icons.chevron_right, color: KlyraColors.muted),
      onTap: onTap,
    );
  }
}
