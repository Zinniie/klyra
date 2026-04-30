import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/models/models.dart';

class BalanceCard extends StatefulWidget {
  const BalanceCard({super.key, required this.user});
  final KlyraUser user;

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool _balanceVisible = true;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'en_CA', symbol: r'$', decimalDigits: 2,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KlyraSpacing.cardPadding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [KlyraColors.navy, KlyraColors.navyMid],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: KlyraColors.navy.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Row ───────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Balance',
                    style: KlyraTextStyles.labelSmall.copyWith(
                      color: Colors.white.withOpacity(0.6),
                      letterSpacing: 0.08,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.user.currency,
                    style: KlyraTextStyles.labelMedium.copyWith(
                      color: KlyraColors.tealMid,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  // Klyra logo mark
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'klyra',
                      style: KlyraTextStyles.labelMedium.copyWith(
                        color: KlyraColors.tealMid,
                        letterSpacing: 0.05,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: KlyraSpacing.lg),

          // ── Balance Amount ─────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _balanceVisible
                    ? Text(
                        formatter.format(widget.user.balance),
                        style: KlyraTextStyles.amountLarge.copyWith(color: KlyraColors.white),
                      )
                    : Text(
                        '••••••',
                        style: KlyraTextStyles.amountLarge.copyWith(
                          color: KlyraColors.white,
                          letterSpacing: 8,
                        ),
                      ),
              ),
              GestureDetector(
                onTap: () => setState(() => _balanceVisible = !_balanceVisible),
                child: Icon(
                  _balanceVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: Colors.white.withOpacity(0.5),
                  size: 20,
                ),
              ),
            ],
          ),

          const SizedBox(height: KlyraSpacing.xl),

          // ── Bottom Row — Account Number ────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account',
                    style: KlyraTextStyles.labelSmall.copyWith(
                      color: Colors.white.withOpacity(0.4),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.user.accountNumber != null
                        ? _maskAccount(widget.user.accountNumber!)
                        : '—',
                    style: KlyraTextStyles.labelMedium.copyWith(
                      color: Colors.white.withOpacity(0.85),
                      letterSpacing: 1.5,
                      fontFamily: 'DM Mono',
                    ),
                  ),
                ],
              ),
              // KYC badge
              if (widget.user.kycVerified)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: KlyraColors.teal.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: KlyraColors.tealMid.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified, color: KlyraColors.tealMid, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        'Verified',
                        style: KlyraTextStyles.labelSmall.copyWith(
                          color: KlyraColors.tealMid,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _maskAccount(String account) {
    if (account.length < 8) return account;
    final last4  = account.substring(account.length - 4);
    final masked = '•' * (account.length - 4);
    return '${masked.replaceAllMapped(RegExp(r'.{1,4}'), (m) => '${m[0]} ')}$last4';
  }
}
