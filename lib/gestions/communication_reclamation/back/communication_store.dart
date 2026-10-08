import 'package:flutter/foundation.dart';

import 'package:flutter_android_app/gestions/communication_reclamation/back/communication_models.dart';
import 'package:flutter_android_app/gestions/devis_contrats/back/contrat.dart';
import 'package:flutter_android_app/gestions/devis_contrats/back/devis.dart';
import 'package:flutter_android_app/gestions/devis_contrats/devis_contrats_module.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_presentation.dart';
import 'package:flutter_android_app/gestions/utilisateurs/back/user_account.dart';
import 'package:flutter_android_app/gestions/utilisateurs/utilisateurs_module.dart';

/// Chat, avis, réclamations et alertes, branchés sur les comptes et les dossiers.
class CommunicationStore extends ChangeNotifier {
  CommunicationStore._() {
    _seed();
    devisContratsStore.addListener(notifyListeners);
    utilisateursStore.addListener(notifyListeners);
  }

  static CommunicationStore? _instance;

  /// Back partagé, créé au premier usage.
  factory CommunicationStore() => _instance ??= CommunicationStore._();

  final List<MessageFil> _messages = [];
  final List<Avis> _avis = [];
  final List<Reclamation> _reclamations = [];
  final Map<String, PreferencesAlertes> _preferences = {};
  final Map<String, Set<String>> _lues = {};
  var _nextMessage = 1;
  var _nextAvis = 1;
  var _nextReclamation = 25;

  /// Compte ouvert.
  UserAccount? get session => utilisateursStore.current;

  /// Whether the open admin is supervising.
  bool get adminView =>
      session?.hasRole(UserRole.admin) == true && !utilisateursStore.clientInterface;

  /// Whether the open account acts as a provider.
  bool get providerView => session?.hasRole(UserRole.provider) == true && !adminView;

  /// Whether the open account acts as a client.
  bool get clientView => session?.hasRole(UserRole.client) == true && !adminView;

  /// Nom du compte [id].
  String nomDe(String id) => utilisateursStore.find(id)?.fullName ?? 'Compte';

  /// Préférences du compte ouvert.
  PreferencesAlertes preferencesActuelles() {
    final id = session?.id;
    if (id == null) return const PreferencesAlertes();
    return _preferences[id] ?? const PreferencesAlertes();
  }

  /// Whether [userId] a encore un contrat qui n'est ni terminé ni annulé.
  bool aContratEnCours(String userId) {
    return devisContratsStore.tousLesContrats().any((contrat) {
      final partie = contrat.clientId == userId || contrat.prestataireId == userId;
      return partie &&
          contrat.statut != StatutContrat.termine &&
          contrat.statut != StatutContrat.annule;
    });
  }

  /// Enregistre [valeur] pour [cle].
  void definirPreference(String cle, bool valeur) {
    final id = session?.id;
    if (id == null) return;
    final actuelles = _preferences[id] ?? const PreferencesAlertes();
    _preferences[id] = switch (cle) {
      'Devis et contrats' => actuelles.copyWith(devisEtContrats: valeur),
      'Messages' => actuelles.copyWith(messages: valeur),
      'Prestations' => actuelles.copyWith(prestations: valeur),
      'Réclamations' => actuelles.copyWith(reclamations: valeur),
      'Avis' => actuelles.copyWith(avis: valeur),
      _ => actuelles,
    };
    notifyListeners();
  }

  /// Conversations visibles pour le compte ouvert.
  List<Dossier> dossiers() {
    final user = session;
    if (user == null) return const [];
    final items = <Dossier>[
      for (final devis in _devisVisibles(user))
        if (devis.contratId == null) _dossierDevis(devis, user),
      for (final contrat in _contratsVisibles(user)) _dossierContrat(contrat, user),
    ];
    items.sort((a, b) => b.moment.compareTo(a.moment));
    return items;
  }

  /// Dossier [id], ou `null` s'il n'est pas visible.
  Dossier? findDossier(String id) {
    for (final dossier in dossiers()) {
      if (dossier.id == id) return dossier;
    }
    return null;
  }

