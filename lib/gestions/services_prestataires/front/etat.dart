import 'package:flutter/foundation.dart';

import 'package:flutter_android_app/gestions/services_prestataires/back/services_prestataires_api.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/modele.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/texte.dart';

/// Mémoire d'écran des services, sans appel au back.
class ServicesPrestatairesEtat extends ChangeNotifier {
  /// Relie l'écran à [back] et pose l'exemple du scénario.
  ServicesPrestatairesEtat(this.back) {
    _semer();
  }

  /// Contrat back branché. L'interface ne l'appelle pas encore.
  final ServicesPrestatairesApi back;

  /// Suppléments proposés sur un tarif.
  static const supplementsConnus = ['Étage', 'Cartons'];

  /// Demande de devis de Sana, lue plus tard depuis Devis et contrats.
  static const demandesDevisEnAttente = 1;

  /// Nom de la fiche, lu plus tard depuis le profil Utilisateurs.
  String nomProfil = 'Ahmed';

  /// Prestataire dont le tableau de bord est ouvert.
  static const prestataireConnecteId = 'connecte';

  final List<Prestataire> _prestataires = const [
    Prestataire(
      id: prestataireConnecteId,
      nom: 'Prestataire',
      secteur: SecteurCompte.demenagement,
    ),
    Prestataire(
      id: 'batiment',
      nom: 'Prestataire bâtiment',
      secteur: SecteurCompte.batiment,
    ),
    Prestataire(
      id: 'maison',
      nom: 'Prestataire maison',
      secteur: SecteurCompte.maison,
    ),
    Prestataire(
      id: 'electricien',
      nom: 'Prestataire électricien',
      secteur: SecteurCompte.electricite,
    ),
  ];

  final List<OffreService> _services = [];
  final Map<String, EtatCreneau> _creneaux = {};
  int _sequence = 0;

  /// Tous les prestataires.
  List<Prestataire> get prestataires => List.unmodifiable(_prestataires);

  /// Toutes les offres, dans l'ordre de publication.
  List<OffreService> get services => List.unmodifiable(_services);

  /// Offres du prestataire dont le tableau de bord est ouvert.
  List<OffreService> get servicesConnecte => servicesDe(prestataireConnecteId);

  /// Offres encore publiées par le prestataire connecté.
  List<OffreService> get servicesPublies {
    return servicesConnecte.where((service) => service.approuve && service.publie).toList();
  }

  /// Demandes qu'un admin n'a pas encore tranchées.
  List<OffreService> get demandesEnAttente {
    return _services.where((service) => service.enAttente).toList();
  }

  /// Profil déjà choisi pour le compte ouvert.
  SecteurCompte get secteurConnecte => _secteurDe(prestataireConnecteId);

  /// Prestataires du même secteur qu'une offre.
  List<Prestataire> prestatairesDuSecteur(SecteurCompte secteur) {
    return _prestataires.where((prestataire) => prestataire.secteur == secteur).toList();
  }

  /// Nom affiché d'un prestataire.
  String nomPrestataire(String id) {
    if (id == prestataireConnecteId) {
      return nomProfil;
    }
    for (final prestataire in _prestataires) {
      if (prestataire.id == id) {
        return prestataire.nom;
      }
    }
    return nomProfil;
  }

  /// Offres affectées à [prestataireId].
  List<OffreService> servicesDe(String prestataireId) {
    return _services
        .where((service) => service.prestataireId == prestataireId)
        .toList();
  }

  /// Vrai dès qu'une offre est publiée. Sinon le tableau de bord se replie.
  bool get aUnServicePublie => servicesPublies.isNotEmpty;

  /// Lundi de la semaine affichée.
  DateTime get lundiCourant => lundiDe(DateTime.now());

  /// Aujourd'hui, sans l'heure.
  DateTime get aujourdhui => dateSeule(DateTime.now());

  /// Zone montrée en tête de fiche.
  String get zoneAffichee {
    final zones = <String>[];
    for (final service in servicesPublies) {
      if (!zones.contains(service.zone)) {
        zones.add(service.zone);
      }
    }
    if (zones.isEmpty) {
      return 'Zone non indiquée';
    }
    return zones.join(', ');
  }

