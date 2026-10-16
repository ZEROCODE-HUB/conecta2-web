// Tamizaje processing + card builders styled to match the reference PDF.

import '/dashboard/web/encuestas/editar/widgets/tamizajes_niveles.dart'
    show usaNivelesGlobales;
import '/tamizajes/shared/assist_utils.dart';
import '/tamizajes/shared/nivel_respuesta.dart'
    show gravedadNivel, nivelConRiesgo, nivelPorPuntaje;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '/backend/schema/structs/index.dart';

import '../helpers/pdf_assets.dart';
import '../helpers/pdf_styles.dart';
import 'pdf_observaciones.dart' show parseQuillDeltaToPdf;

const List<String> _kTodasLasSustancias = [
  'Tabaco/Cigarrillo',
  'Bebidas alcohólicas',
  'Cannabis/Marihuana',
  'Cocaína',
  'Estimulantes tipo anfetamina',
  'Inhalantes',
  'Tranquilizantes o pastillas para dormir',
  'Alucinógenos',
  'Opiáceos',
  'Otras drogas',
];

// ---------------------------------------------------------------------------
// Data retrieval
// ---------------------------------------------------------------------------

List<RespustaTamizajeStruct> generarRespuestasPorDefecto() {
  final respuestasDefault = <RespustaTamizajeStruct>[];
  for (var sustancia in _kTodasLasSustancias) {
    try {
      respuestasDefault.add(
        RespustaTamizajeStruct(
          pregunta:
              '¿Con qué frecuencia ha consumido $sustancia en los últimos 3 meses?',
          respuesta: 'Nunca',
        ),
      );
    } catch (e) {
      print('Error al crear respuesta por defecto para $sustancia: $e');
    }
  }
  return respuestasDefault;
}

List<RespustaTamizajeStruct> completarSustanciasFaltantes(
    List<RespustaTamizajeStruct> respuestasExistentes) {
  try {
    final Map<String, bool> sustanciasExistentes = {};
    for (var respuesta in respuestasExistentes) {
      for (var sustancia in _kTodasLasSustancias) {
        if (respuesta.pregunta.contains(sustancia)) {
          sustanciasExistentes[sustancia] = true;
          break;
        }
      }
    }

    final respuestasCompletas = <RespustaTamizajeStruct>[
      ...respuestasExistentes,
    ];
    for (var sustancia in _kTodasLasSustancias) {
      if (!sustanciasExistentes.containsKey(sustancia)) {
        respuestasCompletas.add(
          RespustaTamizajeStruct(
            pregunta:
                '¿Con qué frecuencia ha consumido $sustancia en los últimos 3 meses?',
            respuesta: 'Nunca',
          ),
        );
      }
    }
    return respuestasCompletas;
  } catch (e) {
    print('  ERROR al completar sustancias faltantes: $e');
    return respuestasExistentes;
  }
}

/// Lee los tamizajes del usuario y devuelve **un resultado por documento**
/// `Respuestas`, con su fecha y sus propias notas del profesional, del más
/// reciente al más antiguo. Lee las dos rutas donde se guardan
/// (`/Encuestas/{id}/Respuestas` por `User_respuesta` y
/// `/users/{uid}/Respuestas`) sin duplicar documentos.
Future<List<ResultadoTamizaje>> obtenerTamizajesPorDocumento(
    String userUid) async {
  final resultados = <ResultadoTamizaje>[];
  try {
    final userRef = FirebaseFirestore.instance.collection('users').doc(userUid);
    final docs = <String, DocumentSnapshot<Map<String, dynamic>>>{};

    // 1) Respuestas bajo /Encuestas/{id}/Respuestas filtradas por userRespuesta
    try {
      final snap = await FirebaseFirestore.instance
          .collectionGroup('Respuestas')
          .where('User_respuesta', isEqualTo: userRef)
          .get()
          .timeout(const Duration(seconds: 12));
      for (final doc in snap.docs) {
        docs[doc.reference.path] = doc;
      }
    } catch (e) {
      print('  Info: no se pudo leer collectionGroup Respuestas: $e');
    }

    // 2) Respuestas guardadas bajo /users/{userUid}/Respuestas/...
    try {
      final snap = await userRef
          .collection('Respuestas')
          .get()
          .timeout(const Duration(seconds: 10));
      for (final doc in snap.docs) {
        docs[doc.reference.path] = doc;
      }
    } catch (e) {
      print('  Info: no se pudo leer users/$userUid/Respuestas: $e');
    }

    final encuestasCache = <String, Map<String, dynamic>?>{};
    for (final doc in docs.values) {
      final r = await _resultadoDeDocumento(doc, encuestasCache);
      if (r != null) resultados.add(r);
    }

    resultados.sort((a, b) {
      if (a.fecha == null && b.fecha == null) return 0;
      if (a.fecha == null) return 1;
      if (b.fecha == null) return -1;
      return b.fecha!.compareTo(a.fecha!);
    });
  } catch (e) {
    print('  ERROR al obtener respuestas de tamizaje: $e');
  }
  return resultados;
}

