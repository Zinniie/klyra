import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/models.dart';
import '../../../core/router/router.dart';
import '../../../core/theme/app_theme.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key, required this.user});
  final KlyraUser user;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          KlyraSpacing.pageHorizontal, 16,
          KlyraSpacing.pageHorizontal, 0,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Good ${_greeting()},', style: KlyraTextStyles.bodyMedium),
                  Text(user.firstName, style: KlyraTextStyles.headlineLarge),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: KlyraColors.navy),
              onPressed: () => context.push(KlyraRoutes.notifications),
            ),
            GestureDetector(
              onTap: () => context.push(KlyraRoutes.profile),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: KlyraColors.tealLight,
                child: Text(
                  user.firstName[0].toUpperCase(),
                  style: KlyraTextStyles.labelLarge.copyWith(color: KlyraColors.teal),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }
}
