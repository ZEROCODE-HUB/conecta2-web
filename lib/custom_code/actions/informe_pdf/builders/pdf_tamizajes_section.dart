// Tamizaje processing + card builders styled to match the reference PDF.

import '/tamizajes/shared/assist_utils.dart';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '/backend/schema/structs/index.dart';
import '/components/rich_text_notas/rich_text_notas_widget.dart'
    show quillDeltaToPlainText;

import '../helpers/pdf_assets.dart';
import '../helpers/pdf_styles.dart';

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

String _mergeQuillDeltas(List<String> deltas) {
  if (deltas.isEmpty) return '';
  final mergedOps = <dynamic>[];
  for (var i = 0; i < deltas.length; i++) {
    final delta = deltas[i].trim();
    if (delta.isEmpty) continue;
    
    try {
      final decoded = jsonDecode(delta);
      if (decoded is List) {
        mergedOps.addAll(decoded);
      } else if (decoded is Map && decoded.containsKey('ops') && decoded['ops'] is List) {
        mergedOps.addAll(decoded['ops'] as List);
      } else {
        mergedOps.add({"insert": "$delta\n"});
      }
    } catch (_) {
      mergedOps.add({"insert": "$delta\n"});
    }
    
    if (i < deltas.length - 1) {
      mergedOps.add({"insert": "\n\n"});
    }
  }
  return jsonEncode(mergedOps);
}

Future<Map<String, dynamic>> obtenerRespuestasTamizajeSeguro(
    String userUid) async {
  try {
    final respuestasAgregadas = <RespustaTamizajeStruct>[];
    final notasAgregadas = <String>[];
    final encuestasCache = <String, Map<String, dynamic>?>{};
    final assistCandidatos =
        <({Map<String, dynamic> data, Map<String, dynamic> encuesta})>[];

    final userRef = FirebaseFirestore.instance.collection('users').doc(userUid);

    // 1) Respuestas bajo /Encuestas/{id}/Respuestas filtradas por userRespuesta
    try {
      final snap = await FirebaseFirestore.instance
          .collectionGroup('Respuestas')
          .where('User_respuesta', isEqualTo: userRef)
          .get()
          .timeout(const Duration(seconds: 12));

      for (final doc in snap.docs) {
        // ASSIST (Consumo de SPA): se resume en su propia tarjeta por
        // sustancia; no pasa al agrupamiento genérico por `Tipo`.
        final encuestaRef = doc.reference.parent.parent;
        if (encuestaRef != null && encuestaRef.parent.id == 'Encuestas') {
          final enc = await _encuestaDe(encuestaRef, encuestasCache);
          if (enc != null &&
              esEncuestaAssist((enc['categoria'] ?? '').toString(),
                  (enc['titulo'] ?? '').toString())) {
            final data = doc.data();
            final notas = (data['notasProfesional'] ?? '').toString();
            if (notas.isNotEmpty) notasAgregadas.add(notas);
            if (data['invalidado'] != true) {
              assistCandidatos.add((data: data, encuesta: enc));
            }
            continue;
          }
        }
        _procesarDocRespuesta(doc.data(), respuestasAgregadas, notasAgregadas);
      }
    } catch (e) {
      print('  Info: no se pudo leer collectionGroup Respuestas: $e');
    }

    // 2) Fallback: Respuestas guardadas bajo /users/{userUid}/Respuestas/...
    if (respuestasAgregadas.isEmpty) {
      try {
        final snap = await userRef
            .collection('Respuestas')
            .get()
            .timeout(const Duration(seconds: 10));
        for (final doc in snap.docs) {
          _procesarDocRespuesta(
              doc.data(), respuestasAgregadas, notasAgregadas);
        }
      } catch (e) {
        print('  Info: no se pudo leer users/$userUid/Respuestas: $e');
      }
    }

    final assist = _resultadoAssistMasReciente(assistCandidatos);

    if (respuestasAgregadas.isNotEmpty || assist != null) {
      return {
        'respuestas': respuestasAgregadas,
        'completadoSinRespuestas': false,
        'notasProfesional': _mergeQuillDeltas(notasAgregadas),
        'assist': assist,
      };
    }

    return {
      'respuestas': <RespustaTamizajeStruct>[],
      'completadoSinRespuestas': false,
      'notasProfesional': '',
    };
  } catch (e) {
    print('  ERROR al obtener respuestas de tamizaje: $e');
    return {
      'respuestas': <RespustaTamizajeStruct>[],
      'completadoSinRespuestas': false,
      'notasProfesional': '',
    };
  }
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

/// Tarjeta ASSIST con la última aplicación válida: nivel global = peor
/// sustancia y sub-puntajes por sustancia evaluada.
ResultadoTamizaje? _resultadoAssistMasReciente(
    List<({Map<String, dynamic> data, Map<String, dynamic> encuesta})>
        candidatos) {
  if (candidatos.isEmpty) return null;
  final ordenados = [...candidatos]..sort((a, b) {
      final fa = _fechaRespuesta(a.data);
      final fb = _fechaRespuesta(b.data);
      if (fa == null && fb == null) return 0;
      if (fa == null) return 1;
      if (fb == null) return -1;
      return fb.compareTo(fa);
    });
  final ultimo = ordenados.first;
  final r = evaluarAssist(
    preguntas: (ultimo.encuesta['Preguntas'] as List?) ?? const [],
    test: (ultimo.data['test'] as List?) ?? const [],
    alertas: (ultimo.encuesta['alertas'] as List?) ?? const [],
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
        : (peor != null
            ? 'Mayor riesgo: ${peor.sustancia} (${peor.nivel})'
            : ''),
    ideacionSuicida: false,
    impactoImportante: global == 'Alto',
    tipoKey: 'sustancias',
  );
}

/// Procesa un doc de Respuesta (array `test` o `Respusta`) y agrega los
/// items al listado y las notas profesionales recopiladas.
void _procesarDocRespuesta(
  Map<String, dynamic> data,
  List<RespustaTamizajeStruct> respuestas,
  List<String> notas,
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

    final notas1 = data['notasProfesional']?.toString() ?? '';
    final notas2 = data['notas_profesional']?.toString() ?? '';
    if (notas1.isNotEmpty) notas.add(notas1);
    if (notas2.isNotEmpty) notas.add(notas2);
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
  });
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
    switch (key) {
      case 'cdi':
        resultados.add(_clasificarCDI(rs));
        break;
      case 'hamilton':
        resultados.add(_clasificarHamilton(rs));
        break;
      case 'rosemberg':
        resultados.add(_clasificarRosemberg(rs));
        break;
      case 'srq':
        resultados.add(_clasificarSRQ(rs));
        break;
      case 'bdi':
        resultados.add(_clasificarBDI(rs));
        break;
      default:
        final tipoOriginal =
            rs.isNotEmpty ? rs.first.tipo : 'Tamizaje';
        resultados.add(_clasificarGenerico(tipoOriginal, rs));
    }
  });
  return resultados;
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
  final mostrarImpacto = r.impactoImportante && !r.ideacionSuicida;
  final mostrarVital = r.ideacionSuicida;

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
                  pw.SizedBox(height: 4),
                  pw.Row(
                    children: [
                      _kvPair(puntajeLabel, r.puntaje.toString()),
                      if (r.subPuntajes.isNotEmpty) pw.SizedBox(width: 18),
                      if (r.subPuntajes.isNotEmpty)
                        pw.Expanded(child: _buildSubPuntajesRow(r.subPuntajes)),
                    ],
                  ),
                  pw.SizedBox(height: 4),
                  _kvPair('ESTADO:', r.estado),
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
      ],
    ),
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
