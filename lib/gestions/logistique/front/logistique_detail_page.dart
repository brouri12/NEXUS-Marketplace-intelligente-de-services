import 'package:flutter/material.dart';

import 'package:flutter_android_app/core/theme/indigo_or_chart.dart';
import 'package:flutter_android_app/core/ui/nexus_ui.dart';
import 'package:flutter_android_app/gestions/communication_reclamation/front/messages_page.dart';
import 'package:flutter_android_app/gestions/devis_contrats/devis_contrats_module.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_presentation.dart';
import 'package:flutter_android_app/gestions/logistique/back/logistique_store.dart';
import 'package:flutter_android_app/gestions/logistique/back/trajet.dart';
import 'package:flutter_android_app/gestions/logistique/front/logistique_form_page.dart';
import 'package:flutter_android_app/gestions/logistique/front/logistique_page.dart';

/// Suivi d'un trajet : itinéraire, arrivée estimée, retards et actions.
class LogistiqueDetailPage extends StatelessWidget {
  /// Affiche le trajet [trajetId].
  const LogistiqueDetailPage({super.key, required this.store, required this.trajetId});

  /// Trajets du compte ouvert.
  final LogistiqueStore store;

  /// Identifiant du trajet.
  final String trajetId;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final trajet = store.find(trajetId);
        if (trajet == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Suivi')),
            body: const Center(child: Text('Ce trajet n\'est pas accessible.')),
          );
        }
        final contrat = devisContratsStore.findContrat(trajet.contratId);
        final conducteur = store.providerView && trajet.prestataireId == store.session?.id;
        final (action, icone) = switch (trajet.status) {
          TrajetStatus.enAttente when conducteur => ('Démarrer le trajet', Icons.play_arrow),
          TrajetStatus.enCours || TrajetStatus.enRetard when conducteur => (
            'Je suis arrivé',
            Icons.flag,
          ),
          _ => (null, null),
        };
        return Scaffold(
          appBar: AppBar(title: Text('Suivi ${trajet.numero}')),
          bottomNavigationBar: action == null
              ? null
              : BarreAction(
                  label: action,
                  icone: icone,
                  onPressed: () => _dire(
                    context,
                    trajet.status == TrajetStatus.enAttente
                        ? store.demarrer(trajet.id)
                        : store.terminer(trajet.id),
                  ),
                ),
          body: ListView(
            children: [
              _Carte(trajet: trajet),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                                'Retard de ${trajet.retardMinutes} min : ${trajet.note}. '
                                'L\'arrivée estimée est recalculée.',
                                style: const TextStyle(
                                  color: IndigoOrChart.onErreurConteneur,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                                Text(
                                  trajet.status == TrajetStatus.termine
                                      ? 'Arrivée'
                                      : 'Arrivée estimée',
                                  style: const TextStyle(
                                    color: IndigoOrChart.onPrimaireConteneur,
                                  ),
                                ),
                                Text(
                                  formatHeure(trajet.arriveeReelle ?? trajet.eta),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: IndigoOrChart.primaire,
                                  ),
                                ),
                                Text(
                                  '${formatKm(trajet.distanceKm)} · '
                                  '${dureeEstimeeMinutes(trajet.distanceKm)} min d\'itinéraire',
                                  style: const TextStyle(color: IndigoOrChart.onPrimaireConteneur),
                                ),
                              ],
                            ),
                            const Icon(Icons.psychology, size: 40, color: IndigoOrChart.primaire),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    InfoLigne('Statut', labelTrajetStatus(trajet.status)),
                    InfoLigne('Prestataire', store.nomDe(trajet.prestataireId)),
                    InfoLigne('Client', store.nomDe(trajet.clientId)),
                    InfoLigne('Contrat', contrat?.numero ?? trajet.contratId),
                    InfoLigne('Service', contrat?.service ?? ''),
                    InfoLigne(
                      'Départ prévu',
                      '${formatDate(trajet.departPrevu)} ${formatHeure(trajet.departPrevu)}',
                    ),
                    if (trajet.departReel != null)
                      InfoLigne('Parti à', formatHeure(trajet.departReel!)),
                    if (trajet.note.isNotEmpty && trajet.status != TrajetStatus.enRetard)
                      InfoLigne('Remarque', trajet.note),
                    const SizedBox(height: 16),
                    if (conducteur) ..._actionsConducteur(context, trajet),
                    if (!store.adminView)
                      OutlinedButton.icon(
                        onPressed: () => ouvrirDiscussion(context, 'c:${trajet.contratId}'),
                        icon: const Icon(Icons.forum_outlined),
                        label: Text(conducteur ? 'Prévenir le client' : 'Contacter le prestataire'),
                      ),
                    if (store.adminView ||
                        (conducteur && trajet.status == TrajetStatus.enAttente)) ...[
                      const SizedBox(height: 8),
                      TextButton.icon(
                        style: TextButton.styleFrom(foregroundColor: IndigoOrChart.erreur),
                        onPressed: () => _supprimer(context, trajet),
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Supprimer le trajet'),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _actionsConducteur(BuildContext context, Trajet trajet) {
    return [
      if (trajet.status == TrajetStatus.enAttente) ...[
        OutlinedButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => LogistiqueFormPage(store: store, trajet: trajet),
              ),
            );
          },
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Modifier le trajet'),
        ),
        const SizedBox(height: 8),
      ],
      if (trajet.status == TrajetStatus.enCours || trajet.status == TrajetStatus.enRetard) ...[
        OutlinedButton.icon(
          onPressed: () => _retard(context, trajet),
          icon: const Icon(Icons.warning_amber_rounded),
          label: const Text('Signaler un retard'),
        ),
        const SizedBox(height: 8),
      ],
    ];
  }

  Future<void> _retard(BuildContext context, Trajet trajet) async {
    final minutes = TextEditingController(text: '15');
    final motif = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => NexusDialog(
        titre: 'Signaler un retard',
        icone: Icons.warning_amber_rounded,
        message: 'L\'arrivée estimée recule du temps indiqué.',
        confirmer: 'Signaler',
        danger: true,
        onConfirmer: () => Navigator.of(context).pop(true),
        contenu: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: minutes,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Retard (minutes)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: motif,
              decoration: const InputDecoration(labelText: 'Motif'),
            ),
          ],
        ),
      ),
    );
    final valeurs = (minutes.text, motif.text);
    minutes.dispose();
    motif.dispose();
    if (ok != true || !context.mounted) return;
    _dire(context, store.signalerRetard(trajet.id, valeurs.$1, valeurs.$2));
  }

  Future<void> _supprimer(BuildContext context, Trajet trajet) async {
    final navigator = Navigator.of(context);
    final ok = await confirmerNexus(
      context,
      titre: 'Supprimer ${trajet.numero} ?',
      message: 'Le trajet disparaît du suivi. Le contrat, lui, reste.',
      confirmer: 'Supprimer',
      icone: Icons.delete_outline,
      danger: true,
    );
    if (!ok || !context.mounted) return;
    final erreur = store.supprimer(trajet.id);
    if (erreur != null) {
      _dire(context, erreur);
      return;
    }
    navigator.pop();
  }

  void _dire(BuildContext context, String? erreur) {
    if (erreur == null) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erreur)));
  }
}

