import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/amount_keyboard.dart';

class TopUpScreen extends StatefulWidget {
  const TopUpScreen({super.key});

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  String _amountStr = '0';
  bool   _loading   = false;

  double get _amount => double.tryParse(_amountStr) ?? 0;

  void _onKey(String key) {
    setState(() {
      if (key == '⌫') {
        _amountStr = _amountStr.length > 1
            ? _amountStr.substring(0, _amountStr.length - 1)
            : '0';
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

  Future<void> _topUp() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _loading = false);
    _showSuccess();
  }

  void _showSuccess() {
    final fmt = NumberFormat('#,##0.00', 'en_CA');
    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(
          KlyraSpacing.pageHorizontal, KlyraSpacing.xl,
          KlyraSpacing.pageHorizontal, KlyraSpacing.xxxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: const BoxDecoration(
                color: KlyraColors.tealLight, shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                  color: KlyraColors.teal, size: 40),
            ),
            const SizedBox(height: KlyraSpacing.lg),
            Text('Top-up successful!', style: KlyraTextStyles.headlineMedium),
            const SizedBox(height: KlyraSpacing.sm),
            Text(
              '\$${fmt.format(_amount)} CAD has been added\nto your Klyra wallet.',
              style: KlyraTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: KlyraSpacing.xl),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // close sheet
                Navigator.of(context).pop(); // leave TopUpScreen
              },
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KlyraColors.surface,
      appBar: AppBar(title: const Text('Top Up Wallet')),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Enter amount', style: KlyraTextStyles.bodyMedium),
                  const SizedBox(height: KlyraSpacing.md),
                  Text(
                    '\$$_amountStr',
                    style: KlyraTextStyles.amountLarge.copyWith(
                      color: _amount > 0
                          ? KlyraColors.navy
                          : KlyraColors.muted,
                    ),
                  ),
                  const SizedBox(height: KlyraSpacing.xs),
                  Text('CAD', style: KlyraTextStyles.labelMedium),
                ],
              ),
            ),
          ),
          AmountKeyboard(onKey: _onKey),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              KlyraSpacing.pageHorizontal, 16,
              KlyraSpacing.pageHorizontal, 32,
            ),
            child: ElevatedButton(
              onPressed:
                  _amount >= KlyraConstants.minTransferAmount && !_loading
                      ? _topUp
                      : null,
              child: _loading
                  ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2, color: KlyraColors.white,
                      ),
                    )
                  : Text('Top Up \$$_amountStr'),
            ),
          ),
        ],
      ),
    );
  }
}
