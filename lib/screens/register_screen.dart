import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../strings.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/common.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
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
      await context.read<AppState>().register(
            _name.text.trim(),
            _email.text.trim(),
            _phone.text.trim(),
            _password.text,
          );
      // Root now shows the home screen. Remove this page from the stack.
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
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
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleIconButton(
                  icon: Icons.chevron_left,
                  onTap: () => Navigator.pop(context),
                ),
                const SizedBox(height: 20),
                const Text(S.createAccount,
                    style:
                        TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                const Text(S.createSubtitle,
                    style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 24),
                LabeledField(
                  label: S.fullName,
                  controller: _name,
                  hint: S.fullNameHint,
                  icon: Icons.person_outline,
                  validator: Validators.required,
                ),
                const SizedBox(height: 14),
                LabeledField(
                  label: S.email,
                  controller: _email,
                  hint: S.emailHint,
                  icon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                const SizedBox(height: 14),
                LabeledField(
                  label: S.phone,
                  controller: _phone,
                  hint: S.phoneHint,
                  icon: Icons.phone_iphone,
                  keyboardType: TextInputType.phone,
                  validator: Validators.phone,
                ),
                const SizedBox(height: 14),
                LabeledField(
                  label: S.password,
                  controller: _password,
                  hint: S.passwordHint,
                  icon: Icons.lock_outline,
                  obscure: true,
                  helper: S.passwordHelper,
                  validator: Validators.newPassword,
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(_error!,
                        style: const TextStyle(color: AppColors.accent)),
                  ),
                const SizedBox(height: 20),
                Wide(
                  child: FilledButton(
                    onPressed: _busy ? null : _submit,
                    child: const Text(S.createAccount),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text.rich(
                      TextSpan(
                        text: S.haveAccount,
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 13),
                        children: [
                          TextSpan(
                            text: S.logIn,
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
