import 'package:flutter/material.dart';

import 'package:flutter_android_app/core/theme/indigo_or_chart.dart';

const _names = [
  'Amine Ben Salem',
  'Leïla Trabelsi',
  'Sami Gharbi',
  'Nadia Ben Amor',
];
const _services = [
  'Déménagement',
  'Montage de meubles',
  'Transport de colis',
  'Aide au déménagement',
];
const _dates = [
  'Sam. 12 oct. · 08:00',
  'Lun. 14 oct. · 14:00',
  'Mer. 16 oct. · 09:30',
  'Mar. 8 oct. · 08:00',
];

class _Intro extends StatelessWidget {
  const _Intro(this.title, this.subtitle);
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(subtitle, style: const TextStyle(color: IndigoOrChart.texteMuted)),
      ],
    ),
  );
}

class _Section extends StatelessWidget {
  const _Section(this.title);
  final String title;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
    child: Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: IndigoOrChart.texteMuted,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _Tag extends StatelessWidget {
  const _Tag(this.text, {this.color = IndigoOrChart.primaireConteneur});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: color == IndigoOrChart.erreurConteneur
            ? IndigoOrChart.erreur
            : IndigoOrChart.primaire,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

/// Fils de discussion liés à un dossier précis.
class MessagesPage extends StatelessWidget {
  /// Crée la liste de conversations.
  const MessagesPage({super.key});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.only(bottom: 20),
    children: [
      const _Intro(
        'Vos dossiers, vos échanges',
        'Chaque conversation est liée à un devis, un contrat ou un litige.',
      ),
      const _Section('Conversations récentes'),
      for (var i = 0; i < _names.length; i++)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: IndigoOrChart.primaireConteneur,
                foregroundColor: IndigoOrChart.primaire,
                child: Text(_names[i][0]),
              ),
              title: Text(
                _names[i],
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${_services[i]} · ${_dates[i]}'),
                    const SizedBox(height: 5),
                    Text(
                      [
                        'Je peux prévoir deux personnes pour le chargement.',
                        'Merci, je vous envoie une photo du meuble.',
                        'Le dossier reste ouvert pour le suivi.',
                        'La conversation reste consultable après annulation.',
                      ][i],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    _Tag(
                      [
                        'Devis envoyé',
                        'Contrat confirmé',
                        'Réclamation ouverte',
                        'Contrat annulé',
                      ][i],
                      color: i == 2
                          ? IndigoOrChart.erreurConteneur
                          : IndigoOrChart.primaireConteneur,
                    ),
                  ],
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ChatPage(
                    name: _names[i],
                    service: _services[i],
                    date: _dates[i],
                    status: [
                      'Devis envoyé',
                      'Contrat confirmé',
                      'Réclamation ouverte',
                      'Contrat annulé',
                    ][i],
                  ),
                ),
              ),
            ),
          ),
        ),
    ],
  );
}

