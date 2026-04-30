import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/models.dart';
import '../../../core/theme/app_theme.dart';

class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({
    super.key,
    required this.transactionId,
    this.transaction,
  });

  final String             transactionId;
  final KlyraTransaction?  transaction;

  @override
  Widget build(BuildContext context) {
    final tx        = transaction;
    final formatter = NumberFormat.currency(locale: 'en_CA', symbol: r'$', decimalDigits: 2);

    if (tx == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Transaction')),
        body: const Center(child: Text('Transaction not found.')),
      );
    }

    final isCredit = tx.isCredit;

    return Scaffold(
      appBar: AppBar(title: const Text('Transaction Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(KlyraSpacing.pageHorizontal),
        child: Column(
          children: [
            const SizedBox(height: KlyraSpacing.lg),
            // Amount
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: isCredit ? KlyraColors.tealLight : KlyraColors.coralLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                color: isCredit ? KlyraColors.teal : KlyraColors.coral,
                size: 36,
              ),
            ),
            const SizedBox(height: KlyraSpacing.md),
            Text(
              '${isCredit ? '+' : '-'}${formatter.format(tx.amount)}',
              style: KlyraTextStyles.amountMedium.copyWith(
                color: isCredit ? KlyraColors.teal : KlyraColors.coral,
              ),
            ),
            const SizedBox(height: KlyraSpacing.xs),
            Text(tx.typeLabel, style: KlyraTextStyles.labelLarge),
            const SizedBox(height: KlyraSpacing.xl),

            // Detail rows
            _DetailCard(children: [
              _DetailRow(label: 'Status',      value: tx.status.name),
              _DetailRow(label: 'Date',        value: DateFormat('MMMM d, yyyy · h:mm a').format(tx.timestamp)),
              _DetailRow(label: 'Description', value: tx.description),
              if (tx.recipientName != null)
                _DetailRow(label: 'Recipient', value: tx.recipientName!),
              if (tx.senderName != null)
                _DetailRow(label: 'From', value: tx.senderName!),
              if (tx.note != null)
                _DetailRow(label: 'Note', value: tx.note!),
              _DetailRow(label: 'Reference', value: tx.id),
            ]),
          ],
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KlyraSpacing.cardPadding),
      decoration: BoxDecoration(
        color: KlyraColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: KlyraColors.navy.withOpacity(0.08)),
      ),
      child: Column(
        children: children
            .expand((w) => [w, const Divider(height: KlyraSpacing.xl)])
            .take(children.length * 2 - 1)
            .toList(),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: KlyraTextStyles.bodyMedium),
        const SizedBox(width: KlyraSpacing.md),
        Flexible(
          child: Text(
            value,
            style: KlyraTextStyles.labelLarge,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
