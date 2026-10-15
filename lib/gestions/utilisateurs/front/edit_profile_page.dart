import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_android_app/core/theme/indigo_or_chart.dart';
import 'package:flutter_android_app/gestions/utilisateurs/back/provider_profile.dart';
import 'package:flutter_android_app/gestions/utilisateurs/back/user_account.dart';
import 'package:flutter_android_app/gestions/utilisateurs/front/utilisateurs_frame.dart';
import 'package:flutter_android_app/gestions/utilisateurs/front/utilisateurs_routes.dart';

/// Modification du nom, de l'e-mail, du téléphone et de la ville.
class EditProfilePage extends StatefulWidget {
  /// Affiche le formulaire du compte ouvert, ou de [userId] si un admin l'ouvre.
  const EditProfilePage({super.key, this.userId});

  /// Compte à modifier. Vide : le compte de la session.
  final String? userId;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _city;
  late final TextEditingController _rate;
  late final TextEditingController _presentation;
  late final TextEditingController _skill;
  final _skills = <String>{};
  final _days = <String>{};
  var _service = '';
  var _ready = false;
  var _error = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ready) return;
    final store = StoreScope.of(context);
    final user = widget.userId == null ? store.current : store.find(widget.userId!);
    _firstName = TextEditingController(text: user?.firstName ?? '');
    _lastName = TextEditingController(text: user?.lastName ?? '');
    _email = TextEditingController(text: user?.email ?? '');
    _phone = TextEditingController(text: user?.phone ?? '');
    _city = TextEditingController(text: user?.city ?? '');
    final profile = user?.providerProfile;
    _service = profile?.service ?? '';
    _skills.addAll(profile?.skills ?? const []);
    _days.addAll(profile?.availability ?? const []);
    _rate = TextEditingController(text: profile == null ? '' : '${profile.hourlyRate}');
    _presentation = TextEditingController(text: profile?.presentation ?? '');
    _skill = TextEditingController();
    _ready = true;
  }

  @override
  void dispose() {
    if (_ready) {
      _firstName.dispose();
      _lastName.dispose();
      _email.dispose();
      _phone.dispose();
      _city.dispose();
      _rate.dispose();
      _presentation.dispose();
      _skill.dispose();
    }
    super.dispose();
  }

  void _save() {
    final store = StoreScope.of(context);
    final skills = _skills.toList();
    final availability = [
      for (final day in providerDays)
        if (_days.contains(day)) day,
    ];
    final error = widget.userId == null
        ? store.updateProfile(
            firstName: _firstName.text,
            lastName: _lastName.text,
            phone: _phone.text,
            city: _city.text,
            service: _service,
            skills: skills,
            hourlyRate: _rate.text,
            availability: availability,
            presentation: _presentation.text,
          )
        : store.updateAccount(
            id: widget.userId!,
            firstName: _firstName.text,
            lastName: _lastName.text,
            email: _email.text,
            phone: _phone.text,
            city: _city.text,
            service: _service,
            skills: skills,
            hourlyRate: _rate.text,
            availability: availability,
            presentation: _presentation.text,
          );
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final target = widget.userId == null ? store.current : store.find(widget.userId!);
    final allowed = widget.userId == null
        ? store.current != null
        : (store.current?.hasRole(UserRole.admin) ?? false) && target != null;
    if (!allowed || target == null) {
      return UtilisateursFrame(
        title: 'Modifier le compte',
        child: ListView(
          children: const [Text('Ce compte n\'est pas accessible.')],
        ),
      );
    }

    return UtilisateursFrame(
      title: widget.userId == null ? 'Modifier le profil' : 'Modifier ${target.fullName}',
      child: ListView(
        children: [
          TextField(
            key: const Key('edit-first-name'),
            controller: _firstName,
            decoration: const InputDecoration(labelText: 'Prénom'),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('edit-last-name'),
            controller: _lastName,
            decoration: const InputDecoration(labelText: 'Nom'),
          ),
          if (widget.userId != null) ...[
            const SizedBox(height: 12),
            TextField(
              key: const Key('edit-email'),
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'E-mail'),
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            key: const Key('edit-phone'),
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Téléphone'),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('edit-city'),
            controller: _city,
            decoration: const InputDecoration(
              labelText: 'Ville',
              helperText: 'Utilisée si une demande ne précise pas le lieu.',
            ),
          ),
          if (target.hasRole(UserRole.provider) || target.providerProfile != null) ...[
            const SizedBox(height: 16),
            _ProviderEditor(
              service: _service,
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
              onAddSkill: () {
                final value = _skill.text.trim();
                if (value.isEmpty) return;
                setState(() {
                  _skills.add(value);
                  _skill.clear();
                });
              },
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
          const SizedBox(height: 16),
          FormErrorText(message: _error),
          FilledButton(onPressed: _save, child: const Text('Enregistrer')),
        ],
      ),
    );
  }
}

class _ProviderEditor extends StatelessWidget {
  const _ProviderEditor({
    required this.service,
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
    final suggestions = skillsByTrade[service] ?? const <String>[];
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
            Text('Informations prestataire', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Text('Métier', style: Theme.of(context).textTheme.titleSmall),
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
            Text('Compétences', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
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
              controller: skill,
              decoration: InputDecoration(
                labelText: 'Autre compétence',
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
              key: const Key('edit-rate'),
              controller: rate,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Tarif horaire',
                suffixText: 'TND',
              ),
            ),
            const SizedBox(height: 16),
            Text('Disponibilités', style: Theme.of(context).textTheme.titleSmall),
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
              key: const Key('edit-presentation'),
              controller: presentation,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Présentation',
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
