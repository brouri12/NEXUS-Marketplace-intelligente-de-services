import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_android_app/core/theme/indigo_or_chart.dart';
import 'package:flutter_android_app/gestions/devis_contrats/back/contrat.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_contrats_frame.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_contrats_routes.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_presentation.dart';

/// Choix du paiement, affiché dès que le client a signé.
///
/// Flux :
/// 1. L'utilisateur choisit « À la livraison » ou « En ligne ».
/// 2a. À la livraison → confirmation directe (récapitulatif + bouton).
/// 2b. En ligne → formulaire carte bancaire simulé puis confirmation.
class PaiementContratPage extends StatefulWidget {
  /// Ouvre le paiement du contrat [contratId].
  const PaiementContratPage({super.key, required this.contratId});

  /// Identifiant reçu par la route.
  final String contratId;

  @override
  State<PaiementContratPage> createState() => _PaiementContratPageState();
}

/// Étapes internes de la page.
enum _Etape { choix, formulaireCarte, confirmation }

class _PaiementContratPageState extends State<PaiementContratPage> {
  ModePaiement? _choix;
  _Etape _etape = _Etape.choix;
  var _error = '';

  // Champs carte
  final _numeroCarte = TextEditingController();
  final _titulaire = TextEditingController();
  final _expiration = TextEditingController();
  final _cvv = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _numeroCarte.dispose();
    _titulaire.dispose();
    _expiration.dispose();
    _cvv.dispose();
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
        if (!store.clientView ||
            contrat == null ||
            user == null ||
            contrat.clientId != user.id ||
            !contrat.signatureClient) {
          return const AccesRefuse(
            title: 'Paiement',
            message: 'Le paiement s\'ouvre après votre signature.',
          );
        }

        // Paiement déjà confirmé → récapitulatif final
        if (contrat.modePaiement != ModePaiement.aucun) {
          return _pageConfirmee(context, contrat);
        }

