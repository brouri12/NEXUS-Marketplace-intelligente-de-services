import 'package:flutter/widgets.dart';

/// Une gestion NEXUS, avec son écran et son contrat back déjà reliés.
class GestionModule {
  /// Crée le lien entre l'identité de la gestion, son écran et son back.
  const GestionModule({
    required this.id,
    required this.title,
    required this.icon,
    required this.responsibilities,
    required this.front,
    required this.back,
  });

  /// Identifiant stable, utilisé comme clé de navigation.
  final String id;

  /// Nom affiché dans le menu.
  final String title;

  /// Icône du menu.
  final IconData icon;

  /// Responsabilités réservées à cette gestion.
  final List<String> responsibilities;

  /// Construit l'écran de la partie front.
  final WidgetBuilder front;

  /// Contrat de la partie back branché sur cet écran.
  final Object back;
}
