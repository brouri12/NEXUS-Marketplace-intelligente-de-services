import 'package:flutter/material.dart';

import 'package:flutter_android_app/gestions/devis_contrats/back/contrat.dart';
import 'package:flutter_android_app/gestions/devis_contrats/back/devis_contrats_store.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_contrats_frame.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_contrats_routes.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_presentation.dart';

/// Filtre admin des contrats.
enum _FiltreContrat {
  tous,
  attente,
  valide,
  enCours,
  termine,
  annule,
}

/// Tous les contrats, en lecture, avec filtre de statut.
class GestionContratsPage extends StatefulWidget {
  /// Liste les contrats pour un admin.
  const GestionContratsPage({super.key});

  @override
  State<GestionContratsPage> createState() => _GestionContratsPageState();
}

class _GestionContratsPageState extends State<GestionContratsPage> {
  final _recherche = TextEditingController();
  var _filtre = _FiltreContrat.tous;

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
            title: 'Contrats',
            message: 'Cette liste est réservée à un admin.',
          );
        }
        final query = _recherche.text.trim().toLowerCase();
        final contrats = [
          for (final item in store.contratsAdmin())
            if (_garde(item.statut))
              if (_correspond(store, item, query)) item,
        ];

        return DevisContratsFrame(
          title: 'Gestion des contrats',
          child: ListView(
            children: [
              TextField(
                controller: _recherche,
                decoration: const InputDecoration(
                  labelText: 'Recherche',
                  hintText: 'Numéro, devis, client, prestataire',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final filtre in _FiltreContrat.values)
                    ChoiceChip(
                      label: Text(_label(filtre)),
                      selected: _filtre == filtre,
                      onSelected: (_) => setState(() => _filtre = filtre),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (contrats.isEmpty)
                const Text('Aucun contrat pour ce filtre.')
              else
                for (final item in contrats)
                  FicheListe(
                    titre: item.numero,
                    icon: Icons.description_outlined,
                    lignes: [
                      'Devis : ${store.devisDuContrat(item)?.numero ?? '—'}',
                      'Client : ${store.nomDe(item.clientId)}',
                      'Prestataire : ${store.nomDe(item.prestataireId)}',
                      'Service : ${item.service}',
                      'Montant : ${formatDt(item.prixAccepte)}',
                      'Date : ${formatDate(item.date)}',
                    ],
                    statut: StatutTexte.contrat(item.statut),
                    onTap: () => openDevisPage(
                      context,
                      DevisContratsRoutes.detailContratAdmin,
                      arguments: item.id,
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }

  bool _garde(StatutContrat statut) {
    return switch (_filtre) {
      _FiltreContrat.tous => true,
      _FiltreContrat.attente => contratEnAttenteSignature(statut),
      _FiltreContrat.valide => statut == StatutContrat.valide,
      _FiltreContrat.enCours => statut == StatutContrat.enCours,
      _FiltreContrat.termine => statut == StatutContrat.termine,
      _FiltreContrat.annule => statut == StatutContrat.annule,
    };
  }

  bool _correspond(DevisContratsStore store, Contrat item, String query) {
    if (query.isEmpty) return true;
    final texte = [
      item.numero,
      store.devisDuContrat(item)?.numero ?? '',
      store.nomDe(item.clientId),
      store.nomDe(item.prestataireId),
      item.service,
    ].join(' ').toLowerCase();
    return texte.contains(query);
  }

  String _label(_FiltreContrat filtre) {
    return switch (filtre) {
      _FiltreContrat.tous => 'Tous',
      _FiltreContrat.attente => 'EN_ATTENTE_SIGNATURE',
      _FiltreContrat.valide => 'VALIDÉ',
      _FiltreContrat.enCours => 'EN_COURS',
      _FiltreContrat.termine => 'TERMINÉ',
      _FiltreContrat.annule => 'ANNULÉ',
    };
  }
}
