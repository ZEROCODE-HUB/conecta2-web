import '/backend/backend.dart';
import '/components/rich_text_notas/rich_text_notas_widget.dart';
import '/dashboard/web/encuestas/editar/widgets/tamizajes_niveles.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/tamizajes/shared/assist_utils.dart';
import '/tamizajes/shared/tamizajes_constants.dart';
import '/tamizajes/shared/widgets/riesgo_sustancias_card.dart';
import '/tamizajes/shared/widgets/agendar_recordatorio_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Wizard step 4: results + professional notes + follow-up reminder.
class PasoResultados extends StatefulWidget {
  const PasoResultados({
    super.key,
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
  State<PasoResultados> createState() => _PasoResultadosState();
}

class _PasoResultadosState extends State<PasoResultados> {
  late String _notasValue;
  bool _guardandoNotas = false;

  @override
  void initState() {
    super.initState();
    _notasValue = widget.notas;
  }

  Future<void> _guardarNotas() async {
    if (widget.respuestaRef == null) return;
    setState(() => _guardandoNotas = true);
    try {
      await updateNotasProfesional(widget.respuestaRef!, _notasValue);
      widget.onNotasGuardadas(_notasValue);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notas guardadas')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _guardandoNotas = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card de resultado con puntaje
                _ResultadoSummaryCard(
                  encuesta: widget.encuesta,
                  adolescente: widget.adolescente,
                  puntajeTotal: widget.puntajeTotal,
                  theme: theme,
                ),

                // Nivel de alerta
                if (_nivelCalculado().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: _NivelAlertaCard(
                      nivel: _nivelCalculado(),
                      categoria: widget.encuesta?.categoria ?? '',
                      theme: theme,
                    ),
                  ),

                // ASSIST: desglose por sustancia evaluada.
                if (_assist != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: RiesgoSustanciasCard(resultado: _assist!),
                  ),

                // Alerta de ideación suicida
                if (widget.tieneIdeacion)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: _IdeacionAlertCard(),
                  ),

                const SizedBox(height: 20),

                // Notas del profesional
                Text(
                  'Notas del profesional',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: theme.primaryText,
                  ),
                ),
                const SizedBox(height: 8),
                RichTextNotasEditor(
                  initialValue: _notasValue,
                  onChanged: (v) => _notasValue = v,
                  placeholder:
                      'Observaciones, contexto clínico, recomendaciones...',
                  minHeight: 160,
                ),
                const SizedBox(height: 12),

                // Botón guardar notas
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _guardandoNotas ? null : _guardarNotas,
                    icon: _guardandoNotas
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.save_outlined, size: 18),
                    label: Text('Guardar notas',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kNavy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Botón agendar recordatorio (usa diálogo compartido)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: widget.adolescente == null
                        ? null
                        : () => showAgendarRecordatorioDialog(
                              context,
                              adolescenteRef: widget.adolescente!.reference,
                              encuestaRef: widget.encuesta?.reference,
                              tituloDefault:
                                  'Seguimiento ${widget.encuesta?.titulo ?? "tamizaje"}',
                              pacienteNombre:
                                  widget.adolescente?.displayName,
                              useBottomSheet: true,
                            ),
                    icon: const Icon(Icons.alarm, size: 18),
                    label: Text('Programar recordatorio',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kNavy,
                      side: const BorderSide(color: kNavy),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Resumen de respuestas
                Text(
                  'Resumen de respuestas',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: theme.primaryText,
                  ),
                ),
                const SizedBox(height: 10),
                ...widget.respuestas
                    .where((r) => !itemSustanciaNoAplica(
                        r, widget.encuesta?.preguntas ?? const []))
                    .map(
                      (r) => _RespuestaResumenItem(respuesta: r, theme: theme),
                    ),
              ],
            ),
          ),
        ),

        // Botón finalizar
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: widget.onCerrar,
              icon: const Icon(Icons.check_circle, size: 20),
              label: Text('Finalizar',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600, fontSize: 15)),
              style: ElevatedButton.styleFrom(
                backgroundColor: kNavy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
      ],
    );
  }

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
    final assist = _assist;
    if (assist != null) return assist.nivelGlobal;
    final categoria = widget.encuesta?.categoria ?? '';
    if (categoria.isEmpty) return '';
    final alertas = widget.encuesta?.alertas.toList() ?? const [];
    return calcularNivelAlerta(
      categoria: categoria,
      puntaje: widget.puntajeTotal,
      alertas: alertas,
    );
  }
}

