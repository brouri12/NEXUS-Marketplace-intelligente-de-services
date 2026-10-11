import 'package:flutter/material.dart';

import 'package:flutter_android_app/gestions/services_prestataires/back/services_prestataires_api.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/etat.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/tableau_de_bord_page.dart';

/// Entrée prestataire.
///
/// Activer le rôle Prestataire, depuis Utilisateurs, ouvre cette page.
class ServicesPrestatairesPage extends StatefulWidget {
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
  State<ServicesPrestatairesPage> createState() =>
      _ServicesPrestatairesPageState();
}

class _ServicesPrestatairesPageState extends State<ServicesPrestatairesPage> {
  late final ServicesPrestatairesEtat _etat;

  @override
  void initState() {
    super.initState();
    _etat = ServicesPrestatairesEtat(widget.back);
  }

  @override
  void dispose() {
    _etat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TableauDeBordPage(etat: _etat);
  }
}
