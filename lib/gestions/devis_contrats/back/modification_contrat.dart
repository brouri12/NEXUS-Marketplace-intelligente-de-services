/// Décision du client sur une proposition.
enum StatutModification {
  /// En attente du client.
  proposee,

  /// Acceptée, le montant du contrat a changé.
  acceptee,

  /// Refusée, le contrat initial reste en vigueur.
  refusee,
}

/// Libellé de [statut].
String labelStatutModification(StatutModification statut) {
  return switch (statut) {
    StatutModification.proposee => 'PROPOSÉE',
    StatutModification.acceptee => 'ACCEPTÉE',
    StatutModification.refusee => 'REFUSÉE',
  };
}

/// Mention affichée au prestataire avant l'envoi.
const remarqueModificationPrestataire =
    'Cette modification doit être acceptée par le client avant son application.';

/// Mention affichée au client avant sa décision.
const remarqueModificationClient =
    'Cette modification ne sera appliquée qu\'après votre acceptation.';

/// Proposition de changement sur un contrat déjà créé.
class ModificationContrat {
  /// Crée une proposition envoyée par le prestataire du contrat.
  const ModificationContrat({
    required this.id,
    required this.contratId,
    required this.prestataireId,
    required this.motif,
    required this.supplement,
    required this.nouvellesConditions,
    required this.prixActuel,
    required this.statut,
    required this.creeeLe,
  });

  /// Identifiant stable.
  final String id;

  /// Contrat concerné.
  final String contratId;

  /// Prestataire qui propose le changement.
  final String prestataireId;

  /// Raison indiquée au client.
  final String motif;

  /// Somme ajoutée au prix actuel, en dinars.
  final int supplement;

  /// Conditions proposées. Vide si elles ne changent pas.
  final String nouvellesConditions;

  /// Prix du contrat au moment de la proposition.
  final int prixActuel;

  /// Décision actuelle.
  final StatutModification statut;

  /// Moment d'envoi.
  final DateTime creeeLe;

  /// Prix qui s'appliquerait après acceptation.
  int get nouveauTotal => prixActuel + supplement;

  /// Copie avec [statut] remplacé.
  ModificationContrat copyWith({StatutModification? statut}) {
    return ModificationContrat(
      id: id,
      contratId: contratId,
      prestataireId: prestataireId,
      motif: motif,
      supplement: supplement,
      nouvellesConditions: nouvellesConditions,
      prixActuel: prixActuel,
      statut: statut ?? this.statut,
      creeeLe: creeeLe,
    );
  }
}
