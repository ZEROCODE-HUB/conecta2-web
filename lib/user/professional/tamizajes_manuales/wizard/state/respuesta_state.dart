import '/backend/backend.dart';
import '/tamizajes/shared/assist_utils.dart';
import 'package:flutter/material.dart';

/// Canonical question-type kinds, decoupled from the raw DB string.
///
/// DB strings can include accented/non-accented variants, plural typos, and
/// case differences (e.g. 'Selección' vs 'seleccion'). Use [PreguntaTipo.from]
/// to resolve any raw value to a known kind.
enum PreguntaTipo {
  descriptiva,
  abiertas,
  seleccionMultiple,
  seleccionUnica,
  verdaderoFalso,
  tamizajeRadio,
  tamizajeSustancias,
  condicionante,
  desconocido,
}

/// Normalise a raw string: lowercase, trim, strip accents.
String _normalizeTipo(String? raw) {
  if (raw == null) return '';
  const withAccents = 'áéíóúüñÁÉÍÓÚÜÑ';
  const withoutAccents = 'aeiouunAEIOUUN';
  var s = raw.trim().toLowerCase();
  final buffer = StringBuffer();
  for (final ch in s.split('')) {
    final idx = withAccents.indexOf(ch);
    buffer.write(idx >= 0 ? withoutAccents[idx] : ch);
  }
  return buffer.toString();
}

PreguntaTipo resolvePreguntaTipo(String? raw) {
  final n = _normalizeTipo(raw);
  if (n.isEmpty) return PreguntaTipo.desconocido;
  if (n == 'descriptiva') return PreguntaTipo.descriptiva;
  if (n == 'abiertas' || n == 'abierta') return PreguntaTipo.abiertas;
  if (n == 'seleccion') return PreguntaTipo.seleccionMultiple;
  if (n == 'seleccion unica' ||
      n == 'seleccion_unica' ||
      n == 'selecciónunica' ||
      n == 'seleccionunica') {
    return PreguntaTipo.seleccionUnica;
  }
  if (n == 'verdadero o falso' || n == 'v/f' || n == 'vf') {
    return PreguntaTipo.verdaderoFalso;
  }
  if (n == 'tamizaje (sustancias)' || n == 'tamizaje sustancias') {
    return PreguntaTipo.tamizajeSustancias;
  }
  if (n == 'condicionante') return PreguntaTipo.condicionante;
  // Any tamizaje-family type that isn't Sustancias behaves as a radio choice
  // over `respuestaTamizaje` attributes.
  if (n.startsWith('tamizaje') || n.startsWith('tamizajes')) {
    return PreguntaTipo.tamizajeRadio;
  }
  return PreguntaTipo.desconocido;
}

/// Per-question answer state for the tamizaje wizard.
class RespuestaState {
  RespuestaState(this.pregunta) {
    textController = TextEditingController();
  }

  final PreguntasEncuestaStruct pregunta;
  late final TextEditingController textController;

  /// Selected attribute (for tamizaje-type radio questions).
  AtributosStruct? atributoSeleccionado;

  /// Multiple selection ('seleccion').
  final Set<String> seleccionMultiple = {};

  /// Single selection ('Selección única').
  String? seleccionUnica;

  /// True/false (1 = true, 0 = false).
  int? trueAndFalseSeleccion;

  /// Opciones marcadas (etiquetas) en una pregunta 'Condicionante'. Es de
  /// selección múltiple: cada opción habilita su `sustanciaValor`.
  final Set<String> condicionanteSeleccionadas = {};

  /// Tipo de la pregunta. Las preguntas de sustancia legacy (`Tamizaje` con
  /// `sustancia`) se tratan igual que `Tamizaje (Sustancias)`.
  PreguntaTipo get tipoKind {
    final kind = resolvePreguntaTipo(pregunta.tipo);
    if (kind == PreguntaTipo.tamizajeRadio && esPreguntaSustancia(pregunta)) {
      return PreguntaTipo.tamizajeSustancias;
    }
    return kind;
  }

  bool esTamizajeRadio() => tipoKind == PreguntaTipo.tamizajeRadio;

  bool get esCondicionante => tipoKind == PreguntaTipo.condicionante;

  bool get esSustancia => tipoKind == PreguntaTipo.tamizajeSustancias;

  bool get esObligatoria => pregunta.nPregunta == 1;

  /// `sustanciaValor` de las opciones marcadas en un Condicionante.
  List<String> get sustanciasMarcadas => [
        for (final opt in pregunta.respuestaCondicionante)
          if (condicionanteSeleccionadas.contains(opt.etiqueta) &&
              opt.sustanciaValor.trim().isNotEmpty)
            opt.sustanciaValor,
      ];

  /// Borra la respuesta (p. ej. cuando la pregunta queda oculta porque se
  /// desmarcó su sustancia en el Condicionante).
  void limpiarRespuesta() {
    atributoSeleccionado = null;
  }

