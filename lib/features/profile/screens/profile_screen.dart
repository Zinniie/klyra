import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/router.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/bloc/auth_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KlyraColors.surface,
      appBar: AppBar(title: const Text('Profile')),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) return const SizedBox.shrink();
          final user = state.user;

          return ListView(
            padding: const EdgeInsets.all(KlyraSpacing.pageHorizontal),
            children: [
              const SizedBox(height: KlyraSpacing.lg),
              // Avatar
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: KlyraColors.tealLight,
                  child: Text(
                    user.firstName[0].toUpperCase(),
                    style: KlyraTextStyles.displaySmall.copyWith(color: KlyraColors.teal),
                  ),
                ),
              ),
              const SizedBox(height: KlyraSpacing.md),
              Center(child: Text(user.displayName, style: KlyraTextStyles.headlineMedium)),
              Center(child: Text(user.email,       style: KlyraTextStyles.bodyMedium)),
              const SizedBox(height: KlyraSpacing.xl),

              // Menu items
              _ProfileTile(
                icon: Icons.security_outlined,
                label: 'Security Settings',
                onTap: () => context.push(KlyraRoutes.security),
              ),
              _ProfileTile(
                icon: Icons.notifications_outlined,
                label: 'Notifications',
                onTap: () => context.push(KlyraRoutes.notifications),
              ),
              const Divider(height: KlyraSpacing.xl),
              _ProfileTile(
                icon: Icons.logout,
                label: 'Sign Out',
                color: KlyraColors.error,
                onTap: () => context.read<AuthBloc>().add(const AuthSignOut()),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String   label;
  final VoidCallback onTap;
  final Color?   color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? KlyraColors.navy;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: c),
      title: Text(label, style: KlyraTextStyles.labelLarge.copyWith(color: c)),
      trailing: color == null
          ? const Icon(Icons.chevron_right, color: KlyraColors.muted)
          : null,
      onTap: onTap,
    );
  }
}
