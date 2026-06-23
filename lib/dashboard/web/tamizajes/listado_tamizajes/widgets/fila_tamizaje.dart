import '/backend/backend.dart';
import '/components/rich_text_notas/rich_text_notas_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/tamizajes/shared/tamizaje_utils.dart';
import '/tamizajes/shared/tamizajes_constants.dart';
import '/tamizajes/shared/widgets/exportar_pdf_button.dart';
import '/tamizajes/shared/widgets/notas_profesional_dialog.dart';
import 'invalidar_boton.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Fila individual de un tamizaje en la tabla admin del dashboard.
/// Clickeable para ver el detalle completo.
class FilaTamizaje extends StatefulWidget {
  const FilaTamizaje({
    super.key,
    required this.respuesta,
    required this.hayIdeacion,
    this.onVerDetalle,
    this.zebra = false,
  });

  final RespuestasRecord respuesta;
  final bool hayIdeacion;
  final void Function(RespuestasRecord)? onVerDetalle;
  final bool zebra;

  @override
  State<FilaTamizaje> createState() => _FilaTamizajeState();
}

class _FilaTamizajeState extends State<FilaTamizaje> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final respuesta = widget.respuesta;

    return MouseRegion(
      cursor: widget.onVerDetalle != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onVerDetalle != null
            ? () => widget.onVerDetalle!(respuesta)
            : null,
        child: Container(
          color: _hover
              ? kNavy.withValues(alpha: 0.06)
              : (widget.zebra
                  ? const Color(0xFFFAFBFC)
                  : Colors.transparent),
          child: Row(
            children: [
              // Paciente
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      respuesta.userRespuesta != null
                          ? FutureBuilder<UsersRecord>(
                              future: UsersRecord.getDocumentOnce(
                                  respuesta.userRespuesta!),
                              builder: (context, snap) {
                                return Text(
                                  snap.data?.displayName ?? '—',
                                  style: theme.bodyMedium.override(
                                    font: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600),
                                    letterSpacing: 0.0,
                                  ),
                                );
                              },
                            )
                          : Text(
                              'Desconocido',
                              style: theme.bodyMedium.override(
                                font: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600),
                                letterSpacing: 0.0,
                              ),
                            ),
                      if (widget.hayIdeacion ||
                          respuesta.alertasEspeciales.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Wrap(
                            spacing: 4.0,
                            runSpacing: 4.0,
                            children: [
                              if (widget.hayIdeacion)
                                _AlertBadge(
                                  text: '⚠ Ideación',
                                  bgColor: const Color(0xFFFFC4C4),
                                  borderColor: Colors.red.shade300,
                                  textColor: Colors.red.shade700,
                                ),
                              if (respuesta.alertasEspeciales.isNotEmpty)
                                _AlertBadge(
                                  text: '⚠ Alerta Clínica',
                                  bgColor: const Color(0xFFFFE0A8),
                                  borderColor: Colors.orange.shade300,
                                  textColor: Colors.orange.shade800,
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Tamizaje
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    respuesta.titlo.isNotEmpty ? respuesta.titlo : '—',
                    style: theme.bodyMedium.override(
                        font: GoogleFonts.inter(), letterSpacing: 0.0),
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
              // Puntaje
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    '${respuesta.puntajeTotal}',
                    style: theme.bodyMedium.override(
                      font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      letterSpacing: 0.0,
                    ),
                  ),
                ),
              ),
              // Notas
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          respuesta.notasProfesional.isNotEmpty
                              ? quillDeltaToPlainText(
                                  respuesta.notasProfesional)
                              : '—',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.bodySmall.override(
                            font: GoogleFonts.inter(),
                            color: theme.secondaryText,
                            letterSpacing: 0.0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4.0),
                      InkWell(
                        onTap: () => showNotasProfesionalDialog(
                          context,
                          respuesta: respuesta,
                        ),
                        borderRadius: BorderRadius.circular(4.0),
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Icon(Icons.edit_note,
                              size: 18.0, color: theme.primary),
                        ),
                      ),
                    ],
                  ),
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
                      color: respuesta.invalidado
                          ? const Color(0xFFFFC4C4)
                          : const Color(0xFFE5F9F1),
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: respuesta.invalidado ? kDanger : kSuccess,
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      respuesta.invalidado ? 'Invalidado' : 'Completado',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 11.0,
                        fontWeight: FontWeight.w600,
                        color: respuesta.invalidado ? kDanger : kSuccess,
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
                      // Botón Ver detalle
                      if (widget.onVerDetalle != null) ...[
                        SizedBox(
                          height: 30,
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                widget.onVerDetalle!(respuesta),
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
                          style: ExportarPdfStyle.web,
                        ),
                      ),
                      const SizedBox(width: 6.0),
                      Expanded(
                        child: InvalidarBoton(respuesta: respuesta),
                      ),
                      const SizedBox(width: 6.0),
                      IconButton(
                        tooltip: 'Eliminar',
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20.0),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Eliminar Tamizaje'),
                              content: const Text('¿Está seguro de eliminar este tamizaje? Esta acción no se puede deshacer.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancelar'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await respuesta.reference.delete();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Tamizaje eliminado correctamente.')),
                              );
                            }
                          }
                        },
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

class _AlertBadge extends StatelessWidget {
  const _AlertBadge({
    required this.text,
    required this.bgColor,
    required this.borderColor,
    required this.textColor,
  });

  final String text;
  final Color bgColor;
  final Color borderColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 10.0,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
