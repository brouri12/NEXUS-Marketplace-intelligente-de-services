import 'package:flutter/material.dart';

import 'package:flutter_android_app/core/ui/nexus_ui.dart';

import 'package:flutter_android_app/gestions/devis_contrats/back/distance_lieux.dart';
import 'package:flutter_android_app/gestions/devis_contrats/back/option_ligne.dart';
import 'package:flutter_android_app/gestions/devis_contrats/devis_contrats_module.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_presentation.dart';
import 'package:flutter_android_app/gestions/services_prestataires/back/offered_service.dart';
import 'package:flutter_android_app/gestions/utilisateurs/back/provider_profile.dart';
import 'package:flutter_android_app/gestions/utilisateurs/front/utilisateurs_frame.dart';
import 'package:flutter_android_app/gestions/utilisateurs/utilisateurs_module.dart';

/// Liste des villes reconnues, pour l'autocomplete.
/// Extraite directement des clés de `_coords` dans distance_lieux.dart.
const _villesConnues = [
  'Tunis',
  'Grand Tunis',
  'La Marsa',
  'Carthage',
  'Sidi Bou Saïd',
  'Ariana',
  'La Soukra',
  'Gammarth',
  'La Goulette',
  'Le Kram',
  'Les Berges du Lac',
  'Centre Urbain Nord',
  'El Menzah',
  'Charguia',
  'Ben Arous',
  'Radès',
  'Mégrine',
  'Ezzahra',
  'Hammam Lif',
  'Manouba',
  'Nabeul',
  'Hammamet',
  'Bizerte',
  'Sousse',
  'Monastir',
  'Mahdia',
  'Sfax',
  'Kairouan',
  'Gabès',
  'Djerba',
  'Zaghouan',
];

/// Demande de devis : le client coche ce que ce prestataire propose.
class DemanderDevisPage extends StatefulWidget {
  /// Ouvre la demande pour [service].
  const DemanderDevisPage({
    super.key,
    required this.service,
    this.lieuInitial = '',
    this.onEnvoyee,
  });

  /// Offre choisie dans le catalogue.
  final OfferedService service;

  /// Lieu repris du besoin décrit sur la marketplace.
  final String lieuInitial;

  /// Appelé une fois la demande enregistrée.
  final VoidCallback? onEnvoyee;

  @override
  State<DemanderDevisPage> createState() => _DemanderDevisPageState();
}

class _DemanderDevisPageState extends State<DemanderDevisPage> {
  final _date = TextEditingController();
  final _lieu = TextEditingController();
  final _autreDescription = TextEditingController();
  final _coches = <String>{};
  var _veutAutre = false;
  var _error = '';
  var _envoyee = false;

  @override
  void initState() {
    super.initState();
    _date.text = formatDate(DateTime.now());
    _lieu.text = widget.lieuInitial;
  }

  @override
  void dispose() {
    _date.dispose();
    _lieu.dispose();
    _autreDescription.dispose();
    super.dispose();
  }

  List<String> get _sousServices {
    if (widget.service.prestations.isNotEmpty) return widget.service.prestations;
    for (final account in utilisateursStore.accounts) {
      final profile = account.providerProfile;
      if (account.fullName == widget.service.providerName && profile != null) {
        return profile.skills;
      }
    }
    return skillsByTrade[widget.service.title] ?? const [];
  }

  List<OptionLigne> get _optionsRetenues {
    final liste = <OptionLigne>[
      for (final label in _sousServices)
        if (_coches.contains(label)) OptionLigne(label: label, prix: prixConnu(label)),
    ];
    if (_veutAutre && _autreDescription.text.trim().isNotEmpty) {
      liste.add(OptionLigne(label: _autreDescription.text.trim(), prix: 0));
    }
    return liste;
  }

  List<String> get _labelsRetenus => _optionsRetenues.map((o) => o.label).toList();

  String get _emplacement {
    return devisContratsStore.emplacementDe(
      widget.service.providerName,
      villeService: widget.service.city,
    );
  }

  DistanceCalculee get _distance {
    return distanceEntre(
      emplacementPrestataire: _emplacement,
      lieuDemande: _lieu.text,
    );
  }

