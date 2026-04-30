import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/router.dart';
import '../../../core/theme/app_theme.dart';
import '../bloc/auth_bloc.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _passwordTouched = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (!_allRulesMet(v)) return 'Password does not meet all requirements';
    return null;
  }

  bool _allRulesMet(String v) =>
      v.length >= 6 &&
      v.contains(RegExp(r'[A-Z]')) &&
      v.contains(RegExp(r'[a-z]')) &&
      v.contains(RegExp(r'[0-9]')) &&
      v.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=\[\]\\;~/`]'));

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final regex = RegExp(r'^[\w.+\-]+@[\w\-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(v.trim())) return 'Enter a valid email address';
    return null;
  }

  String? _validatePhone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Phone number is required';
    if (v.replaceAll(RegExp(r'\D'), '').length < 10) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  void _submit() {
    setState(() => _passwordTouched = true);
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(AuthRegister(
          displayName: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) context.go(KlyraRoutes.home);
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.message),
                backgroundColor: KlyraColors.error),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(KlyraSpacing.pageHorizontal),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: KlyraSpacing.lg),
                  Text('Create account', style: KlyraTextStyles.displaySmall),
                  const SizedBox(height: KlyraSpacing.sm),
                  Text('Join Klyra in minutes',
                      style: KlyraTextStyles.bodyMedium),
                  const SizedBox(height: KlyraSpacing.xl),

                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Enter your full name'
                        : null,
                  ),
                  const SizedBox(height: KlyraSpacing.md),

                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      hintText: '+1 234 567 8900',
                    ),
                    validator: _validatePhone,
                  ),
                  const SizedBox(height: KlyraSpacing.md),

                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: KlyraSpacing.md),

                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscure,
                    textInputAction: TextInputAction.done,
                    onChanged: (_) => setState(() => _passwordTouched = true),
                    onFieldSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(_obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: _validatePassword,
                  ),

                  // Live password rules — shown as soon as user starts typing
                  if (_passwordTouched) ...[
                    const SizedBox(height: KlyraSpacing.sm),
                    _PasswordRules(password: _passwordController.text),
                  ],

                  const SizedBox(height: KlyraSpacing.xl),

                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) => ElevatedButton(
                      onPressed: state is AuthLoading ? null : _submit,
                      child: state is AuthLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: KlyraColors.white,
                              ),
                            )
                          : const Text('Create Account'),
                    ),
                  ),
                  const SizedBox(height: KlyraSpacing.md),
                  Center(
                    child: TextButton(
                      onPressed: () => context.go(KlyraRoutes.login),
                      child: Text(
                        'Already have an account? Sign in',
                        style: KlyraTextStyles.labelLarge
                            .copyWith(color: KlyraColors.teal),
                      ),
                    ),
                  ),
                  const SizedBox(height: KlyraSpacing.lg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Password rules checklist ───────────────────────────────────
class _PasswordRules extends StatelessWidget {
  const _PasswordRules({required this.password});
  final String password;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(KlyraSpacing.md),
      decoration: BoxDecoration(
        color: KlyraColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: KlyraColors.navy.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          _Rule(label: 'At least 6 characters', met: password.length >= 6),
          _Rule(
              label: 'One uppercase letter',
              met: password.contains(RegExp(r'[A-Z]'))),
          _Rule(
              label: 'One lowercase letter',
              met: password.contains(RegExp(r'[a-z]'))),
          _Rule(label: 'One number', met: password.contains(RegExp(r'[0-9]'))),
          _Rule(
              label: 'One symbol (e.g. !@#\$)',
              met: password
                  .contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=\[\]\\;~/`]'))),
        ],
      ),
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule({required this.label, required this.met});
  final String label;
  final bool met;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: met ? KlyraColors.teal : KlyraColors.muted,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: KlyraTextStyles.bodySmall.copyWith(
              color: met ? KlyraColors.teal : KlyraColors.muted,
              fontWeight: met ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
