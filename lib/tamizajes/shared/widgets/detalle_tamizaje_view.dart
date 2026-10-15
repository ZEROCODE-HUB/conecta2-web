import '/backend/backend.dart';
import '/components/rich_text_notas/rich_text_notas_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/tamizajes/shared/assist_utils.dart';
import '/tamizajes/shared/nivel_respuesta.dart';
import '/tamizajes/shared/tamizaje_utils.dart';
import '/tamizajes/shared/tamizajes_constants.dart';
import '/tamizajes/shared/widgets/agendar_recordatorio_dialog.dart';
import '/tamizajes/shared/widgets/riesgo_sustancias_card.dart';
import '/tamizajes/shared/widgets/tamizaje_page_header.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Vista de detalle completa para un tamizaje completado.
///
/// Muestra: información del paciente, puntaje, nivel de alerta, ideación,
/// todas las preguntas/respuestas, notas del profesional, y acciones.
/// Incluye botón "Volver" para regresar al listado.
class DetalleTamizajeView extends StatefulWidget {
  const DetalleTamizajeView({
    super.key,
    required this.respuesta,
    this.adolescente,
    required this.onVolver,
  });

  final RespuestasRecord respuesta;
  final UsersRecord? adolescente;
  final VoidCallback onVolver;

  @override
  State<DetalleTamizajeView> createState() => _DetalleTamizajeViewState();
}

class _DetalleTamizajeViewState extends State<DetalleTamizajeView> {
  late String _notasValue;
  bool _guardandoNotas = false;
  EncuestasRecord? _encuesta;
  UsersRecord? _adolescenteCargado;

  @override
  void initState() {
    super.initState();
    _notasValue = widget.respuesta.notasProfesional;
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    // Cargar encuesta
    try {
      final encuesta = await EncuestasRecord.getDocumentOnce(
          widget.respuesta.parentReference);
      if (mounted) setState(() => _encuesta = encuesta);
    } catch (_) {}

    // Cargar adolescente si no fue proporcionado
    if (widget.adolescente == null && widget.respuesta.userRespuesta != null) {
      try {
        final user =
            await UsersRecord.getDocumentOnce(widget.respuesta.userRespuesta!);
        if (mounted) setState(() => _adolescenteCargado = user);
      } catch (_) {}
    }
  }

  UsersRecord? get _adolescente => widget.adolescente ?? _adolescenteCargado;

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

