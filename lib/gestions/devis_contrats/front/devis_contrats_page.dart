import 'package:flutter/material.dart';

import 'package:flutter_android_app/core/gestion_front_page.dart';
import 'package:flutter_android_app/gestions/devis_contrats/back/devis_contrats_api.dart';

/// Écran réservé de la gestion devis et contrats.
class DevisContratsPage extends StatelessWidget {
  /// Relie cet écran à [back].
  const DevisContratsPage({super.key, required this.back});

  /// Contrat back des devis, commandes, prestations et statuts.
  final DevisContratsApi back;

  /// Nom affiché dans le menu.
  static const title = 'Devis et contrats';

  /// Responsabilités réservées à cette gestion.
  static const responsibilities = [
    'Devis',
    'Commandes',
    'Prestations',
    'Statut',
  ];

  @override
  Widget build(BuildContext context) {
    return GestionFrontPage(
      title: title,
      responsibilities: responsibilities,
      back: back,
    );
  }
}
