import 'package:flutter/material.dart';

import 'package:flutter_android_app/core/theme/indigo_or_chart.dart';
import 'package:flutter_android_app/gestions/communication_reclamation/back/communication_store.dart';
import 'package:flutter_android_app/gestions/communication_reclamation/front/communication_widgets.dart';

/// Ouvre la conversation [dossierId].
void ouvrirDiscussion(BuildContext context, String dossierId) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => ChatPage(dossierId: dossierId)),
  );
}

/// Conversations liées aux devis et aux contrats du compte ouvert.
class MessagesPage extends StatelessWidget {
  /// Crée la liste.
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = communicationStore;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final dossiers = store.dossiers();
        return ListView(
          padding: const EdgeInsets.only(bottom: 20),
          children: [
            IntroCommunication(
              store.adminView ? 'Échanges des dossiers' : 'Vos dossiers, vos échanges',
              store.adminView
                  ? 'Lecture seule. Chaque conversation reste liée à son devis ou à son contrat.'
                  : 'Chaque conversation est liée à un devis, un contrat ou un litige.',
            ),
            if (dossiers.isEmpty)
              const VideCommunication(
                'Aucun échange pour le moment. Un devis ou un contrat ouvrira la conversation.',
              )
            else
              for (final dossier in dossiers)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: IndigoOrChart.primaireConteneur,
                        foregroundColor: IndigoOrChart.primaire,
                        child: Text(dossier.interlocuteur.isEmpty ? '?' : dossier.interlocuteur[0]),
                      ),
                      title: Text(
                        dossier.interlocuteur,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${dossier.service} · ${dossier.quand}'),
                            const SizedBox(height: 5),
                            Text(
                              dossier.apercu,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            TagCommunication(dossier.statut, alerte: dossier.litige),
                          ],
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => ouvrirDiscussion(context, dossier.id),
                    ),
                  ),
                ),
          ],
        );
      },
    );
  }
}

/// Conversation d'un seul dossier.
class ChatPage extends StatefulWidget {
  /// Ouvre le fil [dossierId].
  const ChatPage({super.key, required this.dossierId});

  /// Clé `d:` ou `c:`.
  final String dossierId;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _input = TextEditingController();

  @override
  void initState() {
    super.initState();
    communicationStore.marquerDossierLu(widget.dossierId);
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _send({bool photo = false}) {
    final error = communicationStore.envoyerMessage(
      widget.dossierId,
      _input.text,
      photo: photo,
    );
    if (error != null) {
      dire(context, error);
      return;
    }
    _input.clear();
  }

  @override
  Widget build(BuildContext context) {
    final store = communicationStore;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final dossier = store.findDossier(widget.dossierId);
        if (dossier == null) {
          return const Scaffold(body: Center(child: Text('Conversation inaccessible.')));
        }
        final messages = store.messagesDe(dossier.id);
        final moi = store.session?.id;
        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dossier.interlocuteur, style: const TextStyle(fontSize: 17)),
                Text(
                  '${dossier.service} · ${dossier.quand}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              Container(
                width: double.infinity,
                color: dossier.litige
                    ? IndigoOrChart.erreurConteneur
                    : IndigoOrChart.primaireConteneur,
                padding: const EdgeInsets.all(10),
                child: Text(
                  'Dossier : ${dossier.statut}',
                  style: TextStyle(
                    color: dossier.litige ? IndigoOrChart.erreur : IndigoOrChart.primaire,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final mine = message.auteurId == moi;
                    return Align(
                      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 300),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: mine ? IndigoOrChart.primaireConteneur : Colors.white,
                          border: Border.all(color: IndigoOrChart.contourDiscret),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          message.photo ? 'Photo · ${message.texte}' : message.texte,
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (dossier.lectureSeule)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    dossier.statut == 'Contrat annulé'
                        ? 'Contrat annulé · conversation en lecture seule.'
                        : 'Conversation en lecture seule.',
                    style: const TextStyle(color: IndigoOrChart.texteMuted),
                  ),
                )
              else
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: 'Joindre une photo',
                          onPressed: () => _send(photo: true),
                          icon: const Icon(Icons.attach_file),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _input,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _send(),
                            decoration: const InputDecoration(
                              hintText: 'Votre message',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        IconButton.filled(
                          tooltip: 'Envoyer',
                          onPressed: _send,
                          icon: const Icon(Icons.send),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
