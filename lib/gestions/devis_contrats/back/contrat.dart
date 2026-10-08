import 'package:flutter_android_app/gestions/devis_contrats/back/option_ligne.dart';

/// Cycle de vie d'un contrat.
enum StatutContrat {
  /// Le prestataire n'a pas encore signé.
  attenteSignaturePrestataire,

  /// Le client n'a pas encore signé.
  attenteSignatureClient,

  /// Les deux parties ont signé.
  valide,

  /// Prestation en cours.
  enCours,

  /// Prestation terminée.
  termine,

  /// Contrat annulé.
  annule,
}

/// Libellé précis de [statut].
String labelStatutContrat(StatutContrat statut) {
  return switch (statut) {
    StatutContrat.attenteSignaturePrestataire => 'ATTENTE_SIGNATURE_PRESTATAIRE',
    StatutContrat.attenteSignatureClient => 'ATTENTE_SIGNATURE_CLIENT',
    StatutContrat.valide => 'VALIDÉ',
    StatutContrat.enCours => 'EN_COURS',
    StatutContrat.termine => 'TERMINÉ',
    StatutContrat.annule => 'ANNULÉ',
  };
}

/// Whether [statut] attend encore une signature.
bool contratEnAttenteSignature(StatutContrat statut) {
  return statut == StatutContrat.attenteSignaturePrestataire ||
      statut == StatutContrat.attenteSignatureClient;
}

/// Contrat né d'un devis accepté, entre deux comptes existants.
class Contrat {
  /// Crée un contrat déjà relié à son devis.
  const Contrat({
    required this.id,
    required this.numero,
    required this.devisId,
    required this.clientId,
    required this.prestataireId,
    required this.service,
    required this.date,
    required this.heure,
    required this.lieu,
    required this.options,
    required this.distanceKm,
    required this.prixAccepte,
    required this.conditions,
    required this.statut,
    this.signaturePrestataire = false,
    this.signatureClient = false,
    this.signaturePrestataireLe,
    this.signatureClientLe,
  });

  /// Identifiant stable.
  final String id;

  /// Numéro affiché, par exemple CT-2026-001.
  final String numero;

  /// Devis accepté à l'origine.
  final String devisId;

  /// Compte client existant.
  final String clientId;

  /// Compte prestataire existant.
  final String prestataireId;

  /// Métier.
  final String service;

  /// Jour de la prestation.
  final DateTime date;

  /// Heure affichée.
  final String heure;

  /// Lieu de la prestation.
  final String lieu;

  /// Options reprises du devis.
  final List<OptionLigne> options;

  /// Distance retenue, en kilomètres.
  final double distanceKm;

  /// Montant accepté, en dinars. Une modification acceptée le remplace.
  final int prixAccepte;

  /// Conditions en vigueur.
  final String conditions;

  /// État actuel.
  final StatutContrat statut;

  /// Whether the provider has signed.
  final bool signaturePrestataire;

  /// Whether the client has signed.
  final bool signatureClient;

  /// Moment de la signature prestataire.
  final DateTime? signaturePrestataireLe;

  /// Moment de la signature client.
  final DateTime? signatureClientLe;

  /// Whether both parties have signed.
  bool get deuxSignatures => signaturePrestataire && signatureClient;

  /// Copie avec les champs de suivi remplacés.
  Contrat copyWith({
    int? prixAccepte,
    String? conditions,
    StatutContrat? statut,
    bool? signaturePrestataire,
    bool? signatureClient,
    DateTime? signaturePrestataireLe,
    DateTime? signatureClientLe,
  }) {
    return Contrat(
      id: id,
      numero: numero,
      devisId: devisId,
      clientId: clientId,
      prestataireId: prestataireId,
      service: service,
      date: date,
      heure: heure,
      lieu: lieu,
      options: options,
      distanceKm: distanceKm,
      prixAccepte: prixAccepte ?? this.prixAccepte,
      conditions: conditions ?? this.conditions,
      statut: statut ?? this.statut,
      signaturePrestataire: signaturePrestataire ?? this.signaturePrestataire,
      signatureClient: signatureClient ?? this.signatureClient,
      signaturePrestataireLe: signaturePrestataireLe ?? this.signaturePrestataireLe,
      signatureClientLe: signatureClientLe ?? this.signatureClientLe,
    );
  }
}