/// Clasifica un único doc de `Respuestas` como una tarjeta propia.
/// Devuelve `null` si no tiene ítems (y no está invalidado).
Future<ResultadoTamizaje?> _resultadoDeDocumento(
  DocumentSnapshot<Map<String, dynamic>> doc,
  Map<String, Map<String, dynamic>?> encuestasCache,
) async {
  try {
    final data = doc.data() ?? const <String, dynamic>{};

    // Encuesta padre: /Encuestas/{id}/Respuestas/{doc}
    Map<String, dynamic>? encuesta;
    final encuestaRef = doc.reference.parent.parent;
    if (encuestaRef != null && encuestaRef.parent.id == 'Encuestas') {
      encuesta = await _encuestaDe(encuestaRef, encuestasCache);
    }
    // Las respuestas a encuestas no van en el informe: solo tamizajes.
    if (encuesta?['tipo'] == 'Encuestas') return null;

    final titulo =
        (data['Titlo'] ?? data['titlo'] ?? encuesta?['titulo'] ?? '')
            .toString()
            .trim();
    final esAssist = esEncuestaAssist(
        (encuesta?['categoria'] ?? '').toString(),
        titulo.isNotEmpty ? titulo : (encuesta?['titulo'] ?? '').toString());
    final fecha = _fechaRespuesta(data);
    final notas = _notasDe(data);

    if (data['invalidado'] == true) {
      final key = esAssist ? 'sustancias' : _clasificarTipo(titulo);
      final motivo = (data['motivoInvalidacion'] ?? '').toString().trim();
      return ResultadoTamizaje(
        titulo: _tituloParaTipo(key, titulo.isEmpty ? 'Tamizaje' : titulo),
        nivelRiesgo: 'N/A',
        puntaje: 0,
        subPuntajes: const {},
        estado: 'INVALIDADA',
        escalaLabel: motivo.isEmpty ? '' : 'MOTIVO:',
        escalaSubtitulo: motivo,
        ideacionSuicida: false,
        impactoImportante: false,
        tipoKey: key,
        fecha: fecha,
        notas: notas,
      );
    }

    // ASSIST (Consumo de SPA): resumen por sustancia evaluada.
    if (esAssist && encuesta != null) {
      return _resultadoAssistDe(data, encuesta, fecha: fecha, notas: notas);
    }

    final items = <RespustaTamizajeStruct>[];
    _procesarDocRespuesta(data, items);
    if (items.isEmpty) return null;
    final tipoDoc = titulo.isNotEmpty ? titulo : items.first.tipo;
    final base = _clasificarUnTamizaje(tipoDoc, items)
        .conDocumento(fecha: fecha, notas: notas);
    final categoria = (encuesta?['categoria'] ?? '').toString();
    if (encuesta != null && usaNivelesGlobales(categoria)) {
      return _conNivelPorRangos(base, data, encuesta, categoria);
    }
    return base;
  } catch (e) {
    print('  Error procesando doc de tamizaje: $e');
    return null;
  }
}

/// CDI, autoestima, ansiedad y Beck: nivel con la regla del detalle (puntaje
/// total en los rangos configurados; fuera de todos → 'Sin alerta'), en vez
/// de los cortes fijos de `_clasificarCDI`/`_clasificarBDI`/etc. Se conservan
/// los subpuntajes del clasificador.
ResultadoTamizaje _conNivelPorRangos(
  ResultadoTamizaje base,
  Map<String, dynamic> data,
  Map<String, dynamic> encuesta,
  String categoria,
) {
  final puntaje = (data['puntajeTotal'] as num?)?.round() ?? base.puntaje;
  final nivel = nivelPorPuntaje(
    categoria: categoria,
    puntaje: puntaje,
    alertas: [
      for (final a in (encuesta['alertas'] as List?) ?? const [])
        if (AlertaStruct.maybeFromMap(a) case final s?) s,
    ],
  );
  final String nivelRiesgo;
  if (nivel.isEmpty) {
    nivelRiesgo = 'N/A';
  } else if (nivel == kSinAlerta) {
    nivelRiesgo = 'SIN ALERTA';
  } else {
    nivelRiesgo = const ['BAJO', 'MODERADO', 'ALTO'][gravedadNivel(nivel)];
  }
  return ResultadoTamizaje(
    titulo: base.titulo,
    nivelRiesgo: nivelRiesgo,
    puntaje: puntaje,
    subPuntajes: base.subPuntajes,
    estado: base.estado,
    escalaLabel: base.escalaLabel.isNotEmpty ? base.escalaLabel : 'NIVEL:',
    escalaSubtitulo: nivel == kSinAlerta
        ? 'Sin alerta: el puntaje no está en ningún rango configurado'
        : nivel,
    ideacionSuicida: base.ideacionSuicida,
    impactoImportante: nivelConRiesgo(nivel),
    tipoKey: base.tipoKey,
    fecha: base.fecha,
    notas: base.notas,
  );
}

/// Notas del profesional de un doc de `Respuestas` (Quill delta, HTML o texto).
String _notasDe(Map<String, dynamic> data) {
  final notas = (data['notasProfesional'] ?? '').toString().trim();
  if (notas.isNotEmpty) return notas;
  return (data['notas_profesional'] ?? '').toString().trim();
}

