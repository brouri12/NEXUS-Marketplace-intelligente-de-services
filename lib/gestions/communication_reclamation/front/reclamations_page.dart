import 'package:flutter/material.dart';

import 'package:flutter_android_app/core/theme/indigo_or_chart.dart';
import 'package:flutter_android_app/gestions/communication_reclamation/back/communication_models.dart';
import 'package:flutter_android_app/gestions/communication_reclamation/back/communication_store.dart';
import 'package:flutter_android_app/gestions/communication_reclamation/front/communication_widgets.dart';
import 'package:flutter_android_app/gestions/devis_contrats/devis_contrats_module.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_presentation.dart';

/// Réclamations du client, du prestataire ou file admin.
class ReclamationsPage extends StatelessWidget {
  /// Crée la liste selon le rôle.
  const ReclamationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = communicationStore;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        if (store.adminView) {
          final file = store.reclamationsAdmin();
          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              const IntroCommunication(
                'Dossiers à traiter',
                'Examinez les éléments et consignez une décision motivée. Le paiement n\'est pas modifié.',
              ),
              if (file.isEmpty)
                const VideCommunication('Aucune réclamation.')
              else
                for (final item in file) _TuileReclamation(item: item, admin: true),
            ],
          );
        }

        final miennes = store.reclamationsClient();
        final recues = [
          for (final item in store.reclamationsPrestataire())
            if (item.clientId != store.session?.id) item,
        ];
        final eligible = store.contratsReclamables();
        return ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            const IntroCommunication(
              'Un souci pendant la prestation ?',
              'Chaque réclamation reste liée à son contrat.',
            ),
            if (store.clientView && eligible.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FilledButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const ReclamationFormPage()),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Déposer une réclamation'),
                ),
              ),
            if (store.clientView && eligible.isEmpty)
              const VideCommunication(
                'Aucun contrat engagé sans réclamation déjà ouverte.',
              ),
            if (store.clientView) ...[
              const SectionCommunication('Mes dossiers'),
              if (miennes.isEmpty)
                const VideCommunication('Vous n\'avez déposé aucune réclamation.')
              else
                for (final item in miennes) _TuileReclamation(item: item),
            ],
            if (store.providerView) ...[
              const SectionCommunication('Réclamations reçues'),
              if (recues.isEmpty)
                const VideCommunication('Aucune réclamation sur vos prestations.')
              else
                for (final item in recues) _TuileReclamation(item: item),
            ],
          ],
        );
      },
    );
  }
}

class _TuileReclamation extends StatelessWidget {
  const _TuileReclamation({required this.item, this.admin = false});

  final Reclamation item;
  final bool admin;

  @override
  Widget build(BuildContext context) {
    final store = communicationStore;
    final contrat = devisContratsStore.findContrat(item.contratId);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Card(
        child: ListTile(
          leading: const Icon(Icons.assignment_outlined),
          title: Text('${labelMotif(item.motif)} · ${contrat?.service ?? 'Prestation'}'),
          subtitle: Text(
            admin
                ? '${item.numero} · ${store.nomDe(item.clientId)} / ${store.nomDe(item.prestataireId)}'
                : '${item.numero} · ${contrat?.numero ?? ''}',
          ),
          trailing: TagCommunication(
            labelStatutReclamation(item.statut),
            alerte: reclamationOuverte(item.statut),
          ),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ReclamationDetailPage(reclamationId: item.id),
            ),
          ),
        ),
      ),
    );
  }

}

/// Formulaire de dépôt, limité aux contrats du client.
class ReclamationFormPage extends StatefulWidget {
  /// Choisit un contrat puis le motif. [contratId] présélectionne le dossier.
  const ReclamationFormPage({super.key, this.contratId});

  /// Contrat proposé à l'ouverture.
  final String? contratId;

  @override
  State<ReclamationFormPage> createState() => _ReclamationFormPageState();
}

class _ReclamationFormPageState extends State<ReclamationFormPage> {
  final _description = TextEditingController();
  MotifReclamation _motif = MotifReclamation.retard;
  String? _contratId;
  var _pieces = 0;

