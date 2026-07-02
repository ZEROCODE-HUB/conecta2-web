import '/backend/schema/structs/index.dart';

/// Evaluates special alert conditions defined on a tamizaje (EncuestasRecord)
/// against the actual responses (RespuestaTestStruct) given by the user.
///
/// Returns a list of triggered alert names (strings) that should be saved
/// in the `alertasEspeciales` field of the RespuestasRecord.
List<String> evaluarAlertasEspeciales(
  List<AlertaEspecialStruct> alertas,
  List<RespuestaTestStruct> respuestas,
) {
  final List<String> triggered = [];

  for (final alerta in alertas) {
    if (alerta.nombre.isEmpty || alerta.condicion.isEmpty) continue;

    // Gather the responses for the questions referenced by this alert.
    final preguntasRef = alerta.preguntas;
    if (preguntasRef.isEmpty) continue;

    final relevantes = respuestas
        .where((r) => preguntasRef.contains(r.nPregunta))
        .toList();

    // If we couldn't find any matching responses, skip.
    if (relevantes.isEmpty) continue;

    bool conditionMet = false;

    switch (alerta.condicion) {
      case 'Todas en Sí':
        conditionMet = relevantes.length >= preguntasRef.length &&
            relevantes.every((r) => _respondioSi(r));
        break;

      case 'Al menos una en Sí':
        conditionMet = relevantes.any((r) => _respondioSi(r));
        break;

      case 'Al menos dos en Sí':
        conditionMet =
            relevantes.where((r) => _respondioSi(r)).length >= 2;
        break;

      case 'Todas en No':
        conditionMet = relevantes.length >= preguntasRef.length &&
            relevantes.every((r) => _respondioNo(r));
        break;

      case 'Al menos una en No':
        conditionMet = relevantes.any((r) => _respondioNo(r));
        break;

      case 'Al menos dos en No':
        conditionMet =
            relevantes.where((r) => _respondioNo(r)).length >= 2;
        break;

      case 'Puntaje igual a':
        final sum = relevantes.fold<int>(
          0,
          (acc, r) =>
              acc +
              (r.respuestaTamizaje.isNotEmpty
                  ? r.respuestaTamizaje.first.valor
                  : 0),
        );
        conditionMet = sum == alerta.puntaje;
        break;
    }

    if (conditionMet) {
      triggered.add(alerta.nombre);
    }
  }

  return triggered;
}

/// Checks whether a response was answered "Sí" (Yes).
///
/// Supports several answer formats used across the app:
/// - `respuestaTamizaje` radio options where etiqueta equals 'Sí'
/// - `trueAndFalse` field where 1 means Yes
/// - `respuesta` text containing 'Sí' or 'Si'
/// - `respuestasSeleccionadas` containing 'Sí' or 'Si'
bool _respondioSi(RespuestaTestStruct r) {
  // Tamizaje radio button answer (most common in tamizajes)
  if (r.respuestaTamizaje.isNotEmpty) {
    final selected = r.respuestaTamizaje.first;
    final label = selected.etiqueta.toLowerCase().trim();
    if (label == 'sí' || label == 'si') return true;
  }

  // True/False checkbox
  if (r.hasTrueAndFalse() && r.trueAndFalse == 1) return true;

  // Free-text response
  if (r.hasRespuesta() && r.respuesta.isNotEmpty) {
    final txt = r.respuesta.toLowerCase().trim();
    if (txt == 'sí' || txt == 'si') return true;
  }

  // Single selection containing 'Sí'
  if (r.hasRespuestaSeleccionUnica() && r.respuestaSeleccionUnica.isNotEmpty) {
    final txt = r.respuestaSeleccionUnica.toLowerCase().trim();
    if (txt == 'sí' || txt == 'si') return true;
  }

  // Multiple selection containing 'Sí'
  if (r.respuestasSeleccionadas.isNotEmpty) {
    if (r.respuestasSeleccionadas
        .any((s) => s.toLowerCase().trim() == 'sí' || s.toLowerCase().trim() == 'si')) {
      return true;
    }
  }

  return false;
}

/// Checks whether a response was answered "No".
bool _respondioNo(RespuestaTestStruct r) {
  if (r.respuestaTamizaje.isNotEmpty) {
    final selected = r.respuestaTamizaje.first;
    final label = selected.etiqueta.toLowerCase().trim();
    if (label == 'no') return true;
  }

  if (r.hasTrueAndFalse() && r.trueAndFalse == 0) return true;

  if (r.hasRespuesta() && r.respuesta.isNotEmpty) {
    final txt = r.respuesta.toLowerCase().trim();
    if (txt == 'no') return true;
  }

  if (r.hasRespuestaSeleccionUnica() && r.respuestaSeleccionUnica.isNotEmpty) {
    final txt = r.respuestaSeleccionUnica.toLowerCase().trim();
    if (txt == 'no') return true;
  }

  if (r.respuestasSeleccionadas.isNotEmpty) {
    if (r.respuestasSeleccionadas
        .any((s) => s.toLowerCase().trim() == 'no')) {
      return true;
    }
  }

  return false;
}
