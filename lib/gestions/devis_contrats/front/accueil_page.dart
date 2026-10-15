import 'package:flutter/material.dart';

import 'package:flutter_android_app/gestions/devis_contrats/front/devis_contrats_frame.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_contrats_routes.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_presentation.dart';
import 'package:flutter_android_app/gestions/utilisateurs/utilisateurs_module.dart';

/// Entrée de la gestion, selon le rôle déjà ouvert.
class AccueilPage extends StatelessWidget {
  /// Affiche les portes vers les listes du rôle.
  const AccueilPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = DevisStoreScope.of(context);

    return ListenableBuilder(
      listenable: Listenable.merge([store, utilisateursStore]),
      builder: (context, _) {
        final user = store.session;
        return DevisContratsFrame(
          title: 'Devis et contrats',
          child: ListView(
            children: [
              if (user == null)
                const Text('Connectez-vous pour voir vos devis et vos contrats.')
              else ...[
                Text(user.fullName, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                if (store.providerView) ...[
                  const SectionTitre('Prestataire'),
                  DevisLien(
                    icon: Icons.inbox_outlined,
                    title: 'Demandes de devis',
                    onTap: () => openDevisPage(context, DevisContratsRoutes.demandes),
                  ),
                  DevisLien(
                    icon: Icons.request_quote_outlined,
                    title: 'Mes devis',
                    onTap: () => openDevisPage(context, DevisContratsRoutes.devisPrestataire),
                  ),
                  DevisLien(
                    icon: Icons.description_outlined,
                    title: 'Mes contrats',
                    onTap: () =>
                        openDevisPage(context, DevisContratsRoutes.contratsPrestataire),
                  ),
                ],
                if (store.clientView) ...[
                  const SectionTitre('Client'),
                  DevisLien(
                    icon: Icons.request_quote_outlined,
                    title: 'Mes devis',
                    onTap: () => openDevisPage(context, DevisContratsRoutes.devisClient),
                  ),
                  DevisLien(
                    icon: Icons.description_outlined,
                    title: 'Mes contrats',
                    onTap: () => openDevisPage(context, DevisContratsRoutes.contratsClient),
                  ),
                ],
                if (store.adminView) ...[
                  const SectionTitre('Admin'),
                  DevisLien(
                    icon: Icons.fact_check_outlined,
                    title: 'Gestion des devis',
                    onTap: () => openDevisPage(context, DevisContratsRoutes.devisAdmin),
                  ),
                  DevisLien(
                    icon: Icons.folder_open_outlined,
                    title: 'Gestion des contrats',
                    onTap: () => openDevisPage(context, DevisContratsRoutes.contratsAdmin),
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }
}
