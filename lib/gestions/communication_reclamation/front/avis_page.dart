import 'package:flutter/material.dart';

import 'package:flutter_android_app/core/theme/indigo_or_chart.dart';
import 'package:flutter_android_app/gestions/communication_reclamation/back/communication_store.dart';
import 'package:flutter_android_app/gestions/communication_reclamation/front/communication_widgets.dart';
import 'package:flutter_android_app/gestions/devis_contrats/back/contrat.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_presentation.dart';

/// Avis à rédiger, avis reçus et lecture admin.
class AvisPage extends StatelessWidget {
  /// Crée la liste selon le rôle.
  const AvisPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = communicationStore;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final aEvaluer = store.contratsAEvaluer();
        final publies = store.avisVisibles();
        final userId = store.session?.id;
        return ListView(
          padding: const EdgeInsets.only(bottom: 20),
          children: [
            IntroCommunication(
              store.adminView ? 'Avis publiés' : 'La confiance se partage',
              store.adminView
                  ? 'Lecture seule. Un avis n\'existe qu\'après une prestation terminée.'
                  : 'Un avis ne peut être publié qu’une fois la prestation terminée.',
            ),
            if (!store.adminView) ...[
              const SectionCommunication('À évaluer'),
              if (aEvaluer.isEmpty)
                const VideCommunication(
                  'Aucune prestation terminée en attente d\'avis.',
                )
              else
                for (final contrat in aEvaluer)
                  _ContratAvis(
                    contrat: contrat,
                    nom: store.nomDe(contrat.prestataireId),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => AvisFormPage(contratId: contrat.id),
                      ),
                    ),
                  ),
            ],
            const SectionCommunication('Avis publiés'),
            if (publies.isEmpty)
              const VideCommunication('Aucun avis publié.')
            else
              for (final avis in publies)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: IndigoOrChart.orConteneur,
                        child: Icon(Icons.star, color: IndigoOrChart.orTexte),
                      ),
                      title: Text(
                        store.providerView && avis.prestataireId == userId
                            ? store.nomDe(avis.clientId)
                            : store.nomDe(avis.prestataireId),
                      ),
                      subtitle: Text('${'★' * avis.note} · ${avis.texte}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => AvisDetailPage(avisId: avis.id),
                        ),
                      ),
                    ),
                  ),
                ),
          ],
        );
      },
    );
  }
}

class _ContratAvis extends StatelessWidget {
  const _ContratAvis({required this.contrat, required this.nom, required this.onTap});

  final Contrat contrat;
  final String nom;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Card(
        child: ListTile(
          leading: const CircleAvatar(child: Icon(Icons.local_shipping_outlined)),
          title: Text('${contrat.service} · $nom'),
          subtitle: Text('Terminé · ${contrat.numero} · ${formatDate(contrat.date)}'),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      ),
    );
  }
}

/// Formulaire d'avis lié à un contrat terminé.
class AvisFormPage extends StatefulWidget {
  /// Note le contrat [contratId].
  const AvisFormPage({super.key, required this.contratId});

  /// Contrat terminé.
  final String contratId;

  @override
  State<AvisFormPage> createState() => _AvisFormPageState();
}

class _AvisFormPageState extends State<AvisFormPage> {
  final _texte = TextEditingController();
  var _note = 0;

  @override
  void dispose() {
    _texte.dispose();
    super.dispose();
  }

  void _publier() {
    final id = communicationStore.publierAvis(
      contratId: widget.contratId,
      note: _note,
      texte: _texte.text,
    );
    if (id == null) return;
    if (id.startsWith('av-')) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => AvisDetailPage(avisId: id)),
      );
      return;
    }
    dire(context, id);
  }

  @override
  Widget build(BuildContext context) {
    final store = communicationStore;
    final contrat = store.contratsAEvaluer().where((item) => item.id == widget.contratId);
    final cible = contrat.isEmpty ? null : contrat.first;
    return Scaffold(
      appBar: AppBar(title: const Text('Rédiger un avis')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          IntroCommunication(
            cible == null
                ? 'Avis'
                : '${cible.service} avec ${store.nomDe(cible.prestataireId)}',
            cible == null
                ? 'Ce contrat ne peut plus être noté.'
                : '${cible.numero} · ${formatDate(cible.date)}',
          ),
          const Text('Votre note', style: TextStyle(fontWeight: FontWeight.w700)),
          Row(
            children: [
              for (var i = 1; i <= 5; i++)
                IconButton(
                  tooltip: '$i étoiles',
                  onPressed: () => setState(() => _note = i),
                  icon: Icon(
                    i <= _note ? Icons.star : Icons.star_outline,
                    color: IndigoOrChart.orTexte,
                    size: 34,
                  ),
                ),
            ],
          ),
          TextField(
            controller: _texte,
            maxLength: 280,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Votre expérience',
              hintText: 'Ponctualité, soin, communication…',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: cible == null ? null : _publier,
            icon: const Icon(Icons.publish_outlined),
            label: const Text('Publier l’avis'),
          ),
        ],
      ),
    );
  }
}

/// Détail d'un avis. Le prestataire peut répondre une fois.
class AvisDetailPage extends StatefulWidget {
  /// Affiche l'avis [avisId].
  const AvisDetailPage({super.key, required this.avisId});

  /// Identifiant.
  final String avisId;

  @override
  State<AvisDetailPage> createState() => _AvisDetailPageState();
}

class _AvisDetailPageState extends State<AvisDetailPage> {
  final _reponse = TextEditingController();

  @override
  void dispose() {
    _reponse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = communicationStore;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final avis = store.findAvis(widget.avisId);
        if (avis == null) {
          return const Scaffold(body: Center(child: Text('Avis inaccessible.')));
        }
        final peutRepondre = store.providerView &&
            avis.prestataireId == store.session?.id &&
            avis.reponse == null;
        return Scaffold(
          appBar: AppBar(title: const Text('Détail de l’avis')),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              IntroCommunication(
                'Avis sur ${store.nomDe(avis.prestataireId)}',
                'Publié le ${formatDate(avis.publieLe)} · par ${store.nomDe(avis.clientId)}',
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '★' * avis.note,
                        style: const TextStyle(color: IndigoOrChart.orTexte, fontSize: 22),
                      ),
                      const SizedBox(height: 10),
                      Text(avis.texte),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              if (avis.reponse != null)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.reply),
                    title: const Text('Réponse du prestataire'),
                    subtitle: Text(avis.reponse!),
                  ),
                )
              else if (peutRepondre) ...[
                TextField(
                  controller: _reponse,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Votre réponse',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    final error = store.repondreAvis(avis.id, _reponse.text);
                    if (error != null) dire(context, error);
                  },
                  icon: const Icon(Icons.reply),
                  label: const Text('Répondre une fois'),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
