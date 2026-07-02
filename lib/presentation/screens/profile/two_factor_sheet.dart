import 'package:flutter/material.dart';
import 'profile_ui.dart';

/// Shows the 2FA setup flow: fetches a real QR code + secret from the
/// backend (via [startSetup]), then verifies the 6-digit code the user
/// enters (via [verifyCode]). Returns true if 2FA was successfully enabled.
Future<bool?> show2FASetupSheet(
  BuildContext context, {
  required Future<Map<String, String>> Function() startSetup,
  required Future<bool> Function(String code) verifyCode,
}) {
  final codeCtrl = TextEditingController();
  String? error;
  bool verifying = false;
  bool loadingSetup = true;
  String? qrCodeUrl;
  String? manualSecret;
  String? setupError;

  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheet) {
        if (loadingSetup && setupError == null) {
          startSetup()
              .then((result) {
                loadingSetup = false;
                qrCodeUrl = result['qrCodeUrl'];
                manualSecret = result['manualSecret'];
                if (ctx.mounted) setSheet(() {});
              })
              .catchError((e) {
                loadingSetup = false;
                setupError = "Impossible de contacter le serveur. Réessayez.";
                if (ctx.mounted) setSheet(() {});
              });
        }

        return Padding(
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
                'Activer la double authentification',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  letterSpacing: -.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Scannez ce code avec votre application d'authentification "
                '(Google Authenticator, Authy...) puis saisissez le code à 6 '
                'chiffres généré.',
                style: TextStyle(
                  fontSize: 13.5,
                  color: Colors.black.withOpacity(.5),
                ),
              ),
              const SizedBox(height: 20),
              if (loadingSetup)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: CircularProgressIndicator(color: Colors.black),
                  ),
                )
              else if (setupError != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    setupError!,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                )
              else ...[
                Center(
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black.withOpacity(.15)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: (qrCodeUrl != null && qrCodeUrl!.isNotEmpty)
                        ? Image.network(
                            qrCodeUrl!,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.qr_code_2,
                              size: 100,
                              color: Colors.black87,
                            ),
                          )
                        : const Icon(
                            Icons.qr_code_2,
                            size: 100,
                            color: Colors.black87,
                          ),
                  ),
                ),
                if (manualSecret != null && manualSecret!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      'Code manuel : $manualSecret',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black.withOpacity(.5),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                TextField(
                  controller: codeCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    letterSpacing: 8,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '••••••',
                    errorText: error,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.black.withOpacity(.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                const SizedBox(height: 20),
                ProfileUi.blackButton(
                  label: verifying ? null : 'Vérifier et activer',
                  loading: verifying,
                  onTap: () async {
                    final code = codeCtrl.text.trim();
                    if (code.length != 6 || int.tryParse(code) == null) {
                      setSheet(() => error = 'Entrez un code à 6 chiffres');
                      return;
                    }
                    setSheet(() {
                      error = null;
                      verifying = true;
                    });
                    final ok = await verifyCode(code);
                    if (!ctx.mounted) return;
                    if (ok) {
                      Navigator.pop(ctx, true);
                    } else {
                      setSheet(() {
                        verifying = false;
                        error = 'Code incorrect, réessayez';
                      });
                    }
                  },
                ),
              ],
            ],
          ),
        );
      },
    ),
  );
}

/// Confirmation sheet before turning 2FA off.
Future<bool?> confirmDisable2FASheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(ctx).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ProfileUi.sheetHandle(),
          const SizedBox(height: 24),
          const Text(
            'Désactiver la 2FA ?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Votre compte sera moins protégé contre les connexions non autorisées.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black.withOpacity(.45),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ProfileUi.outlineButton(
                  label: 'Annuler',
                  onTap: () => Navigator.pop(ctx, false),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ProfileUi.blackButton(
                  label: 'Désactiver',
                  onTap: () => Navigator.pop(ctx, true),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
