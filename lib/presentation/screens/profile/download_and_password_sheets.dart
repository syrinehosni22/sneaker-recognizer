import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/settings_repository.dart';
import 'profile_ui.dart';

/// Fetches the user's data export from the backend (GET /me/data-export),
/// falling back to [localFallback] if the request fails, and offers to
/// copy the result to the clipboard.
Future<void> showDownloadDataSheet(
  BuildContext context, {
  required Map<String, dynamic> localFallback,
}) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) =>
        const Center(child: CircularProgressIndicator(color: Colors.black)),
  );
  final data = await SettingsRepository.fetchDataExport(
    localFallback: localFallback,
  );
  if (!context.mounted) return;
  Navigator.pop(context); // close loading dialog

  final jsonStr = const JsonEncoder.withIndent('  ').convert(data);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: ProfileUi.sheetHandle()),
          const SizedBox(height: 20),
          const Text(
            'Mes données',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Voici un export de vos données. Copiez-le pour le conserver ou l'envoyer.",
            style: TextStyle(
              fontSize: 13.5,
              color: Colors.black.withOpacity(.5),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            constraints: const BoxConstraints(maxHeight: 260),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black.withOpacity(.08)),
            ),
            child: SingleChildScrollView(
              child: Text(
                jsonStr,
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ProfileUi.blackButton(
            label: 'Copier dans le presse-papiers',
            onTap: () async {
              await Clipboard.setData(ClipboardData(text: jsonStr));
              if (ctx.mounted) Navigator.pop(ctx);
              ProfileUi.snack(context, 'Données copiées');
            },
          ),
        ],
      ),
    ),
  );
}

/// Static tips explaining what makes a password strong, with a CTA
/// that the caller wires up to the real change-password flow.
void showPasswordTipsSheet(
  BuildContext context, {
  required VoidCallback onChangePassword,
}) {
  final tips = [
    'Au moins 8 caractères (12+ recommandé)',
    'Une majuscule et une minuscule',
    'Au moins un chiffre',
    'Au moins un symbole (!?@#…)',
    "Évitez les mots du dictionnaire ou vos infos personnelles",
    'Un mot de passe unique, non réutilisé ailleurs',
  ];

  showModalBottomSheet(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: ProfileUi.sheetHandle()),
          const SizedBox(height: 20),
          const Text(
            'Choisir un mot de passe fort',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          ...tips.map(
            (t) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 18,
                    color: Colors.black87,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      t,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ProfileUi.blackButton(
            label: 'Modifier mon mot de passe',
            onTap: () {
              Navigator.pop(ctx);
              onChangePassword();
            },
          ),
        ],
      ),
    ),
  );
}
