import '/backend/backend.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// Utilidades compartidas para Tamizajes
// ═══════════════════════════════════════════════════════════════════════════════

/// Formatea una fecha como dd/MM/yyyy.
/// Retorna [fallback] si [dt] es null (por defecto '—').
String formatDate(DateTime? dt, {String fallback = '—'}) {
  if (dt == null) return fallback;
  return '${dt.day.toString().padLeft(2, '0')}/'
      '${dt.month.toString().padLeft(2, '0')}/'
      '${dt.year}';
}

/// Extrae el texto legible de una respuesta de tamizaje.
///
/// Busca en orden: respuesta libre → selección única → selecciones múltiples
/// → selección legacy → atributos de tamizaje.
String respuestaTexto(RespuestaTestStruct item, {String fallback = '—'}) {
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
  if (item.respuestaTamizaje.isNotEmpty) {
    return item.respuestaTamizaje.map((e) => e.etiqueta).join(', ');
  }
  return fallback;
}

/// Retorna `true` si alguna respuesta del test tiene ideación suicida.
bool hasIdeacion(List<RespuestaTestStruct> test) {
  for (final item in test) {
    for (final atributo in item.respuestaTamizaje) {
      if (atributo.ideacionSuicida) return true;
    }
  }
  return false;
}

/// Obtiene la referencia al adolescente de una respuesta, soportando ambas
/// convenciones de almacenamiento:
///   - `/Encuestas/{id}/Respuestas/...` → usa `userRespuesta`
///   - `/users/{id}/Respuestas/...`     → usa `parentReference`
DocumentReference? adolescenteRef(RespuestasRecord r) =>
    r.userRespuesta ?? r.parentReference;

/// Respuestas vacías de [preguntas], una por pregunta y en el mismo orden.
///
/// Los componentes de respuesta escriben con
/// `FFAppState().updateRespuestaEncAtIndex(i, …)`, así que `RespuestaEnc`
/// debe tener una entrada por pregunta antes de abrir el tamizaje (y al
/// cancelar y volver a empezar).
List<RespuestaTestStruct> respuestasIniciales(
  List<PreguntasEncuestaStruct> preguntas,
  DocumentReference? userRef,
) =>
    [
      for (var i = 0; i < preguntas.length; i++)
        RespuestaTestStruct(
          pregunta: preguntas[i].pregunta,
          tipo: preguntas[i].tipo,
          nPregunta: i + 1,
          userRef: userRef,
          respuestaSelection: preguntas[i].respuestaSelection,
          rSeleccionUnica: preguntas[i].respuestasSeleccionUnica,
        ),
    ];
