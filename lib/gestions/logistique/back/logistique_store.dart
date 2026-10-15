import 'package:flutter/foundation.dart';

import 'package:flutter_android_app/core/db/nexus_database.dart';
import 'package:flutter_android_app/gestions/devis_contrats/back/contrat.dart';
import 'package:flutter_android_app/gestions/devis_contrats/devis_contrats_module.dart';
import 'package:flutter_android_app/gestions/logistique/back/logistique_table.dart';
import 'package:flutter_android_app/gestions/logistique/back/trajet.dart';
import 'package:flutter_android_app/gestions/utilisateurs/back/user_account.dart';
import 'package:flutter_android_app/gestions/utilisateurs/utilisateurs_module.dart';

/// Trajets des prestataires vers leurs clients, reliés aux contrats.
class LogistiqueStore extends ChangeNotifier {
  /// Pose les trajets des contrats de démonstration.
  LogistiqueStore() {
    _trajets = [
      Trajet(
        id: 'trj-1',
        numero: 'TRJ-001',
        contratId: 'ct-2',
        clientId: 'u-client',
        prestataireId: 'u-provider',
        pointDepart: 'Tunis, dépôt Trabelsi',
        destination: 'La Marsa',
        distanceKm: 12,
        departPrevu: DateTime(2026, 10, 1, 7, 30),
        departReel: DateTime(2026, 10, 1, 7, 45),
        arriveeReelle: DateTime(2026, 10, 1, 9, 15),
        status: TrajetStatus.termine,
        retardMinutes: 70,
        note: 'Accident sur la route de La Marsa.',
        creeLe: DateTime(2026, 9, 30, 18),
      ),
      Trajet(
        id: 'trj-2',
        numero: 'TRJ-002',
        contratId: 'ct-1',
        clientId: 'u-client',
        prestataireId: 'u-provider',
        pointDepart: 'Tunis, dépôt Trabelsi',
        destination: 'Carthage',
        distanceKm: 10,
        departPrevu: DateTime(2026, 10, 8, 13, 30),
        status: TrajetStatus.enAttente,
        creeLe: DateTime(2026, 10, 6, 10),
      ),
    ];
    devisContratsStore.addListener(notifyListeners);
    utilisateursStore.addListener(notifyListeners);
  }

  List<Trajet> _trajets = [];
  var _next = 3;

  /// Recharge les trajets depuis SQLite.
  Future<void> charger() async {
    final lignes = await nexusDb.charger(tableTrajets, _trajets.map(ligneTrajet));
    if (lignes != null) _trajets = lignes.map(trajetDepuis).toList();
    _next = prochainNumero(_trajets.map((item) => item.id), 'trj-', _next);
    notifyListeners();
  }

  /// Compte ouvert.
  UserAccount? get session => utilisateursStore.current;

  /// Whether the open admin supervises every trajet.
  bool get adminView =>
      session?.hasRole(UserRole.admin) == true && !utilisateursStore.clientInterface;

  /// Whether the open account drives its own trajets.
  bool get providerView => session?.hasRole(UserRole.provider) == true && !adminView;

  /// Whether the open account follows the trajets coming to it.
  bool get clientView => session?.hasRole(UserRole.client) == true && !adminView;

  /// Nom du compte [id].
  String nomDe(String id) => utilisateursStore.find(id)?.fullName ?? 'Compte';

  /// Trajet [id] s'il est visible, ou `null`.
  Trajet? find(String id) {
    for (final trajet in visibles()) {
      if (trajet.id == id) return trajet;
    }
    return null;
  }

  /// Trajets du compte ouvert : conduits, attendus, ou tous pour l'admin.
  List<Trajet> visibles() {
    final id = session?.id;
    if (id == null) return const [];
    final items = [
      for (final trajet in _trajets)
        if (adminView ||
            (providerView && trajet.prestataireId == id) ||
            (clientView && trajet.clientId == id))
          trajet,
    ]..sort(_ordre);
    return items;
  }

