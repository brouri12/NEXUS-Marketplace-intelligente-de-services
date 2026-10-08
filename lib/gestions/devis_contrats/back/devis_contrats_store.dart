import 'package:flutter/foundation.dart';

import 'package:flutter_android_app/gestions/devis_contrats/back/contrat.dart';
import 'package:flutter_android_app/gestions/devis_contrats/back/demande_devis.dart';
import 'package:flutter_android_app/gestions/devis_contrats/back/devis.dart';
import 'package:flutter_android_app/gestions/devis_contrats/back/modification_contrat.dart';
import 'package:flutter_android_app/gestions/devis_contrats/back/option_ligne.dart';
import 'package:flutter_android_app/gestions/utilisateurs/back/user_account.dart';
import 'package:flutter_android_app/gestions/utilisateurs/utilisateurs_module.dart';

/// Devis, contrats et modifications, branchés sur les comptes déjà ouverts.
class DevisContratsStore extends ChangeNotifier {
  /// Crée le back local avec les comptes Sara, Amine et le devis d'exemple.
  DevisContratsStore() {
    const optionsExemple = [
      OptionLigne(label: 'Camion', prix: 40),
      OptionLigne(label: '3 personnes', prix: 60),
      OptionLigne(label: 'Emballage', prix: 30),
      OptionLigne(label: 'Montage', prix: 25),
    ];
    _demandes = [
      DemandeDevis(
        id: 'dem-1',
        clientId: 'u-client',
        prestataireId: 'u-provider',
        service: 'Déménagement',
        date: _jourDemande,
        lieu: 'La Marsa',
        distanceKm: 18,
        prixBase: 100,
        prixParKm: 1,
        options: optionsExemple,
        statut: StatutDemande.recue,
      ),
    ];
    _devis = [
      Devis(
        id: 'dv-1',
        numero: 'DV-001',
        clientId: 'u-client',
        prestataireId: 'u-provider',
        service: 'Déménagement',
        lieu: 'La Marsa',
        date: _jourDevis,
        heure: '09:00',
        dureeEstimee: '4 heures',
        prixBase: 100,
        prixParKm: 1,
        distanceKm: 18,
        options: optionsExemple,
        conditions: 'Accès camion par la rue principale.',
        elementsInclus: 'Camion, équipe, emballage et montage.',
        elementsNonInclus: 'Cartons supplémentaires.',
        statut: StatutDevis.envoye,
      ),
      Devis(
        id: 'dv-2',
        numero: 'DV-002',
        clientId: 'u-client',
        prestataireId: 'u-provider',
        service: 'Déménagement',
        lieu: 'Carthage',
        date: _jourContrat,
        heure: '14:00',
        dureeEstimee: '3 heures',
        prixBase: 80,
        prixParKm: 1,
        distanceKm: 10,
        options: [OptionLigne(label: 'Camion', prix: 40)],
        conditions: 'Stationnement à confirmer la veille.',
        elementsInclus: 'Camion et chauffeur.',
        elementsNonInclus: 'Montage des meubles.',
        statut: StatutDevis.accepte,
        contratId: 'ct-1',
      ),
      Devis(
        id: 'dv-3',
        numero: 'DV-003',
        clientId: 'u-client',
        prestataireId: 'u-provider',
        service: 'Déménagement',
        lieu: 'Ariana',
        date: _jourExpire,
        heure: '08:00',
        dureeEstimee: '2 heures',
        prixBase: 80,
        prixParKm: 1,
        distanceKm: 6,
        options: [OptionLigne(label: 'Emballage', prix: 20)],
        conditions: 'Devis valable sept jours.',
        elementsInclus: 'Emballage.',
        elementsNonInclus: 'Transport.',
        statut: StatutDevis.expire,
      ),
    ];
    _contrats = [
      Contrat(
        id: 'ct-1',
        numero: 'CT-2026-001',
        devisId: 'dv-2',
        clientId: 'u-client',
        prestataireId: 'u-provider',
        service: 'Déménagement',
        date: _jourContrat,
        heure: '14:00',
        lieu: 'Carthage',
        options: [OptionLigne(label: 'Camion', prix: 40)],
        distanceKm: 10,
        prixAccepte: 130,
        conditions: 'Stationnement à confirmer la veille.',
        statut: StatutContrat.attenteSignaturePrestataire,
      ),
    ];
  }

  static final _jourDevis = DateTime(2026, 10, 10);
  static final _jourDemande = DateTime(2026, 10, 12);
  static final _jourContrat = DateTime(2026, 10, 8);
  static final _jourExpire = DateTime(2026, 9, 1);