        return switch (_etape) {
          _Etape.choix => _pageChoix(context, contrat),
          _Etape.formulaireCarte => _pageFormulaireCarte(context, contrat),
          _Etape.confirmation => _pageRecapitulatif(context, contrat),
        };
      },
    );
  }

  // ── Étape 1 : choix du mode ──────────────────────────────────────────────

  Widget _pageChoix(BuildContext context, Contrat contrat) {
    return DevisContratsFrame(
      title: 'Paiement',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _entete(context, contrat),
          const SizedBox(height: 20),
          _ChoixPaiement(
            titre: 'Payer à la livraison',
            detail: 'Vous réglez en espèces à l\'arrivée du prestataire.',
            icone: Icons.local_shipping_outlined,
            selectionne: _choix == ModePaiement.aLivraison,
            onTap: () => setState(() => _choix = ModePaiement.aLivraison),
          ),
          const SizedBox(height: 12),
          _ChoixPaiement(
            titre: 'Payer en ligne',
            detail: 'Réglez maintenant par carte bancaire.',
            icone: Icons.credit_card_outlined,
            selectionne: _choix == ModePaiement.enLigne,
            onTap: () => setState(() => _choix = ModePaiement.enLigne),
          ),
          const SizedBox(height: 20),
          ErreurFormulaire(message: _error),
          FilledButton(
            onPressed: _choix == null ? null : () => _avancer(context),
            child: const Text('Continuer'),
          ),
        ],
      ),
    );
  }

  void _avancer(BuildContext context) {
    final choix = _choix;
    if (choix == null) {
      setState(() => _error = 'Choisissez un mode de paiement.');
      return;
    }
    setState(() {
      _error = '';
      _etape = choix == ModePaiement.enLigne
          ? _Etape.formulaireCarte
          : _Etape.confirmation;
    });
  }

  // ── Étape 2b : formulaire carte bancaire ─────────────────────────────────

  Widget _pageFormulaireCarte(BuildContext context, Contrat contrat) {
    return DevisContratsFrame(
      title: 'Paiement en ligne',
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _entete(context, contrat),
            const SizedBox(height: 20),
            _CarteVisuelle(numero: _numeroCarte.text, titulaire: _titulaire.text),
            const SizedBox(height: 20),
            TextFormField(
              controller: _numeroCarte,
              decoration: const InputDecoration(
                labelText: 'Numéro de carte',
                prefixIcon: Icon(Icons.credit_card_outlined),
                hintText: '•••• •••• •••• ••••',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                _CarteFomatter(),
              ],
              maxLength: 19, // 16 chiffres + 3 espaces
              onChanged: (_) => setState(() {}),
              validator: (v) {
                final chiffres = (v ?? '').replaceAll(' ', '');
                if (chiffres.length != 16) return 'Entrez les 16 chiffres de votre carte.';
                return null;
              },
            ),
            const SizedBox(height: 4),
            TextFormField(
              controller: _titulaire,
              decoration: const InputDecoration(
                labelText: 'Titulaire de la carte',
                prefixIcon: Icon(Icons.person_outline),
                hintText: 'NOM PRÉNOM',
              ),
              textCapitalization: TextCapitalization.characters,
              onChanged: (_) => setState(() {}),
              validator: (v) {
                if ((v ?? '').trim().isEmpty) return 'Indiquez le nom du titulaire.';
                return null;
              },
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _expiration,
                    decoration: const InputDecoration(
                      labelText: 'Date d\'expiration',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                      hintText: 'MM/AA',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _ExpirationFormatter(),
                    ],
                    maxLength: 5,
                    validator: (v) {
                      final parts = (v ?? '').split('/');
                      if (parts.length != 2) return 'Format MM/AA';
                      final mois = int.tryParse(parts[0]) ?? 0;
                      if (mois < 1 || mois > 12) return 'Mois invalide';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _cvv,
                    decoration: const InputDecoration(
                      labelText: 'CVV',
                      prefixIcon: Icon(Icons.lock_outline),
                      hintText: '•••',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    maxLength: 3,
                    obscureText: true,
                    validator: (v) {
                      if ((v ?? '').length != 3) return '3 chiffres requis.';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            _AvertissementSimulation(),
            const SizedBox(height: 12),
            ErreurFormulaire(message: _error),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _etape = _Etape.choix),
                    child: const Text('Retour'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => _validerCarte(context),
                    child: const Text('Payer'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _validerCarte(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _error = '';
      _etape = _Etape.confirmation;
    });
  }

  // ── Étape 2a / 3 : récapitulatif avant confirmation finale ───────────────

  Widget _pageRecapitulatif(BuildContext context, Contrat contrat) {
    final aLivraison = _choix == ModePaiement.aLivraison;
    return DevisContratsFrame(
      title: aLivraison ? 'Confirmer la commande' : 'Confirmer le paiement',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _entete(context, contrat),
          const SizedBox(height: 20),
          _RecapBloc(
            icone: aLivraison ? Icons.local_shipping_outlined : Icons.credit_card_outlined,
            titre: aLivraison ? 'Paiement à la livraison' : 'Paiement en ligne',
            lignes: aLivraison
                ? [
                    'Vous réglerez en espèces à l\'arrivée du prestataire.',
                    'Le prestataire verra « Paiement à la livraison » sur le contrat.',
                  ]
                : [
                    'Carte : ${_masquerNumero(_numeroCarte.text)}',
                    'Le prestataire verra « Déjà payé » sur le contrat.',
                  ],
          ),
          const SizedBox(height: 16),
          ErreurFormulaire(message: _error),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() {
                    _etape = aLivraison ? _Etape.choix : _Etape.formulaireCarte;
                  }),
                  child: const Text('Retour'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => _confirmer(context),
                  child: Text(aLivraison ? 'Confirmer' : 'Confirmer le paiement'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmer(BuildContext context) {
    final choix = _choix;
    if (choix == null) return;
    final error = DevisStoreScope.of(context).choisirPaiement(widget.contratId, choix);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    if (context.mounted) Navigator.of(context).pop();
  }

  // ── Paiement déjà confirmé ───────────────────────────────────────────────

  Widget _pageConfirmee(BuildContext context, Contrat contrat) {
    final aLivraison = contrat.modePaiement == ModePaiement.aLivraison;
    return DevisContratsFrame(
      title: 'Paiement',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _entete(context, contrat),
          const SizedBox(height: 20),
          _RecapBloc(
            icone: aLivraison ? Icons.local_shipping_outlined : Icons.check_circle_outline,
            couleur: IndigoOrChart.succes,
            titre: labelModePaiement(contrat.modePaiement),
            lignes: aLivraison
                ? ['Le prestataire encaissera à son arrivée.']
                : ['Paiement enregistré. Le prestataire est notifié.'],
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Retour au contrat'),
          ),
        ],
      ),
    );
  }

  // ── Widgets partagés ─────────────────────────────────────────────────────

  Widget _entete(BuildContext context, Contrat contrat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contrat ${contrat.numero}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Text('Montant à régler : '),
            Text(
              formatDt(contrat.prixAccepte),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: IndigoOrChart.orTexte,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _masquerNumero(String numero) {
    final chiffres = numero.replaceAll(' ', '');
    if (chiffres.length < 4) return '•••• •••• •••• ••••';
    return '•••• •••• •••• ${chiffres.substring(chiffres.length - 4)}';
  }
}

// ── Widgets auxiliaires ────────────────────────────────────────────────────

class _ChoixPaiement extends StatelessWidget {
  const _ChoixPaiement({
    required this.titre,
    required this.detail,
    required this.icone,
    required this.selectionne,
    required this.onTap,
  });

  final String titre;
  final String detail;
  final IconData icone;
  final bool selectionne;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bordure = selectionne ? IndigoOrChart.primaire : IndigoOrChart.contour;
    return Material(
      color: selectionne ? IndigoOrChart.primaireConteneur : IndigoOrChart.surfaceHaute,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: bordure, width: selectionne ? 2 : 1),
          ),
          child: Row(
            children: [
              Icon(icone, color: IndigoOrChart.primaire),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titre, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(detail, style: const TextStyle(color: IndigoOrChart.texteMuted)),
                  ],
                ),
              ),
              if (selectionne)
                const Icon(Icons.check_circle, color: IndigoOrChart.primaire, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bloc de récapitulatif avec icône et liste de lignes d'information.
class _RecapBloc extends StatelessWidget {
  const _RecapBloc({
    required this.icone,
    required this.titre,
    required this.lignes,
    this.couleur,
  });

  final IconData icone;
  final String titre;
  final List<String> lignes;
  final Color? couleur;

  @override
  Widget build(BuildContext context) {
    final couleurEffective = couleur ?? IndigoOrChart.primaire;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: IndigoOrChart.surfaceHaute,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: IndigoOrChart.contourDiscret),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: couleurEffective.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icone, color: couleurEffective, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titre, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                for (final ligne in lignes)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      ligne,
                      style: const TextStyle(color: IndigoOrChart.texteMuted),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Représentation visuelle simplifiée de la carte.
class _CarteVisuelle extends StatelessWidget {
  const _CarteVisuelle({required this.numero, required this.titulaire});

  final String numero;
  final String titulaire;

  @override
  Widget build(BuildContext context) {
    final numAffiche = numero.isEmpty ? '•••• •••• •••• ••••' : numero.padRight(19, '•');
    final titAffiche = titulaire.trim().isEmpty ? 'TITULAIRE' : titulaire.toUpperCase();
    return Container(
      height: 140,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [IndigoOrChart.primaire, IndigoOrChart.secondaire],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.credit_card, color: IndigoOrChart.onPrimaire, size: 30),
          const Spacer(),
          Text(
            numAffiche,
            style: const TextStyle(
              color: IndigoOrChart.onPrimaire,
              fontSize: 18,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            titAffiche,
            style: const TextStyle(
              color: IndigoOrChart.onPrimaire,
              fontSize: 13,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Avertissement « simulation uniquement ».
class _AvertissementSimulation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: IndigoOrChart.orConteneur,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: IndigoOrChart.or.withAlpha(80)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: IndigoOrChart.orTexte, size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Mode démonstration — aucune donnée réelle n\'est transmise.',
              style: TextStyle(color: IndigoOrChart.orTexte, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Formateurs d'entrée ────────────────────────────────────────────────────

/// Insère un espace tous les 4 chiffres : 1234 5678 9012 3456.
class _CarteFomatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final chiffres = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (var i = 0; i < chiffres.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(chiffres[i]);
    }
    final texte = buffer.toString();
    return newValue.copyWith(
      text: texte,
      selection: TextSelection.collapsed(offset: texte.length),
    );
  }
}

/// Insère le séparateur / après les 2 premiers chiffres : MM/AA.
class _ExpirationFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final chiffres = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();
    for (var i = 0; i < chiffres.length && i < 4; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(chiffres[i]);
    }
    final texte = buffer.toString();
    return newValue.copyWith(
      text: texte,
      selection: TextSelection.collapsed(offset: texte.length),
    );
  }
}
