import '/backend/backend.dart';
import '/components/rich_text_notas/rich_text_notas_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/dashboard/web/tamizajes/listado_tamizajes/export_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'resultados_tami_model.dart';
export 'resultados_tami_model.dart';

class ResultadosTamiWidget extends StatefulWidget {
  const ResultadosTamiWidget({
    super.key,
    required this.encuestaID,
    this.onClose,
  });

  final DocumentReference encuestaID;
  final VoidCallback? onClose;

  @override
  State<ResultadosTamiWidget> createState() => _ResultadosTamiWidgetState();
}

class _ResultadosTamiWidgetState extends State<ResultadosTamiWidget> {
  late ResultadosTamiModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ResultadosTamiModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  /// Persists notas del profesional to Firestore.
  Future<void> _updateNotasProfesional(
      DocumentReference ref, String notas) async {
    await ref.update({'notasProfesional': notas});
  }

  /// Marks a respuesta as invalidada in Firestore.
  Future<void> _invalidarTamizaje(DocumentReference ref) async {
    await ref.update({
      'invalidado': true,
      'fechaInvalidacion': DateTime.now(),
    });
  }

  /// Returns true when any item in the test list has ideacionSuicida == true.
  bool _hasIdeacionSuicida(List<RespuestaTestStruct> test) {
    for (final item in test) {
      for (final atributo in item.respuestaTamizaje) {
        if (atributo.ideacionSuicida) return true;
      }
    }
    return false;
  }

  /// Formats a DateTime nicely.
  String _formatDate(DateTime? dt) {
    if (dt == null) return '—';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: SafeArea(
        child: StreamBuilder<EncuestasRecord>(
          stream: EncuestasRecord.getDocument(widget.encuestaID),
          builder: (context, encuestaSnapshot) {
            final encuesta = encuestaSnapshot.data;

            return Container(
              width: double.infinity,
              height: double.infinity,
              color: FlutterFlowTheme.of(context).primaryBackground,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ──────────────────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 10.0),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom:
                            BorderSide(color: Color(0xFFE4E7EC), width: 1.0),
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          iconSize: 20.0,
                          padding: const EdgeInsets.all(6.0),
                          constraints: const BoxConstraints(),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Color(0xFF265294),
                          ),
                          onPressed: () {
                            if (widget.onClose != null) {
                              widget.onClose!();
                            } else if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Resultados del tamizaje',
                                style: GoogleFonts.inter(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15.0,
                                  letterSpacing: 0.0,
                                ),
                              ),
                              if (encuesta != null) ...[
                                const SizedBox(height: 2.0),
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        encuesta.titulo,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                          color: const Color(0xFF265294),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12.0,
                                          letterSpacing: 0.0,
                                        ),
                                      ),
                                    ),
                                    if (encuesta.categoria.isNotEmpty) ...[
                                      const SizedBox(width: 8.0),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0, vertical: 2.0),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF265294)
                                              .withValues(alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        child: Text(
                                          encuesta.categoria,
                                          style: GoogleFonts.inter(
                                            color: const Color(0xFF265294),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 10.0,
                                            letterSpacing: 0.0,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        _ExportarTamizajeBoton(
                          encuestaID: widget.encuestaID,
                          hasIdeacionSuicida: _hasIdeacionSuicida,
                          formatDate: _formatDate,
                        ),
                      ],
                    ),
                  ),

                  // ── Body ─────────────────────────────────────────────────────
                  Expanded(
                    child: StreamBuilder<List<RespuestasRecord>>(
                      stream: queryRespuestasRecord(
                        parent: widget.encuestaID,
                        queryBuilder: (q) =>
                            q.orderBy('Fecha', descending: true),
                      ),
                      builder: (context, respuestasSnapshot) {
                        if (!respuestasSnapshot.hasData) {
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                FlutterFlowTheme.of(context).primary,
                              ),
                            ),
                          );
                        }

                        final respuestas = respuestasSnapshot.data!;

