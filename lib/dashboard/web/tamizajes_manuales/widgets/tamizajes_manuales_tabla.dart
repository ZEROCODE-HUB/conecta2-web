import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/tamizajes/shared/tamizaje_utils.dart';
import '/tamizajes/shared/tamizajes_constants.dart';
import '/tamizajes/shared/widgets/agendar_recordatorio_dialog.dart';
import '/tamizajes/shared/widgets/confirmar_borrar_dialog.dart';
import '/tamizajes/shared/widgets/exportar_pdf_button.dart';
import '/tamizajes/shared/widgets/tamizaje_tabla_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tabla de tamizajes manuales para el dashboard web del profesional.
class TamizajesManualesTabla extends StatelessWidget {
  const TamizajesManualesTabla({
    super.key,
    required this.respuestas,
    required this.asignadosByRef,
    this.onVerDetalle,
  });

  final List<RespuestasRecord> respuestas;
  final Map<DocumentReference, UsersRecord> asignadosByRef;
  final void Function(RespuestasRecord respuesta, UsersRecord? adolescente)?
      onVerDetalle;

  @override
  Widget build(BuildContext context) {
    return TamizajeTablaWrapper(
      headerColumns: const [
        TamizajeColumna('Tamizaje', flex: 3),
        TamizajeColumna('Adolescente', flex: 3),
        TamizajeColumna('Estado', flex: 2),
        TamizajeColumna('Fecha', flex: 2),
        TamizajeColumna('Profesional', flex: 3),
        TamizajeColumna('Tipo', flex: 2),
        TamizajeColumna('Acciones', flex: 3),
      ],
      rowCount: respuestas.length,
      rowBuilder: (context, index) {
        final r = respuestas[index];
        final adolescente =
            asignadosByRef[r.userRespuesta ?? r.parentReference];
        return _FilaManual(
          respuesta: r,
          adolescente: adolescente,
          zebra: index.isOdd,
          onVerDetalle: onVerDetalle,
        );
      },
    );
  }
}

// ─── Fila individual ─────────────────────────────────────────────────────────

class _FilaManual extends StatefulWidget {
  const _FilaManual({
    required this.respuesta,
    required this.adolescente,
    this.zebra = false,
    this.onVerDetalle,
  });

  final RespuestasRecord respuesta;
  final UsersRecord? adolescente;
  final bool zebra;
  final void Function(RespuestasRecord, UsersRecord?)? onVerDetalle;

  @override
  State<_FilaManual> createState() => _FilaManualState();
}

class _FilaManualState extends State<_FilaManual> {
  bool _hover = false;

  bool _esManual() => widget.respuesta.tipoTamizaje == 'manual';

  @override
  Widget build(BuildContext context) {
    final respuesta = widget.respuesta;
    final adolescente = widget.adolescente;
    final theme = FlutterFlowTheme.of(context);

    return MouseRegion(
      cursor: widget.onVerDetalle != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onVerDetalle != null
            ? () => widget.onVerDetalle!(respuesta, adolescente)
            : null,
        child: Container(
          color: _hover
              ? kNavy.withValues(alpha: 0.06)
              : (widget.zebra ? const Color(0xFFFAFBFC) : Colors.transparent),
          child: Row(
            children: [
              // Tamizaje
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 10.0),
                  child: Text(
                    respuesta.titlo.isNotEmpty ? respuesta.titlo : '—',
                    style: theme.bodyMedium.override(
                      font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      letterSpacing: 0.0,
                    ),
                  ),
                ),
              ),
              // Adolescente
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(adolescente?.displayName ?? '—',
                      style: theme.bodyMedium),
                ),
              ),
              // Estado
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5F9F1),
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: kSuccess, width: 0.8),
                    ),
                    child: Text(
                      'Completado',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w600,
                          color: kSuccess),
                    ),
                  ),
                ),
              ),
              // Fecha
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    formatDate(respuesta.fecha),
                    style: theme.bodySmall.override(
                      font: GoogleFonts.inter(),
                      color: theme.secondaryText,
                      letterSpacing: 0.0,
                    ),
                  ),
                ),
              ),
              // Profesional
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: respuesta.realizadoPor != null
                      ? FutureBuilder<UsersRecord>(
                          future: UsersRecord.getDocumentOnce(
                              respuesta.realizadoPor!),
                          builder: (context, snap) {
                            return Text(
                              snap.data?.displayName ?? '—',
                              style: theme.bodySmall,
                            );
                          },
                        )
                      : Text('—', style: theme.bodySmall),
                ),
              ),
              // Tipo
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: _esManual()
                          ? const Color(0xFFE3F2FD)
                          : const Color(0xFFEDE7F6),
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: _esManual() ? kManualBlue : kAppPurple,
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      _esManual() ? 'Tamizaje Manual' : 'Tamizaje App',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: _esManual() ? kManualBlue : kAppPurple,
                      ),
                    ),
                  ),
                ),
              ),
              // Acciones
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 8.0),
                  child: Row(
                    children: [
                      if (widget.onVerDetalle != null) ...[
                        SizedBox(
                          height: 30,
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                widget.onVerDetalle!(respuesta, adolescente),
                            icon: const Icon(Icons.visibility_outlined,
                                size: 13.0),
                            label: const Text('Ver'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kNavy,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0),
                              textStyle: GoogleFonts.inter(
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w600),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6.0)),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6.0),
                      ],
                      Expanded(
                        child: ExportarPdfButton(
                          respuesta: respuesta,
                          adolescente: adolescente,
                          style: ExportarPdfStyle.web,
                        ),
                      ),
                      const SizedBox(width: 6.0),
                      _MenuTresPuntos(
                        respuesta: respuesta,
                        adolescente: adolescente,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Menú de 3 puntos ───────────────────────────────────────────────────────

class _MenuTresPuntos extends StatelessWidget {
  const _MenuTresPuntos({required this.respuesta, required this.adolescente});

  final RespuestasRecord respuesta;
  final UsersRecord? adolescente;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Más opciones',
      icon: const Icon(Icons.more_vert, size: 20, color: kNavy),
      onSelected: (v) {
        switch (v) {
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
            );
          case 'borrar':
            showConfirmarBorrarDialog(context, respuesta: respuesta);
        }
      },
      itemBuilder: (ctx) => const [
        PopupMenuItem(
          value: 'recordar',
          child: Row(
            children: [
              Icon(Icons.alarm, size: 16),
              SizedBox(width: 8),
              Text('Agendar recordatorio'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'borrar',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 16, color: Colors.red),
              SizedBox(width: 8),
              Text('Borrar', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }
}
