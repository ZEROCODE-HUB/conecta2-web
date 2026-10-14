import '/auth/firebase_auth/auth_util.dart';
import 'sesion_app.dart';
import 'package:flutter/material.dart';

/// Alta a medias: la cuenta de Firebase Auth se creó pero falló el `set()`
/// del perfil en `users`. Borra la cuenta recién creada para no dejar el
/// correo bloqueado ("ya está registrado") y avisa al usuario.
Future<void> revertirAltaIncompleta(
  BuildContext context,
  BaseAuthUser user,
  Object error,
) async {
  try {
    await user.delete();
  } catch (_) {}
  try {
    await authManager.signOut();
  } catch (_) {}
  limpiarSesionApp();
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
          'No se pudo completar el registro. Intenta de nuevo. ($error)'),
      duration: const Duration(seconds: 6),
    ),
  );
}
