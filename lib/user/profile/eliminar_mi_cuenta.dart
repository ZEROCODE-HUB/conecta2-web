import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/user/registration/sesion_app.dart';

/// "Eliminar mi cuenta" (requisito de Google Play). Pide confirmación y
/// llama a la Cloud Function `eliminarMiCuenta`, que borra la cuenta de
/// acceso, el perfil, las respuestas y las emociones del usuario, y lo
/// desvincula de sus adolescentes (acudiente) o pacientes (profesional).
Future<void> eliminarMiCuenta(BuildContext context) async {
  final theme = FlutterFlowTheme.of(context);
  final rol = valueOrDefault(currentUserDocument?.rol, '');
  final detalle = switch (rol) {
    FFAppConstants.acudiente =>
      'Se borrarán tu perfil y tus respuestas, y se quitará el vínculo con '
          'tus adolescentes.',
    FFAppConstants.Profesional =>
      'Se borrarán tu perfil y tus respuestas, y tus pacientes quedarán sin '
          'profesional asignado.',
    _ => 'Se borrarán tu perfil, tus respuestas de tamizajes y encuestas y tu '
        'calendario de emociones.',
  };

  final confirmado = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('¿Eliminar tu cuenta?'),
      content: Text('$detalle\n\nEsta acción no se puede deshacer.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: TextButton.styleFrom(foregroundColor: theme.error),
          child: const Text('Eliminar definitivamente'),
        ),
      ],
    ),
  );
  if (confirmado != true || !context.mounted) return;

  final messenger = ScaffoldMessenger.of(context);
  final router = GoRouter.of(context);
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const PopScope(
      canPop: false,
      child: Center(child: CircularProgressIndicator()),
    ),
  );

  try {
    await FirebaseFunctions.instance.httpsCallable('eliminarMiCuenta').call();
  } catch (e) {
    if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
    final motivo =
        e is FirebaseFunctionsException ? (e.message ?? e.code) : '$e';
    messenger.showSnackBar(
      SnackBar(
        content: Text('No se pudo eliminar tu cuenta: $motivo'),
        backgroundColor: theme.error,
        duration: const Duration(seconds: 6),
      ),
    );
    return;
  }

  if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
  router.prepareAuthEvent();
  await authManager.signOut();
  limpiarSesionApp();
  router.clearRedirectLocation();
  messenger.showSnackBar(
    const SnackBar(content: Text('Tu cuenta fue eliminada.')),
  );
  if (!context.mounted) return;
  context.goNamedAuth(SplashWidget.routeName, context.mounted);
}
