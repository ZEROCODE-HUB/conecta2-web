part of '../wizard_tamizaje_manual.dart';

// Design tokens for this screen.
// _kNavy ya está declarada en wizard_tamizaje_manual.dart
const Color _kNavyDark = Color(0xFF1B3C6E);
const Color _kSuccess = Color(0xFF34A853);
const Color _kAlertBg = Color(0xFFFFF1F1);
const Color _kAlertBorder = Color(0xFFF5B5B5);
const Color _kAlertText = Color(0xFFB42318);
const Color _kAlertIcon = Color(0xFFD92D20);
const Color _kCardBorder = Color(0xFFE4E7EC);
const Color _kSubtleBg = Color(0xFFF7F8FA);

class _PasoResultados extends StatefulWidget {
  const _PasoResultados({
    required this.encuesta,
    required this.adolescente,
    required this.respuestas,
    required this.puntajeTotal,
    required this.tieneIdeacion,
    required this.notas,
    required this.respuestaRef,
    required this.onNotasGuardadas,
    required this.onCerrar,
  });

  final EncuestasRecord? encuesta;
  final UsersRecord? adolescente;
  final List<RespuestaTestStruct> respuestas;
  final int puntajeTotal;
  final bool tieneIdeacion;
  final String notas;
  final DocumentReference? respuestaRef;
  final ValueChanged<String> onNotasGuardadas;
  final VoidCallback onCerrar;

  @override
  State<_PasoResultados> createState() => _PasoResultadosState();
}

class _PasoResultadosState extends State<_PasoResultados> {
  late String _notasValue;
  bool _guardandoNotas = false;

  @override
  void initState() {
    super.initState();
    _notasValue = widget.notas;
  }

  /// Guarda las notas (si las hay) y luego cierra el wizard.
  /// Se usa al presionar "Finalizar" — unifica el flujo de guardar + cerrar.
  Future<void> _finalizar() async {
    setState(() => _guardandoNotas = true);
    try {
      final notas = _notasValue;
      if (widget.respuestaRef != null &&
          quillDeltaToPlainText(notas).trim().isNotEmpty) {
        await updateNotasProfesional(widget.respuestaRef!, notas);
        widget.onNotasGuardadas(notas);
      }
      if (mounted) widget.onCerrar();
    } catch (e) {
      if (mounted) {
        setState(() => _guardandoNotas = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar notas: $e')),
        );
      }
    }
  }

  Future<void> _agendarRecordatorio() async {
    if (widget.adolescente == null) return;
    await showAgendarRecordatorioDialog(
      context,
      adolescenteRef: widget.adolescente!.reference,
      encuestaRef: widget.encuesta?.reference,
      tituloDefault: 'Seguimiento ${widget.encuesta?.titulo ?? "tamizaje"}',
      pacienteNombre: widget.adolescente!.displayName,
    );
  }

  /// Calculates the alert level label for this tamizaje based on the
  /// configured `alertas` ranges and the `puntajeTotal`. Returns empty
  /// string for categories without predefined levels.
  bool get _esAssist => esEncuestaAssist(
      widget.encuesta?.categoria ?? '', widget.encuesta?.titulo ?? '');

  /// ASSIST: puntaje y nivel por sustancia (nivel global = peor sustancia).
  ResultadoAssist? get _assist => (_esAssist && widget.encuesta != null)
      ? evaluarAssistDesdeStructs(
          preguntas: widget.encuesta!.preguntas,
          test: widget.respuestas,
          alertas: widget.encuesta!.alertas,
        )
      : null;

  String _nivelCalculado() {
    final e = widget.encuesta;
    if (e == null) return '';
    // Misma regla que el detalle y que lo que se guarda en nivelAlerta.
    return calcularNivelRespuesta(
      encuesta: e,
      puntajeTotal: widget.puntajeTotal,
      test: widget.respuestas,
    );
  }

