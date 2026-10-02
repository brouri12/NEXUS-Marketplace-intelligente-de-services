import 'package:flutter/material.dart';

import 'package:flutter_android_app/core/gestion_front_page.dart';
import 'package:flutter_android_app/gestions/services_prestataires/back/services_prestataires_api.dart';

/// Écran réservé de la gestion services et prestataires.
class ServicesPrestatairesPage extends StatelessWidget {
  /// Relie cet écran à [back].
  const ServicesPrestatairesPage({super.key, required this.back});

  /// Contrat back des services, compétences, tarifs et disponibilités.
  final ServicesPrestatairesApi back;

  /// Nom affiché dans le menu.
  static const title = 'Services & prestataires';

  /// Responsabilités réservées à cette gestion.
  static const responsibilities = [
    'Services',
    'Compétences',
    'Tarifs',
    'Disponibilités',
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
