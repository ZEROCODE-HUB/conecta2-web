import '/backend/backend.dart';
import '/tamizajes/shared/tamizajes_constants.dart';
import '/tamizajes/shared/widgets/agendar_recordatorio_dialog.dart';
import '/tamizajes/shared/widgets/confirmar_borrar_dialog.dart';
import '/tamizajes/shared/widgets/notas_profesional_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Menú de 3 puntos para acciones sobre un tamizaje (mobile).
///
/// Opciones: Notas profesional, Agendar recordatorio, Borrar.
class TamizajeActionsMenuMobile extends StatelessWidget {
  const TamizajeActionsMenuMobile({
    super.key,
    required this.respuesta,
    required this.adolescente,
  });

  final RespuestasRecord respuesta;
  final UsersRecord? adolescente;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Más opciones',
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      offset: const Offset(0, 40),
      icon: Container(
        width: 40.0,
        height: 40.0,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F3F3),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: const Icon(Icons.more_vert, size: 20.0, color: kNavy),
      ),
      onSelected: (v) {
        switch (v) {
          case 'notas':
            showNotasProfesionalDialog(
              context,
              respuesta: respuesta,
              pacienteNombre: adolescente?.displayName,
            );
          case 'recordar':
            showAgendarRecordatorioDialog(
              context,
              // Las respuestas manuales cuelgan de Encuestas/{id}: el
              // destinatario es userRespuesta, no el documento padre.
              adolescenteRef:
                  adolescente?.reference ?? respuesta.userRespuesta,
              encuestaRef: respuesta.parentReference,
              tituloDefault: 'Seguimiento ${respuesta.titlo}',
              pacienteNombre: adolescente?.displayName,
              useBottomSheet: true,
            );
          case 'borrar':
            showConfirmarBorrarDialog(context, respuesta: respuesta);
        }
      },
      itemBuilder: (ctx) => [
        PopupMenuItem(
          value: 'notas',
          child: Row(
            children: [
              const Icon(Icons.edit_note, size: 18.0, color: kNavy),
              const SizedBox(width: 10.0),
              Text(
                'Notas profesional',
                style: GoogleFonts.inter(
                    fontSize: 14.0, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'recordar',
          child: Row(
            children: [
              const Icon(Icons.alarm, size: 18.0, color: kNavy),
              const SizedBox(width: 10.0),
              Text(
                'Agendar recordatorio',
                style: GoogleFonts.inter(
                    fontSize: 14.0, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'borrar',
          child: Row(
            children: [
              const Icon(Icons.delete_outline, size: 18.0, color: Colors.red),
              const SizedBox(width: 10.0),
              Text(
                'Borrar',
                style: GoogleFonts.inter(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
