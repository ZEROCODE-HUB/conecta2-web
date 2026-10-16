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
/// - Autoestima, CDI, Beck y ansiedad: rangos `[min, max]` configurados en la
///   encuesta ([nivelPorRangos]; fuera de todos → [kSinAlerta]) o, si no hay
///   rangos, los cortes clínicos por defecto (`classifyNivel`).
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

  if (usaNivelesGlobales(categoria)) {
    return nivelPorPuntaje(
      categoria: categoria,
      puntaje: puntajeTotal,
      alertas: encuesta.alertas,
    );
  }

  return calcularNivelAlerta(
    categoria: categoria,
    puntaje: puntajeTotal,
    alertas: encuesta.alertas.toList(),
  );
}

/// Nivel de CDI, autoestima, ansiedad y Beck a partir del puntaje total.
///
/// Rangos `[min, max]` configurados ([nivelPorRangos]; fuera de todos →
/// [kSinAlerta]). Si la encuesta no tiene rangos de su categoría, cortes
/// clínicos por defecto (`classifyNivel`). La usan [calcularNivelRespuesta] y
/// la Tabulación General.
String nivelPorPuntaje({
  required String categoria,
  required num puntaje,
  required Iterable<AlertaStruct> alertas,
}) {
  final porRangos =
      nivelPorRangos(categoria: categoria, puntaje: puntaje, alertas: alertas);
  if (porRangos != null) return porRangos;

  final String clave;
  switch (categoria) {
    case 'Escala autoestima':
      clave = 'autoestima';
      break;
    case 'CDI':
      clave = 'cdi';
      break;
    case 'Depresión Beck':
      clave = 'beck';
      break;
    case 'Escala ansiedad':
      clave = 'ansiedad';
      break;
    default:
      return '';
  }
  return classifyNivel(clave, const [], puntajeTotal: puntaje);
}

/// Nivel de una respuesta para las gráficas de Estadísticas.
///
/// Misma regla que el detalle del tamizaje ([calcularNivelRespuesta], con los
/// rangos configurados en la encuesta). Solo si no se puede clasificar así
/// (encuesta sin categoría o sin rangos) se usan los cortes por defecto de
/// [classifyNivel], como antes.
///
/// [respuesta] es el documento crudo de `Respuestas`; [items] son sus ítems
/// (`test` + `Respusta`) ya aplanados, para el cálculo de respaldo.
String nivelParaEstadisticas({
  required EncuestasRecord? encuesta,
  required Map<String, dynamic> respuesta,
  required String titulo,
  required List<Map<String, dynamic>> items,
}) {
  final puntaje = respuesta['puntajeTotal'] as num?;
  if (encuesta != null) {
    final test = <RespuestaTestStruct>[
      for (final e in (respuesta['test'] as List?) ?? const [])
        if (RespuestaTestStruct.maybeFromMap(e) case final r?) r,
    ];
    final nivel = calcularNivelRespuesta(
      encuesta: encuesta,
      puntajeTotal: puntaje?.round() ?? 0,
      test: test,
    );
    if (nivel.isNotEmpty) return nivel;
  }
  return classifyNivel(
    titulo,
    items,
    puntajeTotal: puntaje,
    alertasEspeciales: (respuesta['alertasEspeciales'] as List?)
        ?.map((e) => e.toString())
        .toList(),
  );
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
/// Sin riesgo: vacío, "Sin alerta" (incluye el puntaje fuera de todos los
/// rangos, [kSinAlerta]), "Sin sintomatología", "Mínima", "Bajo"
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

/// `true` si [nivel] es [kSinAlerta] porque el puntaje no cayó en ningún rango
/// configurado (CDI, autoestima, ansiedad, Beck y Consumo de SPA). En
/// SRQ/RQC/CRQ "Sin alerta" es el nivel sano configurado y devuelve `false`.
bool esSinAlertaPorRango(String? categoria, String nivel) =>
    nivel == kSinAlerta &&
    (usaNivelesGlobales(categoria) || categoria == kCategoriaAssist);

/// Gravedad de un nivel para los PDF: 0 = sin riesgo (incluye
/// [kSinAlerta]), 1 = intermedio (Leve, Moderado/a), 2 = el más severo
/// (Severo, Grave, autoestima Baja).
int gravedadNivel(String nivel) {
  if (!nivelConRiesgo(nivel)) return 0;
  final n = _sinTildes(nivel.trim().toLowerCase());
  if (n.contains('sever') || n.contains('grave') || n.contains('baja')) {
    return 2;
  }
  return 1;
}
