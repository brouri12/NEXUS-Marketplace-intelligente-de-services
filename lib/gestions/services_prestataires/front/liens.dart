import 'package:flutter/material.dart';

/// Dit vers quelle gestion une action part, tant que son écran n'existe pas.
Future<void> montrerLienGestion(
  BuildContext context, {
  required String gestion,
  required String message,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(gestion),
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      );
    },
  );
}
