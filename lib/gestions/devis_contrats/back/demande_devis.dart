import 'package:flutter_android_app/gestions/devis_contrats/back/option_ligne.dart';

/// État d'une demande reçue par un prestataire.
enum StatutDemande {
  /// En attente d'un devis.
  recue,

  /// Refusée par le prestataire.
  refusee,

  /// Un devis a été envoyé.
  traitee,
}

/// Libellé de [statut].
String labelStatutDemande(StatutDemande statut) {
  return switch (statut) {
    StatutDemande.recue => 'REÇUE',
    StatutDemande.refusee => 'REFUSÉE',
    StatutDemande.traitee => 'TRAITÉE',
  };
}

/// Demande de service adressée à un prestataire déjà inscrit.
class DemandeDevis {
  /// Crée une demande complète.
  const DemandeDevis({
    required this.id,
    required this.clientId,
    required this.prestataireId,
    required this.service,
    required this.date,
    required this.lieu,
    required this.distanceKm,
    required this.prixBase,
    required this.prixParKm,
    required this.options,
    required this.statut,
    this.prestataireNom = '',
  });

  /// Identifiant stable.
  final String id;

  /// Compte client existant.
  final String clientId;

  /// Compte prestataire existant, ou un identifiant de catalogue.
  final String prestataireId;

  /// Nom affiché quand le prestataire n'a pas de compte.
  final String prestataireNom;

  /// Métier demandé.
  final String service;

  /// Jour souhaité.
  final DateTime date;

  /// Lieu de la prestation.
  final String lieu;

  /// Distance entre le prestataire et le lieu, en kilomètres.
  final double distanceKm;

  /// Prix de base du service, en dinars.
  final int prixBase;

  /// Prix d'un kilomètre, en dinars.
  final int prixParKm;

  /// Options déjà choisies par le client.
  final List<OptionLigne> options;

  /// État actuel.
  final StatutDemande statut;

  /// Total calculé, avant l'envoi du devis.
  int get total => prixTotal(
    prixBase: prixBase,
    options: options,
    distanceKm: distanceKm,
    prixParKm: prixParKm,
  );

  /// Copie avec [statut] remplacé.
  DemandeDevis copyWith({StatutDemande? statut}) {
    return DemandeDevis(
      id: id,
      clientId: clientId,
      prestataireId: prestataireId,
      prestataireNom: prestataireNom,
      service: service,
      date: date,
      lieu: lieu,
      distanceKm: distanceKm,
      prixBase: prixBase,
      prixParKm: prixParKm,
      options: options,
      statut: statut ?? this.statut,
    );
  }
}