Future<Map<String, dynamic>?> _encuestaDe(
  DocumentReference ref,
  Map<String, Map<String, dynamic>?> cache,
) async {
  if (cache.containsKey(ref.path)) return cache[ref.path];
  try {
    final snap = await ref.get().timeout(const Duration(seconds: 8));
    final data = snap.data();
    cache[ref.path] = data is Map<String, dynamic> ? data : null;
  } catch (_) {
    cache[ref.path] = null;
  }
  return cache[ref.path];
}

DateTime? _fechaRespuesta(Map<String, dynamic> data) {
  final f = data['Fecha'] ?? data['fecha'];
  if (f is Timestamp) return f.toDate();
  if (f is DateTime) return f;
  return null;
}

/// Tarjeta ASSIST de una aplicación: nivel global = peor sustancia y
/// sub-puntajes por sustancia evaluada.
ResultadoTamizaje _resultadoAssistDe(
  Map<String, dynamic> data,
  Map<String, dynamic> encuesta, {
  DateTime? fecha,
  String notas = '',
}) {
  final r = evaluarAssist(
    preguntas: (encuesta['Preguntas'] as List?) ?? const [],
    test: (data['test'] as List?) ?? const [],
    alertas: (encuesta['alertas'] as List?) ?? const [],
  );
  final global = r.nivelGlobal;
  final peor = r.porSustancia.values
      .where((s) => s.nivel == global)
      .fold<SustanciaAssist?>(
          null, (m, s) => m == null || s.puntaje > m.puntaje ? s : m);
  return ResultadoTamizaje(
    titulo: 'CONSUMO DE SUSTANCIAS (ASSIST)',
    nivelRiesgo: global.isEmpty ? 'N/A' : global.toUpperCase(),
    puntaje: peor?.puntaje.toInt() ?? 0,
    subPuntajes: {
      for (final s in r.porSustancia.values)
        s.sustancia.toUpperCase(): s.puntaje.toInt(),
    },
    estado: 'VÁLIDA',
    escalaLabel: 'RIESGO POR SUSTANCIA',
    escalaSubtitulo: r.porSustancia.isEmpty
        ? 'No se marcó consumo de sustancias'
        : global == kSinAlerta
            ? 'Ninguna sustancia quedó dentro de un rango configurado'
            : (peor != null
            ? 'Mayor riesgo: ${peor.sustancia} (${peor.nivel})'
            : ''),
    ideacionSuicida: false,
    impactoImportante: global == 'Alto',
    tipoKey: 'sustancias',
    fecha: fecha,
    notas: notas,
  );
}

/// Procesa un doc de Respuesta (array `test` o `Respusta`) y agrega sus
/// items al listado.
void _procesarDocRespuesta(
  Map<String, dynamic> data,
  List<RespustaTamizajeStruct> respuestas,
) {
  try {
    // Nombre del tamizaje para prefijar la pregunta y poder reagruparlo luego.
    final titulo = (data['Titlo'] ?? data['titlo'] ?? '').toString();

    // Array de respuestas puede venir en `test` (legacy) o `Respusta`.
    final List<dynamic> items = [];
    if (data['test'] is List) items.addAll(data['test'] as List);
    if (data['Respusta'] is List) items.addAll(data['Respusta'] as List);

    for (final item in items) {
      if (item is! Map) continue;
      final m = Map<String, dynamic>.from(item);

      final structItem = RespuestaTestStruct.fromMap(m);
      String respuestaText = structItem.respuesta.trim();
      if (respuestaText.isEmpty) {
        respuestaText = structItem.respuestaSeleccionUnica.trim();
      }
      if (respuestaText.isEmpty && structItem.respuestasSeleccionadas.isNotEmpty) {
        respuestaText = structItem.respuestasSeleccionadas.join(', ');
      }
      if (respuestaText.isEmpty && structItem.respuestaSelection.isNotEmpty) {
        respuestaText = structItem.respuestaSelection.join(', ');
      }
      if (respuestaText.isEmpty && structItem.respuestaTamizaje.isNotEmpty) {
        respuestaText = structItem.respuestaTamizaje.map((e) => e.etiqueta).join(', ');
      }

      final tipo =
          (m['Tipo'] ?? m['tipo'] ?? titulo).toString();
      respuestas.add(RespustaTamizajeStruct(
        pregunta: m['Pregunta']?.toString() ??
            m['pregunta']?.toString() ??
            'Pregunta no disponible',
        respuesta: respuestaText.isEmpty ? 'No respondida' : respuestaText,
        tipo: tipo,
        trueAndFalse: (m['TrueAndFalse'] as num?)?.toInt(),
        nPregunta: (m['NPregunta'] as num?)?.toInt(),
      ));
    }
  } catch (e) {
    print('  Error procesando doc de respuesta: $e');
  }
}

// ---------------------------------------------------------------------------
// Analysis (kept for backwards compatibility with the old orchestrator)
// ---------------------------------------------------------------------------

