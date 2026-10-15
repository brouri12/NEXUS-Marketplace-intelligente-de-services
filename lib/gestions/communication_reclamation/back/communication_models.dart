/// Motif choisi par le client au dépôt.
enum MotifReclamation {
  /// Arrivée après le créneau confirmé.
  retard,

  /// Montant contesté.
  prix,

  /// Bien abîmé.
  degat,

  /// Prestataire absent.
  absence,

  /// Autre situation.
  autre,
}

/// Libellé de [motif].
String labelMotif(MotifReclamation motif) {
  return switch (motif) {
    MotifReclamation.retard => 'Retard',
    MotifReclamation.prix => 'Prix',
    MotifReclamation.degat => 'Dégât',
    MotifReclamation.absence => 'Absence',
    MotifReclamation.autre => 'Autre',
  };
}

/// Cycle d'une réclamation.
enum StatutReclamation {
  /// Déposée, pas encore prise.
  ouverte,

  /// Un admin l'examine.
  enExamen,

  /// Décision de clôture.
  resolue,

  /// Décision de rejet.
  rejetee,
}

/// Libellé de [statut].
String labelStatutReclamation(StatutReclamation statut) {
  return switch (statut) {
    StatutReclamation.ouverte => 'Ouverte',
    StatutReclamation.enExamen => 'En examen',
    StatutReclamation.resolue => 'Résolue',
    StatutReclamation.rejetee => 'Rejetée',
  };
}

/// Whether [statut] accepte encore des messages des parties.
bool reclamationOuverte(StatutReclamation statut) {
  return statut == StatutReclamation.ouverte || statut == StatutReclamation.enExamen;
}

/// Message d'un fil de devis, de contrat ou de litige.
class MessageFil {
  /// Crée un message déjà envoyé.
  const MessageFil({
    required this.id,
    required this.filId,
    required this.auteurId,
    required this.texte,
    required this.envoyeLe,
    this.photo = false,
  });

  /// Identifiant stable.
  final String id;

  /// Fil concerné : dossier ou réclamation.
  final String filId;

  /// Compte auteur.
  final String auteurId;

  /// Texte, ou légende d'une photo.
  final String texte;

  /// Moment d'envoi.
  final DateTime envoyeLe;

  /// Whether the message stands in for a photo.
  final bool photo;
}

/// Avis publié après une prestation terminée.
class Avis {
  /// Crée un avis déjà publié.
  const Avis({
    required this.id,
    required this.contratId,
    required this.clientId,
    required this.prestataireId,
    required this.note,
    required this.texte,
    required this.publieLe,
    this.reponse,
    this.reponseLe,
  });

  /// Identifiant stable.
  final String id;

  /// Contrat terminé.
  final String contratId;

  /// Client auteur.
  final String clientId;

  /// Prestataire évalué.
  final String prestataireId;

  /// Note de 1 à 5.
  final int note;

  /// Commentaire du client.
  final String texte;

  /// Moment de publication.
  final DateTime publieLe;

  /// Réponse unique du prestataire.
  final String? reponse;

  /// Moment de la réponse.
  final DateTime? reponseLe;

  /// Copie avec la réponse du prestataire.
  Avis copyWith({String? reponse, DateTime? reponseLe}) {
    return Avis(
      id: id,
      contratId: contratId,
      clientId: clientId,
      prestataireId: prestataireId,
      note: note,
      texte: texte,
      publieLe: publieLe,
      reponse: reponse ?? this.reponse,
      reponseLe: reponseLe ?? this.reponseLe,
    );
  }
}

/// Réclamation rattachée à un contrat.
class Reclamation {
  /// Crée un dossier de litige.
  const Reclamation({
    required this.id,
    required this.numero,
    required this.contratId,
    required this.clientId,
    required this.prestataireId,
    required this.motif,
    required this.description,
    required this.statut,
    required this.ouverteLe,
    this.pieces = 0,
    this.decisionMotif = '',
    this.decisionPar,
  });

  /// Identifiant stable.
  final String id;

  /// Numéro affiché, par exemple REC-024.
  final String numero;

  /// Contrat concerné.
  final String contratId;

  /// Client qui dépose.
  final String clientId;

  /// Prestataire mis en cause.
  final String prestataireId;

  /// Motif choisi.
  final MotifReclamation motif;