/// Conversation attachée à un seul dossier.
class ChatPage extends StatefulWidget {
  /// Crée un chat avec les informations de son dossier.
  const ChatPage({
    super.key,
    required this.name,
    required this.service,
    required this.date,
    required this.status,
  });
  final String name;
  final String service;
  final String date;
  final String status;
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _input = TextEditingController();
  final _messages = <(String, bool)>[
    ('Bonjour, votre devis est prêt. Le camion est inclus.', false),
    ('Parfait. Est-ce que le prix inclut les cartons ?', true),
    ('Oui, cinq cartons sont compris dans le forfait.', false),
  ];
  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _send() {
    final value = _input.text.trim();
    if (value.isNotEmpty) {
      setState(() {
        _messages.add((value, true));
        _input.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.name, style: const TextStyle(fontSize: 17)),
          Text(
            '${widget.service} · ${widget.date}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    ),
    body: Column(
      children: [
        Container(
          width: double.infinity,
          color: IndigoOrChart.primaireConteneur,
          padding: const EdgeInsets.all(10),
          child: Text(
            'Dossier : ${widget.status}',
            style: const TextStyle(
              color: IndigoOrChart.primaire,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (context, i) {
              final (text, mine) = _messages[i];
              return Align(
                alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 300),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: mine
                        ? IndigoOrChart.primaireConteneur
                        : Colors.white,
                    border: Border.all(color: IndigoOrChart.contourDiscret),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(text),
                ),
              );
            },
          ),
        ),
        if (widget.status == 'Contrat annulé')
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Contrat annulé · conversation en lecture seule.',
              style: TextStyle(color: IndigoOrChart.texteMuted),
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
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Photo jointe (aperçu statique).'),
                      ),
                    ),
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
}

/// Alertes rattachées aux écrans du dossier concerné.
class NotificationsPage extends StatefulWidget {
  /// Crée la liste statique de notifications.
  const NotificationsPage({super.key});
  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final _read = <int>{2};
  static const _items = [
    (
      'Nouveau devis reçu',
      'Amine a envoyé un devis pour votre déménagement.',
      Icons.request_quote_outlined,
    ),
    (
      'Message reçu',
      'Leïla vous a envoyé une photo.',
      Icons.chat_bubble_outline,
    ),
    (
      'Réclamation mise à jour',
      'Le dossier REC-024 est en cours d’examen.',
      Icons.report_outlined,
    ),
    (
      'Prestation terminée',
      'Votre prestation avec Sami est terminée.',
      Icons.task_alt,
    ),
  ];
  @override
  Widget build(BuildContext context) => ListView(
    children: [
      const _Intro(
        'À ne pas manquer',
        'Les nouvelles de vos devis, contrats et échanges.',
      ),
      Align(
        alignment: Alignment.centerRight,
        child: TextButton.icon(
          onPressed: () => setState(() => _read.addAll([0, 1, 2, 3])),
          icon: const Icon(Icons.done_all),
          label: const Text('Tout marquer comme lu'),
        ),
      ),
      for (var i = 0; i < _items.length; i++)
        ListTile(
          tileColor: _read.contains(i)
              ? null
              : IndigoOrChart.orConteneur.withValues(alpha: .35),
          leading: Icon(_items[i].$3, color: IndigoOrChart.primaire),
          title: Text(
            _items[i].$1,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            '${_items[i].$2}\n${['Il y a 12 min', 'Il y a 1 h', 'Hier, 16:42', 'Hier, 10:15'][i]}',
          ),
          isThreeLine: true,
          trailing: _read.contains(i)
              ? null
              : const Icon(Icons.circle, size: 9, color: IndigoOrChart.orTexte),
          onTap: () {
            setState(() => _read.add(i));
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => i == 2
                    ? const ComplaintDetailPage(id: 'REC-024')
                    : ChatPage(
                        name: _names[i % 3],
                        service: _services[i % 3],
                        date: _dates[i % 3],
                        status: 'Dossier en cours',
                      ),
              ),
            );
          },
        ),
    ],
  );
}

/// Réglages par type de notification.
class NotificationSettingsPage extends StatefulWidget {
  /// Crée les préférences statiques d’alertes.
  const NotificationSettingsPage({super.key});
  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final _values = <String, bool>{
    'Devis et contrats': true,
    'Messages': true,
    'Prestations': true,
    'Réclamations': true,
    'Avis': false,
  };

