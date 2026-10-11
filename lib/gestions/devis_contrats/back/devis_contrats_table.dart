import 'package:flutter_android_app/core/db/nexus_database.dart';
import 'package:flutter_android_app/gestions/devis_contrats/back/contrat.dart';
import 'package:flutter_android_app/gestions/devis_contrats/back/demande_devis.dart';
import 'package:flutter_android_app/gestions/devis_contrats/back/devis.dart';
import 'package:flutter_android_app/gestions/devis_contrats/back/modification_contrat.dart';
import 'package:flutter_android_app/gestions/devis_contrats/back/option_ligne.dart';

/// Table des demandes de devis.
const tableDemandes = 'demandes_devis';

/// Table des devis.
const tableDevis = 'devis';

/// Table des contrats.
const tableContrats = 'contrats';

/// Table des propositions de modification.
const tableModifications = 'modifications_contrat';

/// Schéma de la gestion devis et contrats.
const schemaDevisContrats = [
  '''
CREATE TABLE IF NOT EXISTS $tableDemandes (
  id TEXT PRIMARY KEY,
  client_id TEXT NOT NULL,
  prestataire_id TEXT NOT NULL,
  prestataire_nom TEXT NOT NULL,
  service TEXT NOT NULL,
  date INTEGER NOT NULL,
  lieu TEXT NOT NULL,
  distance_km REAL NOT NULL,
  prix_base INTEGER NOT NULL,
  prix_par_km INTEGER NOT NULL,
  options TEXT NOT NULL,
  statut TEXT NOT NULL
)''',
  '''
CREATE TABLE IF NOT EXISTS $tableDevis (
  id TEXT PRIMARY KEY,
  numero TEXT NOT NULL,
  demande_id TEXT,
  client_id TEXT NOT NULL,
  prestataire_id TEXT NOT NULL,
  service TEXT NOT NULL,
  lieu TEXT NOT NULL,
  date INTEGER NOT NULL,
  heure TEXT NOT NULL,
  duree_estimee TEXT NOT NULL,
  prix_base INTEGER NOT NULL,
  prix_par_km INTEGER NOT NULL,
  distance_km REAL NOT NULL,
  options TEXT NOT NULL,
  conditions TEXT NOT NULL,
  elements_inclus TEXT NOT NULL,
  elements_non_inclus TEXT NOT NULL,
  statut TEXT NOT NULL,
  contrat_id TEXT
)''',
  '''
CREATE TABLE IF NOT EXISTS $tableContrats (
  id TEXT PRIMARY KEY,
  numero TEXT NOT NULL,
  devis_id TEXT NOT NULL,
  client_id TEXT NOT NULL,
  prestataire_id TEXT NOT NULL,
  service TEXT NOT NULL,
  date INTEGER NOT NULL,
  heure TEXT NOT NULL,
  lieu TEXT NOT NULL,
  options TEXT NOT NULL,
  distance_km REAL NOT NULL,
  prix_accepte INTEGER NOT NULL,
  conditions TEXT NOT NULL,
  statut TEXT NOT NULL,
  signature_prestataire INTEGER NOT NULL,
  signature_client INTEGER NOT NULL,
  signature_prestataire_le INTEGER,
  signature_client_le INTEGER
)''',
  '''
CREATE TABLE IF NOT EXISTS $tableModifications (
  id TEXT PRIMARY KEY,
  contrat_id TEXT NOT NULL,
  prestataire_id TEXT NOT NULL,
  motif TEXT NOT NULL,
  supplement INTEGER NOT NULL,
  nouvelles_conditions TEXT NOT NULL,
  prix_actuel INTEGER NOT NULL,
  statut TEXT NOT NULL,
  creee_le INTEGER NOT NULL
)''',
];

String _options(List<OptionLigne> options) {
  return sqlJson([
    for (final option in options) {'label': option.label, 'prix': option.prix},
  ]);
}

List<OptionLigne> _lireOptions(Object? value) {
  final items = lireJson(value) as List<Object?>? ?? const [];
  return [
    for (final item in items.cast<Map<String, Object?>>())
      OptionLigne(label: '${item['label']}', prix: item['prix']! as int),
  ];
}

double _km(Object? value) => (value as num?)?.toDouble() ?? 0;

/// Ligne SQLite de [demande].
Map<String, Object?> ligneDemande(DemandeDevis demande) => {
  'id': demande.id,
  'client_id': demande.clientId,
  'prestataire_id': demande.prestataireId,
  'prestataire_nom': demande.prestataireNom,
  'service': demande.service,
  'date': sqlDate(demande.date),
  'lieu': demande.lieu,
  'distance_km': demande.distanceKm,
  'prix_base': demande.prixBase,
  'prix_par_km': demande.prixParKm,
  'options': _options(demande.options),
  'statut': demande.statut.name,
};

/// Demande lue depuis [ligne].
DemandeDevis demandeDepuis(Map<String, Object?> ligne) => DemandeDevis(
  id: ligne['id']! as String,
  clientId: lireTexte(ligne['client_id']),
  prestataireId: lireTexte(ligne['prestataire_id']),
  prestataireNom: lireTexte(ligne['prestataire_nom']),
  service: lireTexte(ligne['service']),
  date: lireDate(ligne['date']),
  lieu: lireTexte(ligne['lieu']),
  distanceKm: _km(ligne['distance_km']),
  prixBase: ligne['prix_base']! as int,
  prixParKm: ligne['prix_par_km']! as int,
  options: _lireOptions(ligne['options']),
  statut: StatutDemande.values.byName(ligne['statut']! as String),
);

