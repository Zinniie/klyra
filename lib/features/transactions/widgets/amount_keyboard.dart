import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class AmountKeyboard extends StatelessWidget {
  const AmountKeyboard({super.key, required this.onKey});
  final void Function(String) onKey;

  static const _rows = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['.', '0', '⌫'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _rows.map((row) => Row(
        children: row.map((key) => Expanded(
          child: GestureDetector(
            onTap: () => onKey(key),
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
