import 'package:flutter/material.dart';

import 'package:flutter_android_app/gestions/services_prestataires/front/composants.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/etat.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/modele.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/texte.dart';

/// Compétences, une liste par service.
class CompetencesPage extends StatelessWidget {
  /// Affiche les services de [etat].
  const CompetencesPage({super.key, required this.etat});

  /// Mémoire d'écran.
  final ServicesPrestatairesEtat etat;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: etat,
      builder: (context, _) {
        final services = etat.servicesConnecte.where((service) => service.approuve);
        return Scaffold(
          appBar: AppBar(title: const Text('Compétences')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              const Legende(
                'Chaque service a ses compétences. Marketplace les compare au besoin extrait.',
              ),
              const SizedBox(height: 16),
              for (final service in services) _carte(context, service),
            ],
          ),
        );
      },
    );
  }

  Widget _carte(BuildContext context, OffreService service) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(service.nom, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Legende(service.resumeCompetences),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => CompetencesServicePage(
                        etat: etat,
                        serviceId: service.id,
                      ),
                    ),
                  );
                },
                child: const Text('Modifier'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pastilles d'un seul service.
class CompetencesServicePage extends StatefulWidget {
  /// Édite les compétences du service [serviceId].
  const CompetencesServicePage({
    super.key,
    required this.etat,
    required this.serviceId,
  });

  /// Mémoire d'écran.
  final ServicesPrestatairesEtat etat;

  /// Offre dont on choisit les pastilles.
  final String serviceId;

  @override
  State<CompetencesServicePage> createState() => _CompetencesServicePageState();
}

class _CompetencesServicePageState extends State<CompetencesServicePage> {
  final _champ = TextEditingController();
  String? _erreur;

  @override
  void dispose() {
    _champ.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final etat = widget.etat;

    return ListenableBuilder(
      listenable: etat,
      builder: (context, _) {
        final service = etat.services.firstWhere(
          (offre) => offre.id == widget.serviceId,
        );
        final enAttente = etat.competencesEnAttenteDe(widget.serviceId);
        return Scaffold(
          appBar: AppBar(title: Text(service.nom)),
          body: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              const Legende(
                'Marketplace compare ces pastilles au besoin extrait.',
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final libelle in competencesDuSecteur(service.secteur))
                    PastilleChoix(
                      libelle: libelle,
                      choisie: etat.competenceConnueChoisie(
                        widget.serviceId,
                        libelle,
                      ),
                      onChoisir: (choisie) {
                        etat.basculerCompetenceConnue(
                          widget.serviceId,
                          libelle,
                          choisie,
                        );
                      },
                    ),
                ],
              ),
              const SizedBox(height: 24),
              const TitreSection('Autre compétence'),
              const SizedBox(height: 8),
              const Legende('Elle sera validée par l\'admin plus tard.'),
              const SizedBox(height: 12),
              TextField(
                key: const Key('champ-competence'),
                controller: _champ,
                textCapitalization: TextCapitalization.sentences,
                maxLength: 40,
                decoration: decorationChamp(context, label: 'Compétence')
                    .copyWith(errorText: _erreur),
                onChanged: (_) {
                  if (_erreur != null) {
                    setState(() => _erreur = null);
                  }
                },
                onSubmitted: (_) => _ajouter(),
              ),
              const SizedBox(height: 12),
              BoutonLarge(
                key: const Key('ajouter-competence'),
                libelle: 'Ajouter',
                onPressed: _ajouter,
              ),
              if (enAttente.isNotEmpty) ...[
                const SizedBox(height: 24),
                for (final competence in enAttente) _attente(competence),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _attente(CompetenceChoisie competence) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(competence.libelle),
        subtitle: const Padding(
          padding: EdgeInsets.only(top: 6),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Pastille.attente(),
          ),
        ),
        trailing: IconButton(
          tooltip: 'Retirer',
          onPressed: () => widget.etat.retirerCompetence(
            widget.serviceId,
            competence.libelle,
          ),
          icon: const Icon(Icons.close),
        ),
      ),
    );
  }

  void _ajouter() {
    final texte = _champ.text.trim();
    if (texte.isEmpty) {
      setState(() => _erreur = 'Indiquez la compétence.');
      return;
    }
    final resultat = widget.etat.ajouterCompetenceLibre(widget.serviceId, texte);
    if (resultat == AjoutCompetence.doublon) {
      setState(() => _erreur = 'Cette compétence est déjà présente.');
      return;
    }
    _champ.clear();
    setState(() => _erreur = null);
  }
}
