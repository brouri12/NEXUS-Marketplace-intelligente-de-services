import 'package:flutter/material.dart';

/// Service qu'un client peut consulter, sans le modifier.
class OfferedService {
  /// Crée une offre affichée dans le catalogue.
  const OfferedService({
    required this.id,
    required this.title,
    required this.providerName,
    required this.city,
    required this.rate,
    required this.icon,
  });

  /// Identifiant stable.
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

  /// Icône associée à un métier connu.
  static IconData iconFor(String title) {
    return switch (title) {
      'Déménagement' => Icons.local_shipping_outlined,
      'Plomberie' => Icons.plumbing_outlined,
      'Ménage' => Icons.cleaning_services_outlined,
      'Électricité' => Icons.electrical_services_outlined,
      'Peinture' => Icons.format_paint_outlined,
      _ => Icons.handyman_outlined,
    };
  }

  /// Catalogue de démonstration, visible par un client.
  static const catalog = [
    OfferedService(
      id: 'demenagement',
      title: 'Déménagement',
      providerName: 'Amine Trabelsi',
      city: 'Tunis',
      rate: '80 TND / heure',
      icon: Icons.local_shipping_outlined,
    ),
    OfferedService(
      id: 'plomberie',
      title: 'Plomberie',
      providerName: 'Sami Jaziri',
      city: 'Tunis',
      rate: '45 TND / heure',
      icon: Icons.plumbing_outlined,
    ),
    OfferedService(
      id: 'menage',
      title: 'Ménage',
      providerName: 'Leila Karoui',
      city: 'Ariana',
      rate: '25 TND / heure',
      icon: Icons.cleaning_services_outlined,
    ),
    OfferedService(
      id: 'electricite',
      title: 'Électricité',
      providerName: 'Hatem Ben Youssef',
      city: 'Tunis',
      rate: '50 TND / heure',
      icon: Icons.electrical_services_outlined,
    ),
    OfferedService(
      id: 'peinture',
      title: 'Peinture',
      providerName: 'Inès Chatti',
      city: 'La Marsa',
      rate: '40 TND / heure',
      icon: Icons.format_paint_outlined,
    ),
  ];
}
