import 'package:flutter/material.dart';

import 'package:flutter_android_app/gestions/communication_reclamation/front/messages_page.dart';
import 'package:flutter_android_app/gestions/devis_contrats/back/devis.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_contrats_frame.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_contrats_routes.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_presentation.dart';

/// Détail d'un devis pour le client, avec acceptation ou refus.
class DetailDevisClientPage extends StatefulWidget {
  /// Affiche le devis [devisId].
  const DetailDevisClientPage({super.key, required this.devisId});

  /// Identifiant reçu par la route.
  final String devisId;

  @override
  State<DetailDevisClientPage> createState() => _DetailDevisClientPageState();
}

class _DetailDevisClientPageState extends State<DetailDevisClientPage> {
  var _vu = false;
  var _error = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_vu) return;
    _vu = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      DevisStoreScope.of(context).marquerVu(widget.devisId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = DevisStoreScope.of(context);

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final devis = store.findDevis(widget.devisId);
        final user = store.session;
        if (!store.clientView || devis == null || user == null || devis.clientId != user.id) {
          return const AccesRefuse(
            title: 'Devis',
            message: 'Ce devis n\'est pas accessible.',
          );
        }

        return DevisContratsFrame(
          title: devis.numero,
          child: ListView(
            children: [
              Text(
                'DEVIS N° ${devis.numero}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              StatutTexte.devis(devis.statut),
              const SizedBox(height: 12),
              InfoLigne('Prestataire', store.nomDe(devis.prestataireId)),
              InfoLigne('Service', devis.service),
              const SizedBox(height: 8),
              MontantBlock(
                prixBase: devis.prixBase,
                options: devis.options,
                distanceKm: devis.distanceKm,
                prixParKm: devis.prixParKm,
              ),
              const SectionTitre('Conditions'),
              Text(devis.conditions.isEmpty ? '—' : devis.conditions),
              const SizedBox(height: 16),
              const RemarqueDevis(),
              if (devis.statut != StatutDevis.brouillon) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => ouvrirDiscussion(
                    context,
                    devis.contratId == null ? 'd:${devis.id}' : 'c:${devis.contratId}',
                  ),
                  icon: const Icon(Icons.forum_outlined),
                  label: const Text('Discuter'),
                ),
              ],
              const SizedBox(height: 16),
              ErreurFormulaire(message: _error),
              if (devis.ouvrable)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _decider(context, accepter: false),
                        child: const Text('Refuser'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => _decider(context, accepter: true),
                        child: const Text('Accepter le devis'),
                      ),
                    ),
                  ],
                ),
              if (devis.statut == StatutDevis.accepte) ...[
                const Text('✓ Devis accepté.'),
                const SizedBox(height: 8),
                const Text('Le contrat correspondant est disponible.'),
                if (devis.contratId != null) ...[
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => openDevisPage(
                      context,
                      DevisContratsRoutes.detailContratClient,
                      arguments: devis.contratId,
                    ),
                    child: const Text('Voir le contrat'),
                  ),
                ],
              ],
              if (devis.statut == StatutDevis.refuse)
                const Text('Devis refusé.'),
            ],
          ),
        );
      },
    );
  }

  void _decider(BuildContext context, {required bool accepter}) {
    final store = DevisStoreScope.of(context);
    final error = accepter
        ? store.accepterDevis(widget.devisId)
        : store.refuserDevis(widget.devisId);
    setState(() => _error = error ?? '');
  }
}