  Future<void> _guardarNotas() async {
    setState(() => _guardandoNotas = true);
    try {
      await updateNotasProfesional(widget.respuesta.reference, _notasValue);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notas guardadas correctamente'),
            backgroundColor: kSuccess,
          ),
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

  /// ASSIST: puntaje y nivel por sustancia (nivel global = peor sustancia).
  /// `null` si el tamizaje no es de Consumo de SPA.
  ResultadoAssist? get _assist {
    final e = _encuesta;
    if (e == null || !esEncuestaAssist(e.categoria, e.titulo)) return null;
    return evaluarAssistDesdeStructs(
      preguntas: e.preguntas,
      test: widget.respuesta.test,
      alertas: e.alertas,
    );
  }

  /// Nivel de la respuesta (fuente única: `calcularNivelRespuesta`).
  String _nivelCalculado() {
    if (_encuesta == null) return '';
    return calcularNivelRespuesta(
      encuesta: _encuesta!,
      puntajeTotal: widget.respuesta.puntajeTotal,
      test: widget.respuesta.test,
    );
  }

  Color _colorNivel(String nivel) {
    final n = nivel.toLowerCase();
    if (n.contains('baja') ||
        n.contains('bajo') ||
        n.contains('sin ') ||
        n.contains('mínima') ||
        n.contains('minima')) return kSuccess;
    if (n.contains('media') ||
        n.contains('moderad') ||
        n.contains('moderado') ||
        n.contains('leve')) {
      return const Color(0xFFF6BD33);
    }
    if (n.contains('elevada') ||
        n.contains('alto') ||
        n.contains('grave') ||
        n.contains('severo')) return const Color(0xFFD92D20);
    return kNavy;
  }

  bool get _esManual => widget.respuesta.tipoTamizaje == 'manual';
  bool get _tieneIdeacion => hasIdeacion(widget.respuesta.test);

  /// Calcula las subescalas D (Disforia) y A (Autoestima Negativa) del CDI.
  /// Usa el campo `variable` de cada pregunta de la encuesta para clasificar
  /// cada respuesta. Retorna ambos valores; si no hay variables configuradas
  /// retorna (d:0, a:0) con flag `tieneVariables = false`.
  ({int d, int a, bool tieneVariables}) _calcularSubescalasCdi() {
    if (_encuesta == null) return (d: 0, a: 0, tieneVariables: false);
    int d = 0, a = 0;
    bool tieneVariables = false;
    final preguntas = _encuesta!.preguntas;
    for (int i = 0; i < widget.respuesta.test.length; i++) {
      final r = widget.respuesta.test[i];
      // nPregunta es 1-indexado; si es 0 (datos antiguos) usa posición i
      final pregIdx = r.nPregunta > 0 ? r.nPregunta - 1 : i;
      if (pregIdx < preguntas.length) {
        final variable = preguntas[pregIdx].variable.trim().toUpperCase();
        final isDisforia = variable == 'D' || variable.contains('DISFORIA');
        final isAutoestima = variable == 'A' || variable.contains('AUTOESTIMA');

        if (isDisforia || isAutoestima) tieneVariables = true;

        final valor = r.respuestaTamizaje.isNotEmpty
            ? r.respuestaTamizaje.first.valor
            : 0;

        if (isDisforia) d += valor;
        if (isAutoestima) a += valor;
      }
    }
    return (d: d, a: a, tieneVariables: tieneVariables);
  }

  // Texto descriptivo breve que explica qué significa el nivel clínico
  // obtenido. Ayuda al profesional a interpretar el resultado sin tener
  // que recordar los rangos de cada escala.
  String _descripcionNivel(String categoria, String nivel) {
    final n = nivel.toLowerCase();
    if (categoria == 'Escala autoestima') {
      if (n.contains('baja'))
        return 'Autoestima baja. Requiere intervención y apoyo.';
      if (n.contains('media'))
        return 'Autoestima media. Seguimiento preventivo.';
      if (n.contains('elevada')) return 'Autoestima saludable.';
    }
    if (categoria == 'CDI') {
      if (n.contains('sin ')) return 'Sin sintomatología depresiva relevante.';
      if (n.contains('leve'))
        return 'Sintomatología leve. Seguimiento recomendado.';
      if (n.contains('severo'))
        return 'Sintomatología severa. Requiere intervención clínica.';
    }
    if (categoria == 'Depresión Beck') {
      if (n.contains('mínima') || n.contains('minima'))
        return 'Sin depresión clínicamente significativa.';
      if (n.contains('leve')) return 'Depresión leve. Seguimiento cercano.';
      if (n.contains('moderad'))
        return 'Depresión moderada. Derivar a evaluación clínica.';
      if (n.contains('grave'))
        return 'Depresión grave. Intervención clínica prioritaria.';
    }
    if (categoria == 'Consumo de SPA') {
      if (n == 'bajo') {
        return 'Riesgo bajo en todas las sustancias evaluadas.';
      }
      if (n == 'moderado') {
        return 'Riesgo moderado en al menos una sustancia. Intervención breve y seguimiento.';
      }
      if (n == 'alto') {
        return 'Riesgo alto en al menos una sustancia. Derivar a atención especializada.';
      }
      if (n.contains('sin ')) return 'Sin indicios de consumo problemático.';
      if (n.contains('moderad'))
        return 'Consumo moderado. Requiere seguimiento.';
      if (n.contains('severo'))
        return 'Consumo severo. Intervención especializada.';
    }
    if (categoria == 'Escala ansiedad') {
      if (n.contains('sin ')) return 'Sin sintomatología de ansiedad.';
      if (n.contains('leve'))
        return 'Ansiedad leve. Seguimiento preventivo recomendado.';
      if (n.contains('moderado'))
        return 'Ansiedad moderada. Requiere atención por psicología.';
      if (n.contains('severo'))
        return 'Ansiedad severa. Requiere atención clínica prioritaria.';
    }
    if (categoria == 'CRQ / SRQ' ||
        categoria == 'CRQ' ||
        categoria == 'SRQ' ||
        categoria == 'RQC') {
      if (n.contains('sin ')) return 'Sin alerta psicosocial.';
      if (n.contains('moderad')) return 'Alerta psicosocial moderada.';
      if (n.contains('severo')) return 'Alerta psicosocial alta.';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final respuesta = widget.respuesta;
    final adolescente = _adolescente;
    final nombre = adolescente?.displayName ?? 'Cargando...';
    final genero = (adolescente?.genero ?? '').trim();
    final edad = _edadFromBirth(adolescente?.fechaNacimiento);
    final esCdi = _encuesta?.categoria == 'CDI';
    final cdiSub = esCdi ? _calcularSubescalasCdi() : null;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: theme.primaryBackground,
      child: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────
          TamizajePageHeader(
            titulo: respuesta.titlo.isNotEmpty
                ? respuesta.titlo
                : 'Detalle del Tamizaje',
            breadcrumb: 'Volver al listado',
            onVolver: widget.onVolver,
            icon: Icons.description_outlined,
            badge: TipoBadge(esManual: _esManual),
          ),

          // ── Contenido scrolleable ─────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(
                  MediaQuery.sizeOf(context).width < 600 ? 16.0 : 24.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Info del paciente + puntaje ────────────────────
                      _InfoCard(
                        nombre: nombre,
                        fecha: formatDate(respuesta.fecha),
                        genero: genero.isEmpty ? '—' : genero,
                        edad: edad == null ? '—' : '$edad',
                        identificacion:
                            (adolescente?.identidad ?? '').trim().isEmpty
                                ? '—'
                                : adolescente!.identidad.trim(),
                        puntaje: respuesta.puntajeTotal,
                        invalidado: respuesta.invalidado,
                        theme: theme,
                      ),

                      // ── Nivel de alerta ────────────────────────────────
                      if (_nivelCalculado().isNotEmpty &&
                          !(_nivelCalculado().toLowerCase().trim() ==
                                  'sin alerta' &&
                              (respuesta.alertasEspeciales
                                      .where((a) => a.trim().isNotEmpty)
                                      .isNotEmpty ||
                                  _tieneIdeacion))) ...[
                        const SizedBox(height: 16.0),
                        _NivelCard(
                          nivel: _nivelCalculado(),
                          categoria: _encuesta?.categoria ?? '',
                          descripcion: _descripcionNivel(
                              _encuesta?.categoria ?? '', _nivelCalculado()),
                          puntaje: respuesta.puntajeTotal,
                          color: _colorNivel(_nivelCalculado()),
                          theme: theme,
                          cdiSub: cdiSub,
                        ),
                      ],

                      // ── ASSIST: riesgo por sustancia ───────────────────
                      if (_assist != null) ...[
                        const SizedBox(height: 16.0),
                        RiesgoSustanciasCard(resultado: _assist!),
                      ],

                      // // ── Subescalas CDI (D + A) ─────────────────────────
                      // if (esCdi && cdiSub != null && cdiSub.tieneVariables) ...[
                      //   const SizedBox(height: 12.0),
                      //   _CdiSubescalasCard(
                      //     g: respuesta.puntajeTotal,
                      //     d: cdiSub.d,
                      //     a: cdiSub.a,
                      //     nivelCalculado: _nivelCalculado().toLowerCase(),
                      //     theme: theme,
                      //   ),
                      // ],

                      // ── Alertas especiales disparadas ──────────────────
                      if (respuesta.alertasEspeciales
                          .where((a) => a.trim().isNotEmpty)
                          .isNotEmpty) ...[
                        const SizedBox(height: 16.0),
                        _AlertasEspecialesCard(
                          alertas: respuesta.alertasEspeciales
                              .where((a) => a.trim().isNotEmpty)
                              .toList(),
                          theme: theme,
                        ),
                      ],

                      // ── Alerta ideación suicida ────────────────────────
                      if (_tieneIdeacion) ...[
                        const SizedBox(height: 16.0),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE5E5),
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(color: Colors.red.shade300),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: const Icon(Icons.warning_amber,
                                    color: Colors.red, size: 24),
                              ),
                              const SizedBox(width: 14.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Alerta de ideación suicida',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w700,
                                        color: Colors.red.shade700,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Se detectó posible ideación suicida. '
                                      'Se recomienda intervención inmediata.',
                                      style: GoogleFonts.inter(
                                        color: Colors.red.shade600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // ── Alerta clínica ansiedad moderada/severa ────────
                      if (_encuesta?.categoria == 'Escala ansiedad' &&
                          (_nivelCalculado()
                                  .toLowerCase()
                                  .contains('moderado') ||
                              _nivelCalculado()
                                  .toLowerCase()
                                  .contains('severo'))) ...[
                        const SizedBox(height: 16.0),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3CD),
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                                color: const Color(0xFFE6A817), width: 1.2),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE6A817)
                                      .withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: const Icon(Icons.psychology_outlined,
                                    color: Color(0xFFB97900), size: 24),
                              ),
                              const SizedBox(width: 14.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Alerta — Atención psicológica requerida',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF7A4F00),
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'El nivel de ansiedad detectado '
                                      '(${_nivelCalculado()}) requiere '
                                      'atención por psicología de forma inmediata.',
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFF7A4F00),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // ── Respuestas ─────────────────────────────────────
                      const SizedBox(height: 24.0),
                      _SectionTitle(
                          title: 'Respuestas del paciente',
                          icon: Icons.quiz_outlined),
                      const SizedBox(height: 12.0),
                      // Las preguntas de sustancias no marcadas en el
                      // Condicionante no aplicaron: no se listan.
                      ...respuesta.test
                          .where((item) => !itemSustanciaNoAplica(
                              item, _encuesta?.preguntas ?? const []))
                          .map(
                        (item) => _PreguntaRespuestaCard(
                          item: item,
                          theme: theme,
                        ),
                      ),

                      // ── Notas del profesional ──────────────────────────
                      const SizedBox(height: 24.0),
                      _SectionTitle(
                          title: 'Notas del profesional',
                          icon: Icons.edit_note),
                      const SizedBox(height: 12.0),
                      Text(
                        'Espacio destinado para el registro del plan de intervención y direccionamiento clínico, incluyendo la ruta de atención sugerida (urgencias, consulta prioritaria o externa), o servicio de remisión (si aplica) y las indicaciones para la red de apoyo del paciente (familia, acudiente o institución educativa)',
                        style: GoogleFonts.inter(
                            fontSize: 13, color: theme.secondaryText),
                        textAlign: TextAlign.justify,
                      ),
                      const SizedBox(height: 12.0),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(color: theme.alternate),
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            RichTextNotasEditor(
                              initialValue: _notasValue,
                              onChanged: (v) => _notasValue = v,
                              placeholder:
                                  'Observaciones, contexto clínico, recomendaciones...',
                              minHeight: 160,
                            ),
                            const SizedBox(height: 12.0),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed:
                                        _guardandoNotas ? null : _guardarNotas,
                                    icon: _guardandoNotas
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white),
                                          )
                                        : const Icon(Icons.save_outlined,
                                            size: 18),
                                    label: Text(
                                      'Guardar notas',
                                      style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: kNavy,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      elevation: 0,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12.0),
                                OutlinedButton.icon(
                                  onPressed: adolescente == null
                                      ? null
                                      : () => showAgendarRecordatorioDialog(
                                            context,
                                            adolescenteRef:
                                                adolescente.reference,
                                            encuestaRef:
                                                respuesta.parentReference,
                                            tituloDefault:
                                                'Seguimiento ${respuesta.titlo}',
                                            pacienteNombre:
                                                adolescente.displayName,
                                            // En el teléfono, hoja inferior.
                                            useBottomSheet:
                                                MediaQuery.sizeOf(context)
                                                        .width <
                                                    600,
                                          ),
                                  icon: const Icon(Icons.alarm, size: 18),
                                  label: Text(
                                    'Recordatorio',
                                    style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: kNavy,
                                    side: const BorderSide(color: kNavy),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14, horizontal: 20),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sub-componentes ─────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.icon});
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: kNavy, size: 20.0),
        const SizedBox(width: 8.0),
        Text(
          title,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: kNavy,
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.nombre,
    required this.fecha,
    required this.genero,
    required this.edad,
    required this.identificacion,
    required this.puntaje,
    required this.invalidado,
    required this.theme,
  });

  final String nombre;
  final String fecha;
  final String genero;
  final String edad;
  final String identificacion;
  final int puntaje;
  final bool invalidado;
  final FlutterFlowTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: theme.alternate),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      // En pantallas estrechas (teléfono) los datos se apilan en 3 bloques;
      // en pantallas anchas se mantienen en una fila.
      child: LayoutBuilder(
        builder: (context, constraints) =>
            constraints.maxWidth < 560 ? _apilada() : _enFila(),
      ),
    );
  }

  String get _edadTexto => edad == '—' ? edad : '$edad años';

  Widget _avatar() => Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: kNavy.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Text(
          nombre.isNotEmpty ? nombre[0].toUpperCase() : '?',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: kNavy,
          ),
        ),
      );

  Widget _estado() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: invalidado ? const Color(0xFFFFC4C4) : const Color(0xFFE5F9F1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: invalidado ? kDanger : kSuccess,
            width: 0.8,
          ),
        ),
        child: Text(
          invalidado ? 'Invalidado' : 'Completado',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: invalidado ? kDanger : kSuccess,
          ),
        ),
      );

  Widget _nombre() => Text(
        nombre,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: theme.primaryText,
        ),
      );

  /// Fila "icono · etiqueta · valor" del bloque de datos (teléfono).
  Widget _dato(IconData icono, String etiqueta, String valor) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Icon(icono, size: 16, color: theme.secondaryText),
            const SizedBox(width: 8),
            SizedBox(
              width: 110,
              child: Text(
                etiqueta,
                style:
                    GoogleFonts.inter(fontSize: 13, color: theme.secondaryText),
              ),
            ),
            Expanded(
              child: Text(
                valor,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.primaryText,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _apilada() {
    final divisor = Divider(height: 1, thickness: 1, color: theme.alternate);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Nombre + estado
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _avatar(),
              const SizedBox(width: 12),
              Expanded(child: _nombre()),
              const SizedBox(width: 8),
              _estado(),
            ],
          ),
        ),
        divisor,
        // 2. Datos
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            children: [
              _dato(Icons.calendar_today_outlined, 'Fecha', fecha),
              _dato(Icons.person_outline, 'Género', genero),
              _dato(Icons.cake_outlined, 'Edad', _edadTexto),
              _dato(Icons.badge_outlined, 'Identificación', identificacion),
            ],
          ),
        ),
        // 3. Puntaje
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: kNavy.withValues(alpha: 0.06),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(14),
              bottomRight: Radius.circular(14),
            ),
          ),
          child: Row(
            children: [
              Text(
                'Puntaje',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kNavy,
                ),
              ),
              const Spacer(),
              Text(
                '$puntaje',
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: kNavy,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _enFila() {
    TextStyle secundario() =>
        GoogleFonts.inter(fontSize: 13, color: theme.secondaryText);
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          _avatar(),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _nombre(),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 13, color: theme.secondaryText),
                    const SizedBox(width: 4),
                    Text(fecha, style: secundario()),
                  ],
                ),
                const SizedBox(height: 6),
                Text('Género: $genero', style: secundario()),
                const SizedBox(height: 2),
                Text('Edad: $_edadTexto', style: secundario()),
                const SizedBox(height: 2),
                Text('Identificación: $identificacion', style: secundario()),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: kNavy.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text('Puntaje',
                    style: GoogleFonts.inter(
                        fontSize: 11, color: theme.secondaryText)),
                const SizedBox(height: 2),
                Text(
                  '$puntaje',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: kNavy,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _estado(),
        ],
      ),
    );
  }
}