  Future<void> _changeValue(String key, bool value) async {
    if (!value && (key == 'Devis et contrats' || key == 'Prestations')) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Désactiver cette alerte ?'),
          content: const Text(
            'Vous avez un contrat en cours. Vous pourriez manquer ses mises à jour.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Garder les alertes'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Désactiver'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    if (mounted) setState(() => _values[key] = value);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Réglages des notifications')),
    body: ListView(
      children: [
        const _Intro(
          'Restez informé',
          'Choisissez où recevoir chaque type de mise à jour.',
        ),
        for (final item in _values.entries)
          SwitchListTile(
            value: item.value,
            title: Text(item.key),
            subtitle: Text(
              item.value
                  ? 'Dans l’application et sur le téléphone'
                  : 'Dans l’application seulement',
            ),
            onChanged: (value) => _changeValue(item.key, value),
          ),
        const Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'Les alertes sur téléphone utilisent le numéro du profil. Les notifications d’un contrat en cours restent actives.',
            style: TextStyle(color: IndigoOrChart.texteMuted),
          ),
        ),
      ],
    ),
  );
}

/// Avis publiés et prestation terminée à évaluer.
class ReviewsPage extends StatelessWidget {
  /// Crée les raccourcis vers les avis.
  const ReviewsPage({super.key});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.only(bottom: 20),
    children: [
      const _Intro(
        'La confiance se partage',
        'Un avis ne peut être publié qu’une fois la prestation terminée.',
      ),
      const _Section('À évaluer'),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Card(
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.local_shipping_outlined),
            ),
            title: const Text('Déménagement · Amine Ben Salem'),
            subtitle: const Text('Terminé le 8 octobre · Contrat CTR-108'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const ReviewFormPage()),
            ),
          ),
        ),
      ),
      const _Section('Avis publiés'),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: IndigoOrChart.orConteneur,
              child: Icon(Icons.star, color: IndigoOrChart.orTexte),
            ),
            title: const Text('Leïla Trabelsi'),
            subtitle: const Text('★★★★★ · Équipe soigneuse et ponctuelle.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const ReviewDetailPage()),
            ),
          ),
        ),
      ),
    ],
  );
}

/// Formulaire d’avis lié au contrat terminé CTR-108.
class ReviewFormPage extends StatefulWidget {
  /// Crée le formulaire de notation.
  const ReviewFormPage({super.key});
  @override
  State<ReviewFormPage> createState() => _ReviewFormPageState();
}

class _ReviewFormPageState extends State<ReviewFormPage> {
  int _rating = 0;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Rédiger un avis')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const _Intro(
          'Déménagement avec Amine',
          'Contrat CTR-108 · Terminé le 8 octobre',
        ),
        const Text('Votre note', style: TextStyle(fontWeight: FontWeight.w700)),
        Row(
          children: [
            for (var i = 1; i <= 5; i++)
              IconButton(
                tooltip: '$i étoiles',
                onPressed: () => setState(() => _rating = i),
                icon: Icon(
                  i <= _rating ? Icons.star : Icons.star_outline,
                  color: IndigoOrChart.orTexte,
                  size: 34,
                ),
              ),
          ],
        ),
        const TextField(
          maxLength: 280,
          maxLines: 5,
          decoration: InputDecoration(
            labelText: 'Votre expérience',
            hintText: 'Ponctualité, soin, communication…',
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _rating == 0
              ? null
              : () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(
                    builder: (_) => const ReviewDetailPage(),
                  ),
                ),
          icon: const Icon(Icons.publish_outlined),
          label: const Text('Publier l’avis'),
        ),
      ],
    ),
  );
}

/// Détail d’un avis avec réponse unique du prestataire.
class ReviewDetailPage extends StatefulWidget {
  /// Crée un avis publié.
  const ReviewDetailPage({super.key});
  @override
  State<ReviewDetailPage> createState() => _ReviewDetailPageState();
}

