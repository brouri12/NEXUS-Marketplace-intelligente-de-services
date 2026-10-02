import 'package:flutter/material.dart';

import 'package:flutter_android_app/core/gestion_front_page.dart';
import 'package:flutter_android_app/gestions/communication_reclamation/back/communication_reclamation_api.dart';

/// Écran réservé de la gestion communication et réclamation.
class CommunicationReclamationPage extends StatelessWidget {
  /// Relie cet écran à [back].
  const CommunicationReclamationPage({super.key, required this.back});

  /// Contrat back du chat, des avis, des réclamations et des notifications.
  final CommunicationReclamationApi back;

  /// Nom affiché dans le menu.
  static const title = 'Communication & réclamation';

  /// Responsabilités réservées à cette gestion.
  static const responsibilities = [
    'Chat',
    'Avis',
    'Réclamations',
    'Notifications',
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
