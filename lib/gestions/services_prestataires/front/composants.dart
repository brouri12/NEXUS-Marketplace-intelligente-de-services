import 'package:flutter/material.dart';

import 'package:flutter_android_app/core/theme/indigo_or_chart.dart';

/// Légende secondaire.
class Legende extends StatelessWidget {
  /// Affiche [texte] en couleur atténuée.
  const Legende(
    this.texte, {
    super.key,
    this.alignement = TextAlign.start,
  });

  /// Texte de la légende.
  final String texte;

  /// Alignement quand la ligne passe à la ligne.
  final TextAlign alignement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      texte,
      textAlign: alignement,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

/// Titre d'un bloc dans une page.
class TitreSection extends StatelessWidget {
  /// Affiche [texte].
  const TitreSection(this.texte, {super.key});

  /// Libellé du bloc.
  final String texte;

  @override
  Widget build(BuildContext context) {
    return Text(texte, style: Theme.of(context).textTheme.titleMedium);
  }
}

/// Pastille de statut.
class Pastille extends StatelessWidget {
  /// Affiche [libelle] sur [fond].
  const Pastille({
    super.key,
    required this.libelle,
    required this.fond,
    required this.encre,
  });

  /// Offre publiée.
  const Pastille.actif({super.key})
    : libelle = 'Actif',
      fond = const Color(0xFFDCEFE4),
      encre = IndigoOrChart.succes;

  /// Offre retirée des résultats.
  const Pastille.masque({super.key})
    : libelle = 'Masqué',
      fond = IndigoOrChart.contourDiscret,
      encre = IndigoOrChart.texteMuted;

  /// Offre sans tarif, donc absente des résultats.
  const Pastille.sansTarif({super.key})
    : libelle = 'Sans tarif',
      fond = IndigoOrChart.erreurConteneur,
      encre = IndigoOrChart.onErreurConteneur;

  /// Saisie libre encore non validée.
  const Pastille.attente({super.key})
    : libelle = 'En attente',
      fond = const Color(0xFFF8EBD6),
      encre = IndigoOrChart.attente;

  /// Offre refusée par l'admin.
  const Pastille.refuse({super.key})
    : libelle = 'Refusé',
      fond = IndigoOrChart.erreurConteneur,
      encre = IndigoOrChart.onErreurConteneur;

  /// Texte court.
  final String libelle;

  /// Fond de la pastille.
  final Color fond;

  /// Couleur du texte.
  final Color encre;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: fond,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          libelle,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: encre,
          ),
        ),
      ),
    );
  }
}

/// Case à cocher en pastille, or quand elle est prise.
class PastilleChoix extends StatelessWidget {
  /// Affiche [libelle], cochée selon [choisie].
  const PastilleChoix({
    super.key,
    required this.libelle,
    required this.choisie,
    required this.onChoisir,
  });

  /// Texte de la pastille.
  final String libelle;

  /// Vrai si la pastille est prise.
  final bool choisie;

  /// Reçoit le nouvel état.
  final ValueChanged<bool> onChoisir;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(libelle),
      selected: choisie,
      onSelected: onChoisir,
      selectedColor: IndigoOrChart.orConteneur,
      checkmarkColor: IndigoOrChart.onOrConteneur,
      backgroundColor: IndigoOrChart.surfaceHaute,
      labelStyle: TextStyle(
        color: choisie ? IndigoOrChart.onOrConteneur : IndigoOrChart.texte,
      ),
      side: BorderSide(
        color: choisie ? IndigoOrChart.or : IndigoOrChart.contour,
      ),
    );
  }
}

/// Un seul choix parmi [options], en pastilles.
class ChoixPastilles<T> extends StatelessWidget {
  /// Affiche les options. [valeur] est la pastille prise.
  const ChoixPastilles({
    super.key,
    required this.valeur,
    required this.options,
    required this.libelle,
    required this.onChoisir,
  });

  /// Option prise.
  final T valeur;

  /// Options, dans l'ordre d'affichage.
  final List<T> options;

  /// Texte d'une option.
  final String Function(T option) libelle;

  /// Reçoit l'option choisie.
  final ValueChanged<T> onChoisir;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in options)
          PastilleChoix(
            libelle: libelle(option),
            choisie: option == valeur,
            onChoisir: (choisie) {
              if (choisie) {
                onChoisir(option);
              }
            },
          ),
      ],
    );
  }
}

/// Résumé du jour, sur le tableau de bord.
class TuileResume extends StatelessWidget {
  /// Affiche [valeur] et [legende]. [onTap] ouvre la suite.
  const TuileResume({
    super.key,
    required this.icone,
    required this.valeur,
    required this.legende,
    this.detail,
    this.onTap,
  });

  /// Icône du résumé.
  final IconData icone;

  /// Fait principal.
  final String valeur;

  /// Nom du résumé.
  final String legende;

  /// Précision sous le nom.
  final String? detail;

  /// Ouverture au toucher.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final contenu = Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: IndigoOrChart.primaireConteneur,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: Center(
                child: Icon(icone, color: IndigoOrChart.primaire),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  valeur,
                  style: theme.textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Legende(legende),
                if (detail != null && detail!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Legende(detail!),
                ],
              ],
            ),
          ),
          if (onTap != null) const Icon(Icons.chevron_right),
        ],
      ),
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12),
      child: onTap == null
          ? contenu
          : InkWell(onTap: onTap, child: contenu),
    );
  }
}

/// Raccourci vers un écran de la gestion.
class TuileRaccourci extends StatelessWidget {
  /// Affiche [titre] et ouvre [onTap].
  const TuileRaccourci({
    super.key,
    required this.icone,
    required this.titre,
    required this.detail,
    required this.onTap,
  });

  /// Icône du raccourci.
  final IconData icone;

  /// Nom de l'écran.
  final String titre;

  /// Précision sous le nom.
  final String detail;

  /// Ouverture au toucher.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icone, color: IndigoOrChart.primaire),
        title: Text(titre),
        subtitle: Text(detail),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

/// Barre fixe en bas d'un écran.
class BarreBasse extends StatelessWidget {
  /// Pose [child] au-dessus du bord de l'écran.
  const BarreBasse({super.key, required this.child});

  /// Contenu, souvent un bouton.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: IndigoOrChart.fond,
        border: Border(top: BorderSide(color: IndigoOrChart.contourDiscret)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: child,
        ),
      ),
    );
  }
}

/// Bouton or, sur toute la largeur.
class BoutonLarge extends StatelessWidget {
  /// Affiche [libelle]. [onPressed] nul désactive le bouton.
  const BoutonLarge({
    super.key,
    required this.libelle,
    required this.onPressed,
  });

  /// Texte du bouton.
  final String libelle;

  /// Action au toucher.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        child: Text(libelle),
      ),
    );
  }
}

/// Champ encadré, fond blanc.
InputDecoration decorationChamp(
  BuildContext context, {
  required String label,
  String? indice,
}) {
  const bord = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
    borderSide: BorderSide(color: IndigoOrChart.contour),
  );
  return InputDecoration(
    labelText: label,
    hintText: indice,
    filled: true,
    fillColor: IndigoOrChart.surfaceHaute,
    counterText: '',
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: bord,
    enabledBorder: bord,
    focusedBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: IndigoOrChart.primaire, width: 1.5),
    ),
  );
}