  /// Messages du fil [filId], du plus ancien au plus récent.
  List<MessageFil> messagesDe(String filId) {
    final items = [for (final message in _messages) if (message.filId == filId) message];
    items.sort((a, b) => a.envoyeLe.compareTo(b.envoyeLe));
    return items;
  }

  /// Marque les messages du dossier comme lus pour le compte ouvert.
  void marquerDossierLu(String dossierId) {
    final id = session?.id;
    if (id == null) return;
    final lus = _lues.putIfAbsent(id, () => {});
    var changed = false;
    for (final message in messagesDe(dossierId)) {
      changed = lus.add('msg:${message.id}') || changed;
    }
    changed = lus.add('dossier:$dossierId') || changed;
    if (changed) notifyListeners();
  }

  /// Envoie un message sur un dossier encore ouvert.
  String? envoyerMessage(String dossierId, String texte, {bool photo = false}) {
    final user = session;
    final dossier = findDossier(dossierId);
    if (user == null) return 'Connectez-vous pour écrire.';
    if (dossier == null) return 'Cette conversation n\'est pas accessible.';
    if (dossier.lectureSeule || adminView) return 'Cette conversation est en lecture seule.';
    final value = texte.trim();
    if (!photo && value.isEmpty) return 'Écrivez un message.';
    _messages.add(
      MessageFil(
        id: 'm-${_nextMessage++}',
        filId: dossierId,
        auteurId: user.id,
        texte: photo ? (value.isEmpty ? 'Photo jointe' : value) : value,
        envoyeLe: DateTime.now(),
        photo: photo,
      ),
    );
    notifyListeners();
    return null;
  }

  /// Whether the client ouvert peut déposer sur [contratId].
  bool peutReclamer(String contratId) {
    return contratsReclamables().any((contrat) => contrat.id == contratId);
  }

  /// Whether the client ouvert peut noter [contratId].
  bool peutEvaluer(String contratId) {
    return contratsAEvaluer().any((contrat) => contrat.id == contratId);
  }

  /// Contrats pour lesquels le client ouvert peut encore déposer.
  List<Contrat> contratsReclamables() {
    final user = session;
    if (user == null || !clientView) return const [];
    return [
      for (final contrat in _contratsVisibles(user))
        if (contrat.clientId == user.id && _reclamable(contrat)) contrat,
    ];
  }

  /// Réclamations déposées par le client ouvert.
  List<Reclamation> reclamationsClient() {
    final user = session;
    if (user == null || !clientView) return const [];
    return [
      for (final item in _reclamations)
        if (item.clientId == user.id) item,
    ];
  }

  /// Réclamations visant le prestataire ouvert.
  List<Reclamation> reclamationsPrestataire() {
    final user = session;
    if (user == null || !providerView) return const [];
    return [
      for (final item in _reclamations)
        if (item.prestataireId == user.id) item,
    ];
  }

  /// File complète, pour l'admin.
  List<Reclamation> reclamationsAdmin() {
    if (!adminView) return const [];
    final items = [..._reclamations];
    items.sort((a, b) => b.ouverteLe.compareTo(a.ouverteLe));
    return items;
  }

  /// Réclamation [id] si le compte ouvert y a accès.
  Reclamation? findReclamation(String id) {
    final user = session;
    if (user == null) return null;
    for (final item in _reclamations) {
      if (item.id != id) continue;
      if (adminView) return item;
      if (item.clientId == user.id || item.prestataireId == user.id) return item;
    }
    return null;
  }

