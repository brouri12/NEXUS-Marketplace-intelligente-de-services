import 'package:flutter/material.dart';

import 'package:flutter_android_app/gestions/devis_contrats/back/devis.dart';
import 'package:flutter_android_app/gestions/devis_contrats/back/devis_contrats_store.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_contrats_frame.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_contrats_routes.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_presentation.dart';

/// Tous les devis, en lecture, avec recherche et filtre.
class GestionDevisPage extends StatefulWidget {
  /// Liste les devis pour un admin.
  const GestionDevisPage({super.key});

  @override
  State<GestionDevisPage> createState() => _GestionDevisPageState();
}

class _GestionDevisPageState extends State<GestionDevisPage> {
  final _recherche = TextEditingController();
  StatutDevis? _statut;

  @override
  void dispose() {
    _recherche.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = DevisStoreScope.of(context);

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        if (!store.adminView) {
          return const AccesRefuse(
            title: 'Devis',
            message: 'Cette liste est réservée à un admin.',
          );
        }
        final query = _recherche.text.trim().toLowerCase();
        final devis = [
          for (final item in store.devisAdmin())
            if (_statut == null || item.statut == _statut)
              if (_correspond(store, item, query)) item,
        ];

        return DevisContratsFrame(
          title: 'Gestion des devis',
          child: ListView(
            children: [
              TextField(
                controller: _recherche,
                decoration: const InputDecoration(
                  labelText: 'Recherche',
                  hintText: 'Numéro, client, prestataire, service',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Filtre(
                    label: 'Tous',
                    selected: _statut == null,
                    onSelected: () => setState(() => _statut = null),
                  ),
                  for (final statut in StatutDevis.values)
                    _Filtre(
                      label: labelStatutDevis(statut),
                      selected: _statut == statut,
                      onSelected: () => setState(() => _statut = statut),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (devis.isEmpty)
                const Text('Aucun devis pour ce filtre.')
              else
                for (final item in devis)
                  FicheListe(
                    titre: item.numero,
                    icon: Icons.request_quote_outlined,
                    lignes: [
                      'Client : ${store.nomDe(item.clientId)}',
                      'Prestataire : ${store.nomDe(item.prestataireId)}',
                      'Service : ${item.service}',
                      'Montant : ${formatDt(item.total)}',
                      'Date : ${formatDate(item.date)}',
                    ],
                    statut: StatutTexte.devis(item.statut),
                    onTap: () => openDevisPage(
                      context,
                      DevisContratsRoutes.detailDevisAdmin,
                      arguments: item.id,
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }

  bool _correspond(DevisContratsStore store, Devis item, String query) {
    if (query.isEmpty) return true;
    final texte = [
      item.numero,
      store.nomDe(item.clientId),
      store.nomDe(item.prestataireId),
      item.service,
      formatDt(item.total),
    ].join(' ').toLowerCase();
    return texte.contains(query);
  }
}

class _Filtre extends StatelessWidget {
  const _Filtre({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}
