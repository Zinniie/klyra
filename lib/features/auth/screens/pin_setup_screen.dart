import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/router.dart';
import '../../../core/theme/app_theme.dart';
import '../bloc/auth_bloc.dart';

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key, this.isChangingPin = false});
  final bool isChangingPin;

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  String _pin        = '';
  String _confirmPin = '';
  bool   _confirming = false;
  String? _error;

  void _onKey(String key) {
    setState(() {
      _error = null;
      final current = _confirming ? _confirmPin : _pin;
      if (key == '⌫') {
        final updated = current.isEmpty ? current : current.substring(0, current.length - 1);
        if (_confirming) { _confirmPin = updated; } else { _pin = updated; }
      } else if (current.length < KlyraConstants.pinLength) {
        final updated = current + key;
        if (_confirming) {
          _confirmPin = updated;
          if (_confirmPin.length == KlyraConstants.pinLength) _submitPin();
        } else {
          _pin = updated;
          if (_pin.length == KlyraConstants.pinLength) {
            setState(() => _confirming = true);
          }
        }
      }
    });
  }

  void _submitPin() {
    if (_pin != _confirmPin) {
      setState(() {
        _error      = 'PINs do not match. Try again.';
        _confirming = false;
        _pin        = '';
        _confirmPin = '';
      });
      return;
    }
    context.read<AuthBloc>().add(AuthSetupPin(pin: _pin));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthPinSetupDone) context.go(KlyraRoutes.home);
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: KlyraColors.error),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(widget.isChangingPin ? 'Change PIN' : 'Set Up PIN')),
        body: Column(
          children: [
            const SizedBox(height: KlyraSpacing.xxl),
            Text(
              _confirming ? 'Confirm your PIN' : 'Create a 6-digit PIN',
              style: KlyraTextStyles.headlineMedium,
            ),
            const SizedBox(height: KlyraSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(KlyraConstants.pinLength, (i) {
                final entered = (_confirming ? _confirmPin : _pin).length > i;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Container(
                    width: 16, height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: entered ? KlyraColors.navy : Colors.transparent,
                      border: Border.all(color: KlyraColors.navy, width: 2),
                    ),
                  ),
                );
              }),
            ),
            if (_error != null) ...[
              const SizedBox(height: KlyraSpacing.md),
              Text(_error!, style: KlyraTextStyles.bodySmall.copyWith(color: KlyraColors.error)),
            ],
            const Spacer(),
            _Numpad(onKey: _onKey),
            const SizedBox(height: KlyraSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _Numpad extends StatelessWidget {
  const _Numpad({required this.onKey});
  final void Function(String) onKey;

  static const _rows = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['', '0', '⌫'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _rows.map((row) => Row(
        children: row.map((key) => Expanded(
          child: GestureDetector(
            onTap: key.isEmpty ? null : () => onKey(key),
            child: SizedBox(
              height: 64,
              child: Center(
                child: key == '⌫'
                    ? const Icon(Icons.backspace_outlined, color: KlyraColors.navy, size: 20)
                    : Text(key, style: KlyraTextStyles.headlineMedium),
              ),
            ),
          ),
        )).toList(),
      )).toList(),
    );
  }
}
