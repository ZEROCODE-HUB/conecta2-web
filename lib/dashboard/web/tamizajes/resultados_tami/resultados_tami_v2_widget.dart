import '/backend/backend.dart';
import '/components/admin_estadsticas/helpers/classification.dart';
import '/dashboard/web/encuestas/editar/widgets/tamizajes_niveles.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/tamizajes/shared/tamizaje_service.dart';
import '/tamizajes/shared/tamizaje_utils.dart';
import '/tamizajes/shared/tamizajes_constants.dart';
import '/tamizajes/shared/widgets/detalle_tamizaje_view.dart';
import '/tamizajes/shared/widgets/tamizaje_page_header.dart';
import '/tamizajes/shared/widgets/tamizaje_empty_state.dart';
import '/tamizajes/shared/widgets/tamizaje_paginador.dart';
import '/tamizajes/shared/widgets/exportar_pdf_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Vista de resultados de un tamizaje específico (template).
///
/// Muestra todas las respuestas completadas para un tamizaje dado,
/// con diseño limpio, botón volver, y click en cada respuesta para
/// ver el detalle completo.
class ResultadosTamiV2Widget extends StatefulWidget {
  const ResultadosTamiV2Widget({
    super.key,
    required this.encuestaID,
    this.onClose,
  });

  final DocumentReference encuestaID;
  final VoidCallback? onClose;

  @override
  State<ResultadosTamiV2Widget> createState() => _ResultadosTamiV2WidgetState();
}

class _ResultadosTamiV2WidgetState extends State<ResultadosTamiV2Widget> {
  RespuestasRecord? _detalleRespuesta;
  int _paginaActual = 0;

  void _cerrarDetalle() => setState(() => _detalleRespuesta = null);

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final enDetalle = _detalleRespuesta != null;

    Widget content;
    if (enDetalle) {
      content = DetalleTamizajeView(
        key: const ValueKey('detalle'),
        respuesta: _detalleRespuesta!,
        onVolver: _cerrarDetalle,
      );
    } else {
      content = _buildListaResultados(theme);
    }

