import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import '/user/profile/eliminar_mi_cuenta.dart';
import '/user/registration/sesion_app.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Acciones al pie del perfil móvil (adolescente, acudiente y profesional):
/// Guardar cambios y Cerrar sesión destacados, Restaurar contraseña
/// secundario y "Eliminar mi cuenta" discreto al final.
class PerfilAcciones extends StatelessWidget {
  const PerfilAcciones({
    super.key,
    required this.onGuardar,
    required this.onRestaurar,
  });

  final Future<void> Function() onGuardar;
  final Future<void> Function() onRestaurar;

  Future<void> _cerrarSesion(BuildContext context) async {
    GoRouter.of(context).prepareAuthEvent();
    await authManager.signOut();
    limpiarSesionApp();
    GoRouter.of(context).clearRedirectLocation();
    if (!context.mounted) return;
    context.goNamedAuth(SplashWidget.routeName, context.mounted);
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    FFButtonOptions estilo({required bool relleno}) => FFButtonOptions(
          width: double.infinity,
          height: 57.0,
          padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
          iconPadding: EdgeInsetsDirectional.zero,
          iconColor: relleno ? theme.primaryBackground : theme.accent2,
          color: relleno ? theme.accent2 : Colors.transparent,
          textStyle: GoogleFonts.outfit(
            color: relleno ? theme.primaryBackground : theme.accent2,
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0.0,
          borderSide: relleno
              ? null
              : BorderSide(color: theme.accent2, width: 1.0),
          borderRadius: BorderRadius.circular(40.0),
        );

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 32.0, 0.0, 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FFButtonWidget(
            onPressed: onGuardar,
            text: 'Guardar cambios',
            options: estilo(relleno: true),
          ),
          const SizedBox(height: 12.0),
          FFButtonWidget(
            onPressed: () => _cerrarSesion(context),
            text: 'Cerrar sesión',
            icon: const Icon(Icons.logout, size: 22.0),
            options: estilo(relleno: false),
          ),
          const SizedBox(height: 12.0),
          FFButtonWidget(
            onPressed: onRestaurar,
            text: 'Restaurar contraseña',
            icon: const Icon(Icons.lock_reset, size: 22.0),
            options: estilo(relleno: false),
          ),
          const SizedBox(height: 24.0),
          TextButton.icon(
            onPressed: () => eliminarMiCuenta(context),
            icon: Icon(Icons.delete_outline,
                size: 16.0, color: theme.secondaryText),
            label: Text(
              'Eliminar mi cuenta',
              style: GoogleFonts.inter(
                color: theme.secondaryText,
                fontSize: 13.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
