import 'package:flutter_android_app/core/db/nexus_database.dart';
import 'package:flutter_android_app/gestions/communication_reclamation/back/communication_models.dart';

/// Table des messages de dossier et de litige.
const tableMessages = 'messages';

/// Table des avis.
const tableAvis = 'avis';

/// Table des réclamations.
const tableReclamations = 'reclamations';

/// Table des préférences d'alertes, une ligne par compte.
const tablePreferences = 'preferences_alertes';

/// Table des alertes et messages lus, une ligne par compte et par clé.
const tableLues = 'alertes_lues';

/// Schéma de la gestion communication et réclamation.
const schemaCommunication = [
  '''
CREATE TABLE IF NOT EXISTS $tableMessages (
  id TEXT PRIMARY KEY,
  fil_id TEXT NOT NULL,
  auteur_id TEXT NOT NULL,
  texte TEXT NOT NULL,
  envoye_le INTEGER NOT NULL,
  photo INTEGER NOT NULL
)''',
  '''
CREATE TABLE IF NOT EXISTS $tableAvis (
  id TEXT PRIMARY KEY,
  contrat_id TEXT NOT NULL,
  client_id TEXT NOT NULL,
  prestataire_id TEXT NOT NULL,
  note INTEGER NOT NULL,
  texte TEXT NOT NULL,
  publie_le INTEGER NOT NULL,
  reponse TEXT,
  reponse_le INTEGER
)''',
  '''
CREATE TABLE IF NOT EXISTS $tableReclamations (
  id TEXT PRIMARY KEY,
  numero TEXT NOT NULL,
  contrat_id TEXT NOT NULL,
  client_id TEXT NOT NULL,
  prestataire_id TEXT NOT NULL,
  motif TEXT NOT NULL,
  description TEXT NOT NULL,
  statut TEXT NOT NULL,
  ouverte_le INTEGER NOT NULL,
  pieces INTEGER NOT NULL,
  decision_motif TEXT NOT NULL,
  decision_par TEXT
)''',
  '''
CREATE TABLE IF NOT EXISTS $tablePreferences (
  id TEXT PRIMARY KEY,
  devis_contrats INTEGER NOT NULL,
  messages INTEGER NOT NULL,
  prestations INTEGER NOT NULL,
  reclamations INTEGER NOT NULL,
  avis INTEGER NOT NULL
)''',
  '''
CREATE TABLE IF NOT EXISTS $tableLues (
  id TEXT PRIMARY KEY,
  compte_id TEXT NOT NULL,
  cle TEXT NOT NULL
)''',
];

/// Ligne SQLite de [message].
Map<String, Object?> ligneMessage(MessageFil message) => {
  'id': message.id,
  'fil_id': message.filId,
  'auteur_id': message.auteurId,
  'texte': message.texte,
  'envoye_le': sqlDate(message.envoyeLe),
  'photo': sqlBool(message.photo),
};

/// Message lu depuis [ligne].
MessageFil messageDepuis(Map<String, Object?> ligne) => MessageFil(
  id: ligne['id']! as String,
  filId: lireTexte(ligne['fil_id']),
  auteurId: lireTexte(ligne['auteur_id']),
  texte: lireTexte(ligne['texte']),
  envoyeLe: lireDate(ligne['envoye_le']),
  photo: lireBool(ligne['photo']),
);

/// Ligne SQLite de [avis].
Map<String, Object?> ligneAvis(Avis avis) => {
  'id': avis.id,
  'contrat_id': avis.contratId,
  'client_id': avis.clientId,
  'prestataire_id': avis.prestataireId,
  'note': avis.note,
  'texte': avis.texte,
  'publie_le': sqlDate(avis.publieLe),
  'reponse': avis.reponse,
  'reponse_le': sqlDate(avis.reponseLe),
};

/// Avis lu depuis [ligne].
Avis avisDepuis(Map<String, Object?> ligne) => Avis(
  id: ligne['id']! as String,
  contratId: lireTexte(ligne['contrat_id']),
  clientId: lireTexte(ligne['client_id']),
  prestataireId: lireTexte(ligne['prestataire_id']),
  note: ligne['note']! as int,
  texte: lireTexte(ligne['texte']),
  publieLe: lireDate(ligne['publie_le']),
  reponse: ligne['reponse'] as String?,
  reponseLe: lireDateOuNull(ligne['reponse_le']),
);

/// Ligne SQLite de [item].
Map<String, Object?> ligneReclamation(Reclamation item) => {
  'id': item.id,
  'numero': item.numero,
  'contrat_id': item.contratId,
  'client_id': item.clientId,
  'prestataire_id': item.prestataireId,
  'motif': item.motif.name,
  'description': item.description,
  'statut': item.statut.name,
  'ouverte_le': sqlDate(item.ouverteLe),
  'pieces': item.pieces,
  'decision_motif': item.decisionMotif,
  'decision_par': item.decisionPar,
};

/// Réclamation lue depuis [ligne].
Reclamation reclamationDepuis(Map<String, Object?> ligne) => Reclamation(
  id: ligne['id']! as String,
  numero: lireTexte(ligne['numero']),
  contratId: lireTexte(ligne['contrat_id']),
  clientId: lireTexte(ligne['client_id']),
  prestataireId: lireTexte(ligne['prestataire_id']),
  motif: MotifReclamation.values.byName(ligne['motif']! as String),
  description: lireTexte(ligne['description']),
  statut: StatutReclamation.values.byName(ligne['statut']! as String),
  ouverteLe: lireDate(ligne['ouverte_le']),
  pieces: (ligne['pieces'] as int?) ?? 0,
  decisionMotif: lireTexte(ligne['decision_motif']),
  decisionPar: ligne['decision_par'] as String?,
);

/// Ligne SQLite des préférences de [compteId].
Map<String, Object?> lignePreferences(String compteId, PreferencesAlertes prefs) => {
  'id': compteId,
  'devis_contrats': sqlBool(prefs.devisEtContrats),
  'messages': sqlBool(prefs.messages),
  'prestations': sqlBool(prefs.prestations),
  'reclamations': sqlBool(prefs.reclamations),
  'avis': sqlBool(prefs.avis),
};

/// Préférences lues depuis [ligne].
PreferencesAlertes preferencesDepuis(Map<String, Object?> ligne) {
  return PreferencesAlertes(
    devisEtContrats: lireBool(ligne['devis_contrats']),
    messages: lireBool(ligne['messages']),
    prestations: lireBool(ligne['prestations']),
    reclamations: lireBool(ligne['reclamations']),
    avis: lireBool(ligne['avis']),
  );
}

/// Ligne SQLite d'une clé lue par [compteId].
Map<String, Object?> ligneLue(String compteId, String cle) => {
  'id': '$compteId|$cle',
  'compte_id': compteId,
  'cle': cle,
};
