import 'package:flutter/material.dart';
import 'package:flutter_android_app/core/theme/indigo_or_chart.dart';

class LogistiqueCreatePage extends StatefulWidget {
  const LogistiqueCreatePage({super.key});

  @override
  State<LogistiqueCreatePage> createState() => _LogistiqueCreatePageState();
}

class _LogistiqueCreatePageState extends State<LogistiqueCreatePage> {
  // Clé pour valider le formulaire
  final _formKey = GlobalKey<FormState>();
  final _departController = TextEditingController();
  final _arriveeController = TextEditingController();

  void _submitForm() {
    // Vérification de la validation des inputs utilisateur
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nouveau trajet initialisé avec succès !'),
          backgroundColor: IndigoOrChart.succes,
        ),
      );
      Navigator.pop(context); // Retour à la liste via le Navigator
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouveau Trajet'),
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
              
              // Input 1: Point de départ
              TextFormField(
                controller: _departController,
                decoration: InputDecoration(
                  labelText: 'Point de départ',
                  prefixIcon: const Icon(Icons.location_on_outlined, color: IndigoOrChart.secondaire),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: IndigoOrChart.or, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le point de départ est obligatoire';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Input 2: Destination
              TextFormField(
                controller: _arriveeController,
                decoration: InputDecoration(
                  labelText: 'Destination',
                  prefixIcon: const Icon(Icons.flag_outlined, color: IndigoOrChart.or),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: IndigoOrChart.or, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La destination est obligatoire';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 32),
              
              // Bouton de soumission
              FilledButton(
                onPressed: _submitForm,
                child: const Text('Démarrer le trajet'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _departController.dispose();
    _arriveeController.dispose();
    super.dispose();
  }
}
