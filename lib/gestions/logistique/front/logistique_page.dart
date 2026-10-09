import 'package:flutter/material.dart';
import 'package:flutter_android_app/core/theme/indigo_or_chart.dart';
import 'package:flutter_android_app/core/gestion_front_page.dart';
import '../back/logistique_api.dart';
import '../domain/trajet.dart';
import 'logistique_create_page.dart';
import 'logistique_detail_page.dart';

class LogistiquePage extends StatelessWidget {
  const LogistiquePage({super.key, required this.back});

  final LogistiqueApi back;

  static const title = 'Logistique';
  static const responsibilities = [
    'Suivi en temps réel',
    'Calcul d\'itinéraire',
    'Alertes de retards',
  ];

  @override
  Widget build(BuildContext context) {
    final trajets = back.trajetsMock;

    return Scaffold(
      appBar: AppBar(
        title: const Text(title),
      ),
      backgroundColor: IndigoOrChart.fond,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: trajets.length,
        itemBuilder: (context, index) {
          final trajet = trajets[index];
          return _buildTrajetCard(context, trajet);
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: IndigoOrChart.or,
        foregroundColor: IndigoOrChart.onOr,
        onPressed: () {
          // Navigation vers le formulaire de création
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LogistiqueCreatePage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTrajetCard(BuildContext context, Trajet trajet) {
    Color statusColor;
    // Utilisation des couleurs sémantiques de la charte
    switch (trajet.status) {
      case TrajetStatus.enAttente:
        statusColor = IndigoOrChart.attente;
        break;
      case TrajetStatus.enCours:
        statusColor = IndigoOrChart.succes;
        break;
      case TrajetStatus.enRetard:
        statusColor = IndigoOrChart.erreur;
        break;
      case TrajetStatus.termine:
        statusColor = IndigoOrChart.secondaire;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Navigation vers l'écran de suivi détaillé
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LogistiqueDetailPage(trajet: trajet),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    trajet.id,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: IndigoOrChart.primaire,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      trajet.status.name.toUpperCase(),
                      style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: IndigoOrChart.secondaire, size: 20),
                  const SizedBox(width: 8),
                  Text(trajet.pointDepart, style: const TextStyle(color: IndigoOrChart.texte)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.arrow_forward, color: IndigoOrChart.contour, size: 16),
                  ),
                  const Icon(Icons.flag_outlined, color: IndigoOrChart.or, size: 20),
                  const SizedBox(width: 8),
                  Text(trajet.destination, style: const TextStyle(color: IndigoOrChart.texte)),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person_outline, color: IndigoOrChart.secondaire, size: 16),
                      const SizedBox(width: 4),
                      Text(trajet.livreurNom, style: const TextStyle(color: IndigoOrChart.texteMuted)),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: IndigoOrChart.primaire, size: 16),
                      const SizedBox(width: 4),
                      Text('ETA: ${trajet.eta}', style: const TextStyle(fontWeight: FontWeight.bold, color: IndigoOrChart.primaire)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
