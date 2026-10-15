import 'package:flutter/material.dart';

import 'package:flutter_android_app/gestions/services_prestataires/front/approbation_services_page.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/available_services_page.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/composants.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/etat.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/tableau_de_bord_page.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/tous_les_services_page.dart';
import 'package:flutter_android_app/gestions/utilisateurs/back/user_account.dart';
import 'package:flutter_android_app/gestions/utilisateurs/utilisateurs_module.dart';

/// Entrée de la gestion services : catalogue, tableau de bord ou supervision.
class ServicesPrestatairesPage extends StatelessWidget {
  /// Relie cet écran à [etat].
  const ServicesPrestatairesPage({super.key, required this.etat});

  /// Offres, compétences, tarifs et disponibilités.
  final ServicesPrestatairesEtat etat;

  /// Nom affiché dans le menu.
  static const title = 'Services & prestataires';

  /// Responsabilités réservées à cette gestion.
  static const responsibilities = [
    'Services',
    'Compétences',
    'Tarifs',
    'Disponibilités',
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: utilisateursStore,
      builder: (context, _) {
        final user = utilisateursStore.current;
        if (user == null) return const SizedBox.shrink();
        if (etat.adminView) return _AdminServicesPage(etat: etat);
        final catalogue = AvailableServicesPage(etat: etat);
        if (!utilisateursStore.clientInterface && user.hasRole(UserRole.provider)) {
          return TableauDeBordPage(
            etat: etat,
            catalogue: user.hasRole(UserRole.client) ? catalogue : null,
          );
        }
        return catalogue;
      },
    );
  }
}

class _AdminServicesPage extends StatelessWidget {
  const _AdminServicesPage({required this.etat});

  final ServicesPrestatairesEtat etat;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: etat,
      builder: (context, _) {
        final enAttente = etat.demandesEnAttente.length + etat.competencesAValider.length;
        return Scaffold(
          appBar: AppBar(title: const Text('Services & prestataires')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              const Legende(
                'Approuvez les offres, validez les compétences libres et réaffectez un service.',
              ),
              const SizedBox(height: 16),
              TuileResume(
                icone: Icons.verified_outlined,
                valeur: '$enAttente à traiter',
                legende: 'Approbation',
                onTap: () => _ouvrir(context, ApprobationServicesPage(etat: etat)),
              ),
              TuileResume(
                icone: Icons.list_alt_outlined,
                valeur: '${etat.services.length} services',
                legende: '${etat.prestataires.length} prestataires actifs',
                onTap: () => _ouvrir(context, TousLesServicesPage(etat: etat)),
              ),
              TuileResume(
                icone: Icons.storefront_outlined,
                valeur: '${etat.offresVisibles.length} visibles',
                legende: 'Catalogue client',
                onTap: () => _ouvrir(context, AvailableServicesPage(etat: etat)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _ouvrir(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (context) => page));
  }
}
