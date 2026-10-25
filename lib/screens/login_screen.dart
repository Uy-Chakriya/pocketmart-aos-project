import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../strings.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/common.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _remember = true;
  bool _hide = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context
          .read<AppState>()
          .login(_email.text.trim(), _password.text, _remember);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = cleanError(e);
          _busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.ink,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.shopping_bag_outlined,
                      color: Colors.white),
                ),
                const SizedBox(height: 24),
                const Text(S.welcomeBack,
                    style:
                        TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                const Text(S.loginSubtitle,
                    style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 28),
                LabeledField(
                  label: S.email,
                  controller: _email,
                  hint: S.emailHint,
                  icon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),
                LabeledField(
                  label: S.password,
                  controller: _password,
                  hint: S.passwordHint,
                  icon: Icons.lock_outline,
                  obscure: _hide,
                  validator: Validators.required,
                  suffix: IconButton(
                    icon: Icon(
                      _hide ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => setState(() => _hide = !_hide),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Checkbox(
                      value: _remember,
                      activeColor: AppColors.ink,
                      onChanged: (v) => setState(() => _remember = v ?? false),
                    ),
                    const Text(S.rememberMe, style: TextStyle(fontSize: 13)),
                  ],
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(_error!,
                        style: const TextStyle(color: AppColors.accent)),
                  ),
                const SizedBox(height: 8),
                Wide(
                  child: FilledButton(
                    onPressed: _busy ? null : _submit,
                    child: const Text(S.logIn),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    ),
                    child: const Text.rich(
                      TextSpan(
                        text: S.newToApp,
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 13),
                        children: [
                          TextSpan(
                            text: S.createAccount,
                            style: TextStyle(
                                color: AppColors.ink,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