  bool estaCompleto() {
    switch (tipoKind) {
      case PreguntaTipo.descriptiva:
        return true;
      case PreguntaTipo.abiertas:
        return textController.text.trim().isNotEmpty;
      case PreguntaTipo.seleccionMultiple:
        return seleccionMultiple.isNotEmpty;
      case PreguntaTipo.seleccionUnica:
        return seleccionUnica != null && seleccionUnica!.isNotEmpty;
      case PreguntaTipo.verdaderoFalso:
        return trueAndFalseSeleccion != null;
      case PreguntaTipo.tamizajeRadio:
        return atributoSeleccionado != null;
      case PreguntaTipo.tamizajeSustancias:
        return atributoSeleccionado != null;
      case PreguntaTipo.condicionante:
        // Igual que el flujo del adolescente: si es obligatoria exige al menos
        // una opción; si no, puede quedar sin marcar (no consume ninguna).
        return !esObligatoria || condicionanteSeleccionadas.isNotEmpty;
      case PreguntaTipo.desconocido:
        // Unknown types cannot block the form; treat as completed.
        return true;
    }
  }

  /// Serializa la respuesta. Si la pregunta está oculta ([visible] = false,
  /// sustancia no marcada en el Condicionante) se guarda sin respuesta para
  /// conservar la alineación `NPregunta` ↔ `Encuesta.Preguntas`.
  RespuestaTestStruct toStruct(int numero, {bool visible = true}) {
    final kind = tipoKind;
    final rawTipo = pregunta.tipo;

    if (!visible) {
      return RespuestaTestStruct(
        pregunta: pregunta.pregunta,
        tipo: rawTipo,
        nPregunta: numero,
        respuestaTamizaje: const [],
      );
    }

    // Collect tamizaje attributes.
    List<AtributosStruct> tamizajeList = [];
    if (kind == PreguntaTipo.tamizajeRadio && atributoSeleccionado != null) {
      tamizajeList = [atributoSeleccionado!];
    } else if (kind == PreguntaTipo.tamizajeSustancias &&
        atributoSeleccionado != null) {
      final opt = atributoSeleccionado!;
      tamizajeList = [
        AtributosStruct(
          etiqueta: '${canonicaSustancia(pregunta.sustancia)}: ${opt.etiqueta}',
          valor: opt.valor,
          ideacionSuicida: opt.ideacionSuicida,
        ),
      ];
    } else if (kind == PreguntaTipo.condicionante) {
      tamizajeList = [
        for (final opt in pregunta.respuestaCondicionante)
          if (condicionanteSeleccionadas.contains(opt.etiqueta))
            AtributosStruct(etiqueta: opt.etiqueta, valor: 0),
      ];
    }

    String respuestaSU = '';
    if ((kind == PreguntaTipo.tamizajeRadio ||
            kind == PreguntaTipo.tamizajeSustancias) &&
        atributoSeleccionado != null) {
      respuestaSU = atributoSeleccionado!.etiqueta;
    } else if (kind == PreguntaTipo.condicionante) {
      respuestaSU = [
        for (final opt in pregunta.respuestaCondicionante)
          if (condicionanteSeleccionadas.contains(opt.etiqueta)) opt.etiqueta,
      ].join(', ');
    } else if (kind == PreguntaTipo.seleccionUnica) {
      respuestaSU = seleccionUnica ?? '';
    }

    return RespuestaTestStruct(
      pregunta: pregunta.pregunta,
      tipo: rawTipo,
      nPregunta: numero,
      respuesta:
          kind == PreguntaTipo.abiertas ? textController.text.trim() : '',
      respuestaSeleccionUnica: respuestaSU,
      // Condicionante: mismo formato que el flujo del adolescente
      // (sustancias habilitadas).
      respuestasSeleccionadas: kind == PreguntaTipo.seleccionMultiple
          ? seleccionMultiple.toList()
          : kind == PreguntaTipo.condicionante
              ? sustanciasMarcadas
              : <String>[],
      trueAndFalse: trueAndFalseSeleccion,
      respuestaTamizaje: tamizajeList,
    );
  }
}

/// Visibilidad de las preguntas de un ASSIST según lo marcado en los
/// Condicionantes (misma regla que el flujo del adolescente): una pregunta de
/// sustancia solo se muestra y valida si su sustancia fue marcada. Sin
/// Condicionante, todas son visibles.
class VisibilidadAssist {
  VisibilidadAssist(List<RespuestaState> estados)
      : conCondicionante = estados.any((e) => e.esCondicionante),
        permitidas = sustanciasPermitidasDesde(estados
            .where((e) => e.esCondicionante)
            .expand((e) => e.sustanciasMarcadas));

  final bool conCondicionante;
  final Set<String> permitidas;

  bool esVisible(RespuestaState e) =>
      !e.esSustancia ||
      !conCondicionante ||
      permitidas.contains(normalizarSustancia(e.pregunta.sustancia));

  /// Limpia las respuestas de las preguntas que quedaron ocultas.
  void limpiarOcultas(List<RespuestaState> estados) {
    for (final e in estados) {
      if (!esVisible(e)) e.limpiarRespuesta();
    }
  }
}
