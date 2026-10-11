import 'package:flutter/material.dart';

import 'package:flutter_android_app/core/theme/indigo_or_chart.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/composants.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/etat.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/liens.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/modele.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/texte.dart';

/// Fiche lue par le client. Aucun crayon sur cette page.
///
/// Marketplace ouvre cet écran. [besoinDejaConfirme] vient du besoin en cours :
/// le bouton part alors vers Devis, sinon il renvoie à l'accueil Marketplace.
/// [permettreApercu] sert au prestataire, depuis son tableau de bord, pour voir
/// les deux libellés.
class FichePubliquePage extends StatefulWidget {
  /// Affiche la fiche de [etat].
  const FichePubliquePage({
    super.key,
    required this.etat,
    this.besoinDejaConfirme = false,
    this.permettreApercu = false,
  });

  /// Mémoire d'écran.
  final ServicesPrestatairesEtat etat;

  /// Vrai quand Marketplace a déjà un besoin confirmé.
  final bool besoinDejaConfirme;

  /// Vrai sur l'aperçu ouvert depuis le tableau de bord.
  final bool permettreApercu;

  @override
  State<FichePubliquePage> createState() => _FichePubliquePageState();
}

class _FichePubliquePageState extends State<FichePubliquePage> {
  late bool _besoin;

  @override
  void initState() {
    super.initState();
    _besoin = widget.besoinDejaConfirme;
  }

  @override
  Widget build(BuildContext context) {
    final etat = widget.etat;
    final besoin = widget.permettreApercu ? _besoin : widget.besoinDejaConfirme;

    return ListenableBuilder(
      listenable: etat,
      builder: (context, _) {
        final services = etat.servicesDeLaFiche(apercu: widget.permettreApercu);
        return Scaffold(
          appBar: AppBar(title: const Text('Fiche publique')),
          body: Column(
            children: [
              if (widget.permettreApercu) _apercu(context),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  children: [
                    _entete(context, etat),
                    const SizedBox(height: 20),
                    const TitreSection('Services'),
                    const SizedBox(height: 12),
                    if (services.isEmpty)
                      const Legende('Aucun service publié.')
                    else
                      for (final service in services) _service(context, service),
                    const SizedBox(height: 8),
                    const TitreSection('Fourchette de prix'),
                    const SizedBox(height: 12),
                    _prix(context, etat),
                    const SizedBox(height: 20),
                    const TitreSection('Note'),
                    const SizedBox(height: 12),
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Legende('Pas encore de note.'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const TitreSection('Derniers avis'),
                    const SizedBox(height: 12),
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Legende('Pas encore d\'avis.'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: BarreBasse(
            child: BoutonLarge(
              libelle: besoin
                  ? 'Demander un devis'
                  : 'D\'abord décrire le besoin',
              onPressed: () => _ouvrirSuite(context, besoin),
            ),
          ),
        );
      },
    );
  }

  Widget _apercu(BuildContext context) {
    return Material(
      color: IndigoOrChart.primaireConteneur,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Aperçu client',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: IndigoOrChart.onPrimaireConteneur,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<bool>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: false, label: Text('Sans besoin')),
                ButtonSegment(value: true, label: Text('Besoin confirmé')),
              ],
              selected: {_besoin},
              onSelectionChanged: (valeurs) {
                setState(() => _besoin = valeurs.first);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _entete(BuildContext context, ServicesPrestatairesEtat etat) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 32,
              backgroundColor: IndigoOrChart.primaireConteneur,
              child: Icon(
                Icons.person,
                size: 32,
                color: IndigoOrChart.primaire,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(etat.nomProfil, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Legende(etat.zoneAffichee),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _service(BuildContext context, OffreService service) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(service.nom, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Legende(
              '${libelleVehicule(service.vehicule)} · ${service.libelleEquipe}',
            ),
            if (widget.permettreApercu && service.tarif == null) ...[
              const SizedBox(height: 8),
              const Pastille.sansTarif(),
            ],
            if (service.competencesVisibles.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final competence in service.competencesVisibles)
                    Chip(
                      label: Text(competence.libelle),
                      backgroundColor: IndigoOrChart.orConteneur,
                      labelStyle: const TextStyle(
                        color: IndigoOrChart.onOrConteneur,
                      ),
                      side: BorderSide.none,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _prix(BuildContext context, ServicesPrestatairesEtat etat) {
    final theme = Theme.of(context);
    final vide = etat.fourchettePrix == null;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          etat.libelleFourchette,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: vide
                ? theme.colorScheme.onSurfaceVariant
                : IndigoOrChart.orTexte,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  void _ouvrirSuite(BuildContext context, bool besoin) {
    if (besoin) {
      montrerLienGestion(
        context,
        gestion: 'Devis et contrats',
        message:
            'Le besoin confirmé et ce prestataire partent vers le formulaire de devis.',
      );
      return;
    }
    montrerLienGestion(
      context,
      gestion: 'Marketplace',
      message:
          'Ce bouton renvoie à l\'accueil Marketplace pour décrire le besoin.',
    );
  }
}
