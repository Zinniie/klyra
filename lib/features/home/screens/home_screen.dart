import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/router.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../transactions/bloc/transaction_bloc.dart';
import '../widgets/balance_card.dart';
import '../widgets/quick_actions.dart';
import '../widgets/recent_transactions_list.dart';
import '../widgets/home_app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<TransactionBloc>().add(
        TransactionLoadRecent(userId: authState.user.uid),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KlyraColors.surface,
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthAuthenticated) return const SizedBox.shrink();
          final user = authState.user;

          return RefreshIndicator(
            color: KlyraColors.teal,
            onRefresh: () async => _loadTransactions(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // ── App Bar ────────────────────────────────────
                SliverToBoxAdapter(
                  child: HomeAppBar(user: user),
                ),

                // ── Balance Card ───────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      KlyraSpacing.pageHorizontal, 8,
                      KlyraSpacing.pageHorizontal, 0,
                    ),
                    child: BalanceCard(user: user),
                  ),
                ),

                // ── Quick Actions ──────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      KlyraSpacing.pageHorizontal, KlyraSpacing.lg,
                      KlyraSpacing.pageHorizontal, 0,
                    ),
                    child: QuickActions(
                      onSend:       () => context.push(KlyraRoutes.sendMoney),
                      onTopUp:      () => context.push(KlyraRoutes.topUp),
                      onHistory:    () => context.push(KlyraRoutes.txHistory),
                      onCards:      () => context.push(KlyraRoutes.cards),
                    ),
                  ),
                ),

                // ── Recent Transactions Header ─────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      KlyraSpacing.pageHorizontal, KlyraSpacing.xl,
                      KlyraSpacing.pageHorizontal, KlyraSpacing.md,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Recent Activity', style: KlyraTextStyles.headlineSmall),
                        TextButton(
                          onPressed: () => context.push(KlyraRoutes.txHistory),
                          child: Text(
                            'See all',
                            style: KlyraTextStyles.labelMedium.copyWith(color: KlyraColors.teal),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Transactions List ──────────────────────────
                BlocBuilder<TransactionBloc, TransactionState>(
                  builder: (context, txState) {
                    if (txState is TransactionLoading) {
                      return const SliverToBoxAdapter(
                        child: _TransactionShimmer(),
                      );
                    }
                    if (txState is TransactionLoaded) {
                      final recent = txState.transactions.take(5).toList();
                      if (recent.isEmpty) {
                        return SliverToBoxAdapter(
                          child: _EmptyTransactions(),
                        );
                      }
                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) => Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: KlyraSpacing.pageHorizontal,
                              vertical: 2,
                            ),
                            child: TransactionListTile(
                              transaction: recent[i],
                              onTap: () => context.push(
                                '/transactions/${recent[i].id}',
                                extra: recent[i],
                              ),
                            ),
                          ),
                          childCount: recent.length,
                        ),
                      );
                    }
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  },
                ),

                // ── Bottom Padding ─────────────────────────────
                const SliverToBoxAdapter(
                  child: SizedBox(height: KlyraSpacing.xxxl),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Empty State ────────────────────────────────────────────────
class _EmptyTransactions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(KlyraSpacing.xl),
      child: Column(
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: KlyraColors.tealLight,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.receipt_long_outlined, color: KlyraColors.teal, size: 36),
          ),
          const SizedBox(height: KlyraSpacing.md),
          Text('No transactions yet', style: KlyraTextStyles.headlineSmall),
          const SizedBox(height: KlyraSpacing.sm),
          Text(
            'Send money or top up your wallet\nto get started.',
            style: KlyraTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Shimmer Loading ────────────────────────────────────────────
class _TransactionShimmer extends StatelessWidget {
  const _TransactionShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(4, (i) => const Padding(
        padding: EdgeInsets.symmetric(
          horizontal: KlyraSpacing.pageHorizontal,
          vertical: 4,
        ),
        child: _ShimmerTile(),
      )),
    );
  }
}

class _ShimmerTile extends StatefulWidget {
  const _ShimmerTile();
  @override State<_ShimmerTile> createState() => _ShimmerTileState();
}

class _ShimmerTileState extends State<_ShimmerTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
    _animation  = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => Container(
        height: 72, width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment(_animation.value - 1, 0),
            end:   Alignment(_animation.value, 0),
            colors: const [Color(0xFFEDF2F7), Color(0xFFF7FAFC), Color(0xFFEDF2F7)],
          ),
        ),
      ),
    );
  }
}