String _obtenerValorRespuestaSeguro(RespustaTamizajeStruct respuesta) {
  try {
    if (respuesta.respuesta.isEmpty) return '0';
    final resp = respuesta.respuesta.toLowerCase().trim();
    const mapeoRespuestas = {
      'nunca': '0',
      'no': '0',
      'pocas veces': '1',
      'rara vez': '1',
      'algunas veces': '2',
      'a veces': '2',
      'frecuentemente': '3',
      'a menudo': '3',
      'siempre': '4',
      'sí': '4',
      'mucho': '4',
    };
    for (final key in mapeoRespuestas.keys) {
      if (resp.contains(key)) return mapeoRespuestas[key]!;
    }
    if (RegExp(r'^\d+$').hasMatch(resp)) {
      final valor = int.tryParse(resp) ?? 1;
      return valor.clamp(0, 4).toString();
    }
    return '1';
  } catch (_) {
    return '0';
  }
}

Map<String, dynamic> generarDatosAnalisisPorDefecto() => {
      'puntuacionTotal': 0.0,
      'promedio': 0.0,
      'nivelRiesgo': 'DESCONOCIDO',
      'totalRespuestas': 0,
      'porcentajeMaximo': 0.0,
    };

Map<String, dynamic> procesarDatosParaAnalisisIndividualSeguro(
    List<RespustaTamizajeStruct> respuestas) {
  try {
    double puntuacionTotal = 0;
    final totalRespuestas = respuestas.length;
    for (var respuesta in respuestas) {
      final valor =
          double.tryParse(_obtenerValorRespuestaSeguro(respuesta)) ?? 0;
      puntuacionTotal += valor;
    }
    final promedio =
        totalRespuestas > 0 ? puntuacionTotal / totalRespuestas : 0;
    String nivelRiesgo;
    if (promedio < 1.5) {
      nivelRiesgo = 'BAJO';
    } else if (promedio < 2.5) {
      nivelRiesgo = 'MODERADO';
    } else {
      nivelRiesgo = 'ALTO';
    }
    final porcentajeMaximo = totalRespuestas > 0
        ? (puntuacionTotal / (totalRespuestas * 4)) * 100
        : 0;
    return {
      'puntuacionTotal': puntuacionTotal,
      'promedio': promedio,
      'nivelRiesgo': nivelRiesgo,
      'totalRespuestas': totalRespuestas,
      'porcentajeMaximo': porcentajeMaximo,
    };
  } catch (e) {
    return generarDatosAnalisisPorDefecto();
  }
}

String generarInterpretacionIndividualSegura(
    List<RespustaTamizajeStruct> respuestas) {
  if (respuestas.isEmpty) {
    return 'No hay respuestas para interpretar.';
  }
  return '';
}

// ---------------------------------------------------------------------------
// Per-test model + classification
// ---------------------------------------------------------------------------

/// Condensed view of a single test's results for rendering.
class ResultadoTamizaje {
  final String titulo;
  final String nivelRiesgo; // SEVERO | ALTO | MODERADO | BAJO | N/A
  final int puntaje;
  final Map<String, int> subPuntajes; // e.g. DISFORIA, SECCIÓN 1, etc.
  final String estado; // VÁLIDA | INVALIDADA
  final String escalaLabel; // "ESCALA DE DEPRESIÓN" etc.
  final String escalaSubtitulo; // "Pc. 96, depresión severa"
  final bool ideacionSuicida;
  final bool impactoImportante;
  final String tipoKey; // internal key (cdi, hamilton, bdi, srq, rosemberg, otros)
  final DateTime? fecha; // fecha de aplicación del tamizaje
  final String notas; // notas del profesional (Quill delta, HTML o texto)

  ResultadoTamizaje({
    required this.titulo,
    required this.nivelRiesgo,
    required this.puntaje,
    required this.subPuntajes,
    required this.estado,
    required this.escalaLabel,
    required this.escalaSubtitulo,
    required this.ideacionSuicida,
    required this.impactoImportante,
    required this.tipoKey,
    this.fecha,
    this.notas = '',
  });

  /// Copia con la fecha y las notas del doc de `Respuestas` de origen.
  ResultadoTamizaje conDocumento({DateTime? fecha, String notas = ''}) =>
      ResultadoTamizaje(
        titulo: titulo,
        nivelRiesgo: nivelRiesgo,
        puntaje: puntaje,
        subPuntajes: subPuntajes,
        estado: estado,
        escalaLabel: escalaLabel,
        escalaSubtitulo: escalaSubtitulo,
        ideacionSuicida: ideacionSuicida,
        impactoImportante: impactoImportante,
        tipoKey: tipoKey,
        fecha: fecha,
        notas: notas,
      );
}

/// Maps a raw `Tipo` string to a normalized bucket key.
String _clasificarTipo(String? tipo) {
  final t = (tipo ?? '').toLowerCase();
  if (t.contains('cdi') || t.contains('depresión infantil')) return 'cdi';
  if (t.contains('hamilton')) return 'hamilton';
  if (t.contains('rosemberg') || t.contains('rosenberg')) return 'rosemberg';
  if (t.contains('srq')) return 'srq';
  if (t.contains('beck') || t.contains('bdi')) return 'bdi';
  if (t.contains('condicionante')) return 'condicionante';
  if (t.contains('sustancia') || t.contains('assist')) return 'sustancias';
  if (t.contains('autoestima')) return 'autoestima';
  return 'otros';
}