  String _formatFecha(DateTime d) {
    const meses = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
    ];
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${meses[d.month - 1]} ${d.year} · $hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final fecha = _formatFecha(DateTime.now());

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HeroCard(
                tamizaje: widget.encuesta?.titulo ?? 'Tamizaje',
                adolescente: widget.adolescente?.displayName ?? '—',
                fecha: fecha,
                puntaje: widget.puntajeTotal,
              ),
              if (_nivelCalculado().isNotEmpty) ...[
                const SizedBox(height: 16),
                _NivelAlertaCard(
                  categoria: widget.encuesta?.categoria ?? '',
                  nivel: _nivelCalculado(),
                ),
              ],
              if (_assist != null) ...[
                const SizedBox(height: 16),
                RiesgoSustanciasCard(resultado: _assist!),
              ],
              if (widget.tieneIdeacion) ...[
                const SizedBox(height: 20),
                const _AlertCard(
                  titulo: 'Alerta clínica prioritaria',
                  mensaje:
                      'Se detectó posible ideación suicida durante el tamizaje. Activar protocolo de seguimiento inmediato y documentar las acciones en las notas.',
                ),
              ],
              const SizedBox(height: 32),
              _SectionTitle(
                icon: Icons.edit_note_rounded,
                title: 'Notas del profesional',
                subtitle:
                    'Observaciones, contexto clínico y recomendaciones de seguimiento.',
                theme: theme,
              ),
              const SizedBox(height: 12),
              _NotesCard(
                initialValue: _notasValue,
                onChanged: (v) => _notasValue = v,
              ),
              const SizedBox(height: 16),
              _ActionButtons(
                guardando: _guardandoNotas,
                onProgramar: _agendarRecordatorio,
                onFinalizar: _finalizar,
              ),
              const SizedBox(height: 32),
              _SectionTitle(
                icon: Icons.fact_check_outlined,
                title: 'Resumen de respuestas',
                subtitle:
                    '${widget.respuestas.length} pregunta(s) registradas en este tamizaje.',
                theme: theme,
              ),
              const SizedBox(height: 12),
              ...widget.respuestas
                  .where((r) => !itemSustanciaNoAplica(
                      r, widget.encuesta?.preguntas ?? const []))
                  .map(
                (r) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _RespuestaCard(
                    numero: r.nPregunta,
                    pregunta: r.pregunta,
                    respuesta: _resumenRespuesta(r),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _resumenRespuesta(RespuestaTestStruct r) {
    if (r.respuesta.isNotEmpty) return r.respuesta;
    if (r.respuestaSeleccionUnica.isNotEmpty) return r.respuestaSeleccionUnica;
    if (r.respuestasSeleccionadas.isNotEmpty) {
      return r.respuestasSeleccionadas.join(', ');
    }
    if (r.respuestaTamizaje.isNotEmpty) {
      return r.respuestaTamizaje.map((e) => e.etiqueta).join(', ');
    }
    if (r.tipo == 'Verdadero o falso') {
      return r.trueAndFalse == 1 ? 'Verdadero' : 'Falso';
    }
    return '—';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero card: gradient navy header with tamizaje info + puntaje.
// ─────────────────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.tamizaje,
    required this.adolescente,
    required this.fecha,
    required this.puntaje,
  });

  final String tamizaje;
  final String adolescente;
  final String fecha;
  final int puntaje;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_kNavy, _kNavyDark],
        ),
        boxShadow: [
          BoxShadow(
            color: _kNavy.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(28),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
              ),
            ),
            child: const Icon(
              Icons.assignment_turned_in_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tamizaje completado',
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  tamizaje,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.person_outline_rounded,
                        color: Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        adolescente,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.event_rounded,
                        color: Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        fecha,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'PUNTAJE',
                  style: GoogleFonts.inter(
                    color: _kNavy,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$puntaje',
                  style: GoogleFonts.inter(
                    color: _kNavy,
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
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
// Alert card: prominent red/orange alert for ideación suicida o alertas.
// ─────────────────────────────────────────────────────────────────────────────

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.titulo, required this.mensaje});

  final String titulo;
  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _kAlertBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kAlertBorder, width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _kAlertBorder),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: _kAlertIcon,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: GoogleFonts.inter(
                    color: _kAlertText,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  mensaje,
                  style: GoogleFonts.inter(
                    color: _kAlertText.withValues(alpha: 0.9),
                    fontSize: 13.5,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
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
// Nivel de alerta card: navy-styled card that shows the calculated level
// label (Autoestima Baja / Media / Elevada, Leve, Moderada, Grave, etc.).
// ─────────────────────────────────────────────────────────────────────────────

class _NivelAlertaCard extends StatelessWidget {
  const _NivelAlertaCard({required this.categoria, required this.nivel});

  final String categoria;
  final String nivel;

  Color _colorForNivel() {
    final n = nivel.toLowerCase();
    if (n.contains('baja') ||
        n.contains('bajo') ||
        n.contains('sin ') ||
        n.contains('mínima') ||
        n.contains('minima')) {
      return const Color(0xFF34A853);
    }
    if (n.contains('media') ||
        n.contains('moderad') ||
        n.contains('leve')) {
      return const Color(0xFFF6BD33);
    }
    if (n.contains('elevada') ||
        n.contains('alto') ||
        n.contains('grave') ||
        n.contains('severo')) {
      return const Color(0xFFD92D20);
    }
    return _kNavy;
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorForNivel();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            child: Icon(Icons.insights_rounded, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nivel · ${categoria.isEmpty ? 'Tamizaje' : categoria}',
                  style: GoogleFonts.inter(
                    color: _kNavyDark.withValues(alpha: 0.65),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  nivel,
                  style: GoogleFonts.inter(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
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
// Section title: icon + title + subtitle header for each section.
// ─────────────────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.theme,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final FlutterFlowTheme theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _kNavy.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: _kNavy, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  color: _kNavyDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  color: theme.secondaryText,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notes card.
// ─────────────────────────────────────────────────────────────────────────────

class _NotesCard extends StatelessWidget {
  const _NotesCard({
    required this.initialValue,
    required this.onChanged,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: RichTextNotasEditor(
        initialValue: initialValue,
        onChanged: onChanged,
        placeholder:
            'Escribe observaciones, contexto clínico y recomendaciones…',
        minHeight: 180,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Action buttons row.
// ─────────────────────────────────────────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.guardando,
    required this.onProgramar,
    required this.onFinalizar,
  });

  final bool guardando;
  final VoidCallback onProgramar;
  final VoidCallback onFinalizar;

  @override
  Widget build(BuildContext context) {
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    );
    const pad = EdgeInsets.symmetric(horizontal: 20, vertical: 16);

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ElevatedButton.icon(
          onPressed: guardando ? null : onProgramar,
          icon: const Icon(Icons.alarm_add_rounded, size: 18),
          label: Text(
            'Programar recordatorio',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _kNavy,
            foregroundColor: Colors.white,
            padding: pad,
            shape: buttonShape,
            elevation: 0,
          ),
        ),
        ElevatedButton.icon(
          onPressed: guardando ? null : onFinalizar,
          icon: guardando
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.check_circle_outline_rounded, size: 18),
          label: Text(
            guardando ? 'Guardando…' : 'Finalizar',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _kSuccess,
            foregroundColor: Colors.white,
            padding: pad,
            shape: buttonShape,
            elevation: 0,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Respuesta card: navy circle with number + question + answer.
// ─────────────────────────────────────────────────────────────────────────────

class _RespuestaCard extends StatelessWidget {
  const _RespuestaCard({
    required this.numero,
    required this.pregunta,
    required this.respuesta,
  });

  final int numero;
  final String pregunta;
  final String respuesta;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kCardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: _kNavy,
            child: Text(
              '$numero',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pregunta,
                  style: GoogleFonts.inter(
                    color: _kNavyDark,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _kSubtleBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _kCardBorder),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: _kNavy,
                        size: 14,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          respuesta,
                          style: GoogleFonts.inter(
                            color: Colors.black.withValues(alpha: 0.75),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
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
