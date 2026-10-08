import 'package:flutter/material.dart';

import 'package:flutter_android_app/gestions/utilisateurs/back/utilisateurs_store.dart';
import 'package:flutter_android_app/gestions/utilisateurs/front/utilisateurs_frame.dart';
import 'package:flutter_android_app/gestions/utilisateurs/front/utilisateurs_routes.dart';

/// Connexion par e-mail, avec le code supplémentaire si le compte l'exige.
class SignInPage extends StatefulWidget {
  /// Affiche le formulaire de connexion.
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _DemoAccount {
  const _DemoAccount(this.label, this.email, this.icon);

  final String label;
  final String email;
  final IconData icon;
}

const _demos = [
  _DemoAccount('Sara, cliente', 'sara@nexus.app', Icons.person_outline),
  _DemoAccount('Amine, prestataire', 'amine@nexus.app', Icons.handyman_outlined),
  _DemoAccount('Nour, admin', 'admin@nexus.app', Icons.admin_panel_settings_outlined),
];

class _SignInPageState extends State<SignInPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _code = TextEditingController();
  var _error = '';
  var _askCode = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _code.dispose();
    super.dispose();
  }

  void _submit() {
    final store = StoreScope.of(context);
    final status = store.signIn(
      email: _email.text,
      password: _password.text,
      code: _code.text,
    );
    switch (status) {
      case SignInStatus.success:
        break;
      case SignInStatus.invalid:
        setState(() => _error = 'E-mail ou mot de passe refusé.');
      case SignInStatus.suspended:
        setState(() => _error = 'Ce compte est suspendu.');
      case SignInStatus.pending:
        setState(
          () => _error =
              'Ce compte prestataire attend la confirmation d\'un administrateur.',
        );
      case SignInStatus.codeRequired:
        setState(() {
          _askCode = true;
          _error = 'Ce compte demande le code de connexion.';
        });
      case SignInStatus.badCode:
        setState(() => _error = 'Le code est incorrect.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return UtilisateursFrame(
      title: 'Connexion',
      child: ListView(
        children: [
          const SizedBox(height: 12),
          Icon(Icons.apartment_outlined, size: 40, color: theme.colorScheme.primary),
          const SizedBox(height: 12),
          Text('NEXUS', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 4),
          const Text('Marketplace intelligente de services'),
          const SizedBox(height: 28),
          TextField(
            key: const Key('sign-in-email'),
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'E-mail',
              prefixIcon: Icon(Icons.mail_outline),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('sign-in-password'),
            controller: _password,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Mot de passe',
              prefixIcon: Icon(Icons.lock_outline),
            ),
          ),
          if (_askCode) ...[
            const SizedBox(height: 12),
            TextField(
              key: const Key('sign-in-code'),
              controller: _code,
              decoration: const InputDecoration(
                labelText: 'Code',
                prefixIcon: Icon(Icons.pin_outlined),
                helperText: 'Démonstration : ${UtilisateursStore.demoSignInCode}',
              ),
            ),
          ],
          const SizedBox(height: 16),
          FormErrorText(message: _error),
          FilledButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.login),
            label: const Text('Se connecter'),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            children: [
              TextButton.icon(
                onPressed: () => openUtilisateursPage(context, UtilisateursRoutes.forgot),
                icon: const Icon(Icons.key_outlined),
                label: const Text('Mot de passe oublié'),
              ),
              TextButton.icon(
                onPressed: () => openUtilisateursPage(context, UtilisateursRoutes.signUp),
                icon: const Icon(Icons.person_add_outlined),
                label: const Text('Créer un compte'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Comptes de démonstration', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          for (final demo in _demos)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(demo.icon),
                title: Text(demo.label),
                subtitle: Text(demo.email),
                onTap: () {
                  setState(() {
                    _email.text = demo.email;
                    _password.text = UtilisateursStore.demoPassword;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }
}
