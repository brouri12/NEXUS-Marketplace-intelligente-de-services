import 'package:flutter/material.dart';

import 'package:flutter_android_app/core/theme/indigo_or_chart.dart';
import 'package:flutter_android_app/core/ui/nexus_ui.dart';
import 'package:flutter_android_app/gestions/devis_contrats/back/contrat.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_presentation.dart';
import 'package:flutter_android_app/gestions/logistique/back/logistique_store.dart';
import 'package:flutter_android_app/gestions/logistique/back/trajet.dart';
import 'package:flutter_android_app/gestions/logistique/front/logistique_page.dart';
import 'package:flutter_android_app/gestions/utilisateurs/utilisateurs_module.dart';

/// Planification ou correction d'un trajet.
class LogistiqueFormPage extends StatefulWidget {
  /// Crée un trajet, ou modifie [trajet].
  const LogistiqueFormPage({super.key, required this.store, this.trajet, this.contratId});

  /// Trajets du compte ouvert.
  final LogistiqueStore store;

  /// Trajet à corriger. Absent, le formulaire en crée un.
  final Trajet? trajet;

  /// Contrat déjà choisi, depuis le détail d'un contrat.
  final String? contratId;

  @override
  State<LogistiqueFormPage> createState() => _LogistiqueFormPageState();
}

class _LogistiqueFormPageState extends State<LogistiqueFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _depart = TextEditingController();
  final _destination = TextEditingController();
  final _distance = TextEditingController();
  final _date = TextEditingController();
  final _heure = TextEditingController();
  String? _contratId;
  var _erreur = '';

  bool get _edition => widget.trajet != null;

  @override
  void initState() {
    super.initState();
    final trajet = widget.trajet;
    if (trajet != null) {
      _contratId = trajet.contratId;
      _depart.text = trajet.pointDepart;
      _destination.text = trajet.destination;
      _distance.text = formatKm(trajet.distanceKm).replaceAll(' km', '');
      _date.text = formatDate(trajet.departPrevu);
      _heure.text = formatHeure(trajet.departPrevu);
      return;
    }
    _depart.text = utilisateursStore.current?.city ?? '';
    final contrats = widget.store.contratsPlanifiables();
    final choisi = contrats.where((contrat) => contrat.id == widget.contratId);
    if (choisi.isNotEmpty) {
      _choisir(choisi.first);
    } else if (contrats.isNotEmpty) {
      _choisir(contrats.first);
    }
  }

  void _choisir(Contrat contrat) {
    _contratId = contrat.id;
    _destination.text = contrat.lieu;
    _distance.text = formatKm(contrat.distanceKm).replaceAll(' km', '');
    _date.text = formatDate(contrat.date);
    final heure = int.tryParse(contrat.heure.split(':').first) ?? 9;
    final avant = (heure - 1).clamp(0, 23).toString().padLeft(2, '0');
    _heure.text = '$avant:${contrat.heure.split(':').last.padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _depart.dispose();
    _destination.dispose();
    _distance.dispose();
    _date.dispose();
    _heure.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;
    final store = widget.store;
    final trajet = widget.trajet;
    final erreur = trajet == null
        ? store.creer(
            contratId: _contratId ?? '',
            depart: _depart.text,
            destination: _destination.text,
            distance: _distance.text,
            date: _date.text,
            heure: _heure.text,
          )
        : store.modifier(
            trajet.id,
            depart: _depart.text,
            destination: _destination.text,
            distance: _distance.text,
            date: _date.text,
            heure: _heure.text,
          );
    if (erreur != null) {
      setState(() => _erreur = erreur);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_edition ? 'Trajet mis à jour.' : 'Trajet planifié.'),
        backgroundColor: IndigoOrChart.succes,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final contrats = _edition ? const <Contrat>[] : widget.store.contratsPlanifiables();
    final km = double.tryParse(_distance.text.trim().replaceAll(',', '.'));

    return Scaffold(
      appBar: AppBar(title: Text(_edition ? 'Modifier le trajet' : 'Nouveau trajet')),
      bottomNavigationBar: BarreAction(
        label: _edition ? 'Enregistrer' : 'Planifier le trajet',
        icone: Icons.route_outlined,
        actif: _edition || contrats.isNotEmpty,
        onPressed: _submitForm,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Initialisation de course',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: IndigoOrChart.primaire,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              if (!_edition) ...[
                if (contrats.isEmpty)
                  const Text(
                    'Aucun contrat à desservir. Un trajet se planifie sur un contrat signé ou en signature.',
                  )
                else
                  DropdownButtonFormField<String>(
                    initialValue: _contratId,
                    decoration: _decoration('Contrat', Icons.description_outlined),
                    items: [
                      for (final contrat in contrats)
                        DropdownMenuItem(
                          value: contrat.id,
                          child: Text(
                            '${contrat.numero} · ${widget.store.nomDe(contrat.clientId)}',
                          ),
                        ),
                    ],
                    onChanged: (id) {
                      final contrat = contrats.firstWhere((item) => item.id == id);
                      setState(() => _choisir(contrat));
                    },
                  ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _depart,
                decoration: _decoration('Point de départ', Icons.location_on_outlined),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Le point de départ est obligatoire'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _destination,
                decoration: _decoration('Destination', Icons.flag_outlined),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'La destination est obligatoire'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _distance,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: _decoration('Distance (km)', Icons.route_outlined),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _date,
                      decoration: _decoration('Date', Icons.event_outlined),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _heure,
                      decoration: _decoration('Départ', Icons.schedule),
                    ),
                  ),
                ],
              ),
              if (km != null && km > 0) ...[
                const SizedBox(height: 16),
                Text(
                  'Itinéraire estimé : ${dureeEstimeeMinutes(km)} min '
                  '($vitesseMoyenneKmH km/h en moyenne, $margeMinutes min de marge).',
                  style: const TextStyle(color: IndigoOrChart.texteMuted),
                ),
              ],
              if (_erreur.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(_erreur, style: const TextStyle(color: IndigoOrChart.erreur)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: IndigoOrChart.secondaire),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: IndigoOrChart.or, width: 2),
      ),
    );
  }
}