  /// Fourchette des tarifs publiés.
  FourchettePrix? get fourchettePrix {
    final montants = [
      for (final service in servicesPublies)
        if (service.tarif != null) service.tarif!.montantDt,
    ]..sort();
    if (montants.isEmpty) {
      return null;
    }
    return FourchettePrix(minimum: montants.first, maximum: montants.last);
  }

  /// Prix affiché sur la fiche.
  String get libelleFourchette {
    final prix = fourchettePrix;
    if (prix == null) {
      return 'Aucun tarif publié';
    }
    if (prix.minimum != prix.maximum) {
      return '${prix.minimum} – ${prix.maximum} DT';
    }
    final avecTarif = [
      for (final service in servicesPublies)
        if (service.tarif != null) service,
    ];
    if (avecTarif.length == 1) {
      final type = libelleTypeTarif(avecTarif.first.tarif!.type).toLowerCase();
      return '${prix.minimum} DT · $type';
    }
    return '${prix.minimum} DT';
  }

  /// Prochain bloc ouvert, encore devant nous.
  RefCreneau? get prochainCreneau {
    final maintenant = DateTime.now();
    final lundi = lundiDe(maintenant);
    for (var decalage = 0; decalage < 7; decalage++) {
      final jour = lundi.add(Duration(days: decalage));
      for (final moment in MomentJournee.values) {
        if (etatCreneau(jour, moment) != EtatCreneau.ouvert) {
          continue;
        }
        if (_estPasse(jour, moment, maintenant)) {
          continue;
        }
        return RefCreneau(jour: jour, moment: moment);
      }
    }
    return null;
  }

  /// Blocs fermés de la semaine. Un bloc verrouillé n'est pas un trou.
  List<RefCreneau> get trous {
    final lundi = lundiCourant;
    final liste = <RefCreneau>[];
    for (var decalage = 0; decalage < 7; decalage++) {
      final jour = lundi.add(Duration(days: decalage));
      for (final moment in MomentJournee.values) {
        if (etatCreneau(jour, moment) == EtatCreneau.ferme) {
          liste.add(RefCreneau(jour: jour, moment: moment));
        }
      }
    }
    return liste;
  }

  /// Offres que la fiche client peut montrer : publiées, et tarifées.
  List<OffreService> servicesDeLaFiche({required bool apercu}) {
    if (apercu) {
      return servicesPublies;
    }
    return [
      for (final service in servicesPublies)
        if (service.tarif != null) service,
    ];
  }

  /// Vrai si la pastille connue est cochée sur [serviceId].
  bool competenceConnueChoisie(String serviceId, String libelle) {
    final service = _trouver(serviceId);
    if (service == null) {
      return false;
    }
    return service.competences.any(
      (competence) => competence.validee && _meme(competence.libelle, libelle),
    );
  }

  /// Saisies libres d'un service, encore en attente de l'admin.
  List<CompetenceChoisie> competencesEnAttenteDe(String serviceId) {
    final service = _trouver(serviceId);
    if (service == null) {
      return const [];
    }
    return service.competences.where((competence) => !competence.validee).toList();
  }

  /// État d'un bloc. Samedi matin reste pris par une prestation confirmée.
  EtatCreneau etatCreneau(DateTime jour, MomentJournee moment) {
    if (_estVerrouille(jour, moment)) {
      return EtatCreneau.verrouille;
    }
    final stocke = _creneaux[_cle(jour, moment)];
    if (stocke != null) {
      return stocke;
    }
    return EtatCreneau.ferme;
  }

  /// Envoie une demande dans le secteur du compte.
  ///
  /// Le nom doit appartenir à ce secteur. Le service reste invisible
  /// tant que l'admin ne l'approuve pas.
  void publier({
    required String nom,
    required String description,
    required String ville,
    required int rayonKm,
    required VehiculeService vehicule,
    required int tailleEquipe,
  }) {
    final texte = nom.trim();
    final secteur = secteurConnecte;
    if (!servicesDuSecteur(secteur).any((service) => _meme(service, texte))) {
      return;
    }
    _services.add(
      OffreService(
        id: _nouvelId(),
        prestataireId: prestataireConnecteId,
        nom: texte,
        description: description.trim(),
        ville: ville.trim(),
        rayonKm: rayonKm,
        vehicule: vehicule,
        tailleEquipe: tailleEquipe,
        secteur: secteur,
      ),
    );
    notifyListeners();
  }