  /// Trajets encore actifs du contrat [contratId].
  Trajet? trajetActifDuContrat(String contratId) {
    for (final trajet in _trajets) {
      if (trajet.contratId == contratId && trajet.actif) return trajet;
    }
    return null;
  }

  /// Dernier trajet du contrat [contratId], actif ou non.
  Trajet? trajetDuContrat(String contratId) {
    final items = [
      for (final trajet in _trajets)
        if (trajet.contratId == contratId) trajet,
    ]..sort((a, b) => b.departPrevu.compareTo(a.departPrevu));
    return items.isEmpty ? null : items.first;
  }

  /// Contrats du prestataire ouvert qui n'ont pas encore de trajet actif.
  List<Contrat> contratsPlanifiables() {
    final id = session?.id;
    if (id == null || !providerView) return const [];
    return [
      for (final contrat in devisContratsStore.tousLesContrats())
        if (contrat.prestataireId == id &&
            contrat.statut != StatutContrat.annule &&
            contrat.statut != StatutContrat.termine &&
            trajetActifDuContrat(contrat.id) == null)
          contrat,
    ];
  }

  /// Le prestataire planifie le trajet d'un de ses contrats.
  String? creer({
    required String contratId,
    required String depart,
    required String destination,
    required String distance,
    required String date,
    required String heure,
  }) {
    final user = session;
    if (user == null || !providerView) return 'Seul le prestataire planifie un trajet.';
    final contrat = devisContratsStore.findContrat(contratId);
    if (contrat == null || contrat.prestataireId != user.id) {
      return 'Choisissez un de vos contrats.';
    }
    if (trajetActifDuContrat(contrat.id) != null) {
      return 'Ce contrat a déjà un trajet en cours.';
    }
    final lu = _lire(depart: depart, destination: destination, distance: distance, date: date, heure: heure);
    if (lu.$1 != null) return lu.$1;
    final numero = _next++;
    final trajet = Trajet(
      id: 'trj-$numero',
      numero: 'TRJ-${numero.toString().padLeft(3, '0')}',
      contratId: contrat.id,
      clientId: contrat.clientId,
      prestataireId: contrat.prestataireId,
      pointDepart: depart.trim(),
      destination: destination.trim(),
      distanceKm: lu.$2!,
      departPrevu: lu.$3!,
      status: TrajetStatus.enAttente,
      creeLe: DateTime.now(),
    );
    _trajets = [..._trajets, trajet];
    nexusDb.enregistrer(tableTrajets, ligneTrajet(trajet));
    notifyListeners();
    return null;
  }

  /// Corrige un trajet encore planifié.
  String? modifier(
    String id, {
    required String depart,
    required String destination,
    required String distance,
    required String date,
    required String heure,
  }) {
    final trajet = find(id);
    if (trajet == null) return 'Trajet introuvable.';
    if (!_peutConduire(trajet) && !adminView) return 'Ce trajet ne vous appartient pas.';
    if (trajet.status != TrajetStatus.enAttente) {
      return 'Un trajet parti ne se modifie plus.';
    }
    final lu = _lire(depart: depart, destination: destination, distance: distance, date: date, heure: heure);
    if (lu.$1 != null) return lu.$1;
    _remplacer(
      trajet.copyWith(
        pointDepart: depart.trim(),
        destination: destination.trim(),
        distanceKm: lu.$2,
        departPrevu: lu.$3,
      ),
    );
    return null;
  }

  /// Le prestataire part. Un contrat validé passe en cours.
  String? demarrer(String id) {
    final trajet = find(id);
    if (trajet == null || !_peutConduire(trajet)) return 'Ce trajet ne vous appartient pas.';
    if (trajet.status != TrajetStatus.enAttente) return 'Ce trajet est déjà parti.';
    final contrat = devisContratsStore.findContrat(trajet.contratId);
    if (contrat != null && contrat.statut == StatutContrat.valide) {
      devisContratsStore.demarrerPrestation(contrat.id);
    }
    _remplacer(trajet.copyWith(status: TrajetStatus.enCours, departReel: DateTime.now()));
    return null;
  }

