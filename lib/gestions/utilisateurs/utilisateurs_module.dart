import 'package:flutter/material.dart';

import 'package:flutter_android_app/core/gestion_module.dart';
import 'package:flutter_android_app/gestions/utilisateurs/back/utilisateurs_store.dart';
import 'package:flutter_android_app/gestions/utilisateurs/front/utilisateurs_page.dart';

/// Back partagé des comptes, utilisé par la connexion et la barre latérale.
final utilisateursStore = UtilisateursStore();

/// Gestion des comptes, profils, rôles et de la sécurité.
final utilisateursModule = GestionModule(
  id: 'utilisateurs',
  title: UtilisateursPage.title,
  icon: Icons.person_outline,
  responsibilities: UtilisateursPage.responsibilities,
  front: (context) => UtilisateursPage(store: utilisateursStore),
  back: utilisateursStore,
);
