import 'package:flutter/foundation.dart';

import 'package:flutter_android_app/gestions/utilisateurs/back/provider_profile.dart';
import 'package:flutter_android_app/gestions/utilisateurs/back/user_account.dart';

/// Résultat d'une tentative de connexion.
enum SignInStatus {
  /// Le compte est ouvert.
  success,

  /// L'e-mail ou le mot de passe est refusé.
  invalid,

  /// Le compte est suspendu.
  suspended,

  /// Le mot de passe est bon, le code manque encore.
  codeRequired,

  /// Le compte prestataire attend encore un administrateur.
  pending,

  /// Le code supplémentaire est refusé.
  badCode,
}

/// Comptes, session, rôles et sécurité de la gestion utilisateurs.
class UtilisateursStore extends ChangeNotifier {
  /// Crée le back local avec trois comptes de démonstration.
  UtilisateursStore() {
    final now = DateTime.now();
    _users = [
      UserAccount(
        id: 'u-client',
        firstName: 'Sara',
        lastName: 'Ben Ali',
        email: 'sara@nexus.app',
        phone: '22111000',
        city: 'Tunis',
        password: demoPassword,
        roles: {UserRole.client},
        createdAt: now,
      ),
      UserAccount(
        id: 'u-provider',
        firstName: 'Amine',
        lastName: 'Trabelsi',
        email: 'amine@nexus.app',
        phone: '22999000',
        city: 'Tunis',
        password: demoPassword,
        roles: {UserRole.provider, UserRole.client},
        createdAt: now,
        hasActiveContract: true,
        providerProfile: const ProviderProfile(
          service: 'Déménagement',
          skills: ['Camion', 'Manutention'],
          hourlyRate: 80,
          availability: ['Samedi', 'Dimanche'],
          presentation: 'Camion et deux personnes pour un déménagement.',
        ),
      ),
      UserAccount(
        id: 'u-admin',
        firstName: 'Nour',
        lastName: 'Mansour',
        email: 'admin@nexus.app',
        phone: '55000111',
        city: 'Tunis',
        password: demoPassword,
        roles: {UserRole.admin, UserRole.client},
        createdAt: now,
      ),
    ];
    _sessions['u-admin'] = [
      DeviceSession(
        id: 's-old',
        label: 'Chrome sur Windows',
        startedAt: now.subtract(const Duration(days: 2)),
        current: false,
      ),
    ];
  }

  /// Mot de passe partagé par les comptes de démonstration.
  static const demoPassword = 'nexus123';

  /// Code demandé quand la protection supplémentaire est active.
  static const demoSignInCode = '0000';

  /// Comptes proposés sur l'écran de connexion.
  static const demos = [
    ('Sara, cliente', 'sara@nexus.app'),
    ('Amine, prestataire', 'amine@nexus.app'),
    ('Nour, admin', 'admin@nexus.app'),
  ];

  List<UserAccount> _users = [];
  final Map<String, List<DeviceSession>> _sessions = {};
  String? _currentId;
  String? _resetUserId;
  String? _resetCode;
  var _nextUser = 1;
  var _nextSession = 1;
  var _clientInterface = false;

  /// Whether the admin is looking at the client interface.
  bool get clientInterface => _clientInterface;

  /// Ouvre la barre du bas du client, sans quitter le compte admin.
  void openClientInterface() {
    if (current?.hasRole(UserRole.admin) != true) return;
    _clientInterface = true;
    notifyListeners();
  }

  /// Ramène l'admin sur la barre latérale.
  void closeClientInterface() {
    _clientInterface = false;
    notifyListeners();
  }

  /// Compte ouvert, s'il y en a un.
  UserAccount? get current {
    final id = _currentId;
    if (id == null) return null;
    return find(id);
  }

  /// Code de réinitialisation en cours, visible faute d'envoi d'e-mail.
  String? get resetCode => _resetCode;

  /// Tous les comptes, pour l'écran admin.
  List<UserAccount> get accounts => List.unmodifiable(_users);

  /// Sessions du compte ouvert.
  List<DeviceSession> sessionsOfCurrent() {
    final id = _currentId;
    if (id == null) return const [];
    return List.unmodifiable(_sessions[id] ?? const []);
  }