  @override
  void initState() {
    super.initState();
    final contrats = communicationStore.contratsReclamables();
    final propose = widget.contratId;
    if (propose != null && contrats.any((contrat) => contrat.id == propose)) {
      _contratId = propose;
    } else if (contrats.isNotEmpty) {
      _contratId = contrats.first.id;
    }
  }

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  void _envoyer() {
    final contratId = _contratId;
    if (contratId == null) {
      dire(context, 'Choisissez un contrat.');
      return;
    }
    final result = communicationStore.deposerReclamation(
      contratId: contratId,
      motif: _motif,
      description: _description.text,
      pieces: _pieces,
    );
    if (result == null) return;
    if (result.startsWith('rec-')) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => ReclamationDetailPage(reclamationId: result),
        ),
      );
      return;
    }
    dire(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final store = communicationStore;
    final contrats = store.contratsReclamables();
    final choisi = contrats.where((item) => item.id == _contratId);
    final contrat = choisi.isEmpty ? null : choisi.first;
    return Scaffold(
      appBar: AppBar(title: const Text('Déposer une réclamation')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const IntroCommunication(
            'Décrivez la situation',
            'La réclamation sera rattachée au contrat choisi.',
          ),
          if (contrats.isEmpty)
            const Text('Aucun contrat ne peut recevoir une réclamation.')
          else
            DropdownButtonFormField<String>(
              initialValue: _contratId,
              decoration: const InputDecoration(
                labelText: 'Contrat',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final item in contrats)
                  DropdownMenuItem(
                    value: item.id,
                    child: Text('${item.numero} · ${item.service}'),
                  ),
              ],
              onChanged: (value) => setState(() => _contratId = value),
            ),
          if (contrat != null) ...[
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.handshake_outlined),
                title: Text('${contrat.service} · ${store.nomDe(contrat.prestataireId)}'),
                subtitle: Text('${contrat.numero} · ${formatDate(contrat.date)}'),
              ),
            ),
          ],
          const SizedBox(height: 16),
          DropdownButtonFormField<MotifReclamation>(
            initialValue: _motif,
            decoration: const InputDecoration(
              labelText: 'Motif',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final motif in MotifReclamation.values)
                DropdownMenuItem(value: motif, child: Text(labelMotif(motif))),
            ],
            onChanged: (value) => setState(() => _motif = value ?? _motif),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _description,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Expliquez ce qui s’est passé…',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => setState(() => _pieces += 1),
            icon: const Icon(Icons.add_a_photo_outlined),
            label: Text(_pieces == 0 ? 'Ajouter des photos' : '$_pieces photo(s) ajoutée(s)'),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: contrats.isEmpty ? null : _envoyer,
            icon: const Icon(Icons.send_outlined),
            label: const Text('Envoyer la réclamation'),
          ),
        ],
      ),
    );
  }
}

/// Détail du litige. L'admin tranche, les parties échangent.
class ReclamationDetailPage extends StatefulWidget {
  /// Affiche la réclamation [reclamationId].
  const ReclamationDetailPage({super.key, required this.reclamationId});

  /// Identifiant.
  final String reclamationId;

  @override
  State<ReclamationDetailPage> createState() => _ReclamationDetailPageState();
}

class _ReclamationDetailPageState extends State<ReclamationDetailPage> {
  final _message = TextEditingController();

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _decider(StatutReclamation statut) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(labelStatutReclamation(statut)),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Motif obligatoire',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (!mounted || reason == null) return;
    final error = communicationStore.deciderReclamation(
      reclamationId: widget.reclamationId,
      statut: statut,
      motif: reason,
    );
    if (error != null && mounted) dire(context, error);
  }

  @override
  Widget build(BuildContext context) {
    final store = communicationStore;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final item = store.findReclamation(widget.reclamationId);
        if (item == null) {
          return const Scaffold(body: Center(child: Text('Réclamation inaccessible.')));
        }
        final messages = store.messagesDe(store.filReclamation(item.id));
        final ouvert = reclamationOuverte(item.statut);
        return Scaffold(
          appBar: AppBar(title: Text('Réclamation ${item.numero}')),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              IntroCommunication(
                '${labelMotif(item.motif)} de prestation',
                'Ouverte le ${formatDate(item.ouverteLe)}',
              ),
              TagCommunication(
                labelStatutReclamation(item.statut),
                alerte: ouvert,
              ),
              const SizedBox(height: 14),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Description', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Text(item.description),
                      const SizedBox(height: 14),
                      const Text('Parties', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 5),
                      Text(
                        '${store.nomDe(item.clientId)} (client) · ${store.nomDe(item.prestataireId)} (prestataire)',
                      ),
                      const SizedBox(height: 14),
                      const Text('Pièces jointes', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 5),
                      Text(item.pieces == 0 ? 'Aucune photo' : '${item.pieces} photo(s)'),
                      if (item.decisionMotif.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        const Text('Décision', style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 5),
                        Text(item.decisionMotif),
                        if (item.decisionPar != null)
                          Text(
                            'Par ${store.nomDe(item.decisionPar!)}',
                            style: const TextStyle(color: IndigoOrChart.texteMuted),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
              const SectionCommunication('Fil du litige'),
              Card(
                child: Column(
                  children: [
                    if (messages.isEmpty)
                      const ListTile(title: Text('Aucun message.'))
                    else
                      for (final message in messages)
                        ListTile(
                          leading: CircleAvatar(child: Text(store.nomDe(message.auteurId)[0])),
                          title: Text(store.nomDe(message.auteurId)),
                          subtitle: Text(message.texte),
                        ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (store.adminView) ...[
                const SectionCommunication('Décision administrative'),
                const Text(
                  'La résolution consigne la décision sans modifier le paiement.',
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    OutlinedButton(
                      onPressed: () => _decider(StatutReclamation.enExamen),
                      child: const Text('En examen'),
                    ),
                    FilledButton(
                      onPressed: () => _decider(StatutReclamation.resolue),
                      child: const Text('Résoudre'),
                    ),
                    TextButton(
                      onPressed: () => _decider(StatutReclamation.rejetee),
                      child: const Text('Rejeter'),
                    ),
                  ],
                ),
              ] else if (ouvert) ...[
                TextField(
                  controller: _message,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.chat_outlined),
                    hintText: 'Message pour le litige',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: () {
                      final error = store.ecrireLitige(item.id, _message.text);
                      if (error != null) {
                        dire(context, error);
                        return;
                      }
                      _message.clear();
                    },
                    child: const Text('Envoyer'),
                  ),
                ),
              ] else
                const Text(
                  'Dossier clos. Le fil reste consultable.',
                  style: TextStyle(color: IndigoOrChart.texteMuted),
                ),
            ],
          ),
        );
      },
    );
  }
}
