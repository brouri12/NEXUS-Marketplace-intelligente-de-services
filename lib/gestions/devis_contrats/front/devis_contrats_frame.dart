import 'package:flutter/material.dart';

import 'package:flutter_android_app/gestions/utilisateurs/front/utilisateurs_frame.dart';

/// Cadre commun des écrans devis et contrats.
class DevisContratsFrame extends StatelessWidget {
  /// Affiche [title] et [child] dans la largeur lisible des formulaires.
  const DevisContratsFrame({super.key, required this.title, required this.child});

  /// Titre de la barre.
  final String title;

  /// Contenu défilant de l'écran.
  final Widget child;

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
    if (!nested.canPop()) return null;
    return IconButton(
      tooltip: 'Retour',
      onPressed: nested.pop,
      icon: const Icon(Icons.arrow_back),
    );
  }
}

/// Écran refusé, même forme que le détail d'un compte inaccessible.
class AccesRefuse extends StatelessWidget {
  /// Affiche [message] sous [title].
  const AccesRefuse({super.key, required this.title, required this.message});

  /// Titre de la barre.
  final String title;

  /// Motif déjà rédigé.
  final String message;

  @override
  Widget build(BuildContext context) {
    return DevisContratsFrame(
      title: title,
      child: ListView(children: [Text(message)]),
    );
  }
}

/// Réexporte l'erreur de formulaire déjà utilisée par les comptes.
typedef ErreurFormulaire = FormErrorText;