  /// Retourne le compte [id], ou `null` s'il n'existe pas.
  UserAccount? find(String id) {
    for (final user in _users) {
      if (user.id == id) return user;
    }
    return null;
  }

  /// Ouvre une session.
  ///
  /// Retourne [SignInStatus.codeRequired] quand le mot de passe est bon
  /// et que [code] est encore vide.
  SignInStatus signIn({
    required String email,
    required String password,
    String code = '',
  }) {
    final user = _byEmail(email);
    if (user == null || user.password != password) {
      return SignInStatus.invalid;
    }
    if (user.suspended) return SignInStatus.suspended;
    if (user.hasRole(UserRole.provider) && !user.confirmed) {
      return SignInStatus.pending;
    }
    if (user.requiresSignInCode && code.trim() != demoSignInCode) {
      return code.trim().isEmpty ? SignInStatus.codeRequired : SignInStatus.badCode;
    }

    final now = DateTime.now();
    _currentId = user.id;
    _replace(user.copyWith(lastAccess: now));
    final previous = _sessions[user.id] ?? const <DeviceSession>[];
    _sessions[user.id] = [
      for (final session in previous) session.copyWith(current: false),
      DeviceSession(
        id: 's-${_nextSession++}',
        label: 'Cet appareil',
        startedAt: now,
        current: true,
      ),
    ];
    notifyListeners();
    return SignInStatus.success;
  }

