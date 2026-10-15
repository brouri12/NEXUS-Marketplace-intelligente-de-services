import 'package:flutter/material.dart';

import 'package:flutter_android_app/core/gestion_module.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/etat.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/services_prestataires_page.dart';

/// Back partagé des offres, compétences, tarifs et créneaux.
final servicesEtat = ServicesPrestatairesEtat();

/// Gestion des services, compétences, tarifs et disponibilités.
final servicesPrestatairesModule = GestionModule(
  id: 'services_prestataires',
  title: ServicesPrestatairesPage.title,
  icon: Icons.handyman_outlined,
  responsibilities: ServicesPrestatairesPage.responsibilities,
  front: (context) => ServicesPrestatairesPage(etat: servicesEtat),
  back: servicesEtat,
);
