import 'package:flutter/material.dart';

import 'package:flutter_android_app/core/gestion_front_page.dart';
import 'package:flutter_android_app/gestions/marketplace/back/marketplace_api.dart';

/// Écran réservé de la marketplace.
class MarketplacePage extends StatelessWidget {
  /// Relie cet écran à [back].
  const MarketplacePage({super.key, required this.back});

  /// Contrat back de la recherche et de la mise en relation.
  final MarketplaceApi back;

  /// Nom affiché dans le menu.
  static const title = 'Marketplace';

  /// Responsabilités réservées à cette gestion.
  static const responsibilities = [
    'Besoin en langage naturel',
    'Recherche de prestataires',
    'Mise en relation',
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