  /// Dépose une réclamation sur un contrat du client ouvert.
  String? deposerReclamation({
    required String contratId,
    required MotifReclamation motif,
    required String description,
    int pieces = 0,
  }) {
    final user = session;
    final contrat = devisContratsStore.findContrat(contratId);
    if (user == null || !clientView) return 'Seul le client peut déposer une réclamation.';
    if (contrat == null || contrat.clientId != user.id) {
      return 'Ce contrat ne vous concerne pas.';
    }
    if (!_reclamable(contrat)) {
      return 'Une réclamation se dépose sur une prestation engagée, sans dossier déjà ouvert.';
    }
    final texte = description.trim();
    if (texte.isEmpty) return 'Décrivez la situation.';
    final numero = _nextReclamation++;
    final item = Reclamation(
      id: 'rec-$numero',
      numero: 'REC-${numero.toString().padLeft(3, '0')}',
      contratId: contrat.id,
      clientId: contrat.clientId,
      prestataireId: contrat.prestataireId,
      motif: motif,
      description: texte,
      statut: StatutReclamation.ouverte,
      ouverteLe: DateTime.now(),
      pieces: pieces,
    );
    _reclamations.add(item);
    _messages.add(
      MessageFil(
        id: 'm-${_nextMessage++}',
        filId: _filReclamation(item.id),
        auteurId: user.id,
        texte: texte,
        envoyeLe: item.ouverteLe,
      ),
    );
    notifyListeners();
    return item.id;
  }

  /// Ajoute un message au litige tant qu'il n'est pas tranché.
  String? ecrireLitige(String reclamationId, String texte) {
    final user = session;
    final item = findReclamation(reclamationId);
    if (user == null || item == null) return 'Ce dossier n\'est pas accessible.';
    if (adminView) return 'L\'admin consigne une décision, il n\'écrit pas dans le fil.';
    if (!reclamationOuverte(item.statut)) return 'Ce dossier est clos.';
    final value = texte.trim();
    if (value.isEmpty) return 'Écrivez un message.';
    _messages.add(
      MessageFil(
        id: 'm-${_nextMessage++}',
        filId: _filReclamation(item.id),
        auteurId: user.id,
        texte: value,
        envoyeLe: DateTime.now(),
      ),
    );
    notifyListeners();
    return null;
  }

  /// L'admin change l'état, avec un motif obligatoire. Le paiement n'est pas modifié.
  String? deciderReclamation({
    required String reclamationId,
    required StatutReclamation statut,
    required String motif,
  }) {
    final user = session;
    final item = findReclamation(reclamationId);
    if (user == null || !adminView) return 'Seul un admin peut trancher.';
    if (item == null) return 'Réclamation introuvable.';
    final raison = motif.trim();
    if (raison.isEmpty) return 'Un motif est obligatoire.';
    final index = _reclamations.indexWhere((value) => value.id == item.id);
    _reclamations[index] = item.copyWith(
      statut: statut,
      decisionMotif: raison,
      decisionPar: user.id,
    );
    notifyListeners();
    return null;
  }

  /// Contrats terminés que le client ouvert n'a pas encore notés.
  List<Contrat> contratsAEvaluer() {
    final user = session;
    if (user == null || !clientView) return const [];
    return [
      for (final contrat in _contratsVisibles(user))
        if (contrat.clientId == user.id &&
            contrat.statut == StatutContrat.termine &&
            avisDuContrat(contrat.id) == null)
          contrat,
    ];
  }

  /// Avis visible pour le compte ouvert.
  List<Avis> avisVisibles() {
    final user = session;
    if (user == null) return const [];
    if (adminView) return List.unmodifiable(_avis);
    return [
      for (final avis in _avis)
        if (avis.clientId == user.id || (providerView && avis.prestataireId == user.id))
          avis,
    ];
  }

  /// Avis du contrat [contratId], ou `null`.
  Avis? avisDuContrat(String contratId) {
    for (final avis in _avis) {
      if (avis.contratId == contratId) return avis;
    }
    return null;
  }

  /// Avis [id] s'il est visible.
  Avis? findAvis(String id) {
    for (final avis in avisVisibles()) {
      if (avis.id == id) return avis;
    }
    return null;
  }

  /// Le client publie un seul avis sur une prestation terminée.
  String? publierAvis({
    required String contratId,
    required int note,
    required String texte,
  }) {
    final user = session;
    final contrat = devisContratsStore.findContrat(contratId);
    if (user == null || !clientView) return 'Seul le client peut publier un avis.';
    if (contrat == null || contrat.clientId != user.id) {
      return 'Ce contrat ne vous concerne pas.';
    }
    if (contrat.statut != StatutContrat.termine) {
      return 'Un avis se publie une fois la prestation terminée.';
    }
    if (avisDuContrat(contrat.id) != null) return 'Vous avez déjà publié un avis.';
    if (note < 1 || note > 5) return 'Choisissez une note de 1 à 5.';
    final value = texte.trim();
    if (value.isEmpty) return 'Décrivez votre expérience.';
    final avis = Avis(
      id: 'av-${_nextAvis++}',
      contratId: contrat.id,
      clientId: contrat.clientId,
      prestataireId: contrat.prestataireId,
      note: note,
      texte: value,
      publieLe: DateTime.now(),
    );
    _avis.add(avis);
    notifyListeners();
    return avis.id;
  }

