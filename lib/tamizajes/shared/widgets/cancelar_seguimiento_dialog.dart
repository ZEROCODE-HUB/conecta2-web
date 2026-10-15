import '/backend/backend.dart';
import '/tamizajes/shared/tamizajes_constants.dart';
import 'package:flutter/material.dart';

/// Pide confirmación y borra un recordatorio de seguimiento pendiente
/// (colección `reminders`). Lo usan la sección web "Recordatorios" y la
/// lista móvil del profesional. Retorna `true` si se canceló.
Future<bool> confirmarCancelarSeguimiento(
  BuildContext context, {
  required RemindersRecord recordatorio,
  required String pacienteNombre,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Cancelar recordatorio'),
      content: Text(
        '¿Cancelar el recordatorio "${recordatorio.title}" para '
        '$pacienteNombre? No se enviará y se eliminará de la lista.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Volver'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: kDanger,
            foregroundColor: Colors.white,
          ),
          child: const Text('Cancelar recordatorio'),
        ),
      ],
    ),
  );
  if (ok != true) return false;
  try {
    await recordatorio.reference.delete();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recordatorio cancelado')),
      );
    }
    return true;
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo cancelar: $e')),
      );
    }
    return false;
  }
}
