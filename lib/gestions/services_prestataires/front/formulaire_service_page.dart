import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_android_app/gestions/services_prestataires/front/composants.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/etat.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/modele.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/texte.dart';
import 'package:flutter_android_app/gestions/utilisateurs/utilisateurs_module.dart';

/// Formulaire d'un service. Annuler ne garde rien.
class FormulaireServicePage extends StatefulWidget {
  /// Écrit dans [etat] seulement au moment d'enregistrer.
  const FormulaireServicePage({super.key, required this.etat, this.service});

  /// Mémoire d'écran.
  final ServicesPrestatairesEtat etat;

  /// Offre à modifier. Absente, le formulaire crée une demande.
  final OffreService? service;

  @override
  State<FormulaireServicePage> createState() => _FormulaireServicePageState();
}

class _FormulaireServicePageState extends State<FormulaireServicePage> {
  final _formulaire = GlobalKey<FormState>();
  final _description = TextEditingController();
  final _ville = TextEditingController();
  final _rayon = TextEditingController(text: '25');
  String? _service;
  String? _erreurService;
  VehiculeService _vehicule = VehiculeService.aucun;
  int _equipe = 2;
  String _erreur = '';

  bool get _edition => widget.service != null;

  @override
  void initState() {
    super.initState();
    final service = widget.service;
    if (service == null) {
      _ville.text = utilisateursStore.current?.city ?? '';
      return;
    }
    _service = service.nom;
    _description.text = service.description;
    _ville.text = service.ville;
    _rayon.text = '${service.rayonKm}';
    _vehicule = service.vehicule;
    _equipe = service.tailleEquipe;
  }

  @override
  void dispose() {
    _description.dispose();
    _ville.dispose();
    _rayon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_edition ? 'Modifier le service' : 'Formulaire de service'),
      ),
      body: Form(
        key: _formulaire,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
              Legende(
                'Profil du compte : ${libelleSecteur(widget.service?.secteur ?? widget.etat.secteurConnecte)}. Les services ajoutés restent dans ce secteur.',
              ),
              const SizedBox(height: 16),
              Text('Service', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              if (_edition)
                Text(_service ?? '', style: theme.textTheme.bodyLarge)
              else
                ChoixPastilles<String>(
                  valeur: _service ?? '',
                  options: servicesDuSecteur(widget.etat.secteurConnecte),
                  libelle: (service) => service,
                  onChoisir: (service) => setState(() {
                    _service = service;
                    _erreurService = null;
                  }),
                ),
              if (_erreurService != null) ...[
                const SizedBox(height: 8),
                Text(
                  _erreurService!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('champ-description'),
              controller: _description,
              textCapitalization: TextCapitalization.sentences,
              maxLength: 180,
              maxLines: 3,
              decoration: decorationChamp(context, label: 'Description courte'),
              validator: (valeur) => _requis(valeur, 'La description manque.'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('champ-ville'),
              controller: _ville,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              maxLength: 40,
              decoration: decorationChamp(context, label: 'Ville'),
              validator: (valeur) => _requis(valeur, 'La ville manque.'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _rayon,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 3,
              decoration: decorationChamp(context, label: 'Rayon').copyWith(
                suffixText: 'km',
              ),
              validator: _validerRayon,
            ),
            const SizedBox(height: 20),
            Text('Véhicule', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            ChoixPastilles<VehiculeService>(
              valeur: _vehicule,
              options: VehiculeService.values,
              libelle: libelleVehicule,
              onChoisir: (vehicule) => setState(() => _vehicule = vehicule),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Taille d\'équipe',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: 'Retirer une personne',
                  onPressed: _equipe > 1
                      ? () => setState(() => _equipe -= 1)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text('$_equipe', style: theme.textTheme.titleMedium),
                IconButton(
                  tooltip: 'Ajouter une personne',
                  onPressed: _equipe < 20
                      ? () => setState(() => _equipe += 1)
                      : null,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Legende(
              _edition
                  ? 'Les changements s\'appliquent tout de suite à l\'offre.'
                  : 'L\'admin approuve le service avant sa publication.',
            ),
            if (_erreur.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                _erreur,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
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
                child: Text(_edition ? 'Enregistrer' : 'Envoyer la demande'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _requis(String? valeur, String message) {
    if (valeur == null || valeur.trim().isEmpty) {
      return message;
    }
    return null;
  }

  String? _validerRayon(String? valeur) {
    final rayon = int.tryParse(valeur?.trim() ?? '');
    if (rayon == null || rayon < 1 || rayon > 200) {
      return 'Indiquez un rayon entre 1 et 200 km.';
    }
    return null;
  }

  void _enregistrer() {
    if (_service == null) {
      setState(() => _erreurService = 'Choisissez un service du secteur.');
    }
    if (_service == null || !_formulaire.currentState!.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();
    final service = widget.service;
    final erreur = service == null
        ? widget.etat.publier(
            nom: _service!,
            description: _description.text,
            ville: _ville.text,
            rayonKm: int.parse(_rayon.text.trim()),
            vehicule: _vehicule,
            tailleEquipe: _equipe,
          )
        : widget.etat.modifier(
            service.id,
            description: _description.text,
            ville: _ville.text,
            rayonKm: int.parse(_rayon.text.trim()),
            vehicule: _vehicule,
            tailleEquipe: _equipe,
          );
    if (erreur != null) {
      setState(() => _erreur = erreur);
      return;
    }
    Navigator.of(context).pop();
  }
}
