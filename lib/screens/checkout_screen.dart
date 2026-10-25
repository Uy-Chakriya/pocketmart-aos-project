import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../strings.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/common.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _address;
  late final TextEditingController _phone;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final u = context.read<AppState>().user!;
    _address = TextEditingController(text: u.address);
    _phone = TextEditingController(text: u.phone);
  }

  @override
  void dispose() {
    _address.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _place() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      final order = await context
          .read<AppState>()
          .placeOrder(_address.text.trim(), _phone.text.trim());
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => OrderSuccessScreen(order: order)),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        showMessage(context, cleanError(e));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  CircleIconButton(
                    icon: Icons.chevron_left,
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 12),
                  const Text(S.checkout,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(S.deliveryDetails,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      LabeledField(
                        label: S.address,
                        controller: _address,
                        hint: S.addressHint,
                        icon: Icons.location_on_outlined,
                        validator: Validators.required,
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
                      const SizedBox(height: 24),
                      const Text(S.paymentMethod,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.ink, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceMuted,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.payments_outlined,
                                  size: 20),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(S.cashOnDelivery,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  Text(S.cashOnDeliverySub,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                            const Icon(Icons.radio_button_checked,
                                color: AppColors.ink),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(S.orderSummary,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      SummaryRows(
                        subtotal: app.subtotal,
                        fee: AppState.deliveryFee,
                        total: app.total,
                        boxed: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Wide(
                child: FilledButton(
                  onPressed: _busy || app.cart.isEmpty ? null : _place,
                  child: Text(S.placeOrder(money(app.total))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