class _Carte extends StatelessWidget {
  const _Carte({required this.trajet});

  final Trajet trajet;

  @override
  Widget build(BuildContext context) {
    final progression = switch (trajet.status) {
      TrajetStatus.enAttente => 0.0,
      TrajetStatus.termine => 1.0,
      _ => _avancement(trajet),
    };
    return Container(
      height: 220,
      color: IndigoOrChart.secondaireConteneur,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Expanded(
            child: CustomPaint(
              painter: _Itineraire(
                progression: progression,
                couleur: couleurTrajet(trajet.status),
              ),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: IndigoOrChart.secondaire, size: 18),
              const SizedBox(width: 4),
              Expanded(child: Text(trajet.pointDepart, overflow: TextOverflow.ellipsis)),
              const Icon(Icons.flag_outlined, color: IndigoOrChart.or, size: 18),
              const SizedBox(width: 4),
              Flexible(child: Text(trajet.destination, overflow: TextOverflow.ellipsis)),
            ],
          ),
        ],
      ),
    );
  }

  double _avancement(Trajet trajet) {
    final depart = trajet.departReel ?? trajet.departPrevu;
    final total = trajet.eta.difference(depart).inSeconds;
    if (total <= 0) return 0.9;
    final ecoule = DateTime.now().difference(depart).inSeconds;
    return (ecoule / total).clamp(0.05, 0.95);
  }
}

class _Itineraire extends CustomPainter {
  _Itineraire({required this.progression, required this.couleur});

  final double progression;
  final Color couleur;

  @override
  void paint(Canvas canvas, Size size) {
    final chemin = Path()
      ..moveTo(12, size.height * 0.75)
      ..cubicTo(
        size.width * 0.35,
        size.height * 0.05,
        size.width * 0.6,
        size.height * 1.0,
        size.width - 12,
        size.height * 0.25,
      );
    canvas.drawPath(
      chemin,
      Paint()
        ..color = IndigoOrChart.contour
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );
    final mesure = chemin.computeMetrics().first;
    final parcouru = mesure.extractPath(0, mesure.length * progression);
    canvas.drawPath(
      parcouru,
      Paint()
        ..color = couleur
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );
    final position = mesure.getTangentForOffset(mesure.length * progression)?.position;
    canvas.drawCircle(Offset(12, size.height * 0.75), 8, Paint()..color = IndigoOrChart.secondaire);
    canvas.drawCircle(
      Offset(size.width - 12, size.height * 0.25),
      8,
      Paint()..color = IndigoOrChart.or,
    );
    if (position != null) {
      canvas.drawCircle(position, 11, Paint()..color = IndigoOrChart.surfaceHaute);
      canvas.drawCircle(position, 7, Paint()..color = couleur);
    }
  }

  @override
  bool shouldRepaint(_Itineraire oldDelegate) {
    return oldDelegate.progression != progression || oldDelegate.couleur != couleur;
  }
}