    return PopScope(
      canPop: !enDetalle,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && enDetalle) _cerrarDetalle();
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: content,
      ),
    );
  }

  Widget _buildListaResultados(FlutterFlowTheme theme) {
    return Container(
      key: const ValueKey('lista'),
      width: double.infinity,
      height: double.infinity,
      color: theme.primaryBackground,
      child: StreamBuilder<EncuestasRecord>(
        stream: EncuestasRecord.getDocument(widget.encuestaID),
        builder: (context, encuestaSnap) {
          final encuesta = encuestaSnap.data;

          return Column(
            children: [
              // ── Header ─────────────────────────────────────────────
              TamizajePageHeader(
                titulo: encuesta?.titulo ?? 'Resultados del Tamizaje',
                breadcrumb: 'Volver a Tamizajes',
                onVolver: () {
                  if (widget.onClose != null) {
                    widget.onClose!();
                  } else if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
                icon: Icons.quiz_outlined,
                badge: encuesta != null && encuesta.categoria.isNotEmpty
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: kNavy.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Text(
                          encuesta.categoria,
                          style: GoogleFonts.inter(
                            color: kNavy,
                            fontWeight: FontWeight.w600,
                            fontSize: 11.0,
                          ),
                        ),
                      )
                    : null,
              ),

              // ── Lista de respuestas ────────────────────────────────
              Expanded(
                child: StreamBuilder<List<RespuestasRecord>>(
                  stream: queryRespuestasRecord(
                    parent: widget.encuestaID,
                    queryBuilder: (q) => q,
                  ),
                  builder: (context, snap) {
                    if (!snap.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(kNavy),
                        ),
                      );
                    }

                    final respuestas = snap.data!;
                    TamizajeService.ordenarPorFecha(respuestas,
                        descendente: true);

                    if (respuestas.isEmpty) {
                      return const TamizajeEmptyState(
                        icon: Icons.assignment_outlined,
                        mensaje: 'No hay resultados registrados',
                        submensaje:
                            'Aún no se han completado tamizajes de este tipo',
                      );
                    }

                    final result = TamizajeService.paginar(
                        respuestas, _paginaActual);

                    return Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(24.0),
                            itemCount: result.pagina.length,
                            itemBuilder: (context, index) {
                              final r = result.pagina[index];
                              return _RespuestaCard(
                                respuesta: r,
                                encuesta: encuesta,
                                onVerDetalle: () => setState(
                                    () => _detalleRespuesta = r),
                              );
                            },
                          ),
                        ),
                        if (result.totalPaginas > 1)
                          TamizajePaginador(
                            paginaActual: _paginaActual,
                            totalPaginas: result.totalPaginas,
                            onCambiarPagina: (p) =>
                                setState(() => _paginaActual = p),
                            totalRegistros: respuestas.length,
                            style: PaginadorStyle.web,
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Card de una respuesta completada ────────────────────────────────────────

class _RespuestaCard extends StatefulWidget {
  const _RespuestaCard({
    required this.respuesta,
    required this.encuesta,
    required this.onVerDetalle,
  });

  final RespuestasRecord respuesta;
  final EncuestasRecord? encuesta;
  final VoidCallback onVerDetalle;

  @override
  State<_RespuestaCard> createState() => _RespuestaCardState();
}

class _RespuestaCardState extends State<_RespuestaCard> {
  bool _hover = false;

  int? _edadFromBirth(DateTime? birth) {
    if (birth == null) return null;
    final now = DateTime.now();
    int age = now.year - birth.year;
    if (now.month < birth.month ||
        (now.month == birth.month && now.day < birth.day)) {
      age--;
    }
    if (age < 0 || age > 120) return null;
    return age;
  }

  // Deriva el nivel clínico a partir de la categoría configurada en el
  // tamizaje y del puntaje total. Devuelve '' si no hay encuesta aún.
  String _nivelDe(EncuestasRecord? encuesta, RespuestasRecord r) {
    if (encuesta == null) return '';
    String titulo = encuesta.titulo;
    switch (encuesta.categoria) {
      case 'Consumo de SPA':
        titulo = 'sustancias';
        break;
      case 'Escala autoestima':
        titulo = 'autoestima';
        break;
      case 'CDI':
        titulo = 'cdi';
        break;
      case 'Depresión Beck':
        titulo = 'beck';
        break;
      case 'CRQ / SRQ':
      case 'CRQ':
      case 'SRQ':
        titulo = 'srq';
        break;
    }
    return classifyNivel(
      titulo,
      const [],
      puntajeTotal: r.puntajeTotal,
      umbrales: _umbralesFrom(encuesta),
    );
  }

  // Proyecta los umbrales configurados al crear el tamizaje en una
  // estructura plana reutilizable por classifyNivel. Devuelve null si la
  // encuesta no tiene umbrales o la categoría no es configurable.
  UmbralesConfig? _umbralesFrom(EncuestasRecord e) {
    final cat = e.categoria;
    if (cat == 'Escala autoestima' || cat == 'CDI') {
      return umbralesTripleteDesdeEncuesta(e);
    }
    if (cat == 'Depresión Beck' && e.alertas.length >= 4) {
      return UmbralesConfig(
        beckMinimaMax: e.alertas[0].max,
        beckLeveMax: e.alertas[1].max,
        beckModeradaMax: e.alertas[2].max,
      );
    }
    return null;
  }

  Color _colorNivel(String nivel) {
    final n = nivel.toLowerCase();
    if (n.contains('grave')) return kDanger;
    if (n.contains('severo') || n.contains('severa')) return kDanger;
    if (n.contains('baja')) return kDanger;
    if (n.contains('moderad')) return const Color(0xFFFF8A00);
    if (n.contains('leve') || n.contains('media')) return const Color(0xFFE0A800);
    if (n.contains('sin ') ||
        n.contains('mínima') ||
        n.contains('elevada')) return kSuccess;
    return kNavy;
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final r = widget.respuesta;
    final tieneIdeacion = hasIdeacion(r.test);
    final nivel = _nivelDe(widget.encuesta, r);
    final nivelColor = _colorNivel(nivel);
    final alertasEspeciales = r.alertasEspeciales
        .where((a) => a.trim().isNotEmpty)
        .toList();

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onVerDetalle,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12.0),
          padding: const EdgeInsets.all(18.0),
          decoration: BoxDecoration(
            color: _hover ? kNavy.withValues(alpha: 0.03) : Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: _hover ? kNavy.withValues(alpha: 0.3) : theme.alternate,
              width: _hover ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _hover ? 0.08 : 0.04),
                blurRadius: _hover ? 12 : 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar + nombre paciente
              Expanded(
                flex: 3,
                child: r.userRespuesta != null
                    ? FutureBuilder<UsersRecord>(
                        future: UsersRecord.getDocumentOnce(
                            r.userRespuesta!),
                        builder: (context, snap) {
                          final name =
                              snap.data?.displayName ?? 'Cargando...';
                          final genero = (snap.data?.genero ?? '').trim();
                          final edad = _edadFromBirth(snap.data?.fechaNacimiento);
                          final inicial = name.isNotEmpty
                              ? name[0].toUpperCase()
                              : '?';
                          return Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: kNavy.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  inicial,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: kNavy,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      formatDate(r.fecha),
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: theme.secondaryText,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Género: ${genero.isEmpty ? '—' : genero}  ·  Edad: ${edad == null ? '—' : '$edad'}',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: theme.secondaryText,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      )
                    : Text('Paciente desconocido',
                        style: theme.bodyMedium),
              ),

              // Puntaje
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: kNavy.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text('Puntaje',
                        style: GoogleFonts.inter(
                            fontSize: 10, color: theme.secondaryText)),
                    Text(
                      '${r.puntajeTotal}',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: kNavy,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Nivel clínico
              if (nivel.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: nivelColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: nivelColor.withValues(alpha: 0.35), width: 0.8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Nivel',
                          style: GoogleFonts.inter(
                              fontSize: 10, color: theme.secondaryText)),
                      const SizedBox(height: 2),
                      Text(
                        nivel,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: nivelColor,
                        ),
                      ),
                    ],
                  ),
                ),
              if (nivel.isNotEmpty) const SizedBox(width: 12),

              // Badges
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Estado
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: r.invalidado
                          ? const Color(0xFFFFC4C4)
                          : const Color(0xFFE5F9F1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: r.invalidado ? kDanger : kSuccess,
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      r.invalidado ? 'Invalidado' : 'Completado',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: r.invalidado ? kDanger : kSuccess,
                      ),
                    ),
                  ),
                  if (tieneIdeacion) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC4C4),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: Colors.red.shade300, width: 0.8),
                      ),
                      child: Text(
                        '⚠ Ideación',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                  for (final alerta in alertasEspeciales) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE5CC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFFFF8A00), width: 0.8),
                      ),
                      child: Text(
                        alerta,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFB35900),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(width: 12),

              // Acciones
              Column(
                children: [
                  SizedBox(
                    height: 32,
                    child: ElevatedButton.icon(
                      onPressed: widget.onVerDetalle,
                      icon:
                          const Icon(Icons.visibility_outlined, size: 14),
                      label: const Text('Ver detalle'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kNavy,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        textStyle: GoogleFonts.inter(
                            fontSize: 11, fontWeight: FontWeight.w600),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 32,
                    child: ExportarPdfButton(
                      respuesta: r,
                      style: ExportarPdfStyle.web,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
