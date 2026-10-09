import 'package:flutter_android_app/core/gestion_module.dart';
import 'package:flutter_android_app/gestions/communication_reclamation/communication_reclamation_module.dart';
import 'package:flutter_android_app/gestions/devis_contrats/devis_contrats_module.dart';
import 'package:flutter_android_app/gestions/marketplace/marketplace_module.dart';
import 'package:flutter_android_app/gestions/services_prestataires/services_prestataires_module.dart';
import 'package:flutter_android_app/gestions/utilisateurs/utilisateurs_module.dart';
import 'package:flutter_android_app/gestions/logistique/logistique_module.dart';

/// Les cinq gestions de NEXUS, dans l'ordre du produit.
final List<GestionModule> gestions = [
  utilisateursModule,
  servicesPrestatairesModule,
  marketplaceModule,
  devisContratsModule,
  communicationReclamationModule,
  logistiqueModule,
];