class _ReviewDetailPageState extends State<ReviewDetailPage> {
  bool _replied = false;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Détail de l’avis')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const _Intro(
          'Une expérience recommandée',
          'Publié le 9 octobre · par Nadia',
        ),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '★★★★★',
                  style: TextStyle(color: IndigoOrChart.orTexte, fontSize: 22),
                ),
                SizedBox(height: 10),
                Text(
                  'Équipe ponctuelle et très soigneuse. Le déménagement s’est déroulé sans stress.',
                ),
                SizedBox(height: 12),
                Text(
                  'Nadia · Déménagement',
                  style: TextStyle(color: IndigoOrChart.texteMuted),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        if (_replied)
          const Card(
            child: ListTile(
              leading: Icon(Icons.reply),
              title: Text('Réponse du prestataire'),
              subtitle: Text('Merci Nadia pour votre confiance !'),
            ),
          )
        else
          OutlinedButton.icon(
            onPressed: () => setState(() => _replied = true),
            icon: const Icon(Icons.reply),
            label: const Text('Répondre une fois'),
          ),
      ],
    ),
  );
}

/// Tableau des réclamations du client et entrée de la file admin.
class ComplaintsPage extends StatelessWidget {
  /// Crée le suivi des réclamations.
  const ComplaintsPage({super.key});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.only(bottom: 24),
    children: [
      const _Intro(
        'Un souci pendant la prestation ?',
        'Chaque réclamation reste liée à son contrat.',
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: FilledButton.icon(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const ComplaintFormPage()),
          ),
          icon: const Icon(Icons.add),
          label: const Text('Déposer une réclamation'),
        ),
      ),
      const _Section('Mes dossiers'),
      for (final item in [
        ('REC-024', 'Retard · Transport de colis', 'En examen'),
        ('REC-019', 'Dégât · Déménagement', 'Résolue'),
      ])
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Card(
            child: ListTile(
              leading: const Icon(Icons.assignment_outlined),
              title: Text(item.$2),
              subtitle: Text('${item.$1} · Contrat CTR-108'),
              trailing: _Tag(item.$3, color: IndigoOrChart.orConteneur),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ComplaintDetailPage(id: item.$1),
                ),
              ),
            ),
          ),
        ),
      const _Section('Administration'),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: OutlinedButton.icon(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const AdminComplaintsPage(),
            ),
          ),
          icon: const Icon(Icons.admin_panel_settings_outlined),
          label: const Text('Ouvrir la file des réclamations'),
        ),
      ),
    ],
  );
}

/// Formulaire de dépôt lié d’avance au contrat CTR-108.
class ComplaintFormPage extends StatefulWidget {
  /// Crée le formulaire de signalement.
  const ComplaintFormPage({super.key});
  @override
  State<ComplaintFormPage> createState() => _ComplaintFormPageState();
}

class _ComplaintFormPageState extends State<ComplaintFormPage> {
  String _reason = 'Retard';
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Déposer une réclamation')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const _Intro(
          'Décrivez la situation',
          'La réclamation sera directement rattachée à votre contrat.',
        ),
        const Card(
          child: ListTile(
            leading: Icon(Icons.handshake_outlined),
            title: Text('Déménagement · Amine Ben Salem'),
            subtitle: Text('Contrat CTR-108 · 8 octobre'),
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _reason,
          decoration: const InputDecoration(
            labelText: 'Motif',
            border: OutlineInputBorder(),
          ),
          items: const ['Retard', 'Prix', 'Dégât', 'Absence', 'Autre']
              .map(
                (reason) =>
                    DropdownMenuItem(value: reason, child: Text(reason)),
              )
              .toList(),
          onChanged: (value) => setState(() => _reason = value ?? _reason),
        ),
        const SizedBox(height: 14),
        const TextField(
          maxLines: 5,
          decoration: InputDecoration(
            labelText: 'Description',
            hintText: 'Expliquez ce qui s’est passé…',
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
          ),
        ),
        OutlinedButton.icon(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ajout de photos (aperçu statique).')),
          ),
          icon: const Icon(Icons.add_a_photo_outlined),
          label: const Text('Ajouter des photos'),
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => const ComplaintDetailPage(id: 'REC-025'),
            ),
          ),
          icon: const Icon(Icons.send_outlined),
          label: const Text('Envoyer la réclamation'),
        ),
      ],
    ),
  );
}