  /// Suggestions filtrées selon la saisie actuelle.
  List<String> _suggestions(String saisie) {
    if (saisie.trim().isEmpty) return const [];
    final cle = saisie.toLowerCase().trim();
    return [
      for (final ville in _villesConnues)
        if (ville.toLowerCase().contains(cle)) ville,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final service = widget.service;
    final options = _optionsRetenues;
    final distance = _distance;

    return Scaffold(
      appBar: AppBar(title: const Text('Demander un devis')),
      bottomNavigationBar: _envoyee
          ? null
          : BarreAction(
              label: 'Envoyer la demande',
              icone: Icons.send_outlined,
              onPressed: _envoyer,
            ),
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
            for (final opt in options)
              InfoLigne(
                opt.label,
                opt.aChiffrer ? 'Prix fixé par le prestataire' : formatDt(opt.prix),
              ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Retour'),
            ),
          ] else ...[
            Text(
              'Ce que ${service.providerName} propose',
              style: Theme.of(context).textTheme.titleMedium,
            ),
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

            // ── Option "Autre" ────────────────────────────────────────────
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Autre'),
              value: _veutAutre,
              onChanged: (value) => setState(() => _veutAutre = value ?? false),
            ),
            if (_veutAutre) ...[
              TextField(
                controller: _autreDescription,
                decoration: const InputDecoration(
                  labelText: 'Décrivez la prestation',
                  hintText: 'Ex. : Démontage de meubles',
                  prefixIcon: Icon(Icons.edit_outlined),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),
              const Text('Le prestataire indiquera le prix de cette prestation sur le devis.'),
              if (_autreDescription.text.trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                _ApercuAutre(description: _autreDescription.text.trim()),
              ],
              const SizedBox(height: 12),
            ],

            // ── Date ─────────────────────────────────────────────────────
            const SizedBox(height: 8),
            TextField(
              controller: _date,
              decoration: const InputDecoration(labelText: 'Date'),
            ),

            // ── Lieu avec autocomplete ────────────────────────────────────
            const SizedBox(height: 12),
            _ChampLieuAutocomplete(
              controller: _lieu,
              suggestions: _suggestions,
              onChanged: () => setState(() {}),
            ),
            const SizedBox(height: 12),
            InfoLigne('Emplacement du prestataire', _emplacement),
            InfoLigne(
              'Distance',
              _lieu.text.trim().isEmpty
                  ? 'Saisissez le lieu'
                  : '${formatKm(distance.km)} · ${distance.mention}',
            ),

            // ── Récapitulatif ─────────────────────────────────────────────
            const SizedBox(height: 16),
            Text('Éléments retenus', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (_labelsRetenus.isEmpty)
              const Text('Aucun élément choisi.')
            else
              for (final opt in options)
                InfoLigne(
                  opt.label,
                  opt.aChiffrer ? 'Prix fixé par le prestataire' : formatDt(opt.prix),
                ),
            const SizedBox(height: 16),
            FormErrorText(message: _error),
          ],
        ],
      ),
    );
  }

  void _envoyer() {
    if (_veutAutre && _autreDescription.text.trim().isEmpty) {
      setState(() => _error = 'Décrivez la prestation Autre, ou décochez-la.');
      return;
    }
    final options = _optionsRetenues;
    final error = devisContratsStore.envoyerDemande(
      prestataireNom: widget.service.providerName,
      service: widget.service.title,
      date: _date.text,
      lieu: _lieu.text,
      emplacementPrestataire: _emplacement,
      options: options,
      prixBase: widget.service.prixBase,
    );
    setState(() {
      _error = error ?? '';
      _envoyee = error == null;
    });
    if (error == null) widget.onEnvoyee?.call();
  }
}

// ── Widgets auxiliaires ────────────────────────────────────────────────────

/// Champ "Lieu où se rendre" avec suggestions au-dessous.
class _ChampLieuAutocomplete extends StatefulWidget {
  const _ChampLieuAutocomplete({
    required this.controller,
    required this.suggestions,
    required this.onChanged,
  });

  final TextEditingController controller;
  final List<String> Function(String) suggestions;
  final VoidCallback onChanged;

  @override
  State<_ChampLieuAutocomplete> createState() => _ChampLieuAutocompleteState();
}

class _ChampLieuAutocompleteState extends State<_ChampLieuAutocomplete> {
  List<String> _liste = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.controller,
          decoration: const InputDecoration(
            labelText: 'Lieu où se rendre',
            prefixIcon: Icon(Icons.location_on_outlined),
            hintText: 'Ex. : La Marsa, Ariana…',
          ),
          onChanged: (valeur) {
            setState(() => _liste = widget.suggestions(valeur));
            widget.onChanged();
          },
        ),
        if (_liste.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFC9C3B6)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x18000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                for (final ville in _liste)
                  InkWell(
                    onTap: () {
                      widget.controller.text = ville;
                      widget.controller.selection = TextSelection.collapsed(
                        offset: ville.length,
                      );
                      setState(() => _liste = []);
                      widget.onChanged();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_city_outlined,
                            size: 16,
                            color: Color(0xFF4E5E8A),
                          ),
                          const SizedBox(width: 10),
                          Text(ville),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Aperçu de l'option "Autre" saisie, avant envoi.
class _ApercuAutre extends StatelessWidget {
  const _ApercuAutre({required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFD9E0F0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF24315C)),
          const SizedBox(width: 8),
          Expanded(child: Text(description)),
          const Text(
            'Prix du prestataire',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF8A6414),
            ),
          ),
        ],
      ),
    );
  }
}
