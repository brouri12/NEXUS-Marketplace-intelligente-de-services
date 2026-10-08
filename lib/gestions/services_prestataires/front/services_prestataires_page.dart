import 'package:flutter/material.dart';

import 'package:flutter_android_app/core/gestion_front_page.dart';
import 'package:flutter_android_app/gestions/services_prestataires/back/offered_service.dart';
import 'package:flutter_android_app/gestions/services_prestataires/back/services_prestataires_api.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/available_services_page.dart';
import 'package:flutter_android_app/gestions/utilisateurs/back/user_account.dart';
import 'package:flutter_android_app/gestions/utilisateurs/utilisateurs_module.dart';

/// Écran réservé de la gestion services et prestataires.
class ServicesPrestatairesPage extends StatelessWidget {
  /// Relie cet écran à [back].
  const ServicesPrestatairesPage({super.key, required this.back});

  /// Contrat back des services, compétences, tarifs et disponibilités.
  final ServicesPrestatairesApi back;

  /// Nom affiché dans le menu.
  static const title = 'Services & prestataires';

  /// Responsabilités réservées à cette gestion.
  static const responsibilities = [
    'Services',
    'Compétences',
    'Tarifs',
    'Disponibilités',
  ];

  @override
  Widget build(BuildContext context) {
    final user = utilisateursStore.current;
    final asClient = user != null &&
        (utilisateursStore.clientInterface ||
            (user.hasRole(UserRole.client) && !user.hasRole(UserRole.admin)));
    if (asClient) {
      return AvailableServicesPage(
        services: _visibleServices(back),
        ownOffer: user.providerProfile,
      );
    }

    return GestionFrontPage(
      title: title,
      responsibilities: responsibilities,
      back: back,
    );
  }
}

List<OfferedService> _visibleServices(ServicesPrestatairesApi back) {
  final fromAccounts = [
    for (final account in utilisateursStore.accounts)
      if (account.providerProfile != null && account.confirmed)
        OfferedService(
          id: 'account-${account.id}',
          title: account.providerProfile!.service,
          providerName: account.fullName,
          city: account.city,
          rate: account.providerProfile!.rateLabel,
          icon: OfferedService.iconFor(account.providerProfile!.service),
        ),
  ];
  final names = {for (final service in fromAccounts) service.providerName};
  return [
    ...fromAccounts,
    for (final service in back.available)
      if (!names.contains(service.providerName)) service,
  ];
}
