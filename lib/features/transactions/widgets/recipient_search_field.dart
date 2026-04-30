import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/models.dart';
import '../../../core/theme/app_theme.dart';
import '../repository/transaction_repository.dart';

class RecipientSearchField extends StatefulWidget {
  const RecipientSearchField({super.key, required this.onSelected});
  final ValueChanged<KlyraUser> onSelected;

  @override
  State<RecipientSearchField> createState() => _RecipientSearchFieldState();
}

class _RecipientSearchFieldState extends State<RecipientSearchField> {
  final _controller = TextEditingController();
  List<KlyraUser> _results = [];
  bool _loading = false;
  Timer? _debounce;

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      if (!mounted) return;
      setState(() => _loading = true);
      try {
        final results = await context.read<TransactionRepository>().searchRecipients(query.trim());
        if (mounted) setState(() { _results = results; _loading = false; });
      } catch (_) {
        if (mounted) setState(() => _loading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _controller,
          onChanged: _onChanged,
          decoration: InputDecoration(
            hintText: 'Name, phone or account number',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _loading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
          ),
        ),
        if (_results.isNotEmpty) ...[
          const SizedBox(height: KlyraSpacing.sm),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _results.length,
            itemBuilder: (context, i) {
              final user = _results[i];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: KlyraColors.tealLight,
                  child: Text(
                    user.firstName[0].toUpperCase(),
                    style: KlyraTextStyles.labelLarge.copyWith(color: KlyraColors.teal),
                  ),
                ),
                title: Text(user.displayName, style: KlyraTextStyles.labelLarge),
                subtitle: Text(user.phone, style: KlyraTextStyles.bodySmall),
                onTap: () {
                  widget.onSelected(user);
                  _controller.clear();
                  setState(() => _results = []);
                },
              );
            },
          ),
        ],
      ],
    );
  }
}