/// File admin listant les réclamations à examiner.
class AdminComplaintsPage extends StatelessWidget {
  /// Crée la file statique de modération.
  const AdminComplaintsPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Réclamations · Admin')),
    body: ListView(
      children: [
        const _Intro(
          'Dossiers à traiter',
          'Examinez les éléments et consignez une décision motivée.',
        ),
        for (final item in [
          ('REC-024', 'Retard', 'CTR-108 · Nadia / Sami'),
          ('REC-022', 'Prix', 'CTR-104 · Mehdi / Amine'),
          ('REC-019', 'Dégât', 'CTR-101 · Nadia / Amine'),
        ])
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: IndigoOrChart.erreurConteneur,
                  child: Icon(
                    Icons.report_outlined,
                    color: IndigoOrChart.erreur,
                  ),
                ),
                title: Text('${item.$1} · ${item.$2}'),
                subtitle: Text('${item.$3}\nOuverte · 10 oct. 2026'),
                isThreeLine: true,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        ComplaintDetailPage(id: item.$1, admin: true),
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

/// Détail du litige, fil réservé et décisions admin à motif obligatoire.
class ComplaintDetailPage extends StatefulWidget {
  /// Crée l’écran du dossier indiqué.
  const ComplaintDetailPage({super.key, required this.id, this.admin = false});
  final String id;
  final bool admin;
  @override
  State<ComplaintDetailPage> createState() => _ComplaintDetailPageState();
}

class _ComplaintDetailPageState extends State<ComplaintDetailPage> {
  String _status = 'En examen';
  Future<void> _setStatus(String value) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(value),
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
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (!mounted || reason == null) return;
    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Un motif est obligatoire.')),
      );
      return;
    }
    setState(() => _status = value);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Réclamation ${widget.id}')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const _Intro(
          'Retard de prestation',
          'Contrat CTR-108 · Déménagement · Ouverte le 10 oct. 2026',
        ),
        _Tag(_status, color: IndigoOrChart.orConteneur),
        const SizedBox(height: 14),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Description',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 8),
                Text(
                  'Le prestataire est arrivé avec plus d’une heure de retard. Le créneau avait été confirmé à 08:00.',
                ),
                SizedBox(height: 14),
                Text('Parties', style: TextStyle(fontWeight: FontWeight.w700)),
                SizedBox(height: 5),
                Text('Nadia (cliente) · Sami (prestataire)'),
                SizedBox(height: 14),
                Text(
                  'Pièces jointes',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 5),
                Text('2 photos ajoutées'),
              ],
            ),
          ),
        ),
        const _Section('Fil du litige'),
        const Card(
          child: Column(
            children: [
              ListTile(
                leading: CircleAvatar(child: Text('N')),
                title: Text('Nadia · Cliente'),
                subtitle: Text(
                  'J’ai attendu jusqu’à 09:15. Les photos montrent l’heure d’arrivée.',
                ),
              ),
              Divider(height: 1),
              ListTile(
                leading: CircleAvatar(child: Text('S')),
                title: Text('Sami · Prestataire'),
                subtitle: Text(
                  'Un incident sur la route a causé le retard. Je présente mes excuses.',
                ),
              ),
            ],
          ),
        ),
        if (widget.admin) ...[
          const _Section('Décision administrative'),
          const Text(
            'La résolution consigne la décision sans modifier le paiement.',
          ),
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton(
                onPressed: () => _setStatus('En examen'),
                child: const Text('En examen'),
              ),
              FilledButton(
                onPressed: () => _setStatus('Résolue'),
                child: const Text('Résoudre'),
              ),
              TextButton(
                onPressed: () => _setStatus('Rejetée'),
                child: const Text('Rejeter'),
              ),
            ],
          ),
        ] else
          const TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.chat_outlined),
              hintText: 'Message pour le litige',
              border: OutlineInputBorder(),
            ),
          ),
      ],
    ),
  );
}
