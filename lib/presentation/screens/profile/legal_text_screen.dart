import 'package:flutter/material.dart';
import 'profile_ui.dart';

class LegalTextScreen extends StatelessWidget {
  final String title;
  final String content;

  const LegalTextScreen({
    super.key,
    required this.title,
    required this.content,
  });

  static const privacyPolicy = '''
Dernière mise à jour : à compléter par votre équipe juridique.

1. Données collectées
Nous collectons les informations de votre profil (nom, email), les photos que vous scannez pour la reconnaissance de sneakers, ainsi que des données techniques (type d'appareil, journal d'activité).

2. Utilisation des données
Ces données servent à faire fonctionner la reconnaissance de sneakers, sécuriser votre compte et améliorer le service.

3. Partage des données
Vos données ne sont jamais vendues. Elles peuvent être partagées avec des prestataires techniques (hébergement, paiement) sous contrat de confidentialité.

4. Vos droits
Vous pouvez à tout moment demander l'accès, la rectification ou la suppression de vos données depuis "Télécharger mes données" ou "Supprimer mon compte".

Ceci est un texte d'exemple à remplacer par votre politique de confidentialité réelle.
''';

  static const termsOfUse = '''
Dernière mise à jour : à compléter par votre équipe juridique.

1. Acceptation des conditions
En utilisant l'application, vous acceptez les présentes conditions d'utilisation.

2. Compte utilisateur
Vous êtes responsable de la confidentialité de vos identifiants et de toute activité effectuée depuis votre compte.

3. Usage autorisé
L'application est destinée à un usage personnel de reconnaissance et de gestion de sneakers. Tout usage frauduleux entraînera la suspension du compte.

4. Responsabilité
Le service est fourni "en l'état", sans garantie de disponibilité continue.

Ceci est un texte d'exemple à remplacer par vos conditions d'utilisation réelles.
''';

  @override
  Widget build(BuildContext context) {
    return ProfileUi.scaffold(
      title: title,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        child: Text(
          content,
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: Colors.black.withOpacity(.75),
          ),
        ),
      ),
    );
  }
}
