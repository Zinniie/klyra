import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/models.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../bloc/card_bloc.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey        = GlobalKey<FormState>();
  final _numberCtrl     = TextEditingController();
  final _expiryCtrl     = TextEditingController();
  final _cvvCtrl        = TextEditingController();
  final _nameCtrl       = TextEditingController();
  CardBrand _detectedBrand = CardBrand.other;
  bool _saving = false;

  @override
  void dispose() {
    _numberCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _onNumberChanged(String v) {
    final digits = v.replaceAll(' ', '');
    CardBrand brand = CardBrand.other;
    if (digits.startsWith('4')) {
      brand = CardBrand.visa;
    } else if (digits.startsWith('5')) {
      brand = CardBrand.mastercard;
    } else if (digits.startsWith('3')) {
      brand = CardBrand.amex;
    } else if (digits.startsWith('6')) {
      brand = CardBrand.discover;
    }
    if (brand != _detectedBrand) setState(() => _detectedBrand = brand);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    setState(() => _saving = true);

    final digits    = _numberCtrl.text.replaceAll(' ', '');
    final last4     = digits.substring(digits.length - 4);
    final expParts  = _expiryCtrl.text.split('/');
    final month     = int.tryParse(expParts[0]) ?? 1;
    final year      = int.tryParse(expParts.length > 1 ? '20${expParts[1]}' : '2025') ?? 2025;

    final card = KlyraCard(
      id:                    'card-${DateTime.now().millisecondsSinceEpoch}',
      brand:                 _detectedBrand,
      type:                  CardType.debit,
      last4:                 last4,
      expiryMonth:           month,
      expiryYear:            year,
      cardholderName:        _nameCtrl.text.trim(),
      isDefault:             false,
      stripePaymentMethodId: 'pm_mock_${DateTime.now().millisecondsSinceEpoch}',
    );

    context.read<CardBloc>().add(CardAdd(userId: authState.user.uid, card: card));

    // Wait for the bloc to reload, then pop with success
    await Future.delayed(const Duration(milliseconds: 900));
    if (mounted) {
      setState(() => _saving = false);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_brandLabel(_detectedBrand)} ending in $last4 added'),
          backgroundColor: KlyraColors.teal,
        ),
      );
    }
  }

  String _brandLabel(CardBrand b) {
    switch (b) {
      case CardBrand.visa:       return 'Visa';
      case CardBrand.mastercard: return 'Mastercard';
      case CardBrand.amex:       return 'Amex';
      case CardBrand.discover:   return 'Discover';
      default:                   return 'Card';
    }
  }

  IconData _brandIcon(CardBrand b) {
    switch (b) {
      case CardBrand.visa:
      case CardBrand.mastercard:
      case CardBrand.amex:
      case CardBrand.discover:
        return Icons.credit_card;
      default:
        return Icons.credit_card_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KlyraColors.surface,
      appBar: AppBar(title: const Text('Add Card')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(KlyraSpacing.pageHorizontal),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: KlyraSpacing.md),

              // Card preview
              _CardPreview(
                brand:  _detectedBrand,
                number: _numberCtrl.text,
                expiry: _expiryCtrl.text,
                name:   _nameCtrl.text,
              ),
              const SizedBox(height: KlyraSpacing.xl),

              // Card number
              TextFormField(
                controller:    _numberCtrl,
                keyboardType:  TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _CardNumberFormatter(),
                ],
                maxLength:   19,
                onChanged:   _onNumberChanged,
                decoration:  InputDecoration(
                  labelText:   'Card number',
                  counterText: '',
                  suffixIcon: Icon(
                    _brandIcon(_detectedBrand),
                    color: KlyraColors.teal,
                  ),
                ),
                validator: (v) {
                  final d = (v ?? '').replaceAll(' ', '');
                  if (d.length < 13) return 'Enter a valid card number';
                  return null;
                },
              ),
              const SizedBox(height: KlyraSpacing.md),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller:    _expiryCtrl,
                      keyboardType:  TextInputType.number,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _ExpiryFormatter(),
                      ],
                      maxLength: 5,
                      decoration: const InputDecoration(
                        labelText:   'MM/YY',
                        counterText: '',
                      ),
                      validator: (v) {
                        if (v == null || v.length < 5) return 'Invalid';
                        final parts = v.split('/');
                        final m = int.tryParse(parts[0]) ?? 0;
                        if (m < 1 || m > 12) return 'Invalid month';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: KlyraSpacing.md),
                  Expanded(
                    child: TextFormField(
                      controller:    _cvvCtrl,
                      keyboardType:  TextInputType.number,
                      obscureText:   true,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      maxLength: 4,
                      decoration: const InputDecoration(
                        labelText:   'CVV',
                        counterText: '',
                      ),
                      validator: (v) {
                        if (v == null || v.length < 3) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: KlyraSpacing.md),

              TextFormField(
                controller:        _nameCtrl,
                textCapitalization: TextCapitalization.words,
                textInputAction:   TextInputAction.done,
                onChanged:         (_) => setState(() {}),
                decoration: const InputDecoration(labelText: 'Name on card'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),

              const SizedBox(height: KlyraSpacing.xxl),

              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2, color: KlyraColors.white,
                        ),
                      )
                    : const Text('Save Card'),
              ),
              const SizedBox(height: KlyraSpacing.md),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline, size: 14, color: KlyraColors.muted),
                    const SizedBox(width: 4),
                    Text('Your card details are encrypted', style: KlyraTextStyles.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Card visual preview ────────────────────────────────────────
class _CardPreview extends StatelessWidget {
  const _CardPreview({
    required this.brand,
    required this.number,
    required this.expiry,
    required this.name,
  });

  final CardBrand brand;
  final String    number;
  final String    expiry;
  final String    name;

  String get _maskedNumber {
    final digits = number.replaceAll(' ', '');
    if (digits.isEmpty) return '•••• •••• •••• ••••';
    final padded = digits.padRight(16, '•');
    final groups = [padded.substring(0, 4), padded.substring(4, 8),
                    padded.substring(8, 12), padded.substring(12, 16)];
    return groups.join('  ');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [KlyraColors.navy, Color(0xFF1A3A5C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: KlyraColors.navy.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(KlyraSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Klyra', style: KlyraTextStyles.labelLarge.copyWith(
                color: KlyraColors.white, fontFamily: 'Fraunces',
              )),
              Icon(
                brand == CardBrand.other
                    ? Icons.credit_card_outlined
                    : Icons.credit_card,
                color: KlyraColors.white.withOpacity(0.8),
              ),
            ],
          ),
          const Spacer(),
          Text(_maskedNumber, style: KlyraTextStyles.labelLarge.copyWith(
            color: KlyraColors.white, letterSpacing: 2, fontSize: 15,
          )),
          const SizedBox(height: KlyraSpacing.sm),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CARDHOLDER', style: KlyraTextStyles.bodySmall.copyWith(
                    color: KlyraColors.white.withOpacity(0.6), fontSize: 9,
                  )),
                  Text(
                    name.isEmpty ? 'FULL NAME' : name.toUpperCase(),
                    style: KlyraTextStyles.labelMedium.copyWith(color: KlyraColors.white),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('EXPIRES', style: KlyraTextStyles.bodySmall.copyWith(
                    color: KlyraColors.white.withOpacity(0.6), fontSize: 9,
                  )),
                  Text(
                    expiry.isEmpty ? 'MM/YY' : expiry,
                    style: KlyraTextStyles.labelMedium.copyWith(color: KlyraColors.white),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Input formatters ───────────────────────────────────────────
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue next) {
    final digits = next.text.replaceAll(' ', '');
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buf.write(' ');
      buf.write(digits[i]);
    }
    final str = buf.toString();
    return next.copyWith(
      text: str,
      selection: TextSelection.collapsed(offset: str.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue next) {
    var digits = next.text.replaceAll('/', '');
    if (digits.length > 4) digits = digits.substring(0, 4);
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 2) buf.write('/');
      buf.write(digits[i]);
    }
    final str = buf.toString();
    return next.copyWith(
      text: str,
      selection: TextSelection.collapsed(offset: str.length),
    );
  }
}
