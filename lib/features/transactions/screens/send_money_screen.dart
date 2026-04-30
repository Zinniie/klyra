import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/models/models.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../transactions/bloc/transaction_bloc.dart';
import '../widgets/amount_keyboard.dart';
import '../widgets/recipient_search_field.dart';

class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({super.key, this.prefilledRecipient});
  final KlyraUser? prefilledRecipient;

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  // Steps: 0 = recipient, 1 = amount, 2 = review, 3 = success
  int           _step            = 0;
  KlyraUser?    _recipient;
  String        _amountStr       = '0';
  double        get _amount      => double.tryParse(_amountStr) ?? 0;
  final _noteController          = TextEditingController();
  bool          _isProcessing    = false;

  @override
  void initState() {
    super.initState();
    if (widget.prefilledRecipient != null) {
      _recipient = widget.prefilledRecipient;
      _step      = 1;
    }
  }

  @override
  void dispose() { _noteController.dispose(); super.dispose(); }

  void _onAmountKey(String key) {
    setState(() {
      if (key == '⌫') {
        if (_amountStr.length > 1) {
          _amountStr = _amountStr.substring(0, _amountStr.length - 1);
        } else {
          _amountStr = '0';
        }
      } else if (key == '.') {
        if (!_amountStr.contains('.')) _amountStr += '.';
      } else {
        if (_amountStr == '0') {
          _amountStr = key;
        } else if (_amountStr.contains('.')) {
          final parts = _amountStr.split('.');
          if (parts[1].length < 2) _amountStr += key;
        } else if (_amountStr.length < 7) {
          _amountStr += key;
        }
      }
    });
  }

  Future<void> _sendMoney() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated || _recipient == null) return;

    setState(() => _isProcessing = true);

    context.read<TransactionBloc>().add(
      TransactionSendMoney(
        senderId:       authState.user.uid,
        senderName:     authState.user.displayName,
        recipientId:    _recipient!.uid,
        recipientName:  _recipient!.displayName,
        recipientPhone: _recipient!.phone,
        amount:         _amount,
        note:           _noteController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state is TransactionSuccess) {
          setState(() { _isProcessing = false; _step = 3; });
        } else if (state is TransactionError) {
          setState(() => _isProcessing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: KlyraColors.error),
          );
        }
      },
      child: Scaffold(
        backgroundColor: KlyraColors.surface,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () {
              if (_step > 0 && _step < 3) {
                setState(() => _step--);
              } else {
                context.pop();
              }
            },
          ),
          title: Text(_stepTitle),
          actions: [
            if (_step < 3)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Text(
                    'Step ${_step + 1} of 3',
                    style: KlyraTextStyles.labelSmall,
                  ),
                ),
              ),
          ],
        ),
        body: AnimatedSwitcher(
          duration: KlyraConstants.animNormal,
          child: switch (_step) {
            0 => _RecipientStep(
                key: const ValueKey('recipient'),
                onSelected: (user) => setState(() { _recipient = user; _step = 1; }),
              ),
            1 => _AmountStep(
                key: const ValueKey('amount'),
                recipient:  _recipient!,
                amountStr:  _amountStr,
                onKey:      _onAmountKey,
                onContinue: () {
                  if (_amount >= KlyraConstants.minTransferAmount &&
                      _amount <= KlyraConstants.maxTransferAmount) {
                    setState(() => _step = 2);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Amount must be between \$${KlyraConstants.minTransferAmount.toStringAsFixed(0)} '
                          'and \$${KlyraConstants.maxTransferAmount.toStringAsFixed(0)}.',
                        ),
                        backgroundColor: KlyraColors.error,
                      ),
                    );
                  }
                },
              ),
            2 => _ReviewStep(
                key: const ValueKey('review'),
                recipient:       _recipient!,
                amount:          _amount,
                noteController:  _noteController,
                isProcessing:    _isProcessing,
                onConfirm:       _sendMoney,
              ),
            3 => _SuccessStep(
                key: const ValueKey('success'),
                recipient: _recipient!,
                amount:    _amount,
                onDone:    () => context.pop(),
              ),
            _ => const SizedBox.shrink(),
          },
        ),
      ),
    );
  }

  String get _stepTitle => switch (_step) {
    0 => 'Send Money',
    1 => 'Enter Amount',
    2 => 'Review Transfer',
    3 => 'Transfer Sent!',
    _ => 'Send Money',
  };
}

