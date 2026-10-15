import 'package:flutter/material.dart';

import 'package:flutter_android_app/core/gestion_module.dart';
import 'package:flutter_android_app/gestions/logistique/back/logistique_store.dart';
import 'package:flutter_android_app/gestions/logistique/front/logistique_page.dart';

/// Back partagé des trajets.
final logistiqueStore = LogistiqueStore();

/// Gestion de la logistique et du suivi des trajets.
final logistiqueModule = GestionModule(
  id: 'logistique',
  title: LogistiquePage.title,
  icon: Icons.local_shipping_outlined,
  responsibilities: LogistiquePage.responsibilities,
  front: (context) => LogistiquePage(store: logistiqueStore),
  back: logistiqueStore,
);
