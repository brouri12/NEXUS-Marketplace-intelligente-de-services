import 'package:flutter/material.dart';

import 'package:flutter_android_app/gestions/devis_contrats/back/devis_contrats_store.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/accueil_page.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/contrats_prestataire_page.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/creer_devis_page.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/demandes_page.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/detail_contrat_admin_page.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/detail_contrat_client_page.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/detail_contrat_prestataire_page.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/detail_devis_admin_page.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/detail_devis_client_page.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/detail_devis_prestataire_page.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/gestion_contrats_page.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/gestion_devis_page.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/mes_contrats_client_page.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/mes_devis_client_page.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/mes_devis_prestataire_page.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/modification_client_page.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/proposer_modification_page.dart';

/// Noms des écrans de la gestion devis et contrats.
abstract final class DevisContratsRoutes {
  /// Entrée selon le rôle ouvert.
  static const accueil = '/';

  /// Demandes reçues par le prestataire.
  static const demandes = '/demandes';

  /// Création d'un devis. L'argument est l'identifiant de la demande.
  static const creer = '/demandes/devis';

  /// Devis du prestataire.
  static const devisPrestataire = '/prestataire/devis';

  /// Détail d'un devis prestataire. L'argument est l'identifiant.
  static const detailDevisPrestataire = '/prestataire/devis/detail';

  /// Contrats du prestataire.
  static const contratsPrestataire = '/prestataire/contrats';

  /// Détail d'un contrat prestataire. L'argument est l'identifiant.
  static const detailContratPrestataire = '/prestataire/contrats/detail';

  /// Proposition de modification. L'argument est l'identifiant du contrat.
  static const proposer = '/prestataire/contrats/modification';

  /// Devis du client.
  static const devisClient = '/client/devis';

  /// Détail d'un devis client. L'argument est l'identifiant.
  static const detailDevisClient = '/client/devis/detail';

  /// Contrats du client.
  static const contratsClient = '/client/contrats';

  /// Détail d'un contrat client. L'argument est l'identifiant.
  static const detailContratClient = '/client/contrats/detail';

  /// Proposition reçue. L'argument est l'identifiant du contrat.
  static const modificationClient = '/client/contrats/modification';

  /// Tous les devis, pour l'admin.
  static const devisAdmin = '/admin/devis';

  /// Détail admin d'un devis. L'argument est l'identifiant.
  static const detailDevisAdmin = '/admin/devis/detail';

  /// Tous les contrats, pour l'admin.
  static const contratsAdmin = '/admin/contrats';

  /// Détail admin d'un contrat. L'argument est l'identifiant.
  static const detailContratAdmin = '/admin/contrats/detail';

  /// Construit la page demandée par [settings].
  static Route<void> generate(RouteSettings settings, DevisContratsStore store) {
    final page = switch (settings.name) {
      demandes => const DemandesPage(),
      creer => CreerDevisPage(demandeId: settings.arguments! as String),
      devisPrestataire => const MesDevisPrestatairePage(),
      detailDevisPrestataire => DetailDevisPrestatairePage(
        devisId: settings.arguments! as String,
      ),
      contratsPrestataire => const ContratsPrestatairePage(),
      detailContratPrestataire => DetailContratPrestatairePage(
        contratId: settings.arguments! as String,
      ),
      proposer => ProposerModificationPage(contratId: settings.arguments! as String),
      devisClient => const MesDevisClientPage(),
      detailDevisClient => DetailDevisClientPage(devisId: settings.arguments! as String),
      contratsClient => const MesContratsClientPage(),
      detailContratClient => DetailContratClientPage(
        contratId: settings.arguments! as String,
      ),
      modificationClient => ModificationClientPage(
        contratId: settings.arguments! as String,
      ),
      devisAdmin => const GestionDevisPage(),
      detailDevisAdmin => DetailDevisAdminPage(devisId: settings.arguments! as String),
      contratsAdmin => const GestionContratsPage(),
      detailContratAdmin => DetailContratAdminPage(
        contratId: settings.arguments! as String,
      ),
      _ => const AccueilPage(),
    };
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (context) => DevisStoreScope(store: store, child: page),
    );
  }
}

/// Ouvre [route] au-dessus de l'écran actuel.
void openDevisPage(BuildContext context, String route, {Object? arguments}) {
  Navigator.of(context).pushNamed(route, arguments: arguments);
}

/// Rend [DevisContratsStore] disponible aux écrans poussés par le navigateur.
class DevisStoreScope extends InheritedWidget {
  /// Publie [store] pour [child].
  const DevisStoreScope({super.key, required this.store, required super.child});

  /// Back des devis, contrats et modifications.
  final DevisContratsStore store;

  /// Store au-dessus de [context].
  static DevisContratsStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<DevisStoreScope>();
    assert(scope != null, 'DevisStoreScope est absent au-dessus de cet écran.');
    return scope!.store;
  }

  @override
  bool updateShouldNotify(DevisStoreScope oldWidget) => store != oldWidget.store;
}
