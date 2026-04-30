import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/models.dart';
import '../../../core/router/router.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../bloc/card_bloc.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<CardBloc>().add(CardLoad(userId: authState.user.uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KlyraColors.surface,
      appBar: AppBar(
        title: const Text('My Cards'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push(KlyraRoutes.addCard),
          ),
        ],
      ),
      body: BlocBuilder<CardBloc, CardState>(
        builder: (context, state) {
          if (state is CardLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CardLoaded) {
            if (state.cards.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.credit_card_outlined, size: 56, color: KlyraColors.muted),
                    const SizedBox(height: KlyraSpacing.md),
                    Text('No cards added yet', style: KlyraTextStyles.headlineSmall),
                    const SizedBox(height: KlyraSpacing.sm),
                    ElevatedButton(
                      onPressed: () => context.push(KlyraRoutes.addCard),
                      child: const Text('Add a Card'),
                    ),
                  ],
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(KlyraSpacing.pageHorizontal),
              itemCount: state.cards.length,
              separatorBuilder: (_, __) => const SizedBox(height: KlyraSpacing.sm),
              itemBuilder: (context, i) => _CardTile(card: state.cards[i]),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _CardTile extends StatelessWidget {
  const _CardTile({required this.card});
  final KlyraCard card;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(KlyraSpacing.cardPadding),
      decoration: BoxDecoration(
        color: KlyraColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KlyraColors.navy.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          const Icon(Icons.credit_card, size: 32, color: KlyraColors.navy),
          const SizedBox(width: KlyraSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(card.displayLabel, style: KlyraTextStyles.labelLarge),
                Text(card.expiryLabel,  style: KlyraTextStyles.bodySmall),
              ],
            ),
          ),
          if (card.isDefault)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: KlyraColors.tealLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Default', style: KlyraTextStyles.labelSmall.copyWith(color: KlyraColors.teal)),
            ),
        ],
      ),
    );
  }
}
