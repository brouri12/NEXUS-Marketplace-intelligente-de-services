import 'package:flutter_android_app/core/db/nexus_database.dart';
import 'package:flutter_android_app/gestions/logistique/back/trajet.dart';

/// Table des trajets.
const tableTrajets = 'trajets';

/// Schéma de la gestion logistique.
const schemaLogistique = [
  '''
CREATE TABLE IF NOT EXISTS $tableTrajets (
  id TEXT PRIMARY KEY,
  numero TEXT NOT NULL,
  contrat_id TEXT NOT NULL,
  client_id TEXT NOT NULL,
  prestataire_id TEXT NOT NULL,
  point_depart TEXT NOT NULL,
  destination TEXT NOT NULL,
  distance_km REAL NOT NULL,
  depart_prevu INTEGER NOT NULL,
  statut TEXT NOT NULL,
  cree_le INTEGER NOT NULL,
  depart_reel INTEGER,
  arrivee_reelle INTEGER,
  retard_minutes INTEGER NOT NULL,
  note TEXT NOT NULL
)''',
];

/// Ligne SQLite de [trajet].
Map<String, Object?> ligneTrajet(Trajet trajet) => {
  'id': trajet.id,
  'numero': trajet.numero,
  'contrat_id': trajet.contratId,
  'client_id': trajet.clientId,
  'prestataire_id': trajet.prestataireId,
  'point_depart': trajet.pointDepart,
  'destination': trajet.destination,
  'distance_km': trajet.distanceKm,
  'depart_prevu': sqlDate(trajet.departPrevu),
  'statut': trajet.status.name,
  'cree_le': sqlDate(trajet.creeLe),
  'depart_reel': sqlDate(trajet.departReel),
  'arrivee_reelle': sqlDate(trajet.arriveeReelle),
  'retard_minutes': trajet.retardMinutes,
  'note': trajet.note,
};

/// Trajet lu depuis [ligne].
Trajet trajetDepuis(Map<String, Object?> ligne) => Trajet(
  id: ligne['id']! as String,
  numero: lireTexte(ligne['numero']),
  contratId: lireTexte(ligne['contrat_id']),
  clientId: lireTexte(ligne['client_id']),
  prestataireId: lireTexte(ligne['prestataire_id']),
  pointDepart: lireTexte(ligne['point_depart']),
  destination: lireTexte(ligne['destination']),
  distanceKm: (ligne['distance_km'] as num?)?.toDouble() ?? 0,
  departPrevu: lireDate(ligne['depart_prevu']),
  status: TrajetStatus.values.byName(ligne['statut']! as String),
  creeLe: lireDate(ligne['cree_le']),
  departReel: lireDateOuNull(ligne['depart_reel']),
  arriveeReelle: lireDateOuNull(ligne['arrivee_reelle']),
  retardMinutes: (ligne['retard_minutes'] as int?) ?? 0,
  note: lireTexte(ligne['note']),
);
