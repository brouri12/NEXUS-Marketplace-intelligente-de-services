import 'package:flutter/material.dart';

import 'package:flutter_android_app/gestions/devis_contrats/back/modification_contrat.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_contrats_frame.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_contrats_routes.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_presentation.dart';

/// Le prestataire propose un supplément, sans modifier le contrat directement.
class ProposerModificationPage extends StatefulWidget {
  /// Propose un changement sur [contratId].
  const ProposerModificationPage({super.key, required this.contratId});

  /// Identifiant reçu par la route.
  final String contratId;

  @override
  State<ProposerModificationPage> createState() => _ProposerModificationPageState();
}

class _ProposerModificationPageState extends State<ProposerModificationPage> {
  final _motif = TextEditingController();
  final _supplement = TextEditingController();
  final _conditions = TextEditingController();
  final _autre = TextEditingController();
  final _coches = <String>{};
  var _veutAutre = false;
  var _error = '';

  @override
  void dispose() {
    _motif.dispose();
    _supplement.dispose();
    _conditions.dispose();
    _autre.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = DevisStoreScope.of(context);

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final contrat = store.findContrat(widget.contratId);
        final user = store.session;
        if (!store.providerView ||
            contrat == null ||
            user == null ||
            contrat.prestataireId != user.id) {
          return const AccesRefuse(
            title: 'Modification',
            message: 'Ce contrat n\'est pas accessible.',
          );
        }
        final ajout = int.tryParse(_supplement.text.trim());
        final supplement = ajout != null && ajout >= 0 ? ajout : 0;
        final retenus = [
          for (final option in contrat.options)
            if (_coches.contains(option.label)) option.label,
          if (_veutAutre && _autre.text.trim().isNotEmpty) _autre.text.trim(),
        ];

        return DevisContratsFrame(
          title: 'Proposer une modification',
          child: ListView(
            children: [
              InfoLigne('Contrat', contrat.numero),
              InfoLigne('Prix actuel', formatDt(contrat.prixAccepte)),
              const SizedBox(height: 12),
              Text(
                'Ce que vous voulez changer',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (contrat.options.isEmpty)
                const Text('Aucune option sur ce contrat.')
              else
                for (final option in contrat.options)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(option.label),
                    value: _coches.contains(option.label),
                    onChanged: (value) {
                      setState(() {
                        if (value ?? false) {
                          _coches.add(option.label);
                        } else {
                          _coches.remove(option.label);
                        }
                      });
                    },
                  ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Autre'),
                value: _veutAutre,
                onChanged: (value) => setState(() => _veutAutre = value ?? false),
              ),
              if (_veutAutre) ...[
                TextField(
                  controller: _autre,
                  decoration: const InputDecoration(labelText: 'Décrivez l\'autre changement'),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 8),
              Text('Éléments retenus', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (retenus.isEmpty)
                const Text('Aucun élément choisi.')
              else
                for (final label in retenus) InfoLigne(label, 'À modifier'),
              const SizedBox(height: 12),
              TextField(
                controller: _motif,
                decoration: const InputDecoration(labelText: 'Motif de modification'),
                minLines: 2,
                maxLines: 4,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _supplement,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Supplément'),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _conditions,
                decoration: const InputDecoration(labelText: 'Nouvelles conditions'),
                minLines: 2,
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              InfoLigne('Supplément', formatDt(supplement)),
              Text(
                'Nouveau total : ${formatDt(contrat.prixAccepte + supplement)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              const Text(remarqueModificationPrestataire),
              const SizedBox(height: 16),
              ErreurFormulaire(message: _error),
              FilledButton(
                onPressed: () => _envoyer(context, retenus),
                child: const Text('Envoyer la proposition'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _envoyer(BuildContext context, List<String> retenus) {
    if (retenus.isEmpty) {
      setState(() => _error = 'Cochez au moins un élément à modifier.');
      return;
    }
    if (_veutAutre && _autre.text.trim().isEmpty) {
      setState(() => _error = 'Décrivez le changement Autre, ou décochez-le.');
      return;
    }
    final store = DevisStoreScope.of(context);
    final conditions = [
      if (_conditions.text.trim().isNotEmpty) _conditions.text.trim(),
      for (final label in retenus) label,
    ].join('\n');
    final error = store.proposerModification(
      contratId: widget.contratId,
      motif: _motif.text,
      supplement: _supplement.text,
      nouvellesConditions: conditions,
    );
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.of(context).pop();
  }
}