String _tituloParaTipo(String key, String fallback) {
  switch (key) {
    case 'cdi':
      return 'CUESTIONARIO DE DEPRESIÓN INFANTIL (CDI)';
    case 'hamilton':
      return 'TEST DE ANSIEDAD DE HAMILTON';
    case 'rosemberg':
      return 'ESCALA DE AUTOESTIMA ROSEMBERG';
    case 'srq':
      return 'SRQ SELF REPORT QUESTIONARE';
    case 'bdi':
      return 'INVENTARIO DE DEPRESIÓN DE BECK (BDI-2)';
    case 'sustancias':
      return 'CONSUMO DE SUSTANCIAS (ASSIST)';
    default:
      return fallback.toUpperCase();
  }
}

bool _respuestaEsPositiva(RespustaTamizajeStruct r) {
  if (r.trueAndFalse == 1) return true;
  final v = r.respuesta.toLowerCase().trim();
  if (v.isEmpty) return false;
  if (v == 'sí' || v == 'si' || v == 'yes' || v == '1' || v == 'true') {
    return true;
  }
  if (RegExp(r'^\d+$').hasMatch(v)) {
    final n = int.tryParse(v) ?? 0;
    return n >= 1;
  }
  return false;
}

int _sumaNumericaRespuestas(List<RespustaTamizajeStruct> rs) {
  int total = 0;
  for (final r in rs) {
    if (r.trueAndFalse > 0) {
      total += r.trueAndFalse;
      continue;
    }
    final v = r.respuesta.trim();
    final asInt = int.tryParse(v);
    if (asInt != null) {
      total += asInt;
    } else {
      total += int.tryParse(_obtenerValorRespuestaSeguro(r)) ?? 0;
    }
  }
  return total;
}

bool _tocaIdeacionSuicida(List<RespustaTamizajeStruct> rs) {
  for (final r in rs) {
    final text = '${r.pregunta} ${r.respuesta}'.toLowerCase();
    final palabrasClave = ['suicid', 'quitarme la vida', 'deseos de morir'];
    final mencionaSuicidio = palabrasClave.any(text.contains);
    if (mencionaSuicidio && _respuestaEsPositiva(r)) return true;
  }
  return false;
}

// Per-test classification functions ----------------------------------------

ResultadoTamizaje _clasificarCDI(List<RespustaTamizajeStruct> rs) {
  final total = _sumaNumericaRespuestas(rs);
  int disforia = 0;
  int autoestima = 0;
  for (final r in rs) {
    final p = r.pregunta.toLowerCase();
    final val = (r.trueAndFalse > 0)
        ? r.trueAndFalse
        : (int.tryParse(r.respuesta.trim()) ?? 0);
    if (p.contains('triste') ||
        p.contains('solo') ||
        p.contains('lloro') ||
        p.contains('ánimo')) {
      disforia += val;
    } else if (p.contains('feo') ||
        p.contains('torpe') ||
        p.contains('culpa') ||
        p.contains('inútil')) {
      autoestima += val;
    }
  }
  String nivel;
  String subtitulo;
  if (total >= 20) {
    nivel = 'SEVERO';
    subtitulo = 'Pc. 96, depresión severa';
  } else if (total >= 14) {
    nivel = 'ALTO';
    subtitulo = 'depresión marcada';
  } else if (total >= 7) {
    nivel = 'MODERADO';
    subtitulo = 'depresión moderada';
  } else {
    nivel = 'BAJO';
    subtitulo = 'sintomatología mínima';
  }
  return ResultadoTamizaje(
    titulo: _tituloParaTipo('cdi', 'CDI'),
    nivelRiesgo: nivel,
    puntaje: total,
    subPuntajes: {'DISFORIA': disforia, 'AUTOESTIMA NEGATIVA': autoestima},
    estado: 'VÁLIDA',
    escalaLabel: 'ESCALA DE DEPRESIÓN:',
    escalaSubtitulo: subtitulo,
    ideacionSuicida: _tocaIdeacionSuicida(rs),
    impactoImportante: nivel == 'MODERADO' || nivel == 'ALTO' || nivel == 'SEVERO',
    tipoKey: 'cdi',
  );
}

ResultadoTamizaje _clasificarHamilton(List<RespustaTamizajeStruct> rs) {
  final total = _sumaNumericaRespuestas(rs);
  String nivel;
  String subtitulo;
  if (total >= 30) {
    nivel = 'ALTO';
    subtitulo = 'Ansiedad Grave (o Severa)';
  } else if (total >= 15) {
    nivel = 'MODERADO';
    subtitulo = 'Ansiedad Moderada';
  } else if (total >= 6) {
    nivel = 'BAJO';
    subtitulo = 'Ansiedad Leve';
  } else {
    nivel = 'BAJO';
    subtitulo = 'Sin ansiedad';
  }
  return ResultadoTamizaje(
    titulo: _tituloParaTipo('hamilton', 'Hamilton'),
    nivelRiesgo: nivel,
    puntaje: total,
    subPuntajes: const {},
    estado: 'VÁLIDA',
    escalaLabel: 'ESCALA DE ANSIEDAD:',
    escalaSubtitulo: subtitulo,
    ideacionSuicida: _tocaIdeacionSuicida(rs),
    impactoImportante: nivel == 'MODERADO' || nivel == 'ALTO',
    tipoKey: 'hamilton',
  );
}

