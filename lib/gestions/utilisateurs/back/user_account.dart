import 'package:flutter_android_app/gestions/utilisateurs/back/provider_profile.dart';

/// Libellé français de [role].
String labelForRole(UserRole role) {
  return switch (role) {
    UserRole.client => 'Client',
    UserRole.provider => 'Prestataire',
    UserRole.admin => 'Admin',
  };
}

/// Rôle possible sur un compte NEXUS.
enum UserRole {
  /// Personne qui décrit un besoin.
  client,

  /// Personne qui propose un service.
  provider,

  /// Personne qui gère les comptes.
  admin,
}

/// Session ouverte sur un compte.
class DeviceSession {
  /// Crée une session déjà ouverte.
  const DeviceSession({
    required this.id,
    required this.label,
    required this.startedAt,
    required this.current,
  });

  /// Identifiant stable de la session.
  final String id;

  /// Appareil ou navigateur affiché.
  final String label;

  /// Moment d'ouverture.
  final DateTime startedAt;

  /// Whether this session is the one in use.
  final bool current;

  /// Returns a copy with [current] replaced.
  DeviceSession copyWith({bool? current}) {
    return DeviceSession(
      id: id,
      label: label,
      startedAt: startedAt,
      current: current ?? this.current,
    );
  }
}

/// Compte, profil et droits d'une personne.
class UserAccount {
  /// Crée un compte complet.
  const UserAccount({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.city,
    required this.password,
    required this.roles,
    required this.createdAt,
    this.lastAccess,
    this.suspended = false,
    this.suspensionReason = '',
    this.requiresSignInCode = false,
    this.hasActiveContract = false,
    this.confirmed = true,
    this.providerProfile,
  });

  /// Identifiant stable.
  final String id;

  /// Prénom affiché.
  final String firstName;

  /// Nom affiché.
  final String lastName;

  /// Adresse utilisée pour se connecter.
  final String email;

  /// Téléphone de contact.
  final String phone;

  /// Ville reprise par la marketplace si le besoin n'en donne pas.
  final String city;

  /// Mot de passe conservé pour cette démonstration locale.
  final String password;

  /// Rôles actifs.
  final Set<UserRole> roles;

  /// Date de création.
  final DateTime createdAt;

  /// Dernière connexion réussie.
  final DateTime? lastAccess;

  /// Whether the account is blocked.
  final bool suspended;

  /// Motif affiché quand le compte est suspendu.
  final String suspensionReason;

  /// Whether a second code is required at sign-in.
  final bool requiresSignInCode;

  /// Whether a contract still blocks removing the provider role.
  final bool hasActiveContract;

  /// Whether an admin has confirmed this provider account.
  final bool confirmed;

  /// Fiche métier, absente pour un client simple.
  final ProviderProfile? providerProfile;

  /// Nom complet.
  String get fullName => '$firstName $lastName'.trim();

  /// Whether [role] is active.
  bool hasRole(UserRole role) => roles.contains(role);

  /// Whether this account is only a client, with no right to change its role.
  bool get isSimpleClient =>
      hasRole(UserRole.client) &&
      !hasRole(UserRole.provider) &&
      !hasRole(UserRole.admin);

  /// Returns a copy with the given fields replaced.
  UserAccount copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? city,
    String? password,
    Set<UserRole>? roles,
    DateTime? lastAccess,
    bool? suspended,
    String? suspensionReason,
    bool? requiresSignInCode,
    bool? hasActiveContract,
    bool? confirmed,
    ProviderProfile? providerProfile,
  }) {
    return UserAccount(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      password: password ?? this.password,
      roles: roles ?? this.roles,
      createdAt: createdAt,
      lastAccess: lastAccess ?? this.lastAccess,
      suspended: suspended ?? this.suspended,
      suspensionReason: suspensionReason ?? this.suspensionReason,
      requiresSignInCode: requiresSignInCode ?? this.requiresSignInCode,
      hasActiveContract: hasActiveContract ?? this.hasActiveContract,
      confirmed: confirmed ?? this.confirmed,
      providerProfile: providerProfile ?? this.providerProfile,
    );
  }
}
