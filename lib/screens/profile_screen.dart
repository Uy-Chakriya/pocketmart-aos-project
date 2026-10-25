import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../strings.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/common.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  bool _editing = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  void _startEdit() {
    final u = context.read<AppState>().user!;
    _name.text = u.name;
    _phone.text = u.phone;
    _address.text = u.address;
    setState(() => _editing = true);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await context.read<AppState>().updateProfile(
            _name.text.trim(),
            _phone.text.trim(),
            _address.text.trim(),
          );
      if (!mounted) return;
      setState(() => _editing = false);
      showMessage(context, S.profileSaved);
    } catch (e) {
      if (mounted) showMessage(context, cleanError(e));
    }
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
                Text(value.isEmpty ? '-' : value,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final u = app.user!;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(S.profile,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.sand,
                    shape: BoxShape.circle,
                  ),
                  child: Text(u.initials,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(u.name,
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w700)),
                      Text(u.email,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: cardDecoration(),
              child: _editing
                  ? Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          LabeledField(
                            label: S.name,
                            controller: _name,
                            hint: S.fullNameHint,
                            icon: Icons.person_outline,
                            validator: Validators.required,
                          ),
                          const SizedBox(height: 12),
                          LabeledField(
                            label: S.phone,
                            controller: _phone,
                            hint: S.phoneHint,
                            icon: Icons.phone_iphone,
                            keyboardType: TextInputType.phone,
                            validator: Validators.phone,
                          ),
                          const SizedBox(height: 12),
                          LabeledField(
                            label: S.address,
                            controller: _address,
                            hint: S.addressHint,
                            icon: Icons.location_on_outlined,
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        _row(Icons.person_outline, S.name, u.name),
                        const Divider(height: 1),
                        _row(Icons.phone_iphone, S.phone, u.phone),
                        const Divider(height: 1),
                        _row(Icons.location_on_outlined, S.address, u.address),
                      ],
                    ),
            ),
            const SizedBox(height: 16),
            Wide(
              child: _editing
                  ? FilledButton(
                      onPressed: _save, child: const Text(S.saveChanges))
                  : FilledButton.icon(
                      onPressed: _startEdit,
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text(S.editProfile),
                    ),
            ),
            const SizedBox(height: 10),
            Wide(
              child: OutlinedButton.icon(
                onPressed: () => app.logout(),
                icon: const Icon(Icons.logout, size: 18, color: AppColors.accent),
                label: const Text(S.logOut,
                    style: TextStyle(color: AppColors.accent)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
