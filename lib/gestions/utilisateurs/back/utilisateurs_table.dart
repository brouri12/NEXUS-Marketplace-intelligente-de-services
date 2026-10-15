import 'package:flutter_android_app/core/db/nexus_database.dart';
import 'package:flutter_android_app/gestions/utilisateurs/back/provider_profile.dart';
import 'package:flutter_android_app/gestions/utilisateurs/back/user_account.dart';

/// Table SQLite des comptes.
const tableUtilisateurs = 'utilisateurs';

/// Schéma de la gestion utilisateurs.
const schemaUtilisateurs = [
  '''
CREATE TABLE IF NOT EXISTS $tableUtilisateurs (
  id TEXT PRIMARY KEY,
  prenom TEXT NOT NULL,
  nom TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  telephone TEXT NOT NULL,
  ville TEXT NOT NULL,
  mot_de_passe TEXT NOT NULL,
  roles TEXT NOT NULL,
  cree_le INTEGER NOT NULL,
  dernier_acces INTEGER,
  suspendu INTEGER NOT NULL,
  motif_suspension TEXT NOT NULL,
  code_connexion INTEGER NOT NULL,
  contrat_actif INTEGER NOT NULL,
  confirme INTEGER NOT NULL,
  profil TEXT
)''',
];

/// Ligne SQLite de [user].
Map<String, Object?> ligneUtilisateur(UserAccount user) {
  final profil = user.providerProfile;
  return {
    'id': user.id,
    'prenom': user.firstName,
    'nom': user.lastName,
    'email': user.email,
    'telephone': user.phone,
    'ville': user.city,
    'mot_de_passe': user.password,
    'roles': sqlListe([for (final role in user.roles) role.name]),
    'cree_le': sqlDate(user.createdAt),
    'dernier_acces': sqlDate(user.lastAccess),
    'suspendu': sqlBool(user.suspended),
    'motif_suspension': user.suspensionReason,
    'code_connexion': sqlBool(user.requiresSignInCode),
    'contrat_actif': sqlBool(user.hasActiveContract),
    'confirme': sqlBool(user.confirmed),
    'profil': profil == null
        ? null
        : sqlJson({
            'service': profil.service,
            'skills': profil.skills,
            'hourlyRate': profil.hourlyRate,
            'availability': profil.availability,
            'presentation': profil.presentation,
          }),
  };
}

/// Compte lu depuis [ligne].
UserAccount utilisateurDepuis(Map<String, Object?> ligne) {
  final profil = lireJson(ligne['profil']) as Map<String, Object?>?;
  return UserAccount(
    id: ligne['id']! as String,
    firstName: lireTexte(ligne['prenom']),
    lastName: lireTexte(ligne['nom']),
    email: lireTexte(ligne['email']),
    phone: lireTexte(ligne['telephone']),
    city: lireTexte(ligne['ville']),
    password: lireTexte(ligne['mot_de_passe']),
    roles: {
      for (final name in lireListe(ligne['roles']))
        UserRole.values.byName(name),
    },
    createdAt: lireDate(ligne['cree_le']),
    lastAccess: lireDateOuNull(ligne['dernier_acces']),
    suspended: lireBool(ligne['suspendu']),
    suspensionReason: lireTexte(ligne['motif_suspension']),
    requiresSignInCode: lireBool(ligne['code_connexion']),
    hasActiveContract: lireBool(ligne['contrat_actif']),
    confirmed: lireBool(ligne['confirme']),
    providerProfile: profil == null
        ? null
        : ProviderProfile(
            service: '${profil['service']}',
            skills: [for (final item in profil['skills']! as List<Object?>) '$item'],
            hourlyRate: profil['hourlyRate']! as int,
            availability: [
              for (final item in profil['availability']! as List<Object?>) '$item',
            ],
            presentation: '${profil['presentation'] ?? ''}',
          ),
  );
}