  List<DemandeDevis> _demandes = [];
  List<Devis> _devis = [];
  List<Contrat> _contrats = [];
  List<ModificationContrat> _modifications = [];
  var _nextDevis = 4;
  var _nextDemande = 2;
  var _nextContrat = 2;
  var _nextModification = 1;

  /// Compte ouvert dans la gestion utilisateurs.
  UserAccount? get session => utilisateursStore.current;

  /// Whether the open admin is supervising, not using the client interface.
  bool get adminView =>
      session?.hasRole(UserRole.admin) == true && !utilisateursStore.clientInterface;

  /// Whether the open account acts as a provider.
  bool get providerView =>
      session?.hasRole(UserRole.provider) == true && !adminView;

  /// Whether the open account acts as a client.
  bool get clientView => session?.hasRole(UserRole.client) == true && !adminView;

  /// Nom du compte [id].
  String nomDe(String id) => utilisateursStore.find(id)?.fullName ?? 'Compte';

  /// Téléphone du compte [id].
  String telephoneDe(String id) => utilisateursStore.find(id)?.phone ?? '';

  /// Ville du compte [id], utilisée comme adresse ou zone.
  String villeDe(String id) => utilisateursStore.find(id)?.city ?? '';

  /// Nom du prestataire d'une demande, compte ou catalogue.
  String nomPrestataire(DemandeDevis demande) {
    final account = utilisateursStore.find(demande.prestataireId);
    if (account != null) return account.fullName;
    if (demande.prestataireNom.isNotEmpty) return demande.prestataireNom;
    return 'Compte';
  }

  /// Demande [id], ou `null`.
  DemandeDevis? findDemande(String id) => _first(_demandes, id);

  /// Devis [id], ou `null`.
  Devis? findDevis(String id) => _first(_devis, id);

  /// Contrat [id], ou `null`.
  Contrat? findContrat(String id) => _first(_contrats, id);

  /// Devis relié à [contrat], ou `null`.
  Devis? devisDuContrat(Contrat contrat) => findDevis(contrat.devisId);

  /// Contrat relié à [devis], ou `null`.
  Contrat? contratDuDevis(Devis devis) {
    final id = devis.contratId;
    if (id == null) return null;
    return findContrat(id);
  }

  /// Demandes encore visibles pour le prestataire ouvert.
  List<DemandeDevis> demandesRecues() {
    final id = session?.id;
    if (id == null || !providerView) return const [];
    return _sortedDemandes(
      _demandes.where(
        (demande) =>
            demande.prestataireId == id && demande.statut != StatutDemande.traitee,
      ),
    );
  }

  /// Devis préparés par le prestataire ouvert.
  List<Devis> devisPrestataire() {
    final id = session?.id;
    if (id == null || !providerView) return const [];
    return _sortedDevis(_devis.where((devis) => devis.prestataireId == id));
  }

  /// Devis destinés au client ouvert.
  List<Devis> devisClient() {
    final id = session?.id;
    if (id == null || !clientView) return const [];
    return _sortedDevis(_devis.where((devis) => devis.clientId == id));
  }

  /// Tous les devis, pour l'admin.
  List<Devis> devisAdmin() {
    if (!adminView) return const [];
    return _sortedDevis(_devis);
  }

  /// Contrats du prestataire ouvert.
  List<Contrat> contratsPrestataire() {
    final id = session?.id;
    if (id == null || !providerView) return const [];
    return _sortedContrats(_contrats.where((contrat) => contrat.prestataireId == id));
  }

  /// Contrats du client ouvert.
  List<Contrat> contratsClient() {
    final id = session?.id;
    if (id == null || !clientView) return const [];
    return _sortedContrats(_contrats.where((contrat) => contrat.clientId == id));
  }

  /// Tous les contrats, pour l'admin.
  List<Contrat> contratsAdmin() {
    if (!adminView) return const [];
    return _sortedContrats(_contrats);
  }

  /// Propositions d'un contrat, de la plus récente à la plus ancienne.
  List<ModificationContrat> modificationsDe(String contratId) {
    final items = [
      for (final item in _modifications)
        if (item.contratId == contratId) item,
    ]..sort((a, b) => b.creeeLe.compareTo(a.creeeLe));
    return List.unmodifiable(items);
  }

