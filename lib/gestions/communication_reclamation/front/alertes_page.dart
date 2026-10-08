import 'package:flutter/material.dart';

import 'package:flutter_android_app/core/theme/indigo_or_chart.dart';
import 'package:flutter_android_app/gestions/communication_reclamation/back/communication_models.dart';
import 'package:flutter_android_app/gestions/communication_reclamation/back/communication_store.dart';
import 'package:flutter_android_app/gestions/communication_reclamation/front/avis_page.dart';
import 'package:flutter_android_app/gestions/communication_reclamation/front/communication_widgets.dart';
import 'package:flutter_android_app/gestions/communication_reclamation/front/messages_page.dart';
import 'package:flutter_android_app/gestions/communication_reclamation/front/reclamations_page.dart';

/// Alertes du compte ouvert, filtrées par ses préférences.
class AlertesPage extends StatelessWidget {
  /// Crée la liste.
  const AlertesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = communicationStore;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final items = store.alertes();
        return ListView(
          children: [
            const IntroCommunication(
              'À ne pas manquer',
              'Les nouvelles de vos devis, contrats et échanges.',
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: items.isEmpty ? null : store.toutMarquerLu,
                icon: const Icon(Icons.done_all),
                label: const Text('Tout marquer comme lu'),
              ),
            ),
            if (items.isEmpty)
              const VideCommunication('Aucune alerte pour ce rôle.')
            else
              for (final alerte in items)
                ListTile(
                  tileColor: alerte.lue
                      ? null
                      : IndigoOrChart.orConteneur.withValues(alpha: .35),
                  leading: Icon(_icone(alerte.type), color: IndigoOrChart.primaire),
                  title: Text(alerte.titre, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('${alerte.detail}\n${ilYa(alerte.quand)}'),
                  isThreeLine: true,
                  trailing: alerte.lue
                      ? null
                      : const Icon(Icons.circle, size: 9, color: IndigoOrChart.orTexte),
                  onTap: () {
                    store.marquerAlerteLue(alerte.id);
                    _ouvrir(context, alerte);
                  },
                ),
          ],
        );
      },
    );
  }

  void _ouvrir(BuildContext context, Alerte alerte) {
    final page = switch (alerte.type) {
      TypeAlerte.reclamation when alerte.reclamationId != null =>
        ReclamationDetailPage(reclamationId: alerte.reclamationId!),
      TypeAlerte.avis when alerte.avisId != null => AvisDetailPage(avisId: alerte.avisId!),
      TypeAlerte.message || TypeAlerte.devis || TypeAlerte.prestation
          when alerte.dossierId != null =>
        ChatPage(dossierId: alerte.dossierId!),
      _ => null,
    };
    if (page == null) return;
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  IconData _icone(TypeAlerte type) {
    return switch (type) {
      TypeAlerte.message => Icons.chat_bubble_outline,
      TypeAlerte.devis => Icons.request_quote_outlined,
      TypeAlerte.prestation => Icons.task_alt,
      TypeAlerte.reclamation => Icons.report_outlined,
      TypeAlerte.avis => Icons.star_outline,
    };
  }
}

/// Réglages des alertes du compte ouvert.
class ReglagesAlertesPage extends StatelessWidget {
  /// Crée l'écran.
  const ReglagesAlertesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = communicationStore;
    return Scaffold(
      appBar: AppBar(title: const Text('Réglages des notifications')),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final prefs = store.preferencesActuelles();
          final valeurs = {
            'Devis et contrats': prefs.devisEtContrats,
            'Messages': prefs.messages,
            'Prestations': prefs.prestations,
            'Réclamations': prefs.reclamations,
            'Avis': prefs.avis,
          };
          return ListView(
            children: [
              const IntroCommunication(
                'Restez informé',
                'Choisissez où recevoir chaque type de mise à jour.',
              ),
              for (final item in valeurs.entries)
                SwitchListTile(
                  value: item.value,
                  title: Text(item.key),
                  subtitle: Text(
                    item.value ? 'Affichée dans l’application' : 'Masquée',
                  ),
                  onChanged: (value) => _changer(context, item.key, value),
                ),
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Couper une alerte la retire de cette liste. Le numéro du profil reste celui des alertes sur téléphone. Un contrat encore ouvert demande une confirmation.',
                  style: TextStyle(color: IndigoOrChart.texteMuted),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _changer(BuildContext context, String cle, bool valeur) async {
    final store = communicationStore;
    final user = store.session;
    final sensible = cle == 'Devis et contrats' || cle == 'Prestations';
    if (!valeur && user != null && sensible && store.aContratEnCours(user.id)) {
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
      if (confirmed != true || !context.mounted) return;
    }
    store.definirPreference(cle, valeur);
  }
}
