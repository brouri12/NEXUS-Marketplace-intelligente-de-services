import 'package:flutter/material.dart';

import 'package:flutter_android_app/core/gestion_front_page.dart';
import 'package:flutter_android_app/gestions/utilisateurs/back/utilisateurs_api.dart';

/// Écran réservé de la gestion utilisateurs.
class UtilisateursPage extends StatelessWidget {
  /// Relie cet écran à [back].
  const UtilisateursPage({super.key, required this.back});

  /// Contrat back des comptes, profils, rôles et de la sécurité.
  final UtilisateursApi back;

  /// Nom affiché dans le menu.
  static const title = 'Utilisateurs';

  /// Responsabilités réservées à cette gestion.
  static const responsibilities = ['Comptes', 'Profils', 'Rôles', 'Sécurité'];

  @override
  Widget build(BuildContext context) {
    return GestionFrontPage(
      title: title,
      responsibilities: responsibilities,
      back: back,
    );
  }
}
