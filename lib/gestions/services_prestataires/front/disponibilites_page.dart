import 'package:flutter/material.dart';

import 'package:flutter_android_app/core/theme/indigo_or_chart.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/composants.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/etat.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/modele.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/texte.dart';

/// Semaine du prestataire, découpée en matin, après-midi et soir.
class DisponibilitesPage extends StatefulWidget {
  /// Affiche la semaine portée par [etat].
  const DisponibilitesPage({super.key, required this.etat});

  /// Mémoire d'écran.
  final ServicesPrestatairesEtat etat;

  @override
  State<DisponibilitesPage> createState() => _DisponibilitesPageState();
}

class _DisponibilitesPageState extends State<DisponibilitesPage> {
  late DateTime _jour;

  @override
  void initState() {
    super.initState();
    _jour = widget.etat.aujourdhui;
  }

  @override
  Widget build(BuildContext context) {
    final etat = widget.etat;
    final lundi = etat.lundiCourant;
    final jours = List<DateTime>.generate(
      7,
      (decalage) => lundi.add(Duration(days: decalage)),
    );

    return ListenableBuilder(
      listenable: etat,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Disponibilités')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              const Legende(
                'Chaque jour se découpe en matin, après-midi et soir. '
                'Samedi matin ne correspond que si ce bloc est ouvert et libre.',
              ),
              const SizedBox(height: 16),
              Text(
                libelleSemaine(lundi),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 76,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: jours.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final jour = jours[index];
                    final verrouille = MomentJournee.values.any(
                      (moment) =>
                          etat.etatCreneau(jour, moment) ==
                          EtatCreneau.verrouille,
                    );
                    return _JourSemaine(
                      jour: jour,
                      selectionne: jour == _jour,
                      verrouille: verrouille,
                      onTap: () => setState(() => _jour = jour),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Text(
                libelleJour(_jour),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              for (final moment in MomentJournee.values)
                _TuileCreneau(
                  moment: moment,
                  etat: etat.etatCreneau(_jour, moment),
                  onChanged: (ouvert) {
                    etat.definirCreneau(_jour, moment, ouvert);
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class _JourSemaine extends StatelessWidget {
  const _JourSemaine({
    required this.jour,
    required this.selectionne,
    required this.verrouille,
    required this.onTap,
  });

  final DateTime jour;
  final bool selectionne;
  final bool verrouille;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final encre = selectionne ? IndigoOrChart.onPrimaire : IndigoOrChart.texte;
    return Material(
      color: selectionne ? IndigoOrChart.primaire : IndigoOrChart.surfaceHaute,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        side: selectionne
            ? BorderSide.none
            : const BorderSide(color: IndigoOrChart.contourDiscret),
      ),
      child: InkWell(
        customBorder: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        onTap: onTap,
        child: SizedBox(
          width: 64,
          height: 72,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                nomJourCourt(jour),
                style: TextStyle(color: encre, fontSize: 13),
              ),
              Text(
                '${jour.day}',
                style: TextStyle(color: encre, fontSize: 16),
              ),
              if (verrouille)
                Icon(
                  Icons.lock,
                  size: 12,
                  color: selectionne ? IndigoOrChart.or : IndigoOrChart.attente,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TuileCreneau extends StatelessWidget {
  const _TuileCreneau({
    required this.moment,
    required this.etat,
    required this.onChanged,
  });

  final MomentJournee moment;
  final EtatCreneau etat;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final verrouille = etat == EtatCreneau.verrouille;
    final statut = switch (etat) {
      EtatCreneau.ouvert => 'Ouvert',
      EtatCreneau.ferme => 'Fermé',
      EtatCreneau.verrouille => 'Prestation confirmée',
    };
    final encre = switch (etat) {
      EtatCreneau.ouvert => IndigoOrChart.succes,
      EtatCreneau.ferme => IndigoOrChart.texteMuted,
      EtatCreneau.verrouille => IndigoOrChart.attente,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(libelleMoment(moment), style: theme.textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(statut, style: theme.textTheme.bodyMedium?.copyWith(color: encre)),
                ],
              ),
            ),
            if (verrouille)
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(Icons.lock_outline, color: IndigoOrChart.attente),
              )
            else
              Switch(
                value: etat == EtatCreneau.ouvert,
                onChanged: onChanged,
              ),
          ],
        ),
      ),
    );
  }
}