/// Ligne SQLite de [devis].
Map<String, Object?> ligneDevis(Devis devis) => {
  'id': devis.id,
  'numero': devis.numero,
  'demande_id': devis.demandeId,
  'client_id': devis.clientId,
  'prestataire_id': devis.prestataireId,
  'service': devis.service,
  'lieu': devis.lieu,
  'date': sqlDate(devis.date),
  'heure': devis.heure,
  'duree_estimee': devis.dureeEstimee,
  'prix_base': devis.prixBase,
  'prix_par_km': devis.prixParKm,
  'distance_km': devis.distanceKm,
  'options': _options(devis.options),
  'conditions': devis.conditions,
  'elements_inclus': devis.elementsInclus,
  'elements_non_inclus': devis.elementsNonInclus,
  'statut': devis.statut.name,
  'contrat_id': devis.contratId,
};

/// Devis lu depuis [ligne].
Devis devisDepuis(Map<String, Object?> ligne) => Devis(
  id: ligne['id']! as String,
  numero: lireTexte(ligne['numero']),
  demandeId: ligne['demande_id'] as String?,
  clientId: lireTexte(ligne['client_id']),
  prestataireId: lireTexte(ligne['prestataire_id']),
  service: lireTexte(ligne['service']),
  lieu: lireTexte(ligne['lieu']),
  date: lireDate(ligne['date']),
  heure: lireTexte(ligne['heure']),
  dureeEstimee: lireTexte(ligne['duree_estimee']),
  prixBase: ligne['prix_base']! as int,
  prixParKm: ligne['prix_par_km']! as int,
  distanceKm: _km(ligne['distance_km']),
  options: _lireOptions(ligne['options']),
  conditions: lireTexte(ligne['conditions']),
  elementsInclus: lireTexte(ligne['elements_inclus']),
  elementsNonInclus: lireTexte(ligne['elements_non_inclus']),
  statut: StatutDevis.values.byName(ligne['statut']! as String),
  contratId: ligne['contrat_id'] as String?,
);

/// Ligne SQLite de [contrat].
Map<String, Object?> ligneContrat(Contrat contrat) => {
  'id': contrat.id,
  'numero': contrat.numero,
  'devis_id': contrat.devisId,
  'client_id': contrat.clientId,
  'prestataire_id': contrat.prestataireId,
  'service': contrat.service,
  'date': sqlDate(contrat.date),
  'heure': contrat.heure,
  'lieu': contrat.lieu,
  'options': _options(contrat.options),
  'distance_km': contrat.distanceKm,
  'prix_accepte': contrat.prixAccepte,
  'conditions': contrat.conditions,
  'statut': contrat.statut.name,
  'signature_prestataire': sqlBool(contrat.signaturePrestataire),
  'signature_client': sqlBool(contrat.signatureClient),
  'signature_prestataire_le': sqlDate(contrat.signaturePrestataireLe),
  'signature_client_le': sqlDate(contrat.signatureClientLe),
};

/// Contrat lu depuis [ligne].
Contrat contratDepuis(Map<String, Object?> ligne) => Contrat(
  id: ligne['id']! as String,
  numero: lireTexte(ligne['numero']),
  devisId: lireTexte(ligne['devis_id']),
  clientId: lireTexte(ligne['client_id']),
  prestataireId: lireTexte(ligne['prestataire_id']),
  service: lireTexte(ligne['service']),
  date: lireDate(ligne['date']),
  heure: lireTexte(ligne['heure']),
  lieu: lireTexte(ligne['lieu']),
  options: _lireOptions(ligne['options']),
  distanceKm: _km(ligne['distance_km']),
  prixAccepte: ligne['prix_accepte']! as int,
  conditions: lireTexte(ligne['conditions']),
  statut: StatutContrat.values.byName(ligne['statut']! as String),
  signaturePrestataire: lireBool(ligne['signature_prestataire']),
  signatureClient: lireBool(ligne['signature_client']),
  signaturePrestataireLe: lireDateOuNull(ligne['signature_prestataire_le']),
  signatureClientLe: lireDateOuNull(ligne['signature_client_le']),
);

/// Ligne SQLite de [modification].
Map<String, Object?> ligneModification(ModificationContrat modification) => {
  'id': modification.id,
  'contrat_id': modification.contratId,
  'prestataire_id': modification.prestataireId,
  'motif': modification.motif,
  'supplement': modification.supplement,
  'nouvelles_conditions': modification.nouvellesConditions,
  'prix_actuel': modification.prixActuel,
  'statut': modification.statut.name,
  'creee_le': sqlDate(modification.creeeLe),
};

/// Proposition lue depuis [ligne].
ModificationContrat modificationDepuis(Map<String, Object?> ligne) {
  return ModificationContrat(
    id: ligne['id']! as String,
    contratId: lireTexte(ligne['contrat_id']),
    prestataireId: lireTexte(ligne['prestataire_id']),
    motif: lireTexte(ligne['motif']),
    supplement: ligne['supplement']! as int,
    nouvellesConditions: lireTexte(ligne['nouvelles_conditions']),
    prixActuel: ligne['prix_actuel']! as int,
    statut: StatutModification.values.byName(ligne['statut']! as String),
    creeeLe: lireDate(ligne['creee_le']),
  );
}
