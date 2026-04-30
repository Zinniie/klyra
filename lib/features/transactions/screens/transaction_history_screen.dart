import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../bloc/transaction_bloc.dart';
import '../../home/widgets/recent_transactions_list.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  @override
  void initState() {
    super.initState();
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
      appBar: AppBar(title: const Text('Transaction History')),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TransactionLoaded) {
            if (state.transactions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.receipt_long_outlined, size: 56, color: KlyraColors.muted),
                    const SizedBox(height: KlyraSpacing.md),
                    Text('No transactions yet', style: KlyraTextStyles.headlineSmall),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              color: KlyraColors.teal,
              onRefresh: () async {
                final authState = context.read<AuthBloc>().state;
                if (authState is AuthAuthenticated) {
                  context.read<TransactionBloc>().add(
                    TransactionLoadRecent(userId: authState.user.uid),
                  );
                }
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(KlyraSpacing.pageHorizontal),
                itemCount: state.transactions.length,
                separatorBuilder: (_, __) => const SizedBox(height: KlyraSpacing.sm),
                itemBuilder: (context, i) {
                  final tx = state.transactions[i];
                  return TransactionListTile(
                    transaction: tx,
                    onTap: () => context.push(
                      '/transactions/${tx.id}',
                      extra: tx,
                    ),
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
