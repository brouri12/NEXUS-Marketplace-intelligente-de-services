import 'package:flutter/material.dart';

import 'package:flutter_android_app/core/gestion_module.dart';
import 'package:flutter_android_app/gestions/devis_contrats/back/devis_contrats_store.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_contrats_page.dart';

/// Back partagé des devis et des contrats.
final devisContratsStore = DevisContratsStore();

/// Gestion des devis, des contrats et de leurs modifications.
final devisContratsModule = GestionModule(
  id: 'devis_contrats',
  title: DevisContratsPage.title,
  icon: Icons.request_quote_outlined,
  responsibilities: DevisContratsPage.responsibilities,
  front: (context) => DevisContratsPage(store: devisContratsStore),
  back: devisContratsStore,
);
