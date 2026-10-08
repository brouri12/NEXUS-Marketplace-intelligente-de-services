import 'package:flutter/material.dart';

import 'package:flutter_android_app/gestions/devis_contrats/back/option_ligne.dart';
import 'package:flutter_android_app/gestions/devis_contrats/devis_contrats_module.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_presentation.dart';
import 'package:flutter_android_app/gestions/services_prestataires/back/offered_service.dart';
import 'package:flutter_android_app/gestions/utilisateurs/back/provider_profile.dart';
import 'package:flutter_android_app/gestions/utilisateurs/front/utilisateurs_frame.dart';
import 'package:flutter_android_app/gestions/utilisateurs/utilisateurs_module.dart';

/// Demande de devis : le client coche ce que ce prestataire propose.
class DemanderDevisPage extends StatefulWidget {
  /// Ouvre la demande pour [service].
  const DemanderDevisPage({super.key, required this.service});

  /// Offre choisie dans le catalogue.
  final OfferedService service;

  @override
  State<DemanderDevisPage> createState() => _DemanderDevisPageState();
}

class _DemanderDevisPageState extends State<DemanderDevisPage> {
  final _date = TextEditingController();
  final _lieu = TextEditingController();
  final _distance = TextEditingController();
  final _autre = TextEditingController();
  final _coches = <String>{};
  var _veutAutre = false;
  var _error = '';
  var _envoyee = false;

  @override
  void initState() {
    super.initState();
    _date.text = formatDate(DateTime.now());
  }

  @override
  void dispose() {
    _date.dispose();
    _lieu.dispose();
    _distance.dispose();
    _autre.dispose();
    super.dispose();
  }

  List<String> get _sousServices {
    for (final account in utilisateursStore.accounts) {
      final profile = account.providerProfile;
      if (account.fullName == widget.service.providerName && profile != null) {
        return profile.skills;
      }
    }
    return skillsByTrade[widget.service.title] ?? const [];
  }

  List<String> get _retenus {
    return [
      for (final label in _sousServices)
        if (_coches.contains(label)) label,
      if (_veutAutre && _autre.text.trim().isNotEmpty) _autre.text.trim(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final service = widget.service;
    final retenus = _retenus;

    return Scaffold(
      appBar: AppBar(title: const Text('Demander un devis')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Text(service.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(service.providerName),
          Text('${service.city} · ${service.rate}'),
          const SizedBox(height: 16),
          if (_envoyee) ...[
            const Text('Demande envoyée. Seuls les éléments cochés sont transmis.'),
            const SizedBox(height: 12),
            for (final label in retenus) InfoLigne(label, 'Oui'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Retour aux services'),
            ),
          ] else ...[
            Text('Ce que ${service.providerName} propose', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (_sousServices.isEmpty)
              const Text('Ce prestataire n\'a pas encore indiqué de prestation.')
            else
              for (final label in _sousServices)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(label),
                  value: _coches.contains(label),
                  onChanged: (value) {
                    setState(() {
                      if (value ?? false) {
                        _coches.add(label);
                      } else {
                        _coches.remove(label);
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
                decoration: const InputDecoration(labelText: 'Décrivez l\'autre prestation'),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 8),
            TextField(
              controller: _date,
              decoration: const InputDecoration(labelText: 'Date'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _lieu,
              decoration: const InputDecoration(labelText: 'Lieu'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _distance,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Distance (km)'),
            ),
            const SizedBox(height: 16),
            Text('Éléments retenus', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (retenus.isEmpty)
              const Text('Aucun élément choisi.')
            else
              for (final label in retenus) InfoLigne(label, 'Oui'),
            const SizedBox(height: 16),
            FormErrorText(message: _error),
            FilledButton(
              onPressed: _envoyer,
              child: const Text('Envoyer la demande'),
            ),
          ],
        ],
      ),
    );
  }

  void _envoyer() {
    if (_veutAutre && _autre.text.trim().isEmpty) {
      setState(() => _error = 'Décrivez la prestation Autre, ou décochez-la.');
      return;
    }
    final options = [
      for (final label in _retenus)
        OptionLigne(label: label, prix: prixConnu(label)),
    ];
    final error = devisContratsStore.envoyerDemande(
      prestataireNom: widget.service.providerName,
      service: widget.service.title,
      date: _date.text,
      lieu: _lieu.text,
      distance: _distance.text,
      options: options,
    );
    setState(() {
      _error = error ?? '';
      _envoyee = error == null;
    });
  }
}