  /// Proposition encore sans réponse, ou `null`.
  ModificationContrat? modificationEnAttente(String contratId) {
    for (final item in modificationsDe(contratId)) {
      if (item.statut == StatutModification.proposee) return item;
    }
    return null;
  }

  /// Passe un devis envoyé à VU quand le client l'ouvre.
  void marquerVu(String id) {
    final user = session;
    final devis = findDevis(id);
    if (user == null || devis == null || user.id != devis.clientId) return;
    if (devis.statut != StatutDevis.envoye) return;
    _replaceDevis(devis.copyWith(statut: StatutDevis.vu));
    notifyListeners();
  }

  /// Le client envoie une demande avec seulement les éléments cochés.
  String? envoyerDemande({
    required String prestataireNom,
    required String service,
    required String date,
    required String lieu,
    required String distance,
    required List<OptionLigne> options,
  }) {
    final user = session;
    if (user == null || !user.hasRole(UserRole.client)) {
      return 'Seul un client peut demander un devis.';
    }
    if (options.isEmpty) return 'Cochez au moins un élément.';
    final jour = _lireDate(date);
    if (jour == null) return 'Indiquez la date au format JJ/MM/AAAA.';
    if (lieu.trim().isEmpty) return 'Indiquez le lieu.';
    final km = double.tryParse(distance.trim().replaceAll(',', '.'));
    if (km == null || km <= 0) return 'Indiquez la distance en kilomètres.';

    UserAccount? provider;
    for (final account in utilisateursStore.accounts) {
      if (account.fullName.toLowerCase() == prestataireNom.trim().toLowerCase() &&
          account.hasRole(UserRole.provider)) {
        provider = account;
        break;
      }
    }
    if (provider != null && provider.id == user.id) {
      return 'Vous ne pouvez pas vous adresser un devis.';
    }

    final numero = _nextDemande++;
    _demandes = [
      ..._demandes,
      DemandeDevis(
        id: 'dem-$numero',
        clientId: user.id,
        prestataireId: provider?.id ?? 'ext-$numero',
        prestataireNom: provider?.fullName ?? prestataireNom.trim(),
        service: service,
        date: jour,
        lieu: lieu.trim(),
        distanceKm: km,
        prixBase: prixBaseService(service),
        prixParKm: 1,
        options: options,
        statut: StatutDemande.recue,
      ),
    ];
    notifyListeners();
    return null;
  }

  /// Refuse une demande encore ouverte.
  String? refuserDemande(String id) {
    final user = session;
    if (user == null || !providerView) {
      return 'Seul un prestataire peut refuser une demande.';
    }
    final demande = findDemande(id);
    if (demande == null) return 'Demande introuvable.';
    if (demande.prestataireId != user.id) {
      return 'Cette demande ne vous est pas destinée.';
    }
    if (demande.statut != StatutDemande.recue) {
      return 'Cette demande n\'est plus ouverte.';
    }
    _replaceDemande(demande.copyWith(statut: StatutDemande.refusee));
    notifyListeners();
    return null;
  }

  /// Envoie le devis préparé depuis une demande.
  String? envoyerDevis({
    required String demandeId,
    required String date,
    required String heure,
    required String dureeEstimee,
    required String conditions,
    required String elementsInclus,
    required String elementsNonInclus,
  }) {
    final user = session;
    if (user == null || !providerView) {
      return 'Seul un prestataire peut envoyer un devis.';
    }
    final demande = findDemande(demandeId);
    if (demande == null) return 'Demande introuvable.';
    if (demande.prestataireId != user.id) {
      return 'Cette demande ne vous est pas destinée.';
    }
    if (demande.statut != StatutDemande.recue) {
      return 'Cette demande n\'est plus ouverte.';
    }
    final jour = _lireDate(date);
    if (jour == null) return 'Indiquez la date au format JJ/MM/AAAA.';
    if (heure.trim().isEmpty) return 'Indiquez l\'heure.';
    if (dureeEstimee.trim().isEmpty) return 'Indiquez la durée estimée.';

    final numero = _nextDevis++;
    final devis = Devis(
      id: 'dv-$numero',
      numero: 'DV-${numero.toString().padLeft(3, '0')}',
      demandeId: demande.id,
      clientId: demande.clientId,
      prestataireId: demande.prestataireId,
      service: demande.service,
      lieu: demande.lieu,
      date: jour,
      heure: heure.trim(),
      dureeEstimee: dureeEstimee.trim(),
      prixBase: demande.prixBase,
      prixParKm: demande.prixParKm,
      distanceKm: demande.distanceKm,
      options: demande.options,
      conditions: conditions.trim(),
      elementsInclus: elementsInclus.trim(),
      elementsNonInclus: elementsNonInclus.trim(),
      statut: StatutDevis.envoye,
    );
    _devis = [..._devis, devis];
    _replaceDemande(demande.copyWith(statut: StatutDemande.traitee));
    notifyListeners();
    return null;
  }