  /// Crée un compte et l'ouvre.
  ///
  /// Retourne un message si les champs ne sont pas acceptés.
  String? signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String city,
    required String password,
    required bool client,
    required bool provider,
    String service = '',
    List<String> skills = const [],
    String hourlyRate = '',
    List<String> availability = const [],
    String presentation = '',
  }) {
    final cleanEmail = email.trim().toLowerCase();
    if (firstName.trim().isEmpty || lastName.trim().isEmpty) {
      return 'Indiquez le prénom et le nom.';
    }
    if (!cleanEmail.contains('@') || !cleanEmail.contains('.')) {
      return 'Indiquez un e-mail valide.';
    }
    if (_byEmail(cleanEmail) != null) {
      return 'Cet e-mail est déjà utilisé.';
    }
    if (phone.trim().length < 8) {
      return 'Indiquez un téléphone complet.';
    }
    if (password.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères.';
    }
    if (!client && !provider) {
      return 'Choisissez au moins un rôle.';
    }

    ProviderProfile? profile;
    if (provider) {
      final read = _readProviderProfile(
        service: service,
        skills: skills,
        hourlyRate: hourlyRate,
        availability: availability,
        presentation: presentation,
      );
      if (read.$1 != null) return read.$1;
      profile = read.$2;
    }

    final roles = <UserRole>{
      if (client || provider) UserRole.client,
      if (provider) UserRole.provider,
    };
    final user = UserAccount(
      id: 'u-${_nextUser++}',
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      email: cleanEmail,
      phone: phone.trim(),
      city: city.trim().isEmpty ? 'Tunis' : city.trim(),
      password: password,
      roles: roles,
      createdAt: DateTime.now(),
      lastAccess: provider ? null : DateTime.now(),
      confirmed: !provider,
      providerProfile: profile,
    );
    _users = [..._users, user];
    if (!provider) {
      _currentId = user.id;
      _sessions[user.id] = [
        DeviceSession(
          id: 's-${_nextSession++}',
          label: 'Cet appareil',
          startedAt: user.createdAt,
          current: true,
        ),
      ];
    }
    notifyListeners();
    return null;
  }

  (String?, ProviderProfile?) _readProviderProfile({
    required String service,
    required List<String> skills,
    required String hourlyRate,
    required List<String> availability,
    required String presentation,
  }) {
    final serviceName = service.trim();
    final cleanSkills = [
      for (final skill in skills)
        if (skill.trim().isNotEmpty) skill.trim(),
    ];
    final rate = int.tryParse(hourlyRate.trim());
    if (serviceName.isEmpty) {
      return ('Indiquez le métier.', null);
    }
    if (cleanSkills.isEmpty) {
      return ('Ajoutez au moins une compétence.', null);
    }
    if (rate == null || rate <= 0) {
      return ('Indiquez un tarif horaire.', null);
    }
    if (availability.isEmpty) {
      return ('Indiquez au moins un jour de disponibilité.', null);
    }
    return (
      null,
      ProviderProfile(
        service: serviceName,
        skills: cleanSkills,
        hourlyRate: rate,
        availability: availability,
        presentation: presentation.trim(),
      ),
    );
  }

  /// Ferme la session ouverte.
  void signOut() {
    final id = _currentId;
    if (id != null) {
      final sessions = _sessions[id];
      if (sessions != null) {
        _sessions[id] = [
          for (final session in sessions) session.copyWith(current: false),
        ];
      }
    }
    _currentId = null;
    _clientInterface = false;
    notifyListeners();
  }

  /// Prépare un code pour [email].
  ///
  /// Retourne un message si aucun compte ne correspond.
  String? requestPasswordReset(String email) {
    final user = _byEmail(email);
    if (user == null) return 'Aucun compte pour cet e-mail.';
    _resetUserId = user.id;
    _resetCode = '${1000 + user.email.length * 37 % 9000}';
    notifyListeners();
    return null;
  }

  /// Remplace le mot de passe si [code] correspond au dernier envoi.
  String? confirmPasswordReset({
    required String code,
    required String password,
  }) {
    final userId = _resetUserId;
    final user = userId == null ? null : find(userId);
    if (user == null || _resetCode == null) {
      return 'Demandez un nouveau code.';
    }
    if (code.trim() != _resetCode) return 'Le code est incorrect.';
    if (password.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères.';
    }
    _replace(user.copyWith(password: password));
    _resetUserId = null;
    _resetCode = null;
    notifyListeners();
    return null;
  }

  /// Enregistre le profil du compte ouvert.
  String? updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
    required String city,
    String service = '',
    List<String> skills = const [],
    String hourlyRate = '',
    List<String> availability = const [],
    String presentation = '',
  }) {
    final user = current;
    if (user == null) return 'Connectez-vous.';
    if (firstName.trim().isEmpty || lastName.trim().isEmpty) {
      return 'Indiquez le prénom et le nom.';
    }
    if (phone.trim().length < 8) return 'Indiquez un téléphone complet.';
    if (city.trim().isEmpty) return 'Indiquez une ville.';
    ProviderProfile? profile = user.providerProfile;
    if (user.hasRole(UserRole.provider) || user.providerProfile != null) {
      final read = _readProviderProfile(
        service: service,
        skills: skills,
        hourlyRate: hourlyRate,
        availability: availability,
        presentation: presentation,
      );
      if (read.$1 != null) return read.$1;
      profile = read.$2;
    }
    _replace(
      user.copyWith(
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        phone: phone.trim(),
        city: city.trim(),
        providerProfile: profile,
      ),
    );
    notifyListeners();
    return null;
  }

  /// Modifie l'identité d'un compte, et la fiche métier si c'est un prestataire.
  String? updateAccount({
    required String id,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String city,
    String service = '',
    List<String> skills = const [],
    String hourlyRate = '',
    List<String> availability = const [],
    String presentation = '',
  }) {
    final actor = current;
    if (actor == null || !actor.hasRole(UserRole.admin)) {
      return 'Seul un admin peut modifier ce compte.';
    }
    final user = find(id);
    if (user == null) return 'Compte introuvable.';
    if (firstName.trim().isEmpty || lastName.trim().isEmpty) {
      return 'Indiquez le prénom et le nom.';
    }
    final cleanEmail = email.trim().toLowerCase();
    if (!cleanEmail.contains('@') || !cleanEmail.contains('.')) {
      return 'Indiquez un e-mail valide.';
    }
    final taken = _byEmail(cleanEmail);
    if (taken != null && taken.id != user.id) {
      return 'Cet e-mail est déjà utilisé.';
    }
    if (phone.trim().length < 8) return 'Indiquez un téléphone complet.';
    if (city.trim().isEmpty) return 'Indiquez une ville.';
    final keepProvider = user.hasRole(UserRole.provider) || user.providerProfile != null;
    ProviderProfile? profile = user.providerProfile;
    if (keepProvider) {
      final read = _readProviderProfile(
        service: service,
        skills: skills,
        hourlyRate: hourlyRate,
        availability: availability,
        presentation: presentation,
      );
      if (read.$1 != null) return read.$1;
      profile = read.$2;
    }
    _replace(
      user.copyWith(
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        email: cleanEmail,
        phone: phone.trim(),
        city: city.trim(),
        providerProfile: profile,
      ),
    );
    notifyListeners();
    return null;
  }

  /// Confirme un compte prestataire en attente.
  String? confirmProvider(String id) {
    final actor = current;
    if (actor == null || !actor.hasRole(UserRole.admin)) {
      return 'Seul un admin peut confirmer un compte.';
    }
    final user = find(id);
    if (user == null) return 'Compte introuvable.';
    _replace(user.copyWith(confirmed: true));
    notifyListeners();
    return null;
  }

  /// Change le mot de passe du compte ouvert.
  String? changePassword({
    required String currentPassword,
    required String password,
  }) {
    final user = current;
    if (user == null) return 'Connectez-vous.';
    if (user.password != currentPassword) {
      return 'Le mot de passe actuel est incorrect.';
    }
    if (password.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères.';
    }
    _replace(user.copyWith(password: password));
    notifyListeners();
    return null;
  }

  /// Active ou retire le code demandé à la connexion.
  void setSignInCodeRequired(bool required) {
    final user = current;
    if (user == null) return;
    _replace(user.copyWith(requiresSignInCode: required));
    notifyListeners();
  }

  /// Ferme toutes les sessions sauf celle en cours.
  void disconnectOtherSessions() {
    final id = _currentId;
    if (id == null) return;
    _sessions[id] = [
      for (final session in _sessions[id] ?? const <DeviceSession>[])
        if (session.current) session,
    ];
    notifyListeners();
  }

  /// Met à jour les rôles client et prestataire du compte ouvert.
  String? updateOwnRoles({required bool client, required bool provider}) {
    final user = current;
    if (user == null) return 'Connectez-vous.';
    if (user.isSimpleClient) {
      return 'Un client ne peut pas changer son rôle.';
    }
    final next = <UserRole>{
      if (client || provider) UserRole.client,
      if (provider) UserRole.provider,
      if (user.hasRole(UserRole.admin)) UserRole.admin,
    };
    if (!provider &&
        user.hasRole(UserRole.provider) &&
        user.hasActiveContract) {
      return 'Un contrat est encore en cours. Le rôle prestataire reste actif.';
    }
    if (next.isEmpty) return 'Le compte doit garder au moins un rôle.';
    _replace(user.copyWith(roles: next));
    notifyListeners();
    return null;
  }

  /// Change les rôles d'un autre compte.
  String? updateRoles({
    required String id,
    required bool client,
    required bool provider,
    required bool admin,
  }) {
    final user = find(id);
    if (user == null) return 'Compte introuvable.';
    if (!provider && user.hasRole(UserRole.provider) && user.hasActiveContract) {
      return 'Un contrat est encore en cours. Le rôle prestataire reste actif.';
    }
    final next = <UserRole>{
      if (client || provider) UserRole.client,
      if (provider) UserRole.provider,
      if (admin) UserRole.admin,
    };
    if (next.isEmpty) return 'Le compte doit garder au moins un rôle.';
    _replace(user.copyWith(roles: next));
    notifyListeners();
    return null;
  }

  /// Suspend un autre compte.
  String? suspend(String id, String reason) {
    if (id == _currentId) {
      return 'Vous ne pouvez pas suspendre la session en cours.';
    }
    final user = find(id);
    if (user == null) return 'Compte introuvable.';
    if (reason.trim().isEmpty) return 'Indiquez un motif.';
    _replace(
      user.copyWith(suspended: true, suspensionReason: reason.trim()),
    );
    notifyListeners();
    return null;
  }

  /// Rouvre un compte suspendu.
  String? restore(String id) {
    final user = find(id);
    if (user == null) return 'Compte introuvable.';
    _replace(user.copyWith(suspended: false, suspensionReason: ''));
    notifyListeners();
    return null;
  }

  UserAccount? _byEmail(String email) {
    final clean = email.trim().toLowerCase();
    for (final user in _users) {
      if (user.email == clean) return user;
    }
    return null;
  }

  void _replace(UserAccount next) {
    _users = [
      for (final user in _users) user.id == next.id ? next : user,
    ];
  }
}
