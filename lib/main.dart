import 'package:flutter/material.dart';

import 'package:flutter_android_app/app/nexus_app.dart';
import 'package:flutter_android_app/core/db/nexus_database.dart';
import 'package:flutter_android_app/gestions/communication_reclamation/back/communication_store.dart';
import 'package:flutter_android_app/gestions/communication_reclamation/back/communication_table.dart';
import 'package:flutter_android_app/gestions/devis_contrats/back/devis_contrats_table.dart';
import 'package:flutter_android_app/gestions/devis_contrats/devis_contrats_module.dart';
import 'package:flutter_android_app/gestions/logistique/back/logistique_table.dart';
import 'package:flutter_android_app/gestions/logistique/logistique_module.dart';
import 'package:flutter_android_app/gestions/marketplace/back/marketplace_table.dart';
import 'package:flutter_android_app/gestions/marketplace/marketplace_module.dart';
import 'package:flutter_android_app/gestions/services_prestataires/back/services_table.dart';
import 'package:flutter_android_app/gestions/services_prestataires/services_prestataires_module.dart';
import 'package:flutter_android_app/gestions/utilisateurs/back/utilisateurs_table.dart';
import 'package:flutter_android_app/gestions/utilisateurs/utilisateurs_module.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await nexusDb.ouvrir([
      ...schemaUtilisateurs,
      ...schemaDevisContrats,
      ...schemaCommunication,
      ...schemaServices,
      ...schemaLogistique,
      ...schemaMarketplace,
    ]);
    await utilisateursStore.charger();
    await devisContratsStore.charger();
    await communicationStore.charger();
    await servicesEtat.charger();
    await logistiqueStore.charger();
    await marketplaceStore.charger();
  } catch (error, stack) {
    debugPrint('SQLite indisponible, données en mémoire : $error\n$stack');
  }
  runApp(const NexusApp());
}