  /// Publie une demande en attente.
  void approuver(String id) {
    final service = _trouver(id);
    if (service == null || !service.enAttente) {
      return;
    }
    service.approuve = true;
    service.publie = true;
    service.motifRefus = null;
    notifyListeners();
  }

  /// Refuse une demande et garde le motif pour le prestataire.
  void refuser(String id, String motif) {
    final service = _trouver(id);
    final texte = motif.trim();
    if (service == null || !service.enAttente || texte.isEmpty) {
      return;
    }
    service.approuve = false;
    service.publie = false;
    service.motifRefus = texte;
    notifyListeners();
  }

  /// Retire l'offre des résultats. Les contrats passés ne sont pas ici.
  void masquer(String id) {
    final service = _trouver(id);
    if (service == null || !service.approuve || !service.publie) {
      return;
    }
    service.publie = false;
    notifyListeners();
  }

  /// Remet l'offre dans les résultats.
  void afficher(String id) {
    final service = _trouver(id);
    if (service == null || !service.approuve || service.publie) {
      return;
    }
    service.publie = true;
    notifyListeners();
  }

  /// Affecte l'offre à un prestataire du même secteur.
  void affecter(String serviceId, String prestataireId) {
    final service = _trouver(serviceId);
    final cible = _prestataire(prestataireId);
    if (service == null ||
        cible == null ||
        cible.secteur != service.secteur ||
        service.prestataireId == prestataireId) {
      return;
    }
    service.prestataireId = prestataireId;
    notifyListeners();
  }

  /// Pose ou remplace le tarif d'une offre.
  void definirTarif(String id, TarifService tarif) {
    final service = _trouver(id);
    if (service == null) {
      return;
    }
    service.tarif = TarifService(
      type: tarif.type,
      montantDt: tarif.montantDt,
      inclus: tarif.inclus.trim(),
      enPlus: List.unmodifiable(tarif.enPlus),
    );
    notifyListeners();
  }

  /// Coche ou retire une pastille connue de [serviceId].
  void basculerCompetenceConnue(String serviceId, String libelle, bool choisir) {
    final service = _trouver(serviceId);
    if (service == null) {
      return;
    }
    service.competences.removeWhere(
      (competence) => _meme(competence.libelle, libelle),
    );
    if (choisir) {
      service.competences.add(CompetenceChoisie(libelle: libelle, validee: true));
    }
    notifyListeners();
  }

  /// Ajoute une saisie libre au service, ou coche la pastille connue équivalente.
  AjoutCompetence ajouterCompetenceLibre(String serviceId, String libelle) {
    final service = _trouver(serviceId);
    if (service == null) {
      return AjoutCompetence.doublon;
    }
    final texte = libelle.trim();
    for (final connue in competencesDuSecteur(service.secteur)) {
      if (_meme(connue, texte)) {
        basculerCompetenceConnue(serviceId, connue, true);
        return AjoutCompetence.dejaConnue;
      }
    }
    if (service.competences.any((competence) => _meme(competence.libelle, texte))) {
      return AjoutCompetence.doublon;
    }
    service.competences.add(CompetenceChoisie(libelle: texte, validee: false));
    notifyListeners();
    return AjoutCompetence.ajoutee;
  }

  /// Retire une pastille du service, connue ou en attente.
  void retirerCompetence(String serviceId, String libelle) {
    final service = _trouver(serviceId);
    if (service == null) {
      return;
    }
    service.competences.removeWhere(
      (competence) => _meme(competence.libelle, libelle),
    );
    notifyListeners();
  }

  /// Ouvre ou ferme un bloc. Un bloc verrouillé ne bouge pas.
  void definirCreneau(DateTime jour, MomentJournee moment, bool ouvert) {
    if (_estVerrouille(jour, moment)) {
      return;
    }
    _creneaux[_cle(jour, moment)] = ouvert
        ? EtatCreneau.ouvert
        : EtatCreneau.ferme;
    notifyListeners();
  }

