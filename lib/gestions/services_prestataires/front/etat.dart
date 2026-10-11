import 'package:flutter/foundation.dart';

import 'package:flutter_android_app/core/db/nexus_database.dart';
import 'package:flutter_android_app/gestions/devis_contrats/back/contrat.dart';
import 'package:flutter_android_app/gestions/devis_contrats/back/demande_devis.dart';
import 'package:flutter_android_app/gestions/devis_contrats/devis_contrats_module.dart';
import 'package:flutter_android_app/gestions/services_prestataires/back/offered_service.dart';
import 'package:flutter_android_app/gestions/services_prestataires/back/services_table.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/modele.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/texte.dart';
import 'package:flutter_android_app/gestions/utilisateurs/back/user_account.dart';
import 'package:flutter_android_app/gestions/utilisateurs/utilisateurs_module.dart';

/// Offres, compétences, tarifs et créneaux des prestataires inscrits.
class ServicesPrestatairesEtat extends ChangeNotifier {
  /// Pose les offres de démonstration des comptes prestataires.
  ServicesPrestatairesEtat() {
    _semer();
    utilisateursStore.addListener(notifyListeners);
    devisContratsStore.addListener(notifyListeners);
  }

  /// Suppléments proposés sur un tarif.
  static const supplementsConnus = ['Étage', 'Cartons'];

  final List<OffreService> _services = [];
  final Map<String, EtatCreneau> _creneaux = {};
  int _sequence = 0;

  /// Recharge offres et créneaux depuis SQLite.
  Future<void> charger() async {
    final offres = await nexusDb.charger(tableOffres, _services.map(ligneOffre));
    final creneaux = await nexusDb.charger(tableCreneaux, [
      for (final entry in _creneaux.entries) _ligneCreneau(entry.key, entry.value),
    ]);
    if (offres != null) {
      _services
        ..clear()
        ..addAll(offres.map(offreDepuis));
    }
    if (creneaux != null) {
      _creneaux
        ..clear()
        ..addEntries([
          for (final ligne in creneaux)
            MapEntry(
              ligne['id']! as String,
              EtatCreneau.values.byName(ligne['etat']! as String),
            ),
        ]);
    }
    _sequence = prochainNumero(_services.map((item) => item.id), 'service-', 1) - 1;
    notifyListeners();
  }

  UserAccount? get _session => utilisateursStore.current;

  /// Whether the open admin supervises the catalogue.
  bool get adminView =>
      _session?.hasRole(UserRole.admin) == true && !utilisateursStore.clientInterface;

  /// Whether the open account manages its own services.
  bool get providerView => _session?.hasRole(UserRole.provider) == true && !adminView;

  /// Compte prestataire ouvert.
  String get prestataireConnecteId => _session?.id ?? '';

  /// Nom affiché sur la fiche du compte ouvert.
  String get nomProfil => _session?.fullName ?? 'Prestataire';

  /// Demandes de devis encore sans réponse pour le prestataire ouvert.
  int get demandesDevisEnAttente {
    return devisContratsStore
        .demandesRecues()
        .where((demande) => demande.statut == StatutDemande.recue)
        .length;
  }

  /// Prestataires confirmés et actifs, avec le secteur de leur métier.
  List<Prestataire> get prestataires {
    return [
      for (final account in utilisateursStore.accounts)
        if (account.hasRole(UserRole.provider) && account.confirmed && !account.suspended)
          Prestataire(
            id: account.id,
            nom: account.fullName,
            secteur: secteurDuMetier(account.providerProfile?.service),
          ),
    ];
  }

  /// Toutes les offres, dans l'ordre de publication.
  List<OffreService> get services => List.unmodifiable(_services);

  /// Offres du prestataire ouvert.
  List<OffreService> get servicesConnecte => servicesDe(prestataireConnecteId);

  /// Offres encore publiées par le prestataire ouvert.
  List<OffreService> get servicesPublies => servicesPubliesDe(prestataireConnecteId);

  /// Offres publiées par [prestataireId].
  List<OffreService> servicesPubliesDe(String prestataireId) {
    return servicesDe(prestataireId)
        .where((service) => service.approuve && service.publie)
        .toList();
  }

  /// Offres qu'un client peut trouver : publiées, tarifées, d'un compte actif.
  List<OffreService> get offresVisibles {
    final actifs = {for (final prestataire in prestataires) prestataire.id};
    return [
      for (final service in _services)
        if (service.approuve &&
            service.publie &&
            service.tarif != null &&
            actifs.contains(service.prestataireId))
          service,
    ];
  }