  /// Le prestataire répond une seule fois.
  String? repondreAvis(String avisId, String texte) {
    final user = session;
    final avis = findAvis(avisId);
    if (user == null || !providerView) return 'Seul le prestataire peut répondre.';
    if (avis == null || avis.prestataireId != user.id) return 'Cet avis ne vous concerne pas.';
    if (avis.reponse != null) return 'Vous avez déjà répondu.';
    final value = texte.trim();
    if (value.isEmpty) return 'Écrivez une réponse.';
    final index = _avis.indexWhere((item) => item.id == avis.id);
    _avis[index] = avis.copyWith(reponse: value, reponseLe: DateTime.now());
    notifyListeners();
    return null;
  }

  /// Alertes du compte ouvert, de la plus récente à la plus ancienne.
  List<Alerte> alertes() {
    final user = session;
    if (user == null) return const [];
    final items = _calculerAlertes(user);
    items.sort((a, b) => b.quand.compareTo(a.quand));
    return items;
  }

  /// Nombre d'alertes non lues.
  int get alertesNonLues => alertes().where((alerte) => !alerte.lue).length;

  /// Marque l'alerte comme lue.
  void marquerAlerteLue(String id) {
    final userId = session?.id;
    if (userId == null) return;
    final changed = _lues.putIfAbsent(userId, () => {}).add(id);
    if (changed) notifyListeners();
  }

  /// Marque toutes les alertes visibles comme lues.
  void toutMarquerLu() {
    final userId = session?.id;
    if (userId == null) return;
    final lus = _lues.putIfAbsent(userId, () => {});
    for (final alerte in alertes()) {
      lus.add(alerte.id);
    }
    notifyListeners();
  }

  void _seed() {
    final matin = DateTime(2026, 10, 8, 8, 10);
    _messages.addAll([
      MessageFil(
        id: 'm-${_nextMessage++}',
        filId: 'd:dv-1',
        auteurId: 'u-provider',
        texte: 'Bonjour, votre devis est prêt. Le camion est inclus.',
        envoyeLe: matin,
      ),
      MessageFil(
        id: 'm-${_nextMessage++}',
        filId: 'd:dv-1',
        auteurId: 'u-client',
        texte: 'Parfait. Est-ce que le prix inclut les cartons ?',
        envoyeLe: matin.add(const Duration(minutes: 20)),
      ),
      MessageFil(
        id: 'm-${_nextMessage++}',
        filId: 'c:ct-1',
        auteurId: 'u-provider',
        texte: 'Je peux signer dès que le stationnement est confirmé.',
        envoyeLe: matin.add(const Duration(hours: 2)),
      ),
      MessageFil(
        id: 'm-${_nextMessage++}',
        filId: 'c:ct-2',
        auteurId: 'u-client',
        texte: 'Le camion est arrivé après 09:00.',
        envoyeLe: DateTime(2026, 10, 1, 9, 20),
      ),
    ]);
    _reclamations.add(
      Reclamation(
        id: 'rec-24',
        numero: 'REC-024',
        contratId: 'ct-2',
        clientId: 'u-client',
        prestataireId: 'u-provider',
        motif: MotifReclamation.retard,
        description:
            'Le prestataire est arrivé avec plus d\'une heure de retard. Le créneau avait été confirmé à 08:00.',
        statut: StatutReclamation.enExamen,
        ouverteLe: DateTime(2026, 10, 1, 18),
        pieces: 2,
      ),
    );
    _messages.addAll([
      MessageFil(
        id: 'm-${_nextMessage++}',
        filId: _filReclamation('rec-24'),
        auteurId: 'u-client',
        texte: 'J\'ai attendu jusqu\'à 09:15. Les photos montrent l\'heure d\'arrivée.',
        envoyeLe: DateTime(2026, 10, 1, 18, 5),
      ),
      MessageFil(
        id: 'm-${_nextMessage++}',
        filId: _filReclamation('rec-24'),
        auteurId: 'u-provider',
        texte: 'Un incident sur la route a causé le retard. Je présente mes excuses.',
        envoyeLe: DateTime(2026, 10, 1, 19),
      ),
    ]);
  }

