import 'package:flutter/material.dart';
import '../../../services/settings_repository.dart';
import 'profile_ui.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  List<PaymentMethodModel> _methods = [];
  bool _loading = true;
  String? _busyId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final methods = await SettingsRepository.fetchPaymentMethods().timeout(
        const Duration(seconds: 8),
      );
      if (!mounted) return;
      setState(() => _methods = methods);
    } catch (e) {
      debugPrint('Failed to load payment methods: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _remove(PaymentMethodModel m) async {
    setState(() => _busyId = m.id);
    final ok = await SettingsRepository.deletePaymentMethod(m.id);
    if (!mounted) return;
    setState(() => _busyId = null);
    if (ok) {
      setState(() => _methods.removeWhere((e) => e.id == m.id));
      ProfileUi.snack(context, 'Carte supprimée');
    } else {
      ProfileUi.snack(
        context,
        'Échec de la suppression, réessayez',
        error: true,
      );
    }
  }

  void _addCard() {
    final numberCtrl = TextEditingController();
    final expiryCtrl = TextEditingController();
    final cvvCtrl = TextEditingController();
    String? error;
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            16,
            24,
            MediaQuery.of(ctx).viewInsets.bottom +
                MediaQuery.of(ctx).padding.bottom +
                24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: ProfileUi.sheetHandle()),
              const SizedBox(height: 20),
              const Text(
                'Ajouter une carte',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              _field(numberCtrl, 'Numéro de carte', TextInputType.number, 19),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _field(
                      expiryCtrl,
                      'MM/AA',
                      TextInputType.datetime,
                      5,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _field(
                      cvvCtrl,
                      'CVV',
                      TextInputType.number,
                      3,
                      obscure: true,
                    ),
                  ),
                ],
              ),
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(
                  error!,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ],
              const SizedBox(height: 20),
              ProfileUi.blackButton(
                label: saving ? null : 'Enregistrer la carte',
                loading: saving,
                onTap: () async {
                  final digits = numberCtrl.text.replaceAll(' ', '');
                  if (digits.length < 12 ||
                      expiryCtrl.text.length != 5 ||
                      cvvCtrl.text.length < 3) {
                    setSheet(() => error = 'Vérifiez les informations saisies');
                    return;
                  }
                  setSheet(() {
                    error = null;
                    saving = true;
                  });
                  try {
                    final created = await SettingsRepository.addPaymentMethod(
                      cardNumber: digits,
                      expiry: expiryCtrl.text,
                      cvv: cvvCtrl.text,
                    );
                    if (created == null) throw Exception('empty response');
                    setState(() => _methods = [..._methods, created]);
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (mounted) ProfileUi.snack(context, 'Carte ajoutée');
                  } catch (e) {
                    setSheet(() {
                      saving = false;
                      error = "Échec de l'ajout, vérifiez votre connexion";
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    TextInputType type,
    int maxLen, {
    bool obscure = false,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      obscureText: obscure,
      maxLength: maxLen,
      style: const TextStyle(fontSize: 15, color: Colors.black),
      decoration: InputDecoration(
        counterText: '',
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 13,
          color: Colors.black.withOpacity(.45),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black.withOpacity(.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProfileUi.scaffold(
      title: 'Moyens de paiement',
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _methods.isEmpty
                      ? Center(
                          child: Text(
                            'Aucun moyen de paiement enregistré',
                            style: TextStyle(
                              color: Colors.black.withOpacity(.4),
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          color: Colors.black,
                          onRefresh: _load,
                          child: ListView(
                            children: _methods
                                .map(
                                  (m) => ProfileUi.row(
                                    label: '•••• •••• •••• ${m.last4}',
                                    subtitle: 'Expire ${m.expiry}',
                                    icon: Icons.credit_card,
                                    trailing: _busyId == m.id
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.black45,
                                            ),
                                          )
                                        : GestureDetector(
                                            onTap: () => _remove(m),
                                            child: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.red,
                                              size: 20,
                                            ),
                                          ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: ProfileUi.blackButton(
                    label: 'Ajouter une carte',
                    onTap: _addCard,
                  ),
                ),
              ],
            ),
    );
  }
}
