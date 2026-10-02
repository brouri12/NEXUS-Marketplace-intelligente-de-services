import 'package:flutter/material.dart';

import 'package:flutter_android_app/core/gestion_module.dart';
import 'package:flutter_android_app/gestions/services_prestataires/back/services_prestataires_api.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/services_prestataires_page.dart';

const _back = ServicesPrestatairesApi();

/// Gestion des services, compétences, tarifs et disponibilités.
final servicesPrestatairesModule = GestionModule(
  id: 'services_prestataires',
  title: ServicesPrestatairesPage.title,
  icon: Icons.handyman_outlined,
  responsibilities: ServicesPrestatairesPage.responsibilities,
  front: (context) => const ServicesPrestatairesPage(back: _back),
  back: _back,
);