  /// Récit du client.
  final String description;

  /// État actuel.
  final StatutReclamation statut;

  /// Moment du dépôt.
  final DateTime ouverteLe;

  /// Nombre de photos ajoutées.
  final int pieces;

  /// Motif obligatoire de la décision admin.
  final String decisionMotif;

  /// Admin qui a tranché.
  final String? decisionPar;

  /// Copie avec la décision ou les pièces remplacées.
  Reclamation copyWith({
    StatutReclamation? statut,
    int? pieces,
    String? decisionMotif,
    String? decisionPar,
  }) {
    return Reclamation(
      id: id,
      numero: numero,
      contratId: contratId,
      clientId: clientId,
      prestataireId: prestataireId,
      motif: motif,
      description: description,
      statut: statut ?? this.statut,
      ouverteLe: ouverteLe,
      pieces: pieces ?? this.pieces,
      decisionMotif: decisionMotif ?? this.decisionMotif,
      decisionPar: decisionPar ?? this.decisionPar,
    );
  }
}

/// Préférences d'alertes d'un compte.
class PreferencesAlertes {
  /// Crée des préférences, actives sauf les avis.
  const PreferencesAlertes({
    this.devisEtContrats = true,
    this.messages = true,
    this.prestations = true,
    this.reclamations = true,
    this.avis = false,
  });

  /// Alertes des devis et des contrats.
  final bool devisEtContrats;

  /// Alertes des messages.
  final bool messages;

  /// Alertes des prestations.
  final bool prestations;

  /// Alertes des réclamations.
  final bool reclamations;

  /// Alertes des avis.
  final bool avis;

  /// Copie avec un interrupteur remplacé.
  PreferencesAlertes copyWith({
    bool? devisEtContrats,
    bool? messages,
    bool? prestations,
    bool? reclamations,
    bool? avis,
  }) {
    return PreferencesAlertes(
      devisEtContrats: devisEtContrats ?? this.devisEtContrats,
      messages: messages ?? this.messages,
      prestations: prestations ?? this.prestations,
      reclamations: reclamations ?? this.reclamations,
      avis: avis ?? this.avis,
    );
  }
}

/// Famille d'une alerte, pour ouvrir le bon écran.
enum TypeAlerte {
  /// Message d'un dossier.
  message,

  /// Devis reçu.
  devis,

  /// Prestation terminée.
  prestation,

  /// Réclamation.
  reclamation,

  /// Avis publié ou réponse.
  avis,
}

/// Alerte calculée pour un compte.
class Alerte {
  /// Crée une alerte.
  const Alerte({
    required this.id,
    required this.type,
    required this.titre,
    required this.detail,
    required this.quand,
    required this.lue,
    this.dossierId,
    this.reclamationId,
    this.avisId,
  });

  /// Identifiant stable, propre au compte.
  final String id;

  /// Écran à ouvrir.
  final TypeAlerte type;

  /// Titre court.
  final String titre;

  /// Précision.
  final String detail;

  /// Moment de l'événement.
  final DateTime quand;

  /// Whether the account has opened it.
  final bool lue;

  /// Fil de discussion, s'il y en a un.
  final String? dossierId;

  /// Réclamation, s'il y en a une.
  final String? reclamationId;

  /// Avis, s'il y en a un.
  final String? avisId;
}

/// Résumé d'une conversation liée à un devis ou à un contrat.
class Dossier {
  /// Crée le résumé affiché dans la liste.
  const Dossier({
    required this.id,
    required this.interlocuteur,
    required this.service,
    required this.quand,
    required this.statut,
    required this.apercu,
    required this.lectureSeule,
    required this.litige,
    required this.moment,
  });

  /// Clé du fil, `d:` pour un devis et `c:` pour un contrat.
  final String id;

  /// Autre partie, ou les deux noms pour l'admin.
  final String interlocuteur;

  /// Métier.
  final String service;

  /// Date affichée.
  final String quand;

  /// État du devis ou du contrat.
  final String statut;

  /// Dernier message, ou une invite.
  final String apercu;

  /// Whether new messages are refused.
  final bool lectureSeule;

  /// Whether a réclamation est ouverte sur ce contrat.
  final bool litige;

  /// Date du dossier, pour trier la liste.
  final DateTime moment;
}
