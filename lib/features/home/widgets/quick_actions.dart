import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({
    super.key,
    required this.onSend,
    required this.onTopUp,
    required this.onHistory,
    required this.onCards,
  });

  final VoidCallback onSend;
  final VoidCallback onTopUp;
  final VoidCallback onHistory;
  final VoidCallback onCards;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _ActionButton(icon: Icons.send_outlined,        label: 'Send',    onTap: onSend),
        _ActionButton(icon: Icons.add_circle_outline,   label: 'Top Up',  onTap: onTopUp),
        _ActionButton(icon: Icons.history,              label: 'History', onTap: onHistory),
        _ActionButton(icon: Icons.credit_card_outlined, label: 'Cards',   onTap: onCards),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String   label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: KlyraColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: KlyraColors.navy.withOpacity(0.08)),
            ),
            child: Icon(icon, color: KlyraColors.teal, size: 24),
          ),
          const SizedBox(height: 6),
          Text(label, style: KlyraTextStyles.labelSmall),
        ],
      ),
    );
  }
}
