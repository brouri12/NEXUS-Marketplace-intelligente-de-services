import 'package:flutter/material.dart';

import 'package:flutter_android_app/core/gestion_module.dart';
import 'package:flutter_android_app/gestions/utilisateurs/back/utilisateurs_api.dart';
import 'package:flutter_android_app/gestions/utilisateurs/front/utilisateurs_page.dart';

const _back = UtilisateursApi();

/// Gestion des comptes, profils, rôles et de la sécurité.
final utilisateursModule = GestionModule(
  id: 'utilisateurs',
  title: UtilisateursPage.title,
  icon: Icons.person_outline,
  responsibilities: UtilisateursPage.responsibilities,
  front: (context) => const UtilisateursPage(back: _back),
  back: _back,
);