  void _semer() {
    _ajouter(
      prestataireId: prestataireConnecteId,
      nom: 'Déménagement',
      description: 'Transport de meubles, avec camion et deux personnes.',
      ville: 'Grand Tunis',
      rayonKm: 25,
      vehicule: VehiculeService.camion,
      tailleEquipe: 2,
      tarif: const TarifService(
        type: TypeTarif.camion,
        montantDt: 150,
        inclus: 'Chargement et déchargement',
        enPlus: ['Étage sans ascenseur', 'Cartons'],
      ),
      competences: const [
        CompetenceChoisie(libelle: 'Conduite poids lourd', validee: true),
        CompetenceChoisie(libelle: 'Port de charges', validee: true),
        CompetenceChoisie(libelle: 'Démontage de cuisine', validee: false),
      ],
    );
    _ajouter(
      prestataireId: 'batiment',
      nom: 'Peinture',
      description: 'Murs et plafonds.',
      ville: 'Tunis',
      rayonKm: 15,
      vehicule: VehiculeService.aucun,
      tailleEquipe: 2,
      tarif: const TarifService(
        type: TypeTarif.heure,
        montantDt: 40,
        inclus: 'Main d\'œuvre et préparation des murs',
        enPlus: [],
      ),
      competences: const [
        CompetenceChoisie(libelle: 'Préparation des murs', validee: true),
        CompetenceChoisie(libelle: 'Finition', validee: true),
      ],
    );
    _ajouter(
      prestataireId: 'batiment',
      nom: 'Plomberie',
      description: 'Fuites, robinets et évacuations.',
      ville: 'Tunis',
      rayonKm: 20,
      vehicule: VehiculeService.voiture,
      tailleEquipe: 1,
      tarif: const TarifService(
        type: TypeTarif.heure,
        montantDt: 55,
        inclus: 'Déplacement et main d\'œuvre',
        enPlus: [],
      ),
      competences: const [
        CompetenceChoisie(libelle: 'Recherche de fuite', validee: true),
        CompetenceChoisie(libelle: 'Robinetterie', validee: true),
      ],
    );
    _ajouter(
      prestataireId: 'electricien',
      nom: 'Électricité',
      description: 'Prises, éclairage et tableau.',
      ville: 'Ariana',
      rayonKm: 18,
      vehicule: VehiculeService.voiture,
      tailleEquipe: 1,
      tarif: const TarifService(
        type: TypeTarif.heure,
        montantDt: 50,
        inclus: 'Déplacement et main d\'œuvre',
        enPlus: [],
      ),
      competences: const [
        CompetenceChoisie(libelle: 'Tableau électrique', validee: true),
        CompetenceChoisie(libelle: 'Éclairage', validee: true),
      ],
    );
    _ajouter(
      prestataireId: 'electricien',
      nom: 'Dépannage électrique',
      description: 'Panne, disjoncteur et prises.',
      ville: 'Ariana',
      rayonKm: 18,
      vehicule: VehiculeService.voiture,
      tailleEquipe: 1,
      tarif: const TarifService(
        type: TypeTarif.heure,
        montantDt: 45,
        inclus: 'Déplacement et diagnostic',
        enPlus: [],
      ),
      competences: const [
        CompetenceChoisie(libelle: 'Dépannage', validee: true),
        CompetenceChoisie(libelle: 'Éclairage', validee: true),
      ],
    );
    _ajouter(
      prestataireId: 'batiment',
      nom: 'Menuiserie',
      description: 'Portes, placards et ajustements.',
      ville: 'Tunis',
      rayonKm: 25,
      vehicule: VehiculeService.camion,
      tailleEquipe: 2,
      tarif: const TarifService(
        type: TypeTarif.heure,
        montantDt: 70,
        inclus: 'Main d\'œuvre',
        enPlus: [],
      ),
      competences: const [
        CompetenceChoisie(libelle: 'Portes', validee: true),
        CompetenceChoisie(libelle: 'Placards', validee: true),
      ],
    );
    _ajouter(
      prestataireId: 'maison',
      nom: 'Ménage',
      description: 'Entretien de la maison.',
      ville: 'Grand Tunis',
      rayonKm: 10,
      vehicule: VehiculeService.aucun,
      tailleEquipe: 1,
      tarif: const TarifService(
        type: TypeTarif.heure,
        montantDt: 25,
        inclus: 'Nettoyage des pièces',
        enPlus: [],
      ),
      competences: const [
        CompetenceChoisie(libelle: 'Entretien courant', validee: true),
      ],
    );
    _ajouter(
      prestataireId: 'maison',
      nom: 'Jardinage',
      description: 'Tonte et entretien du jardin.',
      ville: 'La Marsa',
      rayonKm: 12,
      vehicule: VehiculeService.voiture,
      tailleEquipe: 2,
      tarif: const TarifService(
        type: TypeTarif.heure,
        montantDt: 35,
        inclus: 'Tonte et ramassage',
        enPlus: [],
      ),
      competences: const [
        CompetenceChoisie(libelle: 'Tonte', validee: true),
        CompetenceChoisie(libelle: 'Taille', validee: true),
      ],
    );
    _ajouter(
      prestataireId: 'maison',
      nom: 'Climatisation',
      description: 'Pose et entretien d\'un climatiseur.',
      ville: 'Tunis',
      rayonKm: 20,
      vehicule: VehiculeService.voiture,
      tailleEquipe: 1,
      tarif: const TarifService(
        type: TypeTarif.forfait,
        montantDt: 80,
        inclus: 'Contrôle et nettoyage',
        enPlus: [],
      ),
      competences: const [
        CompetenceChoisie(libelle: 'Entretien climatiseur', validee: true),
      ],
    );
    final samedi = lundiDe(DateTime.now()).add(const Duration(days: 5));
    _creneaux[_cle(samedi, MomentJournee.apresMidi)] = EtatCreneau.ouvert;
  }

