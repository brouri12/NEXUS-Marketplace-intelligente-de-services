import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_android_app/core/theme/indigo_or_chart.dart';
import 'package:flutter_android_app/gestions/utilisateurs/back/provider_profile.dart';
import 'package:flutter_android_app/gestions/utilisateurs/front/utilisateurs_frame.dart';
import 'package:flutter_android_app/gestions/utilisateurs/front/utilisateurs_routes.dart';

/// Création d'un compte client, prestataire, ou les deux.
class SignUpPage extends StatefulWidget {
  /// Affiche le formulaire d'inscription.
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _city = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _skill = TextEditingController();
  final _presentation = TextEditingController();
  final _rate = TextEditingController();
  final _skills = <String>{};
  final _days = <String>{};
  var _client = true;
  var _provider = false;
  var _service = '';
  var _error = '';
  var _pending = false;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    _city.dispose();
    _password.dispose();
    _confirm.dispose();
    _skill.dispose();
    _presentation.dispose();
    _rate.dispose();
    super.dispose();
  }

  void _submit() {
    if (_password.text != _confirm.text) {
      setState(() => _error = 'Les deux mots de passe ne correspondent pas.');
      return;
    }
    final error = StoreScope.of(context).signUp(
      firstName: _firstName.text,
      lastName: _lastName.text,
      email: _email.text,
      phone: _phone.text,
      city: _city.text,
      password: _password.text,
      client: _client,
      provider: _provider,
      service: _service,
      skills: _skills.toList(),
      hourlyRate: _rate.text,
      availability: [
        for (final day in providerDays)
          if (_days.contains(day)) day,
      ],
      presentation: _presentation.text,
    );
    if (!mounted) return;
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    if (StoreScope.of(context).current == null) {
      setState(() => _pending = true);
    }
  }

  void _addSkill() {
    final value = _skill.text.trim();
    if (value.isEmpty) return;
    setState(() {
      _skills.add(value);
      _skill.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final suggestions = skillsByTrade[_service] ?? const <String>[];

    return UtilisateursFrame(
      title: 'Inscription',
      child: _pending
          ? ListView(
              children: [
                const SizedBox(height: 24),
                const Icon(Icons.hourglass_top_outlined, size: 40),
                const SizedBox(height: 16),
                Text('Confirmation requise', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                const Text(
                  'Votre compte prestataire est envoyé. Un administrateur doit le confirmer avant la connexion.',
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => openUtilisateursPage(context, UtilisateursRoutes.signIn),
                  child: const Text('Retour à la connexion'),
                ),
              ],
            )
          : ListView(
        children: [
          Text('Votre compte', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          TextField(
            key: const Key('sign-up-first-name'),
            controller: _firstName,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Prénom',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _lastName,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Nom',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'E-mail',
              prefixIcon: Icon(Icons.mail_outline),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Téléphone',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _city,
            decoration: const InputDecoration(
              labelText: 'Ville',
              prefixIcon: Icon(Icons.location_city_outlined),
              helperText: 'Vide : Tunis sera enregistré.',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _password,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Mot de passe',
              prefixIcon: Icon(Icons.lock_outline),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _confirm,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Confirmation',
              prefixIcon: Icon(Icons.lock_outline),
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Client'),
            subtitle: Text(
              _provider
                  ? 'Un prestataire peut aussi décrire un besoin.'
                  : 'Décrire un besoin et demander un devis.',
            ),
            value: _provider || _client,
            onChanged: _provider ? null : (value) => setState(() => _client = value),
          ),
          SwitchListTile(
            key: const Key('sign-up-provider'),
            contentPadding: EdgeInsets.zero,
            title: const Text('Prestataire'),
            subtitle: const Text(
              'Le compte reste fermé tant qu\'un administrateur ne l\'a pas confirmé.',
            ),
            value: _provider,
            onChanged: (value) => setState(() {
              _provider = value;
              if (value) _client = true;
            }),
          ),
          if (_provider) ...[
            const SizedBox(height: 8),
            _ProviderSection(
              service: _service,
              suggestions: suggestions,
              skills: _skills,
              days: _days,
              skill: _skill,
              rate: _rate,
              presentation: _presentation,
              onService: (value) => setState(() => _service = value),
              onToggleSkill: (skill, selected) {
                setState(() {
                  if (selected) {
                    _skills.add(skill);
                  } else {
                    _skills.remove(skill);
                  }
                });
              },
              onAddSkill: _addSkill,
              onToggleDay: (day, selected) {
                setState(() {
                  if (selected) {
                    _days.add(day);
                  } else {
                    _days.remove(day);
                  }
                });
              },
            ),
          ],
          const SizedBox(height: 8),
          FormErrorText(message: _error),
          FilledButton.icon(
            key: const Key('sign-up-submit'),
            onPressed: _submit,
            icon: const Icon(Icons.person_add_outlined),
            label: const Text('Créer le compte'),
          ),
        ],
      ),
    );
  }
}

class _ProviderSection extends StatelessWidget {
  const _ProviderSection({
    required this.service,
    required this.suggestions,
    required this.skills,
    required this.days,
    required this.skill,
    required this.rate,
    required this.presentation,
    required this.onService,
    required this.onToggleSkill,
    required this.onAddSkill,
    required this.onToggleDay,
  });

  final String service;
  final List<String> suggestions;
  final Set<String> skills;
  final Set<String> days;
  final TextEditingController skill;
  final TextEditingController rate;
  final TextEditingController presentation;
  final ValueChanged<String> onService;
  final void Function(String skill, bool selected) onToggleSkill;
  final VoidCallback onAddSkill;
  final void Function(String day, bool selected) onToggleDay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extras = [
      for (final item in skills)
        if (!suggestions.contains(item)) item,
    ];

    return Card(
      color: IndigoOrChart.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Informations prestataire', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            const Text('Ces informations apparaissent dans les services disponibles.'),
            const SizedBox(height: 16),
            Text('Métier', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final trade in providerTrades)
                  ChoiceChip(
                    label: Text(trade),
                    selected: service == trade,
                    onSelected: (_) => onService(trade),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Compétences', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            if (suggestions.isEmpty)
              const Text('Choisissez d\'abord un métier, ou ajoutez une compétence.')
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final item in suggestions)
                    FilterChip(
                      label: Text(item),
                      selected: skills.contains(item),
                      onSelected: (selected) => onToggleSkill(item, selected),
                    ),
                  for (final item in extras)
                    FilterChip(
                      label: Text(item),
                      selected: true,
                      onSelected: (selected) => onToggleSkill(item, selected),
                    ),
                ],
              ),
            const SizedBox(height: 8),
            TextField(
              key: const Key('sign-up-skill'),
              controller: skill,
              decoration: InputDecoration(
                labelText: 'Autre compétence',
                prefixIcon: const Icon(Icons.sell_outlined),
                suffixIcon: IconButton(
                  tooltip: 'Ajouter',
                  onPressed: onAddSkill,
                  icon: const Icon(Icons.add),
                ),
              ),
              onSubmitted: (_) => onAddSkill(),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('sign-up-rate'),
              controller: rate,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Tarif horaire',
                prefixIcon: Icon(Icons.payments_outlined),
                suffixText: 'TND',
              ),
            ),
            const SizedBox(height: 16),
            Text('Disponibilités', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final day in providerDays)
                  FilterChip(
                    label: Text(day),
                    selected: days.contains(day),
                    onSelected: (selected) => onToggleDay(day, selected),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: presentation,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Présentation',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.notes_outlined),
                helperText: 'Facultatif. Décrivez comment vous intervenez.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
