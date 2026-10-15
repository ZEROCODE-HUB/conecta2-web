import '/backend/backend.dart';
import '/components/admin_estadsticas/helpers/classification.dart';
import '/dashboard/web/encuestas/editar/widgets/tamizajes_niveles.dart';
import '/tamizajes/shared/assist_utils.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// Nivel de una respuesta de tamizaje (fuente única)
// ═══════════════════════════════════════════════════════════════════════════════
//
// La usan el detalle del tamizaje, las pantallas de Resultados de los wizards y
// los flujos que guardan la respuesta (se guarda en `Respuestas.nivelAlerta`).
// La Cloud Function `onTamizajeManualAlertaNotificarPadres` lee ese campo y
// aplica `nivelConRiesgo` (portada a JS con la misma regla).

/// Nivel de la respuesta según su tamizaje. '' si no se puede clasificar.
///
/// - ASSIST (Consumo de SPA): el peor nivel por sustancia.
/// - Autoestima, CDI, Beck y ansiedad: umbrales configurados en la encuesta
///   o, si faltan, los cortes clínicos por defecto (`classifyNivel`).
/// - Resto (CRQ/SRQ/RQC…): rangos de `Encuesta.alertas`.
String calcularNivelRespuesta({
  required EncuestasRecord encuesta,
  required int puntajeTotal,
  required List<RespuestaTestStruct> test,
}) {
  if (esEncuestaAssist(encuesta.categoria, encuesta.titulo)) {
    return evaluarAssistDesdeStructs(
      preguntas: encuesta.preguntas,
      test: test,
      alertas: encuesta.alertas,
    ).nivelGlobal;
  }
  final categoria = encuesta.categoria;
  if (categoria.isEmpty) return '';

  if (usaNivelesGlobales(categoria) || categoria == 'Depresión Beck') {
    final String titulo;
    switch (categoria) {
      case 'Escala autoestima':
        titulo = 'autoestima';
        break;
      case 'CDI':
        titulo = 'cdi';
        break;
      case 'Depresión Beck':
        titulo = 'beck';
        break;
      case 'Escala ansiedad':
        titulo = 'ansiedad';
        break;
      default:
        titulo = encuesta.titulo;
    }
    return classifyNivel(
      titulo,
      const [],
      puntajeTotal: puntajeTotal,
      umbrales: _umbralesDe(encuesta),
    );
  }

  return calcularNivelAlerta(
    categoria: categoria,
    puntaje: puntajeTotal,
    alertas: encuesta.alertas.toList(),
  );
}

/// Umbrales configurados al crear el tamizaje, para `classifyNivel`.
/// `null` si el documento no los tiene (se usan los cortes clínicos).
UmbralesConfig? _umbralesDe(EncuestasRecord e) {
  final cat = e.categoria;
  if (cat == 'Escala autoestima' || cat == 'CDI' || cat == 'Escala ansiedad') {
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

String _sinTildes(String s) {
  const con = 'áéíóúüñ';
  const sin = 'aeiouun';
  final b = StringBuffer();
  for (final ch in s.split('')) {
    final i = con.indexOf(ch);
    b.write(i >= 0 ? sin[i] : ch);
  }
  return b.toString();
}

/// `true` si el nivel implica riesgo y amerita avisar al acudiente.
///
/// Sin riesgo: vacío, "Sin alerta", "Sin sintomatología", "Mínima", "Bajo"
/// (ASSIST) y autoestima "Media"/"Elevada". Con riesgo: Leve, Moderado/a,
/// Severo, Grave, Alto, autoestima "Baja", subescalas.
/// Misma regla que `nivelConRiesgo` de la Cloud Function.
bool nivelConRiesgo(String nivel) {
  final n = _sinTildes(nivel.trim().toLowerCase());
  if (n.isEmpty) return false;
  if (n.startsWith('sin ') ||
      n.contains('sin alerta') ||
      n.contains('sin sintomatologia')) {
    return false;
  }
  if (n == 'minima' || n == 'bajo') return false;
  if (n.contains('media') || n.contains('elevada')) return false;
  return true;
}
