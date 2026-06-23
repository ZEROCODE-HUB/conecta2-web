import '/backend/backend.dart';
import '/dashboard/web/usuarios/model/eliminar/eliminar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/custom_code/actions/index.dart' as actions;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

/// Three-dot popup menu replacing the previous edit/delete/print icons.
///
/// Options:
/// - "Editar" / "Eliminar": perfil admin.
/// - "Reporte": PDF branded con cards por tamizaje y factores de alerta
///   (usa `generarInformeIndividualPDF`).
/// - "Imprimir": PDF legacy con tabla cruda de respuestas y resumen de
///   riesgo (usa `generarImprimirPDF`).
class UsuarioActionsMenu extends StatelessWidget {
  const UsuarioActionsMenu({
    super.key,
    required this.user,
    required this.onEditar,
  });

  final UsersRecord user;

  /// Called when "Editar" is selected. The parent widget is responsible for
  /// setting FFAppState / model fields and switching the screen because it
  /// owns those references.
  final VoidCallback onEditar;

  void _handleSelection(BuildContext context, String value) async {
    switch (value) {
      case 'editar':
        if (user.rol == 'Administrador') {
          _showAdminError(context, 'no puedo abrirlo');
          return;
        }
        onEditar();
        break;

      case 'eliminar':
        if (user.rol == 'Administrador') {
          _showAdminError(context, 'No se puede eliminar');
          return;
        }
        await showModalBottomSheet(
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          context: context,
          builder: (ctx) {
            return WebViewAware(
              child: Padding(
                padding: MediaQuery.viewInsetsOf(ctx),
                child: EliminarWidget(
                  userreference: user.reference,
                ),
              ),
            );
          },
        );
        break;

      case 'reporte':
        final respuestas = await queryRespuestasRecordOnce(
          queryBuilder: (respuestasRecord) =>
              respuestasRecord.where('User_respuesta', isEqualTo: user.reference),
          singleRecord: true,
        );

        if (respuestas.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'El usuario aún no ha respondido o diligenciado ningún tamizaje.',
                style: TextStyle(
                  color: FlutterFlowTheme.of(context).primaryBackground,
                ),
              ),
              backgroundColor: FlutterFlowTheme.of(context).error,
              duration: const Duration(seconds: 3),
            ),
          );
          return;
        }

        // Reporte branded con cards por tamizaje, factores de alerta,
        // observaciones y logo IPS.
        await actions.generarInformeIndividualPDF(user.reference.id);
        break;

      case 'imprimir':
        // PDF legacy: tabla cruda de respuestas con analisis por
        // dimensiones y nivel de riesgo. Formato clinico simple.
        await actions.generarImprimirPDF(user.reference.id);
        break;
    }
  }

  void _showAdminError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: FlutterFlowTheme.of(context).primaryBackground,
          ),
        ),
        duration: const Duration(milliseconds: 4000),
        backgroundColor: const Color(0xFF265294),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Opciones',
      icon: Icon(
        Icons.more_vert,
        color: FlutterFlowTheme.of(context).accent2,
        size: 26.0,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      onSelected: (value) => _handleSelection(context, value),
      itemBuilder: (context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'editar',
          child: _menuRow(
            context,
            icon: Icons.edit_sharp,
            label: 'Editar',
          ),
        ),
        PopupMenuItem<String>(
          value: 'eliminar',
          child: _menuRow(
            context,
            icon: Icons.delete,
            label: 'Eliminar',
          ),
        ),
        PopupMenuItem<String>(
          value: 'reporte',
          child: _menuRow(
            context,
            icon: Icons.assignment_outlined,
            label: 'Reporte',
          ),
        ),
        PopupMenuItem<String>(
          value: 'imprimir',
          child: _menuRow(
            context,
            icon: Icons.print,
            label: 'Imprimir',
          ),
        ),
      ],
    );
  }

  Widget _menuRow(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFF265294), size: 22.0),
        const SizedBox(width: 12.0),
        Text(
          label,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.inter(fontWeight: FontWeight.w500),
                fontSize: 14.0,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