  /// Offres du catalogue, au format lu par la demande de devis.
  List<OfferedService> get catalogue => offresVisibles.map(versCatalogue).toList();

  /// Offre [id], ou `null`.
  OffreService? offre(String id) => _trouver(id);

  /// Offre prête pour la demande de devis.
  OfferedService versCatalogue(OffreService service) {
    final tarif = service.tarif;
    return OfferedService(
      id: service.id,
      title: service.nom,
      providerName: nomPrestataire(service.prestataireId),
      city: service.ville,
      rate: tarif == null
          ? 'Tarif à définir'
          : '${tarif.montantDt} DT · ${libelleTypeTarif(tarif.type).toLowerCase()}',
      icon: OfferedService.iconFor(service.nom),
      prestataireId: service.prestataireId,
      prestations: [
        for (final competence in service.competencesVisibles) competence.libelle,
      ],
      prixBase: tarif?.montantDt,
    );
  }

  /// Demandes qu'un admin n'a pas encore tranchées.
  List<OffreService> get demandesEnAttente {
    return _services.where((service) => service.enAttente).toList();
  }

  /// Saisies libres encore à valider, toutes offres confondues.
  List<(OffreService, CompetenceChoisie)> get competencesAValider {
    return [
      for (final service in _services)
        for (final competence in service.competences)
          if (!competence.validee) (service, competence),
    ];
  }

  /// Profil déjà choisi pour le compte ouvert.
  SecteurCompte get secteurConnecte => _secteurDe(prestataireConnecteId);

  /// Prestataires du même secteur qu'une offre.
  List<Prestataire> prestatairesDuSecteur(SecteurCompte secteur) {
    return prestataires.where((prestataire) => prestataire.secteur == secteur).toList();
  }

  /// Nom affiché d'un prestataire.
  String nomPrestataire(String id) => utilisateursStore.find(id)?.fullName ?? 'Prestataire';

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

  /// Zone montrée en tête de la fiche du compte ouvert.
  String get zoneAffichee => zoneDe(prestataireConnecteId);

  /// Zones des offres publiées par [prestataireId].
  String zoneDe(String prestataireId) {
    final zones = <String>[];
    for (final service in servicesPubliesDe(prestataireId)) {
      if (!zones.contains(service.zone)) {
        zones.add(service.zone);
      }
    }
    if (zones.isEmpty) {
      return 'Zone non indiquée';
    }
    return zones.join(', ');
  }

  /// Fourchette des tarifs publiés par le compte ouvert.
  FourchettePrix? get fourchettePrix => fourchetteDe(prestataireConnecteId);

  /// Fourchette des tarifs publiés par [prestataireId].
  FourchettePrix? fourchetteDe(String prestataireId) {
    final montants = [
      for (final service in servicesPubliesDe(prestataireId))
        if (service.tarif != null) service.tarif!.montantDt,
    ]..sort();
    if (montants.isEmpty) {
      return null;
    }
    return FourchettePrix(minimum: montants.first, maximum: montants.last);
  }

  /// Prix affiché sur la fiche du compte ouvert.
  String get libelleFourchette => libelleFourchetteDe(prestataireConnecteId);

