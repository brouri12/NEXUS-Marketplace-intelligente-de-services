import 'package:flutter/material.dart';

import 'package:flutter_android_app/core/gestion_module.dart';
import 'package:flutter_android_app/gestions/communication_reclamation/back/communication_store.dart';
import 'package:flutter_android_app/gestions/communication_reclamation/front/communication_reclamation_page.dart';

/// Gestion du chat, des avis, des réclamations et des notifications.
final communicationReclamationModule = GestionModule(
  id: 'communication_reclamation',
  title: CommunicationReclamationPage.title,
  icon: Icons.forum_outlined,
  responsibilities: CommunicationReclamationPage.responsibilities,
  front: (context) => const CommunicationReclamationPage(),
  back: communicationStore,
);
