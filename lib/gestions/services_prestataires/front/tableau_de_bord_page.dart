import 'package:flutter/material.dart';

import 'package:flutter_android_app/core/theme/indigo_or_chart.dart';
import 'package:flutter_android_app/gestions/devis_contrats/devis_contrats_module.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_contrats_routes.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/competences_page.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/composants.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/disponibilites_page.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/etat.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/fiche_publique_page.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/formulaire_service_page.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/mes_services_page.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/tarifs_page.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/texte.dart';

/// Tableau de bord du prestataire.
class TableauDeBordPage extends StatelessWidget {
  /// Affiche le jour, ou le seul bouton d'ajout si rien n'est publié.
  const TableauDeBordPage({super.key, required this.etat, this.catalogue});

  /// Mémoire d'écran.
  final ServicesPrestatairesEtat etat;

  /// Catalogue client, ouvert quand le prestataire est aussi client.
  final Widget? catalogue;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: etat,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Tableau de bord'),
            actions: [
              if (catalogue != null)
                IconButton(
                  tooltip: 'Catalogue client',
                  onPressed: () => _ouvrir(context, catalogue!),
                  icon: const Icon(Icons.storefront_outlined),
                ),
            ],
          ),
          body: etat.aUnServicePublie ? _tableau(context) : _vide(context),
        );
      },
    );
  }

  Widget _vide(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: Icon(
                Icons.handyman_outlined,
                size: 48,
                color: IndigoOrChart.secondaire,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun service n\'est publié.',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Legende(
              'Profil du compte : ${libelleSecteur(etat.secteurConnecte)}. Le reste du tableau de bord s\'affiche après publication.',
              alignement: TextAlign.center,
            ),
            if (etat.demandesEnAttente.isNotEmpty) ...[
              const SizedBox(height: 12),
              Legende(
                'En attente d\'approbation : ${etat.demandesEnAttente.map((service) => service.nom).join(', ')}.',
                alignement: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            BoutonLarge(
              libelle: 'Ajouter un service',
              onPressed: () => _ouvrirFormulaire(context),
            ),
            if (etat.servicesConnecte.isNotEmpty) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => _ouvrir(context, MesServicesPage(etat: etat)),
                child: const Text('Voir mes services'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _tableau(BuildContext context) {
    final prochain = etat.prochainCreneau;
    final trous = etat.trous;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Legende('Profil du compte : ${libelleSecteur(etat.secteurConnecte)}.'),
        const SizedBox(height: 16),
        const TitreSection('Aujourd\'hui'),
        const SizedBox(height: 12),
        TuileResume(
          icone: Icons.receipt_long_outlined,
          valeur: '${etat.demandesDevisEnAttente} en attente',
          legende: 'Demandes de devis',
          onTap: () => Navigator.of(context).push(
            DevisContratsRoutes.generate(
              const RouteSettings(name: DevisContratsRoutes.demandes),
              devisContratsStore,
            ),
          ),
        ),
        TuileResume(
          icone: Icons.schedule,
          valeur: prochain == null
              ? 'Aucun créneau libre'
              : libelleCreneau(prochain),
          legende: 'Prochain créneau',
          onTap: () => _ouvrirDisponibilites(context),
        ),
        TuileResume(
          icone: Icons.event_busy_outlined,
          valeur: trous.isEmpty ? 'Aucun trou' : '${trous.length} trous',
          legende: 'Dans la semaine',
          detail: resumeTrous(trous),
          onTap: () => _ouvrirDisponibilites(context),
        ),
        const SizedBox(height: 8),
        const TitreSection('Raccourcis'),
        const SizedBox(height: 12),
        TuileRaccourci(
          icone: Icons.home_repair_service_outlined,
          titre: 'Mes services',
          detail: 'Publier ou masquer',
          onTap: () => _ouvrir(context, MesServicesPage(etat: etat)),
        ),
        TuileRaccourci(
          icone: Icons.sell_outlined,
          titre: 'Compétences',
          detail: 'Pastilles de chaque service',
          onTap: () => _ouvrir(context, CompetencesPage(etat: etat)),
        ),
        TuileRaccourci(
          icone: Icons.payments_outlined,
          titre: 'Tarifs',
          detail: 'Un tarif par service',
          onTap: () => _ouvrir(context, TarifsPage(etat: etat)),
        ),
        TuileRaccourci(
          icone: Icons.calendar_month_outlined,
          titre: 'Disponibilités',
          detail: 'Créneaux de la semaine',
          onTap: () => _ouvrirDisponibilites(context),
        ),
        TuileRaccourci(
          icone: Icons.badge_outlined,
          titre: 'Fiche publique',
          detail: 'Page lue par le client',
          onTap: () => _ouvrir(
            context,
            FichePubliquePage(etat: etat, permettreApercu: true),
          ),
        ),
      ],
    );
  }

  void _ouvrirFormulaire(BuildContext context) {
    _ouvrir(context, FormulaireServicePage(etat: etat));
  }

  void _ouvrirDisponibilites(BuildContext context) {
    _ouvrir(context, DisponibilitesPage(etat: etat));
  }

  void _ouvrir(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (context) => page),
    );
  }
}