  /// Prix affiché sur la fiche de [prestataireId].
  String libelleFourchetteDe(String prestataireId) {
    final prix = fourchetteDe(prestataireId);
    if (prix == null) {
      return 'Aucun tarif publié';
    }
    if (prix.minimum != prix.maximum) {
      return '${prix.minimum} – ${prix.maximum} DT';
    }
    final avecTarif = [
      for (final service in servicesPubliesDe(prestataireId))
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

  /// Offres que la fiche montre : publiées, et tarifées hors aperçu.
  List<OffreService> servicesDeLaFiche({required bool apercu, String? prestataireId}) {
    final publies = servicesPubliesDe(prestataireId ?? prestataireConnecteId);
    if (apercu) {
      return publies;
    }
    return [
      for (final service in publies)
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

  /// État d'un bloc du prestataire ouvert.
  ///
  /// Un contrat validé ou en cours verrouille le bloc de sa date et de son heure.
  EtatCreneau etatCreneau(DateTime jour, MomentJournee moment) {
    if (_estVerrouille(jour, moment)) {
      return EtatCreneau.verrouille;
    }
    final stocke = _creneaux[_cle(prestataireConnecteId, jour, moment)];
    if (stocke != null) {
      return stocke;
    }
    return EtatCreneau.ferme;
  }

  /// Envoie une demande dans le secteur du compte.
  ///
  /// Le nom doit appartenir à ce secteur. Le service reste invisible
  /// tant que l'admin ne l'approuve pas.
  String? publier({
    required String nom,
    required String description,
    required String ville,
    required int rayonKm,
    required VehiculeService vehicule,
    required int tailleEquipe,
  }) {
    if (!providerView) return 'Seul un prestataire peut proposer un service.';
    final texte = nom.trim();
    final secteur = secteurConnecte;
    if (!servicesDuSecteur(secteur).any((service) => _meme(service, texte))) {
      return 'Ce service n\'appartient pas à votre secteur.';
    }
    final service = OffreService(
      id: _nouvelId(),
      prestataireId: prestataireConnecteId,
      nom: texte,
      description: description.trim(),
      ville: ville.trim(),
      rayonKm: rayonKm,
      vehicule: vehicule,
      tailleEquipe: tailleEquipe,
      secteur: secteur,
    );
    _services.add(service);
    _enregistrer(service);
    notifyListeners();
    return null;
  }

  /// Le prestataire ou l'admin corrige la zone et l'équipe d'une offre.
  String? modifier(
    String id, {
    required String description,
    required String ville,
    required int rayonKm,
    required VehiculeService vehicule,
    required int tailleEquipe,
  }) {
    final service = _trouver(id);
    if (service == null) return 'Service introuvable.';
    if (!_peutGerer(service)) return 'Ce service ne vous appartient pas.';
    if (ville.trim().isEmpty) return 'La ville manque.';
    service
      ..description = description.trim()
      ..ville = ville.trim()
      ..rayonKm = rayonKm
      ..vehicule = vehicule
      ..tailleEquipe = tailleEquipe;
    _enregistrer(service);
    notifyListeners();
    return null;
  }

  /// Supprime définitivement une offre. Les devis déjà envoyés restent.
  String? supprimer(String id) {
    final service = _trouver(id);
    if (service == null) return 'Service introuvable.';
    if (!_peutGerer(service)) return 'Ce service ne vous appartient pas.';
    _services.remove(service);
    nexusDb.supprimer(tableOffres, id);
    notifyListeners();
    return null;
  }

  /// Publie une demande en attente.
  void approuver(String id) {
    final service = _trouver(id);
    if (!adminView || service == null || !service.enAttente) {
      return;
    }
    service.approuve = true;
    service.publie = true;
    service.motifRefus = null;
    _enregistrer(service);
    notifyListeners();
  }

  /// Refuse une demande et garde le motif pour le prestataire.
  void refuser(String id, String motif) {
    final service = _trouver(id);
    final texte = motif.trim();
    if (!adminView || service == null || !service.enAttente || texte.isEmpty) {
      return;
    }
    service.approuve = false;
    service.publie = false;
    service.motifRefus = texte;
    _enregistrer(service);
    notifyListeners();
  }

  /// L'admin valide une compétence saisie librement.
  void validerCompetence(String serviceId, String libelle) {
    final service = _trouver(serviceId);
    if (!adminView || service == null) return;
    final index = service.competences.indexWhere(
      (competence) => _meme(competence.libelle, libelle),
    );
    if (index < 0) return;
    service.competences[index] = CompetenceChoisie(libelle: libelle, validee: true);
    _enregistrer(service);
    notifyListeners();
  }

  /// Retire l'offre des résultats. Les contrats passés ne sont pas ici.
  void masquer(String id) {
    final service = _trouver(id);
    if (service == null || !service.approuve || !service.publie) {
      return;
    }
    service.publie = false;
    _enregistrer(service);
    notifyListeners();
  }

  /// Remet l'offre dans les résultats.
  void afficher(String id) {
    final service = _trouver(id);
    if (service == null || !service.approuve || service.publie) {
      return;
    }
    service.publie = true;
    _enregistrer(service);
    notifyListeners();
  }

  /// Affecte l'offre à un prestataire du même secteur.
  void affecter(String serviceId, String prestataireId) {
    final service = _trouver(serviceId);
    final cible = _prestataire(prestataireId);
    if (!adminView ||
        service == null ||
        cible == null ||
        cible.secteur != service.secteur ||
        service.prestataireId == prestataireId) {
      return;
    }
    service.prestataireId = prestataireId;
    _enregistrer(service);
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
    _enregistrer(service);
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
    _enregistrer(service);
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
    _enregistrer(service);
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
    _enregistrer(service);
    notifyListeners();
  }

  /// Ouvre ou ferme un bloc. Un bloc verrouillé ne bouge pas.
  void definirCreneau(DateTime jour, MomentJournee moment, bool ouvert) {
    if (_estVerrouille(jour, moment) || prestataireConnecteId.isEmpty) {
      return;
    }
    final cle = _cle(prestataireConnecteId, jour, moment);
    final etat = ouvert ? EtatCreneau.ouvert : EtatCreneau.ferme;
    _creneaux[cle] = etat;
    nexusDb.enregistrer(tableCreneaux, _ligneCreneau(cle, etat));
    notifyListeners();
  }

  void _semer() {
    _ajouter(
      prestataireId: 'u-provider',
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
      prestataireId: 'u-batiment',
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
      prestataireId: 'u-batiment',
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
      prestataireId: 'u-electricite',
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
      prestataireId: 'u-electricite',
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
      prestataireId: 'u-batiment',
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
      prestataireId: 'u-maison',
      nom: 'Ménage',
      description: 'Entretien de la maison.',
      ville: 'Ariana',
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
      prestataireId: 'u-maison',
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
      prestataireId: 'u-maison',
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
    final lundi = lundiDe(DateTime.now());
    for (final (decalage, moment) in [
      (1, MomentJournee.matin),
      (3, MomentJournee.apresMidi),
      (5, MomentJournee.apresMidi),
    ]) {
      _creneaux[_cle('u-provider', lundi.add(Duration(days: decalage)), moment)] =
          EtatCreneau.ouvert;
    }
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
        secteur: secteurDuMetier(nom),
        competences: [...competences],
      ),
    );
  }

  bool _peutGerer(OffreService service) {
    return adminView || (providerView && service.prestataireId == prestataireConnecteId);
  }

  /// Un contrat validé ou en cours du prestataire ouvert tient ce bloc.
  bool _estVerrouille(DateTime jour, MomentJournee moment) {
    final id = prestataireConnecteId;
    final date = dateSeule(jour);
    return devisContratsStore.tousLesContrats().any(
      (contrat) =>
          contrat.prestataireId == id &&
          (contrat.statut == StatutContrat.valide ||
              contrat.statut == StatutContrat.enCours) &&
          dateSeule(contrat.date) == date &&
          _momentDe(contrat.heure) == moment,
    );
  }

  MomentJournee _momentDe(String heure) {
    final h = int.tryParse(heure.split(':').first.trim()) ?? 9;
    if (h < 12) return MomentJournee.matin;
    if (h < 18) return MomentJournee.apresMidi;
    return MomentJournee.soir;
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
    for (final prestataire in prestataires) {
      if (prestataire.id == id) {
        return prestataire;
      }
    }
    return null;
  }

  SecteurCompte _secteurDe(String prestataireId) {
    final metier = utilisateursStore.find(prestataireId)?.providerProfile?.service;
    return secteurDuMetier(metier);
  }

  OffreService? _trouver(String id) {
    for (final service in _services) {
      if (service.id == id) {
        return service;
      }
    }
    return null;
  }

  void _enregistrer(OffreService service) {
    nexusDb.enregistrer(tableOffres, ligneOffre(service));
  }

  Map<String, Object?> _ligneCreneau(String cle, EtatCreneau etat) {
    final morceaux = cle.split('|');
    final date = morceaux[1].split('-').map(int.parse).toList();
    return ligneCreneau(
      cle: cle,
      prestataireId: morceaux[0],
      jour: DateTime(date[0], date[1], date[2]),
      moment: MomentJournee.values.byName(morceaux[2]),
      etat: etat,
    );
  }

  String _nouvelId() {
    _sequence += 1;
    return 'service-$_sequence';
  }

  String _cle(String prestataireId, DateTime jour, MomentJournee moment) {
    final date = dateSeule(jour);
    return '$prestataireId|${date.year}-${date.month}-${date.day}|${moment.name}';
  }

  bool _meme(String a, String b) {
    return a.trim().toLowerCase() == b.trim().toLowerCase();
  }
}