  /// Le prestataire signale un retard, l'arrivée estimée recule d'autant.
  String? signalerRetard(String id, String minutes, String motif) {
    final trajet = find(id);
    if (trajet == null || !_peutConduire(trajet)) return 'Ce trajet ne vous appartient pas.';
    if (trajet.status != TrajetStatus.enCours && trajet.status != TrajetStatus.enRetard) {
      return 'Le retard se signale pendant le trajet.';
    }
    final ajout = int.tryParse(minutes.trim());
    if (ajout == null || ajout <= 0) return 'Indiquez le retard en minutes.';
    if (motif.trim().isEmpty) return 'Indiquez le motif du retard.';
    _remplacer(
      trajet.copyWith(
        status: TrajetStatus.enRetard,
        retardMinutes: trajet.retardMinutes + ajout,
        note: motif.trim(),
      ),
    );
    return null;
  }

  /// Le prestataire est arrivé.
  String? terminer(String id) {
    final trajet = find(id);
    if (trajet == null || !_peutConduire(trajet)) return 'Ce trajet ne vous appartient pas.';
    if (trajet.status == TrajetStatus.enAttente) return 'Démarrez d\'abord le trajet.';
    if (trajet.status == TrajetStatus.termine) return 'Ce trajet est déjà terminé.';
    _remplacer(trajet.copyWith(status: TrajetStatus.termine, arriveeReelle: DateTime.now()));
    return null;
  }

  /// Supprime un trajet planifié, ou n'importe lequel pour l'admin.
  String? supprimer(String id) {
    final trajet = find(id);
    if (trajet == null) return 'Trajet introuvable.';
    if (!adminView) {
      if (!_peutConduire(trajet)) return 'Ce trajet ne vous appartient pas.';
      if (trajet.status != TrajetStatus.enAttente) {
        return 'Seul un trajet encore planifié peut être supprimé.';
      }
    }
    _trajets = [for (final item in _trajets) if (item.id != id) item];
    nexusDb.supprimer(tableTrajets, id);
    notifyListeners();
    return null;
  }

  bool _peutConduire(Trajet trajet) {
    return providerView && trajet.prestataireId == session?.id;
  }

  void _remplacer(Trajet next) {
    _trajets = [for (final item in _trajets) item.id == next.id ? next : item];
    nexusDb.enregistrer(tableTrajets, ligneTrajet(next));
    notifyListeners();
  }

  (String?, double?, DateTime?) _lire({
    required String depart,
    required String destination,
    required String distance,
    required String date,
    required String heure,
  }) {
    if (depart.trim().isEmpty) return ('Le point de départ est obligatoire.', null, null);
    if (destination.trim().isEmpty) return ('La destination est obligatoire.', null, null);
    final km = double.tryParse(distance.trim().replaceAll(',', '.'));
    if (km == null || km <= 0) return ('Indiquez la distance en kilomètres.', null, null);
    final jour = date.trim().split('/');
    final temps = heure.trim().split(':');
    if (jour.length != 3 || temps.length != 2) {
      return ('Indiquez la date JJ/MM/AAAA et l\'heure HH:MM.', null, null);
    }
    final valeurs = [...jour, ...temps].map(int.tryParse).toList();
    if (valeurs.contains(null)) {
      return ('Indiquez la date JJ/MM/AAAA et l\'heure HH:MM.', null, null);
    }
    final [j, m, a, h, min] = valeurs.cast<int>();
    if (m < 1 || m > 12 || j < 1 || j > 31 || h > 23 || min > 59) {
      return ('Cette date ou cette heure n\'existe pas.', null, null);
    }
    return (null, km, DateTime(a, m, j, h, min));
  }

  int _ordre(Trajet a, Trajet b) {
    if (a.actif != b.actif) return a.actif ? -1 : 1;
    return b.departPrevu.compareTo(a.departPrevu);
  }
}