// ─── Sub-componentes ─────────────────────────────────────────────────────────

class _ResultadoSummaryCard extends StatelessWidget {
  const _ResultadoSummaryCard({
    required this.encuesta,
    required this.adolescente,
    required this.puntajeTotal,
    required this.theme,
  });

  final EncuestasRecord? encuesta;
  final UsersRecord? adolescente;
  final int puntajeTotal;
  final FlutterFlowTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFBE5A1).withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFBE5A1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: kNavy.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.assignment_turned_in,
                    color: kNavy, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      encuesta?.titulo ?? 'Tamizaje',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: theme.primaryText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      adolescente?.displayName ?? '—',
                      style: GoogleFonts.inter(
                          fontSize: 13, color: theme.secondaryText),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text('Puntaje total',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: theme.secondaryText)),
                const SizedBox(height: 4),
                Text(
                  '$puntajeTotal',
                  style: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: kNavy,
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

class _NivelAlertaCard extends StatelessWidget {
  const _NivelAlertaCard({
    required this.nivel,
    required this.categoria,
    required this.theme,
  });

  final String nivel;
  final String categoria;
  final FlutterFlowTheme theme;

  Color _colorNivel() {
    final n = nivel.toLowerCase();
    if (n.contains('baja') || n.contains('bajo') || n.contains('sin ') ||
        n.contains('mínima') ||
        n.contains('minima')) return kSuccess;
    if (n.contains('media') || n.contains('moderad') || n.contains('leve')) {
      return const Color(0xFFF6BD33);
    }
    if (n.contains('elevada') || n.contains('alto') || n.contains('grave') ||
        n.contains('severo')) return const Color(0xFFD92D20);
    return kNavy;
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorNivel();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.5)),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.insights, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nivel · ${categoria.isEmpty ? 'Tamizaje' : categoria}',
                  style: GoogleFonts.inter(
                    color: theme.secondaryText,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  nivel,
                  style: GoogleFonts.inter(
                    color: color,
                    fontSize: 16,
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

class _IdeacionAlertCard extends StatelessWidget {
  const _IdeacionAlertCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE5E5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child:
                const Icon(Icons.warning_amber, color: Colors.red, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alerta de ideación suicida',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    color: Colors.red.shade700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Se detectó posible ideación suicida. '
                  'Se recomienda intervención inmediata.',
                  style: GoogleFonts.inter(
                    color: Colors.red.shade600,
                    fontSize: 12,
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

class _RespuestaResumenItem extends StatelessWidget {
  const _RespuestaResumenItem({
    required this.respuesta,
    required this.theme,
  });

  final RespuestaTestStruct respuesta;
  final FlutterFlowTheme theme;

  String _resumen() {
    if (respuesta.respuesta.isNotEmpty) return respuesta.respuesta;
    if (respuesta.respuestaSeleccionUnica.isNotEmpty) {
      return respuesta.respuestaSeleccionUnica;
    }
    if (respuesta.respuestasSeleccionadas.isNotEmpty) {
      return respuesta.respuestasSeleccionadas.join(', ');
    }
    if (respuesta.respuestaTamizaje.isNotEmpty) {
      return respuesta.respuestaTamizaje.map((e) => e.etiqueta).join(', ');
    }
    if (respuesta.tipo == 'Verdadero o falso') {
      return respuesta.trueAndFalse == 1 ? 'Verdadero' : 'Falso';
    }
    return '—';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        border: Border.all(color: theme.alternate),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${respuesta.nPregunta}. ${respuesta.pregunta}',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: theme.primaryText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _resumen(),
            style: GoogleFonts.inter(
                fontSize: 13, color: theme.secondaryText),
          ),
        ],
      ),
    );
  }
}