// ── Step 1: Recipient ──────────────────────────────────────────
class _RecipientStep extends StatelessWidget {
  const _RecipientStep({super.key, required this.onSelected});
  final ValueChanged<KlyraUser> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(KlyraSpacing.pageHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Who are you sending to?', style: KlyraTextStyles.headlineMedium),
              const SizedBox(height: KlyraSpacing.sm),
              Text('Search by name, phone, or account number', style: KlyraTextStyles.bodySmall),
              const SizedBox(height: KlyraSpacing.lg),
              RecipientSearchField(onSelected: onSelected),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Step 2: Amount ─────────────────────────────────────────────
class _AmountStep extends StatelessWidget {
  const _AmountStep({
    super.key,
    required this.recipient,
    required this.amountStr,
    required this.onKey,
    required this.onContinue,
  });
  final KlyraUser recipient;
  final String    amountStr;
  final void Function(String) onKey;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final amount    = double.tryParse(amountStr) ?? 0;
    final formatter = NumberFormat.currency(locale: 'en_CA', symbol: r'$', decimalDigits: 2);

    return Column(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Recipient chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: KlyraColors.tealLight,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: KlyraColors.teal,
                      child: Text(
                        recipient.firstName[0].toUpperCase(),
                        style: const TextStyle(color: KlyraColors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(recipient.displayName, style: KlyraTextStyles.labelLarge.copyWith(color: KlyraColors.navy)),
                  ],
                ),
              ),

              const SizedBox(height: KlyraSpacing.xl),

              // Amount display
              Text(
                formatter.format(amount),
                style: KlyraTextStyles.amountLarge.copyWith(
                  color: amount > 0 ? KlyraColors.navy : KlyraColors.muted,
                ),
              ),
              const SizedBox(height: KlyraSpacing.sm),
              Text('CAD', style: KlyraTextStyles.labelMedium),
            ],
          ),
        ),

        // Keypad
        AmountKeyboard(onKey: onKey),

        // Continue button
        Padding(
          padding: const EdgeInsets.fromLTRB(
            KlyraSpacing.pageHorizontal, 16,
            KlyraSpacing.pageHorizontal, 32,
          ),
          child: ElevatedButton(
            onPressed: amount > 0 ? onContinue : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: amount > 0 ? KlyraColors.teal : KlyraColors.muted,
            ),
            child: const Text('Continue'),
          ),
        ),
      ],
    );
  }
}

// ── Step 3: Review ─────────────────────────────────────────────
class _ReviewStep extends StatelessWidget {
  const _ReviewStep({
    super.key,
    required this.recipient,
    required this.amount,
    required this.noteController,
    required this.isProcessing,
    required this.onConfirm,
  });
  final KlyraUser         recipient;
  final double            amount;
  final TextEditingController noteController;
  final bool              isProcessing;
  final VoidCallback      onConfirm;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'en_CA', symbol: r'$', decimalDigits: 2);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(KlyraSpacing.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(KlyraSpacing.cardPadding),
            decoration: BoxDecoration(
              color: KlyraColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: KlyraColors.navy.withOpacity(0.08)),
            ),
            child: Column(
              children: [
                // To
                _ReviewRow(
                  label: 'To',
                  value: recipient.displayName,
                  sub: recipient.phone,
                ),
                const Divider(height: KlyraSpacing.xl),
                // Amount
                _ReviewRow(
                  label: 'Amount',
                  value: formatter.format(amount),
                  valueStyle: KlyraTextStyles.amountSmall,
                ),
                const Divider(height: KlyraSpacing.xl),
                // Fee
                const _ReviewRow(label: 'Transfer Fee', value: 'Free', valueColor: KlyraColors.teal),
                const Divider(height: KlyraSpacing.xl),
                // Total
                _ReviewRow(
                  label: 'Total Deducted',
                  value: formatter.format(amount),
                  valueStyle: KlyraTextStyles.headlineMedium,
                ),
              ],
            ),
          ),

          const SizedBox(height: KlyraSpacing.lg),

          // Note
          Text('Add a note (optional)', style: KlyraTextStyles.labelLarge),
          const SizedBox(height: KlyraSpacing.sm),
          TextFormField(
            controller: noteController,
            maxLength: 80,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'e.g. Rent, dinner, birthday gift...',
              counterText: '',
            ),
          ),

          const SizedBox(height: KlyraSpacing.xl),

          // Confirm
          ElevatedButton(
            onPressed: isProcessing ? null : onConfirm,
            child: isProcessing
                ? const SizedBox(
                    height: 20, width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2, color: KlyraColors.white,
                    ),
                  )
                : Text('Send ${formatter.format(amount)}'),
          ),

          const SizedBox(height: KlyraSpacing.md),

          // Security note
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 12, color: KlyraColors.muted),
              const SizedBox(width: 4),
              Text(
                'End-to-end encrypted · Instant transfer',
                style: KlyraTextStyles.labelSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({
    required this.label,
    required this.value,
    this.sub,
    this.valueStyle,
    this.valueColor,
  });
  final String  label;
  final String  value;
  final String? sub;
  final TextStyle? valueStyle;
  final Color?  valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: KlyraTextStyles.bodyMedium),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: (valueStyle ?? KlyraTextStyles.headlineSmall).copyWith(
                color: valueColor,
              ),
            ),
            if (sub != null)
              Text(sub!, style: KlyraTextStyles.bodySmall),
          ],
        ),
      ],
    );
  }
}

// ── Step 4: Success ────────────────────────────────────────────
class _SuccessStep extends StatelessWidget {
  const _SuccessStep({super.key, required this.recipient, required this.amount, required this.onDone});
  final KlyraUser recipient;
  final double    amount;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'en_CA', symbol: r'$', decimalDigits: 2);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(KlyraSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Checkmark animation
            Container(
              width: 96, height: 96,
              decoration: const BoxDecoration(
                color: KlyraColors.tealLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: KlyraColors.teal, size: 56),
            ),
            const SizedBox(height: KlyraSpacing.xl),
            Text('Transfer Successful!', style: KlyraTextStyles.displaySmall),
            const SizedBox(height: KlyraSpacing.sm),
            Text(
              '${formatter.format(amount)} sent to ${recipient.firstName}',
              style: KlyraTextStyles.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: KlyraSpacing.xxl),
            ElevatedButton(
              onPressed: onDone,
              child: const Text('Back to Home'),
            ),
            const SizedBox(height: KlyraSpacing.md),
            TextButton(
              onPressed: onDone,
              child: Text(
                'View Transaction',
                style: KlyraTextStyles.labelLarge.copyWith(color: KlyraColors.teal),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
