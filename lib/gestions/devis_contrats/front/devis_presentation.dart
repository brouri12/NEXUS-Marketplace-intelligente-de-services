import 'package:flutter/material.dart';

import 'package:flutter_android_app/core/theme/indigo_or_chart.dart';
import 'package:flutter_android_app/gestions/devis_contrats/back/contrat.dart';
import 'package:flutter_android_app/gestions/devis_contrats/back/devis.dart';
import 'package:flutter_android_app/gestions/devis_contrats/back/option_ligne.dart';

/// Date courte, comme sur les comptes.
String formatDate(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  return '$day/$month/${value.year}';
}

/// Montant en dinars.
String formatDt(int amount) => '$amount DT';

/// Distance lisible.
String formatKm(double km) {
  if (km == km.roundToDouble()) return '${km.round()} km';
  return '${km.toStringAsFixed(1)} km';
}

/// Ligne « Libellé : valeur ».
class InfoLigne extends StatelessWidget {
  /// Affiche [label] puis [value].
  const InfoLigne(this.label, this.value, {super.key});

  /// Nom du champ.
  final String label;

  /// Valeur déjà rédigée.
  final String value;

  @override
  Widget build(BuildContext context) {
    final shown = value.trim().isEmpty ? '—' : value.trim();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text('$label : $shown'),
    );
  }
}

/// Titre de section dans un détail.
class SectionTitre extends StatelessWidget {
  /// Affiche [texte].
  const SectionTitre(this.texte, {super.key});

  /// Titre.
  final String texte;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(texte, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

/// Pastille de statut, hors de l'or des boutons.
class StatutTexte extends StatelessWidget {
  /// Affiche [label] dans [color].
  const StatutTexte({super.key, required this.label, required this.color});

  /// Statut déjà rédigé.
  final String label;

  /// Couleur du statut.
  final Color color;

  /// Pastille d'un devis.
  factory StatutTexte.devis(StatutDevis statut) {
    final color = switch (statut) {
      StatutDevis.accepte => IndigoOrChart.succes,
      StatutDevis.refuse || StatutDevis.expire => IndigoOrChart.erreur,
      StatutDevis.brouillon => IndigoOrChart.texteMuted,
      StatutDevis.envoye || StatutDevis.vu => IndigoOrChart.attente,
    };
    return StatutTexte(label: labelStatutDevis(statut), color: color);
  }

  /// Pastille d'un contrat.
  factory StatutTexte.contrat(StatutContrat statut) {
    final color = switch (statut) {
      StatutContrat.valide || StatutContrat.termine => IndigoOrChart.succes,
      StatutContrat.annule => IndigoOrChart.erreur,
      StatutContrat.enCours ||
      StatutContrat.attenteSignaturePrestataire ||
      StatutContrat.attenteSignatureClient => IndigoOrChart.attente,
    };
    return StatutTexte(label: labelStatutContrat(statut), color: color);
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(color: color, fontWeight: FontWeight.w600),
    );
  }
}

/// Décomposition du prix, toujours calculée.
class MontantBlock extends StatelessWidget {
  /// Affiche la base, les options, la distance et le total.
  const MontantBlock({
    super.key,
    required this.prixBase,
    required this.options,
    required this.distanceKm,
    required this.prixParKm,
  });

  /// Prix de base.
  final int prixBase;

  /// Options choisies.
  final List<OptionLigne> options;

  /// Distance en kilomètres.
  final double distanceKm;

  /// Prix d'un kilomètre.
  final int prixParKm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deplacement = fraisDistance(distanceKm, prixParKm);
    final total = prixTotal(
      prixBase: prixBase,
      options: options,
      distanceKm: distanceKm,
      prixParKm: prixParKm,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InfoLigne('Prix de base', formatDt(prixBase)),
        const SectionTitre('Options choisies'),
        if (options.isEmpty) const InfoLigne('Options', 'Aucune'),
        for (final option in options) InfoLigne(option.label, formatDt(option.prix)),
        const SizedBox(height: 8),
        InfoLigne('Distance', formatKm(distanceKm)),
        InfoLigne('Prix/km', formatDt(prixParKm)),
        InfoLigne('Frais de déplacement', formatDt(deplacement)),
        const SizedBox(height: 8),
        Text('TOTAL : ${formatDt(total)}', style: theme.textTheme.titleMedium),
      ],
    );
  }
}

/// Mention légale sous le devis.
class RemarqueDevis extends StatelessWidget {
  /// Affiche le texte fixe du devis.
  const RemarqueDevis({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(remarqueDevis),
      ),
    );
  }
}

/// Cachet de plateforme, une fois les deux signatures présentes.
class CachetNexus extends StatelessWidget {
  /// Affiche le numéro [numero].
  const CachetNexus({super.key, required this.numero});

  /// Numéro du contrat validé.
  final String numero;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: IndigoOrChart.surfaceHaute,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: IndigoOrChart.succes, width: 2),
        ),
        child: Column(
          children: [
            const Text(
              'NEXUS',
              style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1.2),
            ),
            const SizedBox(height: 4),
            const Text('✓ CONTRAT VALIDÉ'),
            const SizedBox(height: 4),
            Text(numero),
            const SizedBox(height: 8),
            const Text(
              'Document généré, accepté et enregistré par la plateforme.',
              textAlign: TextAlign.center,
              style: TextStyle(color: IndigoOrChart.texteMuted),
            ),
          ],
        ),
      ),
    );
  }
}

/// Carte de liste : le statut passe à la ligne, il ne compresse plus le texte.
class FicheListe extends StatelessWidget {
  /// Affiche [titre], [lignes] et [statut].
  const FicheListe({
    super.key,
    required this.titre,
    required this.lignes,
    required this.statut,
    required this.onTap,
    this.icon = Icons.description_outlined,
  });

  /// Première ligne, par exemple le numéro.
  final String titre;

  /// Détails, une phrase par ligne.
  final List<String> lignes;

  /// Statut, affiché en dessous pour pouvoir aller à la ligne.
  final Widget statut;

  /// Ouvre le détail.
  final VoidCallback onTap;

  /// Icône à gauche du titre.
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(titre, style: Theme.of(context).textTheme.titleMedium),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              for (final ligne in lignes)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(ligne),
                ),
              const SizedBox(height: 4),
              statut,
            ],
          ),
        ),
      ),
    );
  }
}
class DevisLien extends StatelessWidget {
  /// Affiche [title] et appelle [onTap].
  const DevisLien({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  /// Icône du lien.
  final IconData icon;

  /// Libellé.
  final String title;

  /// Ouvre l'écran.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
