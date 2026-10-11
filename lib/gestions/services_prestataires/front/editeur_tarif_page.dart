import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_android_app/core/theme/indigo_or_chart.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/composants.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/etat.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/modele.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/texte.dart';

/// Saisie du tarif d'un service.
class EditeurTarifPage extends StatefulWidget {
  /// Édite le tarif de [serviceId] dans [etat].
  const EditeurTarifPage({
    super.key,
    required this.etat,
    required this.serviceId,
  });

  /// Mémoire d'écran.
  final ServicesPrestatairesEtat etat;

  /// Offre concernée.
  final String serviceId;

  @override
  State<EditeurTarifPage> createState() => _EditeurTarifPageState();
}

class _EditeurTarifPageState extends State<EditeurTarifPage> {
  final _formulaire = GlobalKey<FormState>();
  late final TextEditingController _montant;
  late final TextEditingController _inclus;
  final _supplement = TextEditingController();
  late TypeTarif _type;
  late List<String> _enPlus;

  OffreService get _service {
    return widget.etat.services.firstWhere(
      (service) => service.id == widget.serviceId,
    );
  }

  @override
  void initState() {
    super.initState();
    final tarif = _service.tarif;
    _montant = TextEditingController(
      text: tarif == null ? '' : '${tarif.montantDt}',
    );
    _inclus = TextEditingController(text: tarif?.inclus ?? '');
    _type = tarif?.type ??
        (_service.vehicule == VehiculeService.camion
            ? TypeTarif.camion
            : TypeTarif.forfait);
    _enPlus = [...?tarif?.enPlus];
  }

  @override
  void dispose() {
    _montant.dispose();
    _inclus.dispose();
    _supplement.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extras = [
      for (final nom in _enPlus)
        if (!_connu(nom)) nom,
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Tarif')),
      body: Form(
        key: _formulaire,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Text(_service.nom, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Legende(_service.zone),
            const SizedBox(height: 20),
            Text('Type', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            ChoixPastilles<TypeTarif>(
              valeur: _type,
              options: TypeTarif.values,
              libelle: libelleTypeTarif,
              onChoisir: (type) => setState(() => _type = type),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _montant,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 7,
              decoration: decorationChamp(context, label: 'Montant').copyWith(
                suffixText: 'DT',
              ),
              validator: _validerMontant,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _inclus,
              textCapitalization: TextCapitalization.sentences,
              maxLength: 160,
              maxLines: 3,
              decoration: decorationChamp(
                context,
                label: 'Ce qui est inclus',
                indice: 'Camion et deux personnes',
              ),
              validator: (valeur) {
                if (valeur == null || valeur.trim().isEmpty) {
                  return 'Indiquez ce qui est inclus.';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            Text('En plus', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final nom in ServicesPrestatairesEtat.supplementsConnus)
                  PastilleChoix(
                    libelle: nom,
                    choisie: _contient(nom),
                    onChoisir: (choisie) => _basculerConnu(nom, choisie),
                  ),
                for (final extra in extras)
                  InputChip(
                    label: Text(extra),
                    backgroundColor: IndigoOrChart.orConteneur,
                    labelStyle: const TextStyle(
                      color: IndigoOrChart.onOrConteneur,
                    ),
                    deleteIconColor: IndigoOrChart.onOrConteneur,
                    onDeleted: () {
                      setState(() => _enPlus.remove(extra));
                    },
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _supplement,
                    textCapitalization: TextCapitalization.sentences,
                    maxLength: 40,
                    decoration: decorationChamp(
                      context,
                      label: 'Autre supplément',
                    ),
                    onSubmitted: (_) => _ajouterSupplement(),
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TextButton(
                    onPressed: _ajouterSupplement,
                    child: const Text('Ajouter'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BarreBasse(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(64, 48),
                  shape: const StadiumBorder(),
                ),
                child: const Text('Annuler'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: _enregistrer,
                child: const Text('Enregistrer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _connu(String nom) {
    return ServicesPrestatairesEtat.supplementsConnus.any(
      (connu) => connu.toLowerCase() == nom.toLowerCase(),
    );
  }

  bool _contient(String nom) {
    return _enPlus.any((item) => item.toLowerCase() == nom.toLowerCase());
  }

  void _basculerConnu(String nom, bool choisi) {
    setState(() {
      _enPlus.removeWhere((item) => item.toLowerCase() == nom.toLowerCase());
      if (choisi) {
        _enPlus.add(nom);
      }
    });
  }

  void _ajouterSupplement() {
    final texte = _supplement.text.trim();
    if (texte.isEmpty || _contient(texte)) {
      return;
    }
    setState(() {
      _enPlus.add(texte);
      _supplement.clear();
    });
  }

  String? _validerMontant(String? valeur) {
    final montant = int.tryParse(valeur?.trim() ?? '');
    if (montant == null || montant <= 0) {
      return 'Indiquez le montant en DT.';
    }
    return null;
  }

  void _enregistrer() {
    if (!_formulaire.currentState!.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();
    widget.etat.definirTarif(
      widget.serviceId,
      TarifService(
        type: _type,
        montantDt: int.parse(_montant.text.trim()),
        inclus: _inclus.text,
        enPlus: List<String>.from(_enPlus),
      ),
    );
    Navigator.of(context).pop();
  }
}