  List<Alerte> _calculerAlertes(UserAccount user) {
    final prefs = _preferences[user.id] ?? const PreferencesAlertes();
    final items = <Alerte>[];
    if (prefs.messages && !adminView) {
      for (final dossier in dossiers()) {
        for (final message in messagesDe(dossier.id)) {
          if (message.auteurId == user.id) continue;
          items.add(
            Alerte(
              id: 'msg:${message.id}',
              type: TypeAlerte.message,
              titre: 'Message reçu',
              detail: '${nomDe(message.auteurId)} : ${message.texte}',
              quand: message.envoyeLe,
              lue: _estLue(user.id, 'msg:${message.id}'),
              dossierId: dossier.id,
            ),
          );
        }
      }
    }
    if (prefs.devisEtContrats && clientView) {
      for (final devis in devisContratsStore.devisClient()) {
        if (devis.statut != StatutDevis.envoye && devis.statut != StatutDevis.vu) {
          continue;
        }
        items.add(
          Alerte(
            id: 'devis:${devis.id}',
            type: TypeAlerte.devis,
            titre: 'Nouveau devis reçu',
            detail: '${nomDe(devis.prestataireId)} a envoyé un devis pour ${devis.service}.',
            quand: devis.date,
            lue: _estLue(user.id, 'devis:${devis.id}'),
            dossierId: 'd:${devis.id}',
          ),
        );
      }
    }
    if (prefs.prestations && clientView) {
      for (final contrat in _contratsVisibles(user)) {
        if (contrat.clientId != user.id || contrat.statut != StatutContrat.termine) {
          continue;
        }
        items.add(
          Alerte(
            id: 'fin:${contrat.id}',
            type: TypeAlerte.prestation,
            titre: 'Prestation terminée',
            detail: 'Votre prestation avec ${nomDe(contrat.prestataireId)} est terminée.',
            quand: contrat.date,
            lue: _estLue(user.id, 'fin:${contrat.id}'),
            dossierId: 'c:${contrat.id}',
          ),
        );
      }
    }
    if (prefs.reclamations) {
      for (final item in _reclamations) {
        final concerne = adminView
            ? true
            : item.clientId == user.id || item.prestataireId == user.id;
        if (!concerne) continue;
        items.add(
          Alerte(
            id: 'rec:${item.id}',
            type: TypeAlerte.reclamation,
            titre: 'Réclamation ${labelStatutReclamation(item.statut).toLowerCase()}',
            detail: 'Le dossier ${item.numero} est ${labelStatutReclamation(item.statut).toLowerCase()}.',
            quand: item.ouverteLe,
            lue: _estLue(user.id, 'rec:${item.id}'),
            reclamationId: item.id,
          ),
        );
      }
    }
    if (prefs.avis && providerView) {
      for (final avis in _avis) {
        if (avis.prestataireId != user.id) continue;
        items.add(
          Alerte(
            id: 'avis:${avis.id}',
            type: TypeAlerte.avis,
            titre: 'Nouvel avis',
            detail: '${nomDe(avis.clientId)} a publié un avis.',
            quand: avis.publieLe,
            lue: _estLue(user.id, 'avis:${avis.id}'),
            avisId: avis.id,
          ),
        );
      }
    }
    return items;
  }

  bool _estLue(String userId, String id) => _lues[userId]?.contains(id) ?? false;

  bool _reclamable(Contrat contrat) {
    final engage = contrat.statut == StatutContrat.valide ||
        contrat.statut == StatutContrat.enCours ||
        contrat.statut == StatutContrat.termine;
    if (!engage) return false;
    for (final item in _reclamations) {
      if (item.contratId == contrat.id && reclamationOuverte(item.statut)) return false;
    }
    return true;
  }

