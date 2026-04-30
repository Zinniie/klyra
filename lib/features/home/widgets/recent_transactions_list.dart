import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/models.dart';
import '../../../core/theme/app_theme.dart';

class TransactionListTile extends StatelessWidget {
  const TransactionListTile({
    super.key,
    required this.transaction,
    required this.onTap,
  });

  final KlyraTransaction transaction;
  final VoidCallback     onTap;

  @override
  Widget build(BuildContext context) {
    final isCredit  = transaction.isCredit;
    final formatter = NumberFormat.currency(locale: 'en_CA', symbol: r'$', decimalDigits: 2);

    final (IconData icon, Color iconColor, Color iconBg) = switch (transaction.type) {
      TransactionType.send        => (Icons.arrow_upward,   KlyraColors.coral, KlyraColors.coralLight),
      TransactionType.receive     => (Icons.arrow_downward, KlyraColors.teal,  KlyraColors.tealLight),
      TransactionType.topUp       => (Icons.add,            KlyraColors.teal,  KlyraColors.tealLight),
      TransactionType.withdrawal  => (Icons.arrow_upward,   KlyraColors.coral, KlyraColors.coralLight),
      TransactionType.billPayment => (Icons.receipt_outlined, KlyraColors.amber, KlyraColors.amberLight),
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(KlyraSpacing.md),
        decoration: BoxDecoration(
          color: KlyraColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: KlyraColors.navy.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description,
                    style: KlyraTextStyles.labelLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    DateFormat('MMM d, h:mm a').format(transaction.timestamp),
                    style: KlyraTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            Text(
              '${isCredit ? '+' : '-'}${formatter.format(transaction.amount)}',
              style: KlyraTextStyles.headlineSmall.copyWith(
                color: isCredit ? KlyraColors.teal : KlyraColors.coral,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
