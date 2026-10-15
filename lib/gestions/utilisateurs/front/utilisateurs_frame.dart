import 'package:flutter/material.dart';

/// Cadre commun des écrans utilisateurs, centré sur un grand écran.
class UtilisateursFrame extends StatelessWidget {
  /// Affiche [title] et [child] dans la largeur lisible des formulaires.
  const UtilisateursFrame({
    super.key,
    required this.title,
    required this.child,
    this.leaveGestion = false,
  });

  /// Titre de la barre.
  final String title;

  /// Contenu défilant de l'écran.
  final Widget child;

  /// Whether the back control leaves the gestion instead of the inner page.
  final bool leaveGestion;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        automaticallyImplyLeading: false,
        leading: _leading(context),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth.clamp(0, 560).toDouble();
          return Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: width,
              height: constraints.maxHeight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget? _leading(BuildContext context) {
    final nested = Navigator.of(context);
    if (!nested.canPop() && !leaveGestion) return null;
    return IconButton(
      tooltip: 'Retour',
      onPressed: () => _goBack(context),
      icon: const Icon(Icons.arrow_back),
    );
  }

  void _goBack(BuildContext context) {
    final nested = Navigator.of(context);
    if (!leaveGestion && nested.canPop()) {
      nested.pop();
      return;
    }
    Navigator.of(context, rootNavigator: true).pop();
  }
}

/// Message d'erreur sous un formulaire.
class FormErrorText extends StatelessWidget {
  /// Affiche [message] dans la couleur d'erreur.
  const FormErrorText({super.key, required this.message});

  /// Texte déjà rédigé pour la personne.
  final String message;

  @override
  Widget build(BuildContext context) {
    if (message.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        message,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    );
  }
}
