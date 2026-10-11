import 'package:flutter/material.dart';

/// Offre publiée, telle qu'un client la lit et la demande en devis.
class OfferedService {
  /// Crée une offre affichée dans le catalogue.
  const OfferedService({
    required this.id,
    required this.title,
    required this.providerName,
    required this.city,
    required this.rate,
    required this.icon,
    this.prestataireId = '',
    this.prestations = const [],
    this.prixBase,
  });

  /// Identifiant stable de l'offre.
  final String id;

  /// Nom du service.
  final String title;

  /// Prestataire qui le propose.
  final String providerName;

  /// Ville où le service est disponible.
  final String city;

  /// Tarif affiché, déjà rédigé.
  final String rate;

  /// Icône du métier.
  final IconData icon;

  /// Compte du prestataire.
  final String prestataireId;

  /// Compétences validées, proposées comme cases à cocher.
  final List<String> prestations;

  /// Montant du tarif, repris comme prix de base du devis.
  final int? prixBase;

  /// Icône associée à un métier connu.
  static IconData iconFor(String title) {
    return switch (title) {
      'Déménagement' || 'Transport de meubles' || 'Garde-meuble' =>
        Icons.local_shipping_outlined,
      'Plomberie' => Icons.plumbing_outlined,
      'Ménage' => Icons.cleaning_services_outlined,
      'Électricité' || 'Dépannage électrique' || 'Installation électrique' =>
        Icons.electrical_services_outlined,
      'Peinture' => Icons.format_paint_outlined,
      'Menuiserie' => Icons.carpenter_outlined,
      'Jardinage' => Icons.yard_outlined,
      'Climatisation' => Icons.ac_unit_outlined,
      _ => Icons.handyman_outlined,
    };
  }
}
