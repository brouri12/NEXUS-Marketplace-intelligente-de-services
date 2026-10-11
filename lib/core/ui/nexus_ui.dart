import 'package:flutter/material.dart';

import 'package:flutter_android_app/core/theme/indigo_or_chart.dart';
import 'package:flutter_android_app/core/ui/nexus_motion.dart';

/// Fenêtre NEXUS : pastille d'icône, titre centré, deux boutons en bas.
class NexusDialog extends StatelessWidget {
  /// Affiche [titre]. [onConfirmer] ferme ou valide.
  const NexusDialog({
    super.key,
    required this.titre,
    required this.icone,
    this.message,
    this.contenu,
    this.annuler = 'Annuler',
    required this.confirmer,
    required this.onConfirmer,
    this.danger = false,
    this.confirmerActif = true,
  });

  /// Titre centré.
  final String titre;

  /// Icône de la pastille.
  final IconData icone;

  /// Explication sous le titre.
  final String? message;

  /// Champs ou liste, sous le message.
  final Widget? contenu;

  /// Bouton de gauche.
  final String annuler;

  /// Bouton de droite.
  final String confirmer;

  /// Action du bouton de droite.
  final VoidCallback onConfirmer;

  /// Whether the confirm button is red, for a suppression.
  final bool danger;

  /// Faux tant que le champ obligatoire est vide.
  final bool confirmerActif;

  @override
  Widget build(BuildContext context) {
    final accent = danger ? IndigoOrChart.erreur : IndigoOrChart.or;
    return EntreeDialog(
      child: Dialog(
      backgroundColor: IndigoOrChart.surfaceHaute,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: danger ? IndigoOrChart.erreurConteneur : IndigoOrChart.orConteneur,
              child: Icon(icone, color: accent, size: 28),
            ),
            const SizedBox(height: 14),
            Text(
              titre,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: IndigoOrChart.texteMuted),
              ),
            ],
            if (contenu != null) ...[
              const SizedBox(height: 16),
              contenu!,
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(annuler),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: danger ? IndigoOrChart.onErreur : IndigoOrChart.onOr,
                      disabledBackgroundColor: IndigoOrChart.contourDiscret,
                    ),
                    onPressed: confirmerActif ? onConfirmer : null,
                    child: Text(confirmer),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }
}

/// Demande une confirmation. Renvoie vrai si le bouton de droite est touché.
Future<bool> confirmerNexus(
  BuildContext context, {
  required String titre,
  required String message,
  String annuler = 'Annuler',
  String confirmer = 'Confirmer',
  IconData icone = Icons.help_outline,
  bool danger = false,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => NexusDialog(
      titre: titre,
      icone: icone,
      message: message,
      annuler: annuler,
      confirmer: confirmer,
      danger: danger,
      onConfirmer: () => Navigator.of(context).pop(true),
    ),
  );
  return ok ?? false;
}

/// Liste de choix, un par ligne, qui renvoie la valeur touchée.
Future<T?> choisirNexus<T>(
  BuildContext context, {
  required String titre,
  required List<(T, String)> options,
  IconData icone = Icons.list_alt_outlined,
}) {
  return showDialog<T>(
    context: context,
    builder: (context) => EntreeDialog(
      child: Dialog(
      backgroundColor: IndigoOrChart.surfaceHaute,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 20, 8, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: IndigoOrChart.primaireConteneur,
              child: Icon(icone, color: IndigoOrChart.primaire),
            ),
            const SizedBox(height: 12),
            Text(titre, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            for (final (valeur, libelle) in options)
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                title: Text(libelle),
                trailing: const Icon(Icons.chevron_right, color: IndigoOrChart.secondaire),
                onTap: () => Navigator.of(context).pop(valeur),
              ),
          ],
        ),
      ),
      ),
    ),
  );
}

/// Bandeau fixé en bas : l'action principale en or, pleine largeur.
class BarreAction extends StatelessWidget {
  /// Affiche [label]. [secondaire] se place au-dessus, par exemple un total.
  const BarreAction({
    super.key,
    required this.label,
    required this.onPressed,
    this.icone,
    this.secondaire,
    this.actif = true,
  });

  /// Texte du bouton.
  final String label;

  /// Action du bouton.
  final VoidCallback onPressed;

  /// Icône à gauche du texte.
  final IconData? icone;

  /// Ligne au-dessus du bouton.
  final Widget? secondaire;

  /// Faux pour griser le bouton.
  final bool actif;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: IndigoOrChart.surfaceHaute,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: IndigoOrChart.contourDiscret)),
        ),
        child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (secondaire != null) ...[
                  secondaire!,
                  const SizedBox(height: 10),
                ],
                FilledButton.icon(
                  onPressed: actif ? onPressed : null,
                  icon: Icon(icone ?? Icons.check),
                  label: Text(label),
                ),
              ],
            ),
          ),
      ),
    );
  }
}