                        if (respuestas.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.assignment_outlined,
                                  size: 64.0,
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText
                                      .withValues(alpha: 0.4),
                                ),
                                const SizedBox(height: 16.0),
                                Text(
                                  'No hay resultados registrados',
                                  style: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .override(
                                        font: GoogleFonts.inter(),
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(24.0),
                          itemCount: respuestas.length,
                          itemBuilder: (context, index) {
                            final respuesta = respuestas[index];
                            return _RespuestaCard(
                              respuesta: respuesta,
                              model: _model,
                              onUpdateNotas: _updateNotasProfesional,
                              onInvalidar: _invalidarTamizaje,
                              hasIdeacionSuicida:
                                  _hasIdeacionSuicida(respuesta.test),
                              formatDate: _formatDate,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card widget for a single respuesta
// ─────────────────────────────────────────────────────────────────────────────

class _RespuestaCard extends StatefulWidget {
  const _RespuestaCard({
    required this.respuesta,
    required this.model,
    required this.onUpdateNotas,
    required this.onInvalidar,
    required this.hasIdeacionSuicida,
    required this.formatDate,
  });

  final RespuestasRecord respuesta;
  final ResultadosTamiModel model;
  final Future<void> Function(DocumentReference, String) onUpdateNotas;
  final Future<void> Function(DocumentReference) onInvalidar;
  final bool hasIdeacionSuicida;
  final String Function(DateTime?) formatDate;

  @override
  State<_RespuestaCard> createState() => _RespuestaCardState();
}

class _RespuestaCardState extends State<_RespuestaCard> {
  bool _savingNotas = false;
  bool _invalidating = false;

  @override
  void initState() {
    super.initState();
    // Seed the notas value when first created.
    final refPath = widget.respuesta.reference.path;
    widget.model.notasValueFor(
      refPath,
      initialValue: widget.respuesta.notasProfesional,
    );
  }

  Future<void> _guardarNotas() async {
    final refPath = widget.respuesta.reference.path;
    final valor = widget.model.notasValueFor(refPath);
    setState(() => _savingNotas = true);
    try {
      await widget.onUpdateNotas(widget.respuesta.reference, valor);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notas guardadas correctamente')),
        );
      }
    } finally {
      if (mounted) setState(() => _savingNotas = false);
    }
  }

  Future<void> _confirmarInvalidar() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Invalidar tamizaje'),
        content: const Text(
          '¿Estás seguro de que deseas invalidar este tamizaje?\n'
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Invalidar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _invalidating = true);
      try {
        await widget.onInvalidar(widget.respuesta.reference);
      } finally {
        if (mounted) setState(() => _invalidating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final refPath = widget.respuesta.reference.path;
    final notasInitial = widget.model.notasValueFor(
      refPath,
      initialValue: widget.respuesta.notasProfesional,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Card header ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Patient name via FutureBuilder
                    Expanded(
                      child: widget.respuesta.userRespuesta != null
                          ? FutureBuilder<UsersRecord>(
                              future: UsersRecord.getDocumentOnce(
                                  widget.respuesta.userRespuesta!),
                              builder: (context, userSnap) {
                                final name =
                                    userSnap.data?.displayName ?? 'Cargando...';
                                return Text(
                                  name,
                                  style: GoogleFonts.inter(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14.0,
                                    letterSpacing: 0.0,
                                  ),
                                );
                              },
                            )
                          : Text(
                              'Usuario desconocido',
                              style: GoogleFonts.inter(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                                fontSize: 14.0,
                                letterSpacing: 0.0,
                              ),
                            ),
                    ),
                    const SizedBox(width: 8.0),
                    // Status badge
                    _StatusBadge(invalidado: widget.respuesta.invalidado),
                  ],
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 14.0, color: theme.secondaryText),
                    const SizedBox(width: 4.0),
                    Text(
                      widget.formatDate(widget.respuesta.fecha),
                      style: GoogleFonts.inter(
                        color: theme.secondaryText,
                        fontSize: 11.0,
                        letterSpacing: 0.0,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Icon(Icons.bar_chart_outlined,
                        size: 14.0, color: theme.secondaryText),
                    const SizedBox(width: 4.0),
                    Text(
                      'Puntaje: ${widget.respuesta.puntajeTotal}',
                      style: GoogleFonts.inter(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 11.0,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ],
                ),
                // Ideación suicida badge
                if (widget.hasIdeacionSuicida)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC4C4),
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(color: Colors.red.shade300),
                      ),
                      child: Text(
                        '⚠ Ideación Suicida',
                        style: GoogleFonts.inter(
                          color: Colors.red.shade900,
                          fontWeight: FontWeight.w700,
                          fontSize: 11.0,
                        ),
                      ),
                    ),
                  ),
                // Alertas especiales
                if (widget.respuesta.alertasEspeciales.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: widget.respuesta.alertasEspeciales
                          .map((alerta) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 4.0),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFE0A8),
                                  borderRadius: BorderRadius.circular(20.0),
                                  border:
                                      Border.all(color: Colors.orange.shade300),
                                ),
                                child: Text(
                                  '⚠ $alerta',
                                  style: theme.labelMedium.override(
                                    font: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600),
                                    color: Colors.orange.shade900,
                                    letterSpacing: 0.0,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1),

          // ── Expandable detail ─────────────────────────────────────────
          Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
            ),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16.0),
              childrenPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
              title: Text(
                'Ver detalle de respuestas',
                style: GoogleFonts.inter(
                  color: const Color(0xFF265294),
                  fontWeight: FontWeight.w600,
                  fontSize: 13.0,
                  letterSpacing: 0.0,
                ),
              ),
              children: [
                // ── Preguntas y respuestas ─────────────────────────────
                if (widget.respuesta.test.isNotEmpty) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Respuestas del paciente',
                      style: GoogleFonts.inter(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.0,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  ...widget.respuesta.test.map((item) => _PreguntaRow(
                        item: item,
                        theme: theme,
                      )),
                  const SizedBox(height: 16.0),
                  const Divider(),
                ],

                const SizedBox(height: 12.0),

                // ── Notas del profesional ─────────────────────────────
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Notas del profesional',
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.0,
                      letterSpacing: 0.0,
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
                RichTextNotasEditor(
                  initialValue: notasInitial,
                  onChanged: (v) => widget.model.setNotasValue(refPath, v),
                  placeholder: 'Escribe aquí las notas del profesional...',
                  minHeight: 160,
                ),
                const SizedBox(height: 10.0),
                Align(
                  alignment: Alignment.centerRight,
                  child: FFButtonWidget(
                    onPressed: _savingNotas ? null : _guardarNotas,
                    text: _savingNotas ? 'Guardando...' : 'Guardar notas',
                    options: FFButtonOptions(
                      height: 36.0,
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          16.0, 0.0, 16.0, 0.0),
                      color: const Color(0xFF265294),
                      textStyle: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13.0,
                        letterSpacing: 0.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                      elevation: 0,
                    ),
                  ),
                ),

                const SizedBox(height: 16.0),
                const Divider(),
                const SizedBox(height: 12.0),

                // ── Invalidación ──────────────────────────────────────
                if (!widget.respuesta.invalidado) ...[
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: Colors.orange.shade700, size: 18.0),
                      const SizedBox(width: 6.0),
                      Expanded(
                        child: Text(
                          'Invalidar este tamizaje lo marcará como no válido.',
                          style: theme.labelMedium.override(
                            font: GoogleFonts.inter(),
                            color: theme.secondaryText,
                            letterSpacing: 0.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  FFButtonWidget(
                    onPressed: _invalidating ? null : _confirmarInvalidar,
                    text:
                        _invalidating ? 'Invalidando...' : 'Invalidar tamizaje',
                    options: FFButtonOptions(
                      height: 36.0,
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          16.0, 0.0, 16.0, 0.0),
                      color: const Color(0xFFE53935),
                      textStyle: theme.titleSmall.override(
                        font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        color: Colors.white,
                        letterSpacing: 0.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                      elevation: 0,
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC4C4),
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.cancel_outlined,
                            color: Colors.red.shade700, size: 18.0),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tamizaje invalidado',
                                style: theme.labelLarge.override(
                                  font: GoogleFonts.inter(
                                      fontWeight: FontWeight.w700),
                                  color: Colors.red.shade700,
                                  letterSpacing: 0.0,
                                ),
                              ),
                              if (widget.respuesta.fechaInvalidacion != null)
                                Text(
                                  'Fecha: ${widget.formatDate(widget.respuesta.fechaInvalidacion)}',
                                  style: theme.labelSmall.override(
                                    font: GoogleFonts.inter(),
                                    color: Colors.red.shade600,
                                    letterSpacing: 0.0,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status badge
// ─────────────────────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.invalidado});

  final bool invalidado;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: invalidado ? const Color(0xFFFFC4C4) : const Color(0xFFE5F9F1),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: invalidado ? const Color(0xFFE53935) : const Color(0xFF34A853),
          width: 1.0,
        ),
      ),
      child: Text(
        invalidado ? 'Invalidado' : 'Completado',
        style: GoogleFonts.inter(
          fontSize: 12.0,
          fontWeight: FontWeight.w600,
          color: invalidado ? const Color(0xFFE53935) : const Color(0xFF34A853),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Row for a single question/answer
// ─────────────────────────────────────────────────────────────────────────────

class _PreguntaRow extends StatelessWidget {
  const _PreguntaRow({required this.item, required this.theme});

  final RespuestaTestStruct item;
  final FlutterFlowTheme theme;

  String get _respuestaTexto {
    if (item.respuesta.isNotEmpty) return item.respuesta;
    if (item.respuestaSeleccionUnica.isNotEmpty) {
      return item.respuestaSeleccionUnica;
    }
    if (item.respuestasSeleccionadas.isNotEmpty) {
      return item.respuestasSeleccionadas.join(', ');
    }
    if (item.respuestaSelection.isNotEmpty) {
      return item.respuestaSelection.join(', ');
    }
    return '—';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24.0,
            height: 24.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Text(
              '${item.nPregunta}',
              style: GoogleFonts.inter(
                fontSize: 11.0,
                fontWeight: FontWeight.w700,
                color: theme.primary,
              ),
            ),
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.pregunta,
                  style: theme.bodyMedium.override(
                    font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    letterSpacing: 0.0,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  _respuestaTexto,
                  style: theme.bodySmall.override(
                    font: GoogleFonts.inter(),
                    color: theme.secondaryText,
                    letterSpacing: 0.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Botón exportar PDF — carga todas las respuestas del tamizaje y las exporta
// ─────────────────────────────────────────────────────────────────────────────

class _ExportarTamizajeBoton extends StatefulWidget {
  const _ExportarTamizajeBoton({
    required this.encuestaID,
    required this.hasIdeacionSuicida,
    required this.formatDate,
  });

  final DocumentReference encuestaID;
  final bool Function(List<RespuestaTestStruct>) hasIdeacionSuicida;
  final String Function(DateTime?) formatDate;

  @override
  State<_ExportarTamizajeBoton> createState() => _ExportarTamizajeBotonState();
}

class _ExportarTamizajeBotonState extends State<_ExportarTamizajeBoton> {
  bool _exporting = false;

  String _getRespuestaTexto(RespuestaTestStruct item) {
    if (item.respuesta.isNotEmpty) return item.respuesta;
    if (item.respuestaSeleccionUnica.isNotEmpty) {
      return item.respuestaSeleccionUnica;
    }
    if (item.respuestasSeleccionadas.isNotEmpty) {
      return item.respuestasSeleccionadas.join(', ');
    }
    if (item.respuestaSelection.isNotEmpty) {
      return item.respuestaSelection.join(', ');
    }
    return '—';
  }

  Future<void> _exportar() async {
    setState(() => _exporting = true);
    try {
      // Carga el encuesta document
      final encuesta = await EncuestasRecord.getDocumentOnce(widget.encuestaID);

      // Carga las respuestas
      final respuestas = await queryRespuestasRecordOnce(
        parent: widget.encuestaID,
        queryBuilder: (q) => q.orderBy('Fecha', descending: true),
      );

      if (respuestas.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No hay respuestas para exportar')),
          );
        }
        return;
      }

      // Toma la respuesta más reciente
      final respuesta = respuestas.first;

      String nombre = 'Paciente';
      if (respuesta.userRespuesta != null) {
        try {
          final user =
              await UsersRecord.getDocumentOnce(respuesta.userRespuesta!);
          if (user.displayName.isNotEmpty) nombre = user.displayName;
        } catch (_) {}
      }

      final preguntas = respuesta.test
          .map((item) => PreguntaExport(
                numero: item.nPregunta,
                pregunta: item.pregunta,
                respuesta: _getRespuestaTexto(item),
              ))
          .toList();

      await exportarResultadosPDF(
        titloTamizaje: encuesta.titulo,
        nombrePaciente: nombre,
        fecha: widget.formatDate(respuesta.fecha),
        puntaje: respuesta.puntajeTotal,
        notas: respuesta.notasProfesional,
        preguntas: preguntas,
        invalidado: respuesta.invalidado,
        hayIdeacionSuicida: widget.hasIdeacionSuicida(respuesta.test),
        respuesta: respuesta,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al exportar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _exporting ? null : _exportar,
      icon: _exporting
          ? const SizedBox(
              width: 14.0,
              height: 14.0,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.picture_as_pdf_outlined, size: 16.0),
      label: Text(_exporting ? 'Exportando...' : 'Exportar PDF'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF34A853),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        textStyle: GoogleFonts.inter(
          fontSize: 13.0,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        elevation: 0,
      ),
    );
  }
}
