import 'package:flutter/material.dart';

import 'package:flutter_android_app/gestions/utilisateurs/back/utilisateurs_store.dart';
import 'package:flutter_android_app/gestions/utilisateurs/front/account_detail_page.dart';
import 'package:flutter_android_app/gestions/utilisateurs/front/accounts_page.dart';
import 'package:flutter_android_app/gestions/utilisateurs/front/edit_profile_page.dart';
import 'package:flutter_android_app/gestions/utilisateurs/front/forgot_password_page.dart';
import 'package:flutter_android_app/gestions/utilisateurs/front/profile_page.dart';
import 'package:flutter_android_app/gestions/utilisateurs/front/role_page.dart';
import 'package:flutter_android_app/gestions/utilisateurs/front/security_page.dart';
import 'package:flutter_android_app/gestions/utilisateurs/front/sign_in_page.dart';
import 'package:flutter_android_app/gestions/utilisateurs/front/sign_up_page.dart';
import 'package:flutter_android_app/gestions/utilisateurs/front/welcome_page.dart';

/// Noms des écrans de la gestion utilisateurs.
abstract final class UtilisateursRoutes {
  /// Entrée : créer un compte ou se connecter.
  static const welcome = '/';

  /// Connexion.
  static const signIn = '/connexion';

  /// Inscription.
  static const signUp = '/inscription';

  /// Mot de passe oublié.
  static const forgot = '/mot-de-passe';

  /// Profil du compte ouvert.
  static const profile = '/profil';

  /// Modification du profil.
  static const edit = '/profil/modifier';

  /// Mot de passe et sessions.
  static const security = '/securite';

  /// Rôles du compte ouvert.
  static const role = '/role';

  /// Liste des comptes, réservée à l'admin.
  static const accounts = '/comptes';

  /// Détail d'un compte. L'argument de route est l'identifiant.
  static const account = '/comptes/detail';

  /// Construit la page demandée par [settings].
  static Route<void> generate(RouteSettings settings, UtilisateursStore store) {
    final page = switch (settings.name) {
      signIn => const SignInPage(),
      signUp => const SignUpPage(),
      forgot => const ForgotPasswordPage(),
      profile => const ProfilePage(),
      edit => EditProfilePage(userId: settings.arguments as String?),
      security => const SecurityPage(),
      role => const RolePage(),
      accounts => const AccountsPage(),
      account => AccountDetailPage(userId: settings.arguments! as String),
      _ => const WelcomePage(),
    };
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (context) => StoreScope(store: store, child: page),
    );
  }
}

/// Remplace la pile interne par [route] après une connexion ou une déconnexion.
void openUtilisateursRoot(BuildContext context, String route) {
  Navigator.of(context).pushNamedAndRemoveUntil(route, (route) => false);
}

/// Ouvre [route] au-dessus de l'écran actuel.
void openUtilisateursPage(
  BuildContext context,
  String route, {
  Object? arguments,
}) {
  Navigator.of(context).pushNamed(route, arguments: arguments);
}

/// Rend [UtilisateursStore] disponible aux écrans poussés par le navigateur.
class StoreScope extends InheritedWidget {
  /// Publie [store] pour [child].
  const StoreScope({super.key, required this.store, required super.child});

  /// Back des comptes, profils, rôles et de la sécurité.
  final UtilisateursStore store;

  /// Store au-dessus de [context].
  static UtilisateursStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<StoreScope>();
    assert(scope != null, 'StoreScope est absent au-dessus de cet écran.');
    return scope!.store;
  }

  @override
  bool updateShouldNotify(StoreScope oldWidget) => store != oldWidget.store;
}