ResultadoTamizaje _clasificarRosemberg(List<RespustaTamizajeStruct> rs) {
  final total = _sumaNumericaRespuestas(rs);
  String subtitulo;
  if (total >= 30) {
    subtitulo = 'Autoestima Alta';
  } else if (total >= 26) {
    subtitulo = 'Autoestima Media';
  } else {
    subtitulo = 'Autoestima Baja';
  }
  return ResultadoTamizaje(
    titulo: _tituloParaTipo('rosemberg', 'Rosemberg'),
    nivelRiesgo: 'N/A',
    puntaje: total,
    subPuntajes: const {},
    estado: 'VÁLIDA',
    escalaLabel: 'ESCALA DE AUTOESTIMA:',
    escalaSubtitulo: subtitulo,
    ideacionSuicida: false,
    impactoImportante: false,
    tipoKey: 'rosemberg',
  );
}

ResultadoTamizaje _clasificarSRQ(List<RespustaTamizajeStruct> rs) {
  int total = 0;
  int seccion1 = 0;
  int seccion2 = 0;
  int depresion = 0;
  int angustia = 0;
  int psicosis = 0;
  int epilepsia = 0;
  int alcoholismo = 0;
  int ideacion = 0;

  for (final r in rs) {
    final pos = _respuestaEsPositiva(r) ? 1 : 0;
    total += pos;
    final n = r.nPregunta;
    if (n >= 1 && n <= 20) {
      seccion1 += pos;
    } else if (n >= 21) {
      seccion2 += pos;
    }
    final p = r.pregunta.toLowerCase();
    if (p.contains('triste') || p.contains('llora') || p.contains('interés')) {
      depresion += pos;
    }
    if (p.contains('nervios') || p.contains('asusta') || p.contains('tenso')) {
      angustia += pos;
    }
    if (p.contains('voces') || p.contains('alguien') && p.contains('contra')) {
      psicosis += pos;
    }
    if (p.contains('convuls') || p.contains('ataque')) {
      epilepsia += pos;
    }
    if (p.contains('alcohol') || p.contains('bebid')) {
      alcoholismo += pos;
    }
    if (p.contains('suicid') || p.contains('quitarse la vida')) {
      ideacion += pos;
    }
  }

  String nivel;
  if (total >= 11 || ideacion > 0) {
    nivel = 'SEVERO';
  } else if (total >= 8) {
    nivel = 'ALTO';
  } else if (total >= 4) {
    nivel = 'MODERADO';
  } else {
    nivel = 'BAJO';
  }

  return ResultadoTamizaje(
    titulo: _tituloParaTipo('srq', 'SRQ'),
    nivelRiesgo: nivel,
    puntaje: total,
    subPuntajes: {
      'SECCIÓN 1': seccion1,
      'SECCIÓN 2': seccion2,
      'DEPRESIÓN': depresion,
      'ANGUSTIA': angustia,
      'PSICOSIS': psicosis,
      'EPILEPSIA': epilepsia,
      'ALCOHOLISMO': alcoholismo,
      'IDEACIÓN SUICIDA': ideacion,
    },
    estado: 'VÁLIDA',
    escalaLabel: '',
    escalaSubtitulo: '',
    ideacionSuicida: ideacion > 0,
    impactoImportante:
        nivel == 'MODERADO' || nivel == 'ALTO' || nivel == 'SEVERO',
    tipoKey: 'srq',
  );
}

ResultadoTamizaje _clasificarBDI(List<RespustaTamizajeStruct> rs) {
  final total = _sumaNumericaRespuestas(rs);
  String nivel;
  String subtitulo;
  if (total >= 29) {
    nivel = 'ALTO';
    subtitulo = 'sintomatología depresiva grave';
  } else if (total >= 20) {
    nivel = 'MODERADO';
    subtitulo = 'sintomatología depresiva moderada';
  } else if (total >= 14) {
    nivel = 'MODERADO';
    subtitulo = 'sintomatología depresiva leve';
  } else {
    nivel = 'BAJO';
    subtitulo = 'mínima o ninguna sintomatología';
  }
  return ResultadoTamizaje(
    titulo: _tituloParaTipo('bdi', 'BDI-2'),
    nivelRiesgo: nivel,
    puntaje: total,
    subPuntajes: const {},
    estado: 'VÁLIDA',
    escalaLabel: 'ESCALA DE DEPRESIÓN:',
    escalaSubtitulo: subtitulo,
    ideacionSuicida: _tocaIdeacionSuicida(rs),
    impactoImportante: nivel == 'MODERADO' || nivel == 'ALTO',
    tipoKey: 'bdi',
  );
}

ResultadoTamizaje _clasificarGenerico(
    String tipoOriginal, List<RespustaTamizajeStruct> rs) {
  final total = _sumaNumericaRespuestas(rs);
  final analisis = procesarDatosParaAnalisisIndividualSeguro(rs);
  return ResultadoTamizaje(
    titulo: tipoOriginal.toUpperCase(),
    nivelRiesgo: analisis['nivelRiesgo']?.toString() ?? 'N/A',
    puntaje: total,
    subPuntajes: const {},
    estado: 'VÁLIDA',
    escalaLabel: '',
    escalaSubtitulo: '',
    ideacionSuicida: _tocaIdeacionSuicida(rs),
    impactoImportante: (analisis['nivelRiesgo']?.toString() ?? '') == 'ALTO',
    tipoKey: 'otros',
  );
}

