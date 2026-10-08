import 'package:flutter_android_app/gestions/services_prestataires/back/offered_service.dart';

/// Contrat back des services, compétences, tarifs et disponibilités.
class ServicesPrestatairesApi {
  /// Crée le point d'entrée back du catalogue.
  const ServicesPrestatairesApi();

  /// Services qu'un client peut consulter.
  List<OfferedService> get available => OfferedService.catalog;
}
