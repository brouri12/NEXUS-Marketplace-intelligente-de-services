import 'package:flutter/material.dart';

import 'package:flutter_android_app/core/gestion_module.dart';
import 'package:flutter_android_app/gestions/devis_contrats/back/devis_contrats_api.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_contrats_page.dart';

const _back = DevisContratsApi();

/// Gestion des devis, commandes, prestations et statuts.
final devisContratsModule = GestionModule(
  id: 'devis_contrats',
  title: DevisContratsPage.title,
  icon: Icons.request_quote_outlined,
  responsibilities: DevisContratsPage.responsibilities,
  front: (context) => const DevisContratsPage(back: _back),
  back: _back,
);
