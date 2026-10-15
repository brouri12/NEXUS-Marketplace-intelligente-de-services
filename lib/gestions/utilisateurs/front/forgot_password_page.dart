import 'package:flutter/material.dart';

import 'package:flutter_android_app/gestions/utilisateurs/front/utilisateurs_frame.dart';
import 'package:flutter_android_app/gestions/utilisateurs/front/utilisateurs_routes.dart';

/// Demande un code, puis enregistre un nouveau mot de passe.
class ForgotPasswordPage extends StatefulWidget {
  /// Affiche les deux étapes du mot de passe oublié.
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _email = TextEditingController();
  final _code = TextEditingController();
  final _password = TextEditingController();
  var _sent = false;
  var _error = '';

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _password.dispose();
    super.dispose();
  }

  void _request() {
    final error = StoreScope.of(context).requestPasswordReset(_email.text);
    setState(() {
      _error = error ?? '';
      _sent = error == null;
    });
  }

  void _confirm() {
    final error = StoreScope.of(context).confirmPasswordReset(
      code: _code.text,
      password: _password.text,
    );
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    openUtilisateursRoot(context, UtilisateursRoutes.signIn);
  }

  @override
  Widget build(BuildContext context) {
    final code = StoreScope.of(context).resetCode;

    return UtilisateursFrame(
      title: 'Mot de passe oublié',
      child: ListView(
        children: [
          if (!_sent) ...[
            const Text('Indiquez l\'e-mail du compte. Un code permet de choisir un nouveau mot de passe.'),
            const SizedBox(height: 16),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'E-mail'),
            ),
            const SizedBox(height: 16),
            FormErrorText(message: _error),
            FilledButton(onPressed: _request, child: const Text('Recevoir le code')),
          ] else ...[
            Text('Code de démonstration : $code'),
            const SizedBox(height: 12),
            TextField(
              controller: _code,
              decoration: const InputDecoration(labelText: 'Code'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Nouveau mot de passe'),
            ),
            const SizedBox(height: 16),
            FormErrorText(message: _error),
            FilledButton(onPressed: _confirm, child: const Text('Enregistrer')),
          ],
        ],
      ),
    );
  }
}
