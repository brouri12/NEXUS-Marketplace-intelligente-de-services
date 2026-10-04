/// Métier, compétences, tarif et disponibilités d'un prestataire.
class ProviderProfile {
  /// Crée la fiche demandée à l'inscription.
  const ProviderProfile({
    required this.service,
    required this.skills,
    required this.hourlyRate,
    required this.availability,
    this.presentation = '',
  });

  /// Métier proposé.
  final String service;

  /// Compétences affichées avec le métier.
  final List<String> skills;

  /// Tarif horaire en dinars.
  final int hourlyRate;

  /// Jours où le prestataire peut intervenir.
  final List<String> availability;

  /// Présentation libre, peut rester vide.
  final String presentation;

  /// Tarif déjà rédigé pour les listes.
  String get rateLabel => '$hourlyRate TND / heure';
}

/// Métiers proposés à l'inscription.
const providerTrades = [
  'Déménagement',
  'Plomberie',
  'Ménage',
  'Électricité',
  'Peinture',
];

/// Jours proposés pour les disponibilités.
const providerDays = [
  'Lundi',
  'Mardi',
  'Mercredi',
  'Jeudi',
  'Vendredi',
  'Samedi',
  'Dimanche',
];

/// Compétences suggérées selon le métier.
const skillsByTrade = {
  'Déménagement': ['Camion', 'Manutention', 'Emballage'],
  'Plomberie': ['Fuite', 'Installation', 'Débouchage'],
  'Ménage': ['Maison', 'Bureau', 'Vitres'],
  'Électricité': ['Dépannage', 'Installation', 'Tableau'],
  'Peinture': ['Intérieur', 'Extérieur', 'Façade'],
};
