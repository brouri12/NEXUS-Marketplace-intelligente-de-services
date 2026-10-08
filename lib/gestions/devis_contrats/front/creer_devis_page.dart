import 'package:flutter/material.dart';

import 'package:flutter_android_app/gestions/devis_contrats/back/demande_devis.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_contrats_frame.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_contrats_routes.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_presentation.dart';

/// Préparation du devis à partir d'une demande.
class CreerDevisPage extends StatefulWidget {
  /// Affiche la demande [demandeId].
  const CreerDevisPage({super.key, required this.demandeId});

  /// Identifiant reçu par la route.
  final String demandeId;

  @override
  State<CreerDevisPage> createState() => _CreerDevisPageState();
}

class _CreerDevisPageState extends State<CreerDevisPage> {
  final _date = TextEditingController();
  final _heure = TextEditingController();
  final _duree = TextEditingController();
  final _conditions = TextEditingController();
  final _inclus = TextEditingController();
  final _exclus = TextEditingController();
  var _error = '';
  var _ready = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ready) return;
    _ready = true;
    final demande = DevisStoreScope.of(context).findDemande(widget.demandeId);
    if (demande != null) _date.text = formatDate(demande.date);
  }

  @override
  void dispose() {
    _date.dispose();
    _heure.dispose();
    _duree.dispose();
    _conditions.dispose();
    _inclus.dispose();
    _exclus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = DevisStoreScope.of(context);

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        if (!store.providerView) {
          return const AccesRefuse(
            title: 'Créer le devis',
            message: 'Seul un prestataire peut préparer un devis.',
          );
        }
        final demande = store.findDemande(widget.demandeId);
        if (demande == null || demande.statut != StatutDemande.recue) {
          return const AccesRefuse(
            title: 'Créer le devis',
            message: 'Cette demande n\'est plus ouverte.',
          );
        }

        return DevisContratsFrame(
          title: 'Créer le devis',
          child: ListView(
            children: [
              Text('DEVIS', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              InfoLigne('Client', store.nomDe(demande.clientId)),
              InfoLigne('Service', demande.service),
              const SizedBox(height: 8),
              MontantBlock(
                prixBase: demande.prixBase,
                options: demande.options,
                distanceKm: demande.distanceKm,
                prixParKm: demande.prixParKm,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _date,
                decoration: const InputDecoration(labelText: 'Date'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _heure,
                decoration: const InputDecoration(labelText: 'Heure'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _duree,
                decoration: const InputDecoration(labelText: 'Durée estimée'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _conditions,
                decoration: const InputDecoration(labelText: 'Conditions'),
                minLines: 2,
                maxLines: 4,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _inclus,
                decoration: const InputDecoration(labelText: 'Éléments inclus'),
                minLines: 2,
                maxLines: 4,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _exclus,
                decoration: const InputDecoration(labelText: 'Éléments non inclus'),
                minLines: 2,
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              const RemarqueDevis(),
              const SizedBox(height: 16),
              ErreurFormulaire(message: _error),
              FilledButton(
                onPressed: () => _envoyer(context),
                child: const Text('Envoyer le devis'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _envoyer(BuildContext context) {
    final store = DevisStoreScope.of(context);
    final error = store.envoyerDevis(
      demandeId: widget.demandeId,
      date: _date.text,
      heure: _heure.text,
      dureeEstimee: _duree.text,
      conditions: _conditions.text,
      elementsInclus: _inclus.text,
      elementsNonInclus: _exclus.text,
    );
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    openDevisPage(context, DevisContratsRoutes.devisPrestataire);
  }
}
