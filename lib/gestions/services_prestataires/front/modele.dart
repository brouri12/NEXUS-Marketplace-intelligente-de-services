/// Véhicule qu'un service peut annoncer.
enum VehiculeService { aucun, voiture, camion }

/// Façon de chiffrer un service.
enum TypeTarif { heure, forfait, camion }

/// Découpage d'une journée.
enum MomentJournee { matin, apresMidi, soir }

/// État d'un créneau dans la semaine affichée.
enum EtatCreneau { ouvert, ferme, verrouille }

/// Résultat d'une compétence saisie librement.
enum AjoutCompetence { ajoutee, doublon, dejaConnue }

/// Profil déjà choisi pour le compte, par l'admin.
enum SecteurCompte { demenagement, batiment, maison, electricite }

/// Prestataire qui porte des services de son secteur.
class Prestataire {
  /// Crée un prestataire.
  const Prestataire({
    required this.id,
    required this.nom,
    required this.secteur,
  });

  /// Identifiant stable.
  final String id;

  /// Nom affiché.
  final String nom;

  /// Secteur du compte. Les services ajoutés restent dans ce profil.
  final SecteurCompte secteur;
}

/// Offre du prestataire, publiée ou masquée.
class OffreService {
  /// Crée une offre. [publie] faux retire l'offre des résultats.
  OffreService({
    required this.id,
    required this.prestataireId,
    required this.nom,
    required this.description,
    required this.ville,
    required this.rayonKm,
    required this.vehicule,
    required this.tailleEquipe,
    required this.secteur,
    this.approuve = false,
    this.publie = false,
    this.motifRefus,
    this.tarif,
    List<CompetenceChoisie>? competences,
  }) : competences = competences ?? [];

  /// Identifiant stable dans l'écran.
  final String id;

  /// Prestataire à qui l'offre est affectée.
  String prestataireId;

  /// Nom affiché, par exemple Déménagement.
  final String nom;

  /// Description courte saisie dans le formulaire.
  final String description;

  /// Ville de la zone.
  final String ville;

  /// Rayon de la zone, en kilomètres.
  final int rayonKm;

  /// Véhicule annoncé.
  final VehiculeService vehicule;

  /// Nombre de personnes de l'équipe.
  final int tailleEquipe;

  /// Secteur du compte qui porte cette offre.
  final SecteurCompte secteur;

  /// Vrai quand l'admin a approuvé la demande.
  bool approuve;

  /// Faux quand l'offre est masquée ou pas encore approuvée.
  bool publie;

  /// Motif saisi par l'admin s'il refuse la demande.
  String? motifRefus;

  /// Tarif qui préremplit le devis. Absent, l'offre ne sort pas.
  TarifService? tarif;

  /// Compétences de cette offre. Une saisie libre reste non validée.
  final List<CompetenceChoisie> competences;

  /// Ville et rayon, tels que la fiche les montre.
  String get zone => '$ville · $rayonKm km';

  /// Taille d'équipe en toutes lettres.
  String get libelleEquipe => tailleEquipe > 1
      ? '$tailleEquipe personnes'
      : '$tailleEquipe personne';

  /// Demande encore entre les mains de l'admin.
  bool get enAttente => !approuve && (motifRefus == null || motifRefus!.isEmpty);

  /// Compétences déjà validées, celles que la fiche peut montrer.
  List<CompetenceChoisie> get competencesVisibles {
    return competences.where((competence) => competence.validee).toList();
  }

  /// Résumé des pastilles, y compris celles encore en attente.
  String get resumeCompetences {
    if (competences.isEmpty) {
      return 'Aucune compétence';
    }
    return competences
        .map(
          (competence) => competence.validee
              ? competence.libelle
              : '${competence.libelle} (en attente)',
        )
        .join(', ');
  }
}

/// Tarif d'une offre.
class TarifService {
  /// Crée un tarif en dinars.
  const TarifService({
    required this.type,
    required this.montantDt,
    required this.inclus,
    required this.enPlus,
  });

  /// À l'heure, au forfait ou au camion.
  final TypeTarif type;

  /// Montant entier, en DT.
  final int montantDt;

  /// Ce que le montant couvre.
  final String inclus;

  /// Suppléments, par exemple un étage ou des cartons.
  final List<String> enPlus;
}

/// Pastille de compétence.
class CompetenceChoisie {
  /// Crée une pastille. [validee] faux : saisie libre, encore en attente.
  const CompetenceChoisie({required this.libelle, required this.validee});

  /// Texte de la pastille.
  final String libelle;

  /// Faux tant que l'admin n'a pas validé une saisie libre.
  final bool validee;
}

/// Créneau daté, matin, après-midi ou soir.
class RefCreneau {
  /// Crée la référence d'un bloc.
  const RefCreneau({required this.jour, required this.moment});

  /// Jour du bloc, sans heure.
  final DateTime jour;

  /// Matin, après-midi ou soir.
  final MomentJournee moment;
}

/// Plus petit et plus grand montant publiés.
class FourchettePrix {
  /// Crée la fourchette.
  const FourchettePrix({required this.minimum, required this.maximum});

  /// Plus petit montant, en DT.
  final int minimum;

  /// Plus grand montant, en DT.
  final int maximum;
}