  List<Devis> _devisVisibles(UserAccount user) {
    final seen = <String>{};
    final source = adminView
        ? devisContratsStore.devisAdmin()
        : [...devisContratsStore.devisClient(), ...devisContratsStore.devisPrestataire()];
    return [
      for (final devis in source)
        if (devis.statut != StatutDevis.brouillon &&
            seen.add(devis.id) &&
            (adminView || devis.clientId == user.id || devis.prestataireId == user.id))
          devis,
    ];
  }

  List<Contrat> _contratsVisibles(UserAccount user) {
    final seen = <String>{};
    final source = adminView
        ? devisContratsStore.contratsAdmin()
        : [...devisContratsStore.contratsClient(), ...devisContratsStore.contratsPrestataire()];
    return [
      for (final contrat in source)
        if (seen.add(contrat.id) &&
            (adminView || contrat.clientId == user.id || contrat.prestataireId == user.id))
          contrat,
    ];
  }

  Dossier _dossierDevis(Devis devis, UserAccount user) {
    final id = 'd:${devis.id}';
    final messages = messagesDe(id);
    final lectureSeule = adminView ||
        devis.statut == StatutDevis.expire ||
        devis.statut == StatutDevis.refuse;
    return Dossier(
      id: id,
      interlocuteur: _interlocuteur(user, devis.clientId, devis.prestataireId),
      service: devis.service,
      quand: '${formatDate(devis.date)} · ${devis.heure}',
      statut: _labelDevis(devis.statut),
      apercu: messages.isEmpty ? 'Aucun message pour l\'instant.' : messages.last.texte,
      lectureSeule: lectureSeule,
      litige: false,
      moment: devis.date,
    );
  }

  Dossier _dossierContrat(Contrat contrat, UserAccount user) {
    final id = 'c:${contrat.id}';
    final messages = messagesDe(id);
    final litige = _reclamations.any(
      (item) => item.contratId == contrat.id && reclamationOuverte(item.statut),
    );
    return Dossier(
      id: id,
      interlocuteur: _interlocuteur(user, contrat.clientId, contrat.prestataireId),
      service: contrat.service,
      quand: '${formatDate(contrat.date)} · ${contrat.heure}',
      statut: litige ? 'Réclamation ouverte' : _labelContrat(contrat.statut),
      apercu: messages.isEmpty ? 'Aucun message pour l\'instant.' : messages.last.texte,
      lectureSeule: adminView || contrat.statut == StatutContrat.annule,
      litige: litige,
      moment: contrat.date,
    );
  }

  String _interlocuteur(UserAccount user, String clientId, String prestataireId) {
    if (adminView) return '${nomDe(clientId)} / ${nomDe(prestataireId)}';
    if (user.id == clientId) return nomDe(prestataireId);
    if (user.id == prestataireId) return nomDe(clientId);
    return nomDe(clientId);
  }

  String _labelDevis(StatutDevis statut) {
    return switch (statut) {
      StatutDevis.brouillon => 'Brouillon',
      StatutDevis.envoye => 'Devis envoyé',
      StatutDevis.vu => 'Devis consulté',
      StatutDevis.accepte => 'Devis accepté',
      StatutDevis.refuse => 'Devis refusé',
      StatutDevis.expire => 'Devis expiré',
    };
  }

  String _labelContrat(StatutContrat statut) {
    return switch (statut) {
      StatutContrat.attenteSignaturePrestataire ||
      StatutContrat.attenteSignatureClient => 'En attente de signature',
      StatutContrat.valide => 'Contrat confirmé',
      StatutContrat.enCours => 'Prestation en cours',
      StatutContrat.termine => 'Prestation terminée',
      StatutContrat.annule => 'Contrat annulé',
    };
  }

  String _filReclamation(String id) => 'r:$id';

  /// Fil de messages d'une réclamation.
  String filReclamation(String id) => _filReclamation(id);
}

/// Back partagé de la gestion communication.
CommunicationStore get communicationStore => CommunicationStore();