/// Splits answers by `tipo` and produces a classified result per test.
List<ResultadoTamizaje> clasificarRespuestas(
    List<RespustaTamizajeStruct> respuestas) {
  final Map<String, List<RespustaTamizajeStruct>> buckets = {};
  for (final r in respuestas) {
    final key = _clasificarTipo(r.tipo);
    buckets.putIfAbsent(key, () => []).add(r);
  }
  final resultados = <ResultadoTamizaje>[];
  buckets.forEach((key, rs) {
    final tipoOriginal = rs.isNotEmpty ? rs.first.tipo : 'Tamizaje';
    resultados.add(_clasificarPorClave(key, tipoOriginal, rs));
  });
  return resultados;
}

/// Clasifica los ítems de **un** tamizaje (un doc de `Respuestas`) como una
/// sola tarjeta. La clave sale del título del tamizaje y, si no se reconoce,
/// del `Tipo` del primer ítem.
ResultadoTamizaje _clasificarUnTamizaje(
    String tipoDoc, List<RespustaTamizajeStruct> rs) {
  var key = _clasificarTipo(tipoDoc);
  if (key == 'otros' && rs.isNotEmpty) key = _clasificarTipo(rs.first.tipo);
  return _clasificarPorClave(key, tipoDoc, rs);
}

ResultadoTamizaje _clasificarPorClave(
    String key, String tipoOriginal, List<RespustaTamizajeStruct> rs) {
  switch (key) {
    case 'cdi':
      return _clasificarCDI(rs);
    case 'hamilton':
      return _clasificarHamilton(rs);
    case 'rosemberg':
      return _clasificarRosemberg(rs);
    case 'srq':
      return _clasificarSRQ(rs);
    case 'bdi':
      return _clasificarBDI(rs);
    default:
      return _clasificarGenerico(tipoOriginal, rs);
  }
}

// ---------------------------------------------------------------------------
// Card widgets
// ---------------------------------------------------------------------------

pw.Widget _kvPair(String label, String value, {PdfColor? valueColor}) {
  return pw.RichText(
    text: pw.TextSpan(
      children: [
        pw.TextSpan(
          text: '$label ',
          style: pw.TextStyle(
            fontSize: 8.5,
            fontWeight: pw.FontWeight.bold,
            color: PdfBrand.cardGrey,
          ),
        ),
        pw.TextSpan(
          text: value,
          style: pw.TextStyle(
            fontSize: 8.5,
            color: valueColor ?? PdfBrand.cardGrey,
            fontWeight: (valueColor == PdfBrand.redAlert)
                ? pw.FontWeight.bold
                : pw.FontWeight.normal,
          ),
        ),
      ],
    ),
  );
}

pw.Widget _badgeIcon(pw.MemoryImage? image, PdfColor fallbackColor) {
  if (image != null) {
    return pw.Image(image, width: 16, height: 16, fit: pw.BoxFit.contain);
  }
  return pw.Container(
    width: 14,
    height: 14,
    decoration: pw.BoxDecoration(
      color: fallbackColor,
      borderRadius: pw.BorderRadius.circular(3),
    ),
    alignment: pw.Alignment.center,
    child: pw.Text('!',
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        )),
  );
}