  void _ajouter({
    required String prestataireId,
    required String nom,
    required String description,
    required String ville,
    required int rayonKm,
    required VehiculeService vehicule,
    required int tailleEquipe,
    required TarifService tarif,
    List<CompetenceChoisie> competences = const [],
  }) {
    _services.add(
      OffreService(
        id: _nouvelId(),
        prestataireId: prestataireId,
        nom: nom,
        description: description,
        ville: ville,
        rayonKm: rayonKm,
        vehicule: vehicule,
        tailleEquipe: tailleEquipe,
        approuve: true,
        publie: true,
        tarif: tarif,
        secteur: _secteurDe(prestataireId),
        competences: [...competences],
      ),
    );
  }

  /// Samedi matin est tenu par le contrat de Sana.
  bool _estVerrouille(DateTime jour, MomentJournee moment) {
    return jour.weekday == DateTime.saturday && moment == MomentJournee.matin;
  }

  bool _estPasse(DateTime jour, MomentJournee moment, DateTime maintenant) {
    final aujourdhui = dateSeule(maintenant);
    final date = dateSeule(jour);
    if (date.isBefore(aujourdhui)) {
      return true;
    }
    if (date.isAfter(aujourdhui)) {
      return false;
    }
    final fin = switch (moment) {
      MomentJournee.matin => 12,
      MomentJournee.apresMidi => 18,
      MomentJournee.soir => 22,
    };
    return maintenant.hour >= fin;
  }

  Prestataire? _prestataire(String id) {
    for (final prestataire in _prestataires) {
      if (prestataire.id == id) {
        return prestataire;
      }
    }
    return null;
  }

  SecteurCompte _secteurDe(String prestataireId) {
    return _prestataire(prestataireId)?.secteur ?? SecteurCompte.demenagement;
  }

  OffreService? _trouver(String id) {
    for (final service in _services) {
      if (service.id == id) {
        return service;
      }
    }
    return null;
  }

  String _nouvelId() {
    _sequence += 1;
    return 'service-$_sequence';
  }

  String _cle(DateTime jour, MomentJournee moment) {
    final date = dateSeule(jour);
    return '${date.year}-${date.month}-${date.day}-${moment.name}';
  }

  bool _meme(String a, String b) {
    return a.trim().toLowerCase() == b.trim().toLowerCase();
  }
}
