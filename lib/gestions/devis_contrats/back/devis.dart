import 'package:flutter_android_app/gestions/devis_contrats/back/option_ligne.dart';

/// Cycle de vie d'un devis.
enum StatutDevis {
  /// Pas encore envoyé.
  brouillon,

  /// Envoyé au client.
  envoye,

  /// Ouvert par le client.
  vu,

  /// Accepté par le client.
  accepte,

  /// Refusé par le client.
  refuse,

  /// Délai dépassé.
  expire,
}

/// Libellé de [statut].
String labelStatutDevis(StatutDevis statut) {
  return switch (statut) {
    StatutDevis.brouillon => 'BROUILLON',
    StatutDevis.envoye => 'ENVOYÉ',
    StatutDevis.vu => 'VU',
    StatutDevis.accepte => 'ACCEPTÉ',
    StatutDevis.refuse => 'REFUSÉ',
    StatutDevis.expire => 'EXPIRÉ',
  };
}

/// Devis préparé par un prestataire pour un client existant.
class Devis {
  /// Crée un devis déjà chiffré.
  const Devis({
    required this.id,
    required this.numero,
    required this.clientId,
    required this.prestataireId,
    required this.service,
    required this.lieu,
    required this.date,
    required this.heure,
    required this.dureeEstimee,
    required this.prixBase,
    required this.prixParKm,
    required this.distanceKm,
    required this.options,
    required this.conditions,
    required this.elementsInclus,
    required this.elementsNonInclus,
    required this.statut,
    this.demandeId,
    this.contratId,
  });

  /// Identifiant stable.
  final String id;

  /// Numéro affiché, par exemple DV-001.
  final String numero;

  /// Demande d'origine, absente pour un devis de démonstration.
  final String? demandeId;

  /// Compte client existant.
  final String clientId;

  /// Compte prestataire existant.
  final String prestataireId;

  /// Métier.
  final String service;

  /// Lieu de la prestation.
  final String lieu;

  /// Jour de la prestation.
  final DateTime date;

  /// Heure affichée, par exemple 09:00.
  final String heure;

  /// Durée estimée, rédigée.
  final String dureeEstimee;

  /// Prix de base, en dinars.
  final int prixBase;

  /// Prix d'un kilomètre, en dinars.
  final int prixParKm;

  /// Distance retenue, en kilomètres.
  final double distanceKm;

  /// Options chiffrées.
  final List<OptionLigne> options;

  /// Conditions rédigées par le prestataire.
  final String conditions;

  /// Ce qui est compris dans le prix.
  final String elementsInclus;

  /// Ce qui n'est pas compris.
  final String elementsNonInclus;

  /// État actuel.
  final StatutDevis statut;

  /// Contrat créé après acceptation.
  final String? contratId;

  /// Total calculé automatiquement.
  int get total => prixTotal(
    prixBase: prixBase,
    options: options,
    distanceKm: distanceKm,
    prixParKm: prixParKm,
  );

  /// Whether the client can still accept or refuse.
  bool get ouvrable => statut == StatutDevis.envoye || statut == StatutDevis.vu;

  /// Copie avec le statut ou le contrat remplacé.
  Devis copyWith({StatutDevis? statut, String? contratId}) {
    return Devis(
      id: id,
      numero: numero,
      demandeId: demandeId,
      clientId: clientId,
      prestataireId: prestataireId,
      service: service,
      lieu: lieu,
      date: date,
      heure: heure,
      dureeEstimee: dureeEstimee,
      prixBase: prixBase,
      prixParKm: prixParKm,
      distanceKm: distanceKm,
      options: options,
      conditions: conditions,
      elementsInclus: elementsInclus,
      elementsNonInclus: elementsNonInclus,
      statut: statut ?? this.statut,
      contratId: contratId ?? this.contratId,
    );
  }
}