  /// Le client accepte le devis et un contrat est créé.
  String? accepterDevis(String id) {
    final user = session;
    final devis = findDevis(id);
    if (user == null || !clientView) return 'Seul le client peut accepter ce devis.';
    if (devis == null) return 'Devis introuvable.';
    if (devis.clientId != user.id) return 'Ce devis ne vous est pas destiné.';
    if (!devis.ouvrable) return 'Ce devis ne peut plus être accepté.';

    final numero = _nextContrat++;
    final contrat = Contrat(
      id: 'ct-$numero',
      numero: 'CT-2026-${numero.toString().padLeft(3, '0')}',
      devisId: devis.id,
      clientId: devis.clientId,
      prestataireId: devis.prestataireId,
      service: devis.service,
      date: devis.date,
      heure: devis.heure,
      lieu: devis.lieu,
      options: devis.options,
      distanceKm: devis.distanceKm,
      prixAccepte: devis.total,
      conditions: devis.conditions,
      statut: StatutContrat.attenteSignaturePrestataire,
    );
    _contrats = [..._contrats, contrat];
    _replaceDevis(
      devis.copyWith(statut: StatutDevis.accepte, contratId: contrat.id),
    );
    notifyListeners();
    return null;
  }

  /// Le client refuse le devis.
  String? refuserDevis(String id) {
    final user = session;
    final devis = findDevis(id);
    if (user == null || !clientView) return 'Seul le client peut refuser ce devis.';
    if (devis == null) return 'Devis introuvable.';
    if (devis.clientId != user.id) return 'Ce devis ne vous est pas destiné.';
    if (!devis.ouvrable) return 'Ce devis ne peut plus être refusé.';
    _replaceDevis(devis.copyWith(statut: StatutDevis.refuse));
    notifyListeners();
    return null;
  }

  /// Le prestataire signe son contrat.
  String? signerPrestataire(String id) {
    final user = session;
    final contrat = findContrat(id);
    if (user == null || !providerView) {
      return 'Seul le prestataire peut signer à cette étape.';
    }
    if (contrat == null) return 'Contrat introuvable.';
    if (contrat.prestataireId != user.id) return 'Ce contrat ne vous concerne pas.';
    if (contrat.signaturePrestataire) return 'Vous avez déjà signé.';
    if (contrat.statut == StatutContrat.annule) return 'Ce contrat est annulé.';
    _replaceContrat(
      contrat.copyWith(
        signaturePrestataire: true,
        signaturePrestataireLe: DateTime.now(),
        statut: StatutContrat.attenteSignatureClient,
      ),
    );
    notifyListeners();
    return null;
  }

  /// Le client signe après le prestataire.
  String? signerClient(String id) {
    final user = session;
    final contrat = findContrat(id);
    if (user == null || !clientView) return 'Seul le client peut signer à cette étape.';
    if (contrat == null) return 'Contrat introuvable.';
    if (contrat.clientId != user.id) return 'Ce contrat ne vous concerne pas.';
    if (!contrat.signaturePrestataire) {
      return 'Le prestataire doit signer avant vous.';
    }
    if (contrat.signatureClient) return 'Vous avez déjà signé.';
    _replaceContrat(
      contrat.copyWith(
        signatureClient: true,
        signatureClientLe: DateTime.now(),
        statut: StatutContrat.valide,
      ),
    );
    notifyListeners();
    return null;
  }

  /// Le prestataire propose un supplément, sans changer le contrat tout de suite.
  String? proposerModification({
    required String contratId,
    required String motif,
    required String supplement,
    required String nouvellesConditions,
  }) {
    final user = session;
    final contrat = findContrat(contratId);
    if (user == null || !providerView) {
      return 'Seul le prestataire peut proposer une modification.';
    }
    if (contrat == null) return 'Contrat introuvable.';
    if (contrat.prestataireId != user.id) return 'Ce contrat ne vous concerne pas.';
    if (contrat.statut == StatutContrat.annule) return 'Ce contrat est annulé.';
    if (modificationEnAttente(contrat.id) != null) {
      return 'Une proposition est déjà en attente du client.';
    }
    if (motif.trim().isEmpty) return 'Indiquez le motif.';
    final ajout = int.tryParse(supplement.trim());
    if (ajout == null || ajout < 0) return 'Indiquez un supplément en dinars.';

    final numero = _nextModification++;
    _modifications = [
      ..._modifications,
      ModificationContrat(
        id: 'mod-$numero',
        contratId: contrat.id,
        prestataireId: user.id,
        motif: motif.trim(),
        supplement: ajout,
        nouvellesConditions: nouvellesConditions.trim(),
        prixActuel: contrat.prixAccepte,
        statut: StatutModification.proposee,
        creeeLe: DateTime.now(),
      ),
    ];
    notifyListeners();
    return null;
  }