class _NivelCard extends StatelessWidget {
  const _NivelCard({
    required this.nivel,
    required this.categoria,
    required this.descripcion,
    required this.puntaje,
    required this.color,
    required this.theme,
    this.cdiSub,
  });

  final String nivel;
  final String categoria;
  final String descripcion;
  final int puntaje;
  final Color color;
  final FlutterFlowTheme theme;
  final ({int d, int a, bool tieneVariables})? cdiSub;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.5)),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.insights, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nivel · ${categoria.isEmpty ? 'Tamizaje' : categoria}',
                  style: GoogleFonts.inter(
                    color: theme.secondaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      nivel,
                      style: GoogleFonts.inter(
                        color: color,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        '($puntaje pts)',
                        style: GoogleFonts.inter(
                          color: theme.secondaryText,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                if (descripcion.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    descripcion,
                    style: GoogleFonts.inter(
                      color: theme.primaryText,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                    ),
                  ),
                ],
                if (categoria == 'CDI') ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: color.withValues(alpha: 0.25)),
                    ),
                    child: Text(
                      'Disforia: ${cdiSub!.d}\nAutoestima negativa: ${cdiSub!.a}',
                      style: GoogleFonts.inter(
                        color: theme.primaryText,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
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

// ─── Card de alertas especiales disparadas ──────────────────────────────────

class _AlertasEspecialesCard extends StatelessWidget {
  const _AlertasEspecialesCard({
    required this.alertas,
    required this.theme,
  });

  final List<String> alertas;
  final FlutterFlowTheme theme;

  @override
  Widget build(BuildContext context) {
    const naranja = Color(0xFFFF8A00);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: naranja.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: naranja.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.notifications_active_outlined,
                    color: naranja, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alertas especiales disparadas',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFB35900),
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Las respuestas del paciente cumplieron una o más '
                      'condiciones definidas al configurar este tamizaje.',
                      style: GoogleFonts.inter(
                        color: theme.primaryText,
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final a in alertas)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: naranja, width: 1.2),
                  ),
                  child: Text(
                    a,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFB35900),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreguntaRespuestaCard extends StatelessWidget {
  const _PreguntaRespuestaCard({required this.item, required this.theme});

  final RespuestaTestStruct item;
  final FlutterFlowTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: theme.alternate),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: kNavy.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${item.nPregunta}',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: kNavy,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.pregunta,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: theme.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  respuestaTexto(item),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: theme.secondaryText,
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

// /// Tarjeta de subescalas CDI: muestra G, D y A con sus valores.
// class _CdiSubescalasCard extends StatelessWidget {
//   const _CdiSubescalasCard({
//     required this.g,
//     required this.d,
//     required this.a,
//     required this.nivelCalculado,
//     required this.theme,
//   });

//   final int g;
//   final int d;
//   final int a;
//   final String nivelCalculado;
//   final FlutterFlowTheme theme;

//   @override
//   Widget build(BuildContext context) {
//     String nivelTexto = nivelCalculado;
//     if (nivelCalculado.contains('severo') || nivelCalculado.contains('grave')) {
//       nivelTexto = 'una depresión severa';
//     } else if (nivelCalculado.contains('leve')) {
//       nivelTexto = 'una depresión leve';
//     } else if (nivelCalculado.contains('sin sintomatología')) {
//       nivelTexto = 'sin sintomatología depresiva';
//     }

//     return Container();
//   }
// }

// class _SubescalaChip extends StatelessWidget {
//   const _SubescalaChip({
//     required this.label,
//     required this.valor,
//     required this.color,
//   });

//   final String label;
//   final int valor;
//   final Color color;

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//         decoration: BoxDecoration(
//           color: color.withValues(alpha: 0.08),
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: color.withValues(alpha: 0.25)),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               label,
//               style: GoogleFonts.inter(
//                 fontSize: 10,
//                 fontWeight: FontWeight.w600,
//                 color: color,
//               ),
//             ),
//             const SizedBox(height: 2),
//             Text(
//               '$valor pts',
//               style: GoogleFonts.inter(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w800,
//                 color: color,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