pw.Widget _yellowImpactBadge({PdfAssets? assets}) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: pw.BoxDecoration(
      color: PdfBrand.yellowBadgeBg,
      borderRadius: pw.BorderRadius.circular(8),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          children: [
            _badgeIcon(assets?.warningYellow, PdfBrand.yellowBrand),
            pw.SizedBox(width: 6),
            pw.Text(
              'IMPACTO IMPORTANTE EN\nACTIVIDADES COTIDIANAS',
              style: pw.TextStyle(
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
                color: PdfBrand.cardGrey,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'ACOMPAÑAMIENTO MÉDICO',
          style: pw.TextStyle(
            fontSize: 8,
            color: PdfBrand.darkGrey,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

pw.Widget _redVitalBadge({PdfAssets? assets}) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: pw.BoxDecoration(
      color: PdfBrand.redBadgeBg,
      borderRadius: pw.BorderRadius.circular(8),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _badgeIcon(assets?.warningRed, PdfBrand.redAlert),
            pw.SizedBox(width: 6),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'RIESGO VITAL',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfBrand.redAlert,
                  ),
                ),
                pw.Text(
                  'Pensamientos o deseos suicidas',
                  style: pw.TextStyle(
                    fontSize: 8,
                    color: PdfBrand.darkGrey,
                  ),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'REMISIÓN MÉDICA INMEDIATA',
          style: pw.TextStyle(
            fontSize: 8,
            color: PdfBrand.darkGrey,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

pw.Widget _buildSubPuntajesRow(Map<String, int> subPuntajes) {
  if (subPuntajes.isEmpty) return pw.SizedBox();
  final entries = subPuntajes.entries.toList();
  return pw.Wrap(
    spacing: 18,
    runSpacing: 4,
    children: entries
        .map((e) => _kvPair('${e.key}:', e.value.toString()))
        .toList(),
  );
}

pw.Widget buildTamizajeCard(ResultadoTamizaje r, {PdfAssets? assets}) {
  final bordeColor = colorBordeTarjeta(
    r.nivelRiesgo,
    tipoKey: r.tipoKey,
    titulo: r.titulo,
  );
  final invalidada = r.estado == 'INVALIDADA';
  final mostrarImpacto =
      !invalidada && r.impactoImportante && !r.ideacionSuicida;
  final mostrarVital = !invalidada && r.ideacionSuicida;

  final puntajeLabel =
      r.tipoKey == 'cdi' ? 'PUNTAJE GLOBAL:' : 'PUNTAJE:';

  return pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 22),
    padding: const pw.EdgeInsets.all(14),
    decoration: pw.BoxDecoration(
      color: PdfColors.white,
      border: pw.Border.all(color: bordeColor, width: 1.2),
      borderRadius: pw.BorderRadius.circular(24),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Center(
          child: pw.Text(
            r.titulo,
            style: pw.TextStyle(
              fontSize: 11.5,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _kvPair(
                    'NIVEL DE RIESGO:',
                    r.nivelRiesgo,
                    valueColor: colorValorNivelRiesgo(r.nivelRiesgo),
                  ),
                  if (!invalidada) ...[
                    pw.SizedBox(height: 4),
                    pw.Row(
                      children: [
                        _kvPair(puntajeLabel, r.puntaje.toString()),
                        if (r.subPuntajes.isNotEmpty) pw.SizedBox(width: 18),
                        if (r.subPuntajes.isNotEmpty)
                          pw.Expanded(
                              child: _buildSubPuntajesRow(r.subPuntajes)),
                      ],
                    ),
                  ],
                  pw.SizedBox(height: 4),
                  _kvPair('ESTADO:', r.estado,
                      valueColor: invalidada ? PdfBrand.redAlert : null),
                  if (r.fecha != null) ...[
                    pw.SizedBox(height: 4),
                    _kvPair('FECHA:', _formatearFecha(r.fecha!)),
                  ],
                  if (r.escalaLabel.isNotEmpty) ...[
                    pw.SizedBox(height: 4),
                    pw.Text(
                      r.escalaLabel,
                      style: pw.TextStyle(
                        fontSize: 8.5,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfBrand.cardGrey,
                      ),
                    ),
                    pw.Text(
                      r.escalaSubtitulo,
                      style: pw.TextStyle(
                        fontSize: 8.5,
                        color: PdfBrand.darkGrey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (mostrarImpacto || mostrarVital)
              pw.Row(
                children: [
                  if (mostrarImpacto) _yellowImpactBadge(assets: assets),
                  if (mostrarImpacto && mostrarVital) pw.SizedBox(width: 8),
                  if (mostrarVital) _redVitalBadge(assets: assets),
                ],
              ),
          ],
        ),
        _buildObservacionesTamizaje(r.notas),
      ],
    ),
  );
}

String _formatearFecha(DateTime f) {
  String dos(int n) => n.toString().padLeft(2, '0');
  return '${dos(f.day)}/${dos(f.month)}/${f.year}';
}

/// Notas del profesional de este tamizaje, dentro de su propia tarjeta.
pw.Widget _buildObservacionesTamizaje(String notas) {
  final baseStyle = pw.TextStyle(fontSize: 8.5, color: PdfBrand.darkGrey);
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.SizedBox(height: 10),
      pw.Divider(height: 1, thickness: 0.5, color: PdfColors.grey400),
      pw.SizedBox(height: 8),
      pw.Text(
        'OBSERVACIONES DEL PROFESIONAL:',
        style: pw.TextStyle(
          fontSize: 8.5,
          fontWeight: pw.FontWeight.bold,
          color: PdfBrand.cardGrey,
        ),
      ),
      pw.SizedBox(height: 4),
      ...parseQuillDeltaToPdf(notas, baseStyle),
    ],
  );
}

/// Top-level convenience builder: renders every classified card in order.
List<pw.Widget> buildTamizajeCards(
  List<ResultadoTamizaje> resultados, {
  PdfAssets? assets,
}) {
  return resultados.map((r) => buildTamizajeCard(r, assets: assets)).toList();
}

pw.Widget buildMensajeSinDatosTamizaje() {
  return pw.Container(
    padding: const pw.EdgeInsets.all(15),
    decoration: pw.BoxDecoration(
      color: PdfColors.yellow50,
      border: pw.Border.all(color: PdfColors.yellow700, width: 2),
      borderRadius: pw.BorderRadius.circular(5),
    ),
    child: pw.Column(
      children: [
        pw.Text(
          'SIN DATOS DE TAMIZAJE',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.yellow900,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          'No se encontraron respuestas de tamizaje para este usuario.\n'
          'Este informe contiene únicamente los datos personales.',
          style: const pw.TextStyle(fontSize: 11),
          textAlign: pw.TextAlign.center,
        ),
      ],
    ),
  );
}