  /// Le client accepte la proposition et le montant du contrat change.
  String? accepterModification(String id) {
    final user = session;
    final modification = _findModification(id);
    if (user == null || !clientView) {
      return 'Seul le client peut accepter cette modification.';
    }
    if (modification == null) return 'Proposition introuvable.';
    final contrat = findContrat(modification.contratId);
    if (contrat == null) return 'Contrat introuvable.';
    if (contrat.clientId != user.id) return 'Ce contrat ne vous concerne pas.';
    if (modification.statut != StatutModification.proposee) {
      return 'Cette proposition n\'est plus ouverte.';
    }
    _replaceModification(modification.copyWith(statut: StatutModification.acceptee));
    _replaceContrat(
      contrat.copyWith(
        prixAccepte: modification.nouveauTotal,
        conditions: modification.nouvellesConditions.isEmpty
            ? contrat.conditions
            : modification.nouvellesConditions,
      ),
    );
    notifyListeners();
    return null;
  }

  /// Le client refuse. Le contrat garde son montant.
  String? refuserModification(String id) {
    final user = session;
    final modification = _findModification(id);
    if (user == null || !clientView) {
      return 'Seul le client peut refuser cette modification.';
    }
    if (modification == null) return 'Proposition introuvable.';
    final contrat = findContrat(modification.contratId);
    if (contrat == null || contrat.clientId != user.id) {
      return 'Ce contrat ne vous concerne pas.';
    }
    if (modification.statut != StatutModification.proposee) {
      return 'Cette proposition n\'est plus ouverte.';
    }
    _replaceModification(modification.copyWith(statut: StatutModification.refusee));
    notifyListeners();
    return null;
  }

  ModificationContrat? _findModification(String id) => _first(_modifications, id);

  DateTime? _lireDate(String raw) {
    final parts = raw.trim().split('/');
    if (parts.length != 3) return null;
    final jour = int.tryParse(parts[0]);
    final mois = int.tryParse(parts[1]);
    final annee = int.tryParse(parts[2]);
    if (jour == null || mois == null || annee == null) return null;
    if (mois < 1 || mois > 12 || jour < 1 || jour > 31 || annee < 2020) {
      return null;
    }
    return DateTime(annee, mois, jour);
  }

  T? _first<T extends Object>(List<T> items, String id) {
    for (final item in items) {
      if (_idOf(item) == id) return item;
    }
    return null;
  }

  String _idOf(Object item) {
    return switch (item) {
      DemandeDevis demande => demande.id,
      Devis devis => devis.id,
      Contrat contrat => contrat.id,
      ModificationContrat modification => modification.id,
      _ => '',
    };
  }

  List<DemandeDevis> _sortedDemandes(Iterable<DemandeDevis> items) {
    final list = items.toList()..sort((a, b) => b.date.compareTo(a.date));
    return List.unmodifiable(list);
  }

  List<Devis> _sortedDevis(Iterable<Devis> items) {
    final list = items.toList()..sort((a, b) => b.date.compareTo(a.date));
    return List.unmodifiable(list);
  }

  List<Contrat> _sortedContrats(Iterable<Contrat> items) {
    final list = items.toList()..sort((a, b) => b.date.compareTo(a.date));
    return List.unmodifiable(list);
  }

  void _replaceDemande(DemandeDevis next) {
    _demandes = [
      for (final item in _demandes) item.id == next.id ? next : item,
    ];
  }

  void _replaceDevis(Devis next) {
    _devis = [for (final item in _devis) item.id == next.id ? next : item];
  }

  void _replaceContrat(Contrat next) {
    _contrats = [
      for (final item in _contrats) item.id == next.id ? next : item,
    ];
  }

  void _replaceModification(ModificationContrat next) {
    _modifications = [
      for (final item in _modifications) item.id == next.id ? next : item,
    ];
  }
}
