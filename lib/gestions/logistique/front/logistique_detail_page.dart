import 'package:flutter/material.dart';
import 'package:flutter_android_app/core/theme/indigo_or_chart.dart';
import '../domain/trajet.dart';

class LogistiqueDetailPage extends StatelessWidget {
  final Trajet trajet;

  const LogistiqueDetailPage({super.key, required this.trajet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Suivi ${trajet.id}'),
      ),
      body: Column(
        children: [
          // Section 1 : Carte Interactive (Utilisation de Expanded pour Layout flexible)
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              color: IndigoOrChart.secondaireConteneur,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.map_outlined, size: 100, color: IndigoOrChart.secondaire),
                  Positioned(
                    bottom: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: IndigoOrChart.primaire,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Carte GPS Interactive (En attente API Google Maps)',
                        style: TextStyle(color: IndigoOrChart.onPrimaire),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Section 2 : Informations et IA
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: IndigoOrChart.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Alerte conditionnelle (Retard/Déviation)
                  if (trajet.status == TrajetStatus.enRetard)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: IndigoOrChart.erreurConteneur,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: IndigoOrChart.erreur),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: IndigoOrChart.erreur),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Alerte : Déviation détectée. Nouveau calcul de l\'itinéraire en cours.',
                              style: TextStyle(color: IndigoOrChart.onErreurConteneur, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                  // Mise en valeur du modèle prédictif ETA
                  Card(
                    color: IndigoOrChart.primaireConteneur,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Arrivée estimée (IA)', style: TextStyle(color: IndigoOrChart.onPrimaireConteneur)),
                              Text(
                                trajet.eta,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: IndigoOrChart.primaire,
                                ),
                              ),
                            ],
                          ),
                          const Icon(Icons.psychology, size: 40, color: IndigoOrChart.primaire),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
