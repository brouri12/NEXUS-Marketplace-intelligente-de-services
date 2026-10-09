import 'package:flutter/material.dart';

import 'package:flutter_android_app/core/gestion_module.dart';
import 'package:flutter_android_app/gestions/logistique/back/logistique_api.dart';
import 'package:flutter_android_app/gestions/logistique/front/logistique_page.dart';

const _back = LogistiqueApi();

/// Gestion de la logistique & du suivi en temps réel.
final logistiqueModule = GestionModule(
  id: 'logistique',
  title: LogistiquePage.title,
  icon: Icons.local_shipping_outlined,
  responsibilities: LogistiquePage.responsibilities,
  front: (context) => const LogistiquePage(back: _back),
  back: _back,
);
