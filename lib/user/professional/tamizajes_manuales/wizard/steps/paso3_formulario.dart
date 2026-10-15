import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../state/respuesta_state.dart';
import '../widgets/pregunta_card.dart';

/// Wizard step 3: apply the tamizaje and answer every question.
///
/// Si el tamizaje tiene preguntas 'Condicionante' (ASSIST / Consumo de SPA),
/// el paso se divide como en el flujo del adolescente:
///  - 3a "Consumo": solo los Condicionantes (selección múltiple) y las
///    Descriptivas que los preceden;
///  - 3b "Preguntas": el resto, mostrando solo las preguntas de las sustancias
///    marcadas. Las ocultas no se validan y se guardan sin respuesta.
class PasoFormulario extends StatefulWidget {
  const PasoFormulario({
    super.key,
    required this.encuesta,
    required this.adolescente,
    required this.onFinalizado,
  });

  final EncuestasRecord encuesta;
  final UsersRecord? adolescente;
  /// Devuelve true si se guardó; si es false, el formulario se reactiva
  /// para reintentar.
  final Future<bool> Function(
    List<RespuestaTestStruct> respuestas,
    int puntajeTotal,
    bool tieneIdeacion,
  ) onFinalizado;

  @override
  State<PasoFormulario> createState() => _PasoFormularioState();
}

class _PasoFormularioState extends State<PasoFormulario> {
  late final List<RespuestaState> _estados;
  bool _enviando = false;

  /// true = sub-paso 3a (Condicionantes); false = sub-paso 3b (preguntas).
  bool _enConsumo = false;

  @override
  void initState() {
    super.initState();
    _estados =
        widget.encuesta.preguntas.map((p) => RespuestaState(p)).toList();
    _enConsumo = _estados.any((e) => e.esCondicionante);
  }

  VisibilidadAssist get _visibilidad => VisibilidadAssist(_estados);

  /// Índices de las preguntas del sub-paso 3a: Condicionantes y las
  /// Descriptivas que aparecen antes del primer Condicionante.
  Set<int> get _indicesConsumo {
    final primero = _estados.indexWhere((e) => e.esCondicionante);
    if (primero < 0) return {};
    return {
      for (var i = 0; i < _estados.length; i++)
        if (_estados[i].esCondicionante ||
            (i < primero &&
                _estados[i].tipoKind == PreguntaTipo.descriptiva))
          i,
    };
  }

  List<int> get _indicesVisibles {
    final vis = _visibilidad;
    final consumo = _indicesConsumo;
    return [
      for (var i = 0; i < _estados.length; i++)
        if (_enConsumo ? consumo.contains(i) : !consumo.contains(i))
          if (vis.esVisible(_estados[i])) i,
    ];
  }

  void _continuar() {
    for (final i in _indicesConsumo) {
      if (!_estados[i].estaCompleto()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Marque al menos una opción en la pregunta ${i + 1}')),
        );
        return;
      }
    }
    // Las preguntas de sustancias desmarcadas no deben conservar respuesta.
    _visibilidad.limpiarOcultas(_estados);
    setState(() => _enConsumo = false);
  }

  Future<void> _enviar() async {
    final vis = _visibilidad;
    for (var i = 0; i < _estados.length; i++) {
      final s = _estados[i];
      if (!vis.esVisible(s)) continue;
      if (!s.estaCompleto()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falta responder la pregunta ${i + 1}')),
        );
        return;
      }
    }

    setState(() => _enviando = true);

    final respuestas = <RespuestaTestStruct>[];
    var puntaje = 0;
    var ideacion = false;
    for (var i = 0; i < _estados.length; i++) {
      final s = _estados[i];
      final r = s.toStruct(i + 1, visible: vis.esVisible(s));
      respuestas.add(r);
      for (final atr in r.respuestaTamizaje) {
        puntaje += atr.valor;
        if (atr.ideacionSuicida) ideacion = true;
      }
    }
    final ok = await widget.onFinalizado(respuestas, puntaje, ideacion);
    if (!ok && mounted) setState(() => _enviando = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final vis = _visibilidad;
    final visiblesTotales = [
      for (final e in _estados)
        if (vis.esVisible(e)) e,
    ];
    final total = visiblesTotales.length;
    final respondidas = visiblesTotales.where((s) => s.estaCompleto()).length;
    final indices = _indicesVisibles;
    final tieneConsumo = _indicesConsumo.isNotEmpty;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          color: theme.secondaryBackground,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.encuesta.titulo,
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: theme.primaryText,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (widget.adolescente != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBE5A1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.person,
                              size: 14, color: Color(0xFF265294)),
                          const SizedBox(width: 4),
                          Text(
                            widget.adolescente!.displayName,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF265294),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Spacer(),
                  Text(
                    '$respondidas / $total',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.secondaryText,
                    ),
                  ),
                ],
              ),
              if (tieneConsumo) ...[
                const SizedBox(height: 8),
                Text(
                  _enConsumo
                      ? 'Parte 1 de 2 · Consumo: marque las sustancias que aplican'
                      : 'Parte 2 de 2 · Preguntas de las sustancias marcadas',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF265294),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: total > 0 ? respondidas / total : 0,
                  backgroundColor: theme.alternate,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF34A853)),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: indices.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'No hay preguntas que responder para las opciones '
                      'marcadas. Puede finalizar el tamizaje.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          fontSize: 14, color: theme.secondaryText),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  itemCount: indices.length,
                  itemBuilder: (context, k) {
                    final i = indices[k];
                    return MobilePreguntaCard(
                      numero: i + 1,
                      estado: _estados[i],
                      theme: theme,
                      onChanged: () => setState(() {}),
                    );
                  },
                ),
        ),
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
          child: Row(
            children: [
              if (tieneConsumo && !_enConsumo) ...[
                OutlinedButton.icon(
                  onPressed: _enviando
                      ? null
                      : () => setState(() => _enConsumo = true),
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: Text('Consumo',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF265294),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _enviando
                      ? null
                      : (_enConsumo ? _continuar : _enviar),
                  icon: _enviando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Icon(
                          _enConsumo
                              ? Icons.arrow_forward
                              : Icons.check_circle_outline,
                          size: 20),
                  label: Text(
                    _enConsumo ? 'Continuar' : 'Finalizar y guardar',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF265294),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        const Color(0xFF265294).withValues(alpha: 0.5),
                    disabledForegroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
