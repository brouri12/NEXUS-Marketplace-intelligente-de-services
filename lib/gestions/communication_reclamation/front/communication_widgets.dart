import 'package:flutter/material.dart';

import 'package:flutter_android_app/core/theme/indigo_or_chart.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_presentation.dart';

/// Titre et phrase d'introduction d'un écran.
class IntroCommunication extends StatelessWidget {
  /// Affiche [title] puis [subtitle].
  const IntroCommunication(this.title, this.subtitle, {super.key});

  /// Titre.
  final String title;

  /// Précision.
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(color: IndigoOrChart.texteMuted)),
        ],
      ),
    );
  }
}

/// Petit titre de section.
class SectionCommunication extends StatelessWidget {
  /// Affiche [title] en capitales.
  const SectionCommunication(this.title, {super.key});

  /// Libellé.
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: IndigoOrChart.texteMuted,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/// Pastille de statut.
class TagCommunication extends StatelessWidget {
  /// Affiche [text].
  const TagCommunication(this.text, {super.key, this.alerte = false});

  /// Libellé.
  final String text;

  /// Whether the tag uses the error colors.
  final bool alerte;

  @override
  Widget build(BuildContext context) {
    final color = alerte ? IndigoOrChart.erreurConteneur : IndigoOrChart.primaireConteneur;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: alerte ? IndigoOrChart.erreur : IndigoOrChart.primaire,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Phrase quand une liste est vide.
class VideCommunication extends StatelessWidget {
  /// Affiche [message].
  const VideCommunication(this.message, {super.key});

  /// Explication.
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(message, style: const TextStyle(color: IndigoOrChart.texteMuted)),
    );
  }
}

/// Durée lisible depuis [quand].
String ilYa(DateTime quand) {
  final delta = DateTime.now().difference(quand);
  if (delta.isNegative || delta.inMinutes < 1) return 'À l\'instant';
  if (delta.inMinutes < 60) return 'Il y a ${delta.inMinutes} min';
  if (delta.inHours < 24) return 'Il y a ${delta.inHours} h';
  return formatDate(quand);
}

/// Affiche [message] en bas de l'écran.
void dire(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
