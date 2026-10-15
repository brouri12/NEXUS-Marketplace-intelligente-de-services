import 'package:flutter_android_app/core/db/nexus_database.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/modele.dart';

/// Table des offres de service.
const tableOffres = 'offres_services';

/// Table des créneaux ouverts ou fermés par les prestataires.
const tableCreneaux = 'creneaux';

/// Schéma de la gestion services et prestataires.
const schemaServices = [
  '''
CREATE TABLE IF NOT EXISTS $tableOffres (
  id TEXT PRIMARY KEY,
  prestataire_id TEXT NOT NULL,
  nom TEXT NOT NULL,
  description TEXT NOT NULL,
  ville TEXT NOT NULL,
  rayon_km INTEGER NOT NULL,
  vehicule TEXT NOT NULL,
  taille_equipe INTEGER NOT NULL,
  secteur TEXT NOT NULL,
  approuve INTEGER NOT NULL,
  publie INTEGER NOT NULL,
  motif_refus TEXT,
  tarif TEXT,
  competences TEXT NOT NULL
)''',
  '''
CREATE TABLE IF NOT EXISTS $tableCreneaux (
  id TEXT PRIMARY KEY,
  prestataire_id TEXT NOT NULL,
  jour INTEGER NOT NULL,
  moment TEXT NOT NULL,
  etat TEXT NOT NULL
)''',
];

/// Ligne SQLite de [offre].
Map<String, Object?> ligneOffre(OffreService offre) {
  final tarif = offre.tarif;
  return {
    'id': offre.id,
    'prestataire_id': offre.prestataireId,
    'nom': offre.nom,
    'description': offre.description,
    'ville': offre.ville,
    'rayon_km': offre.rayonKm,
    'vehicule': offre.vehicule.name,
    'taille_equipe': offre.tailleEquipe,
    'secteur': offre.secteur.name,
    'approuve': sqlBool(offre.approuve),
    'publie': sqlBool(offre.publie),
    'motif_refus': offre.motifRefus,
    'tarif': tarif == null
        ? null
        : sqlJson({
            'type': tarif.type.name,
            'montant': tarif.montantDt,
            'inclus': tarif.inclus,
            'enPlus': tarif.enPlus,
          }),
    'competences': sqlJson([
      for (final competence in offre.competences)
        {'libelle': competence.libelle, 'validee': competence.validee},
    ]),
  };
}

/// Offre lue depuis [ligne].
OffreService offreDepuis(Map<String, Object?> ligne) {
  final tarif = lireJson(ligne['tarif']) as Map<String, Object?>?;
  final competences = lireJson(ligne['competences']) as List<Object?>? ?? const [];
  return OffreService(
    id: ligne['id']! as String,
    prestataireId: lireTexte(ligne['prestataire_id']),
    nom: lireTexte(ligne['nom']),
    description: lireTexte(ligne['description']),
    ville: lireTexte(ligne['ville']),
    rayonKm: ligne['rayon_km']! as int,
    vehicule: VehiculeService.values.byName(ligne['vehicule']! as String),
    tailleEquipe: ligne['taille_equipe']! as int,
    secteur: SecteurCompte.values.byName(ligne['secteur']! as String),
    approuve: lireBool(ligne['approuve']),
    publie: lireBool(ligne['publie']),
    motifRefus: ligne['motif_refus'] as String?,
    tarif: tarif == null
        ? null
        : TarifService(
            type: TypeTarif.values.byName('${tarif['type']}'),
            montantDt: tarif['montant']! as int,
            inclus: '${tarif['inclus'] ?? ''}',
            enPlus: [for (final item in tarif['enPlus']! as List<Object?>) '$item'],
          ),
    competences: [
      for (final item in competences.cast<Map<String, Object?>>())
        CompetenceChoisie(
          libelle: '${item['libelle']}',
          validee: item['validee'] == true,
        ),
    ],
  );
}

/// Ligne SQLite d'un créneau.
Map<String, Object?> ligneCreneau({
  required String cle,
  required String prestataireId,
  required DateTime jour,
  required MomentJournee moment,
  required EtatCreneau etat,
}) {
  return {
    'id': cle,
    'prestataire_id': prestataireId,
    'jour': sqlDate(jour),
    'moment': moment.name,
    'etat': etat.name,
  };
}
