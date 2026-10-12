// Pure data-processing helpers used by the TamizajeDataTable widget.

import 'package:cloud_firestore/cloud_firestore.dart';

import '/tamizajes/shared/assist_utils.dart';

import '../data/substance_data.dart';

String quitarTildes(String texto) {
  return texto
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('Á', 'A')
      .replaceAll('É', 'E')
      .replaceAll('Í', 'I')
      .replaceAll('Ó', 'O')
      .replaceAll('Ú', 'U');
}

String extraerSustancia(String pregunta) => sustanciaDesdeTexto(pregunta);

String evaluarNivelRiesgo(
    String sustancia, double puntaje, List<dynamic> alertas) {
  final sustanciaNormalizada = quitarTildes(sustancia.toLowerCase());

  List<Map<String, dynamic>> alertasCoincidentes = [];

  for (var alerta in alertas) {
    if (alerta is! Map<String, dynamic>) continue;

    final sustanciaAlerta = alerta['sustancia'] as String? ?? '';
    final sustanciaAlertaNormalizada =
        quitarTildes(sustanciaAlerta.toLowerCase());

    final nivel = alerta['nivel'] as String?;
    final min = (alerta['min'] as num?)?.toDouble() ?? 0.0;
    final max = (alerta['max'] as num?)?.toDouble() ?? 0.0;

    if (sustanciaAlertaNormalizada == sustanciaNormalizada ||
        sustanciaAlertaNormalizada.trim().isEmpty) {
      alertasCoincidentes.add({
        'nivel': nivel ?? 'Sin alarma',
        'min': min,
        'max': max,
      });
    }
  }

  if (alertasCoincidentes.isEmpty) {
    return 'Sin alarma';
  }

  alertasCoincidentes.sort((a, b) => a['min'].compareTo(b['min']));

  if (puntaje < alertasCoincidentes.first['min']) {
    return 'Sin alarma';
  }

  for (var i = 0; i < alertasCoincidentes.length; i++) {
    var alerta = alertasCoincidentes[i];
    final min = alerta['min'];
    final max = alerta['max'];
    final nivel = alerta['nivel'];

    if (i == alertasCoincidentes.length - 1 && max == 0) {
      if (puntaje >= min) {
        return nivel;
      }
    }

    if (i < alertasCoincidentes.length - 1) {
      final siguienteMin = alertasCoincidentes[i + 1]['min'];
      if (puntaje >= min && puntaje < siguienteMin) {
        return nivel;
      }
    } else if (max > 0) {
      if (puntaje >= min && puntaje <= max) {
        return nivel;
      }
    }
  }

  return alertasCoincidentes.last['nivel'];
}

String sanitizeKey(String name) {
  return name.toUpperCase()
      .replaceAll('Á', 'A')
      .replaceAll('É', 'E')
      .replaceAll('Í', 'I')
      .replaceAll('Ó', 'O')
      .replaceAll('Ú', 'U')
      .replaceAll('Ñ', 'N')
      .replaceAll(RegExp(r'[^A-Z0-9_]'), '_')
      .replaceAll(RegExp(r'_+'), '_');
}

String getSubstanceKey(String substance, String suffix) {
  const substanceKeys = {
    'Tabaco': 'TABACO',
    'Bebidas alcohólicas': 'ALCOHOL',
    'Cannabis': 'CANNABIS',
    'Cocaína': 'COCAINA',
    'Anfetaminas': 'ESTIMULANTES',
    'Inhalantes': 'INHALANTES',
    'Tranquilizantes': 'SEDANTES',
    'Alucinógenos': 'ALUCINOGENOS',
    'Opiáceos': 'OPIACEOS',
    'Otros': 'OTRAS',
  };
  final base = substanceKeys[substance] ?? sanitizeKey(substance);
  return '${base}_$suffix';
}

Map<String, dynamic> procesarRespuestasTamizaje(
  Map<String, dynamic> encuestaData,
  Map<String, dynamic> respuestaData,
) {
  final preguntasEncuesta = encuestaData['Preguntas'] as List<dynamic>? ?? [];
  final alertas = encuestaData['alertas'] as List<dynamic>? ?? [];
  final test = respuestaData['test'] as List<dynamic>? ?? [];
  final categoria = encuestaData['categoria'] as String? ?? '';
  final titulo = encuestaData['titulo'] as String? ?? '';

  final Set<String> variables = {};
  for (var preg in preguntasEncuesta) {
    if (preg is Map<String, dynamic>) {
      final v = preg['variable']?.toString().trim() ?? '';
      if (v.isNotEmpty) {
        variables.add(v);
      }
    }
  }

  final bool esAssist =
      categoria == 'ASSIST' || esEncuestaAssist(categoria, titulo);

  // ASSIST: puntaje y nivel por la sustancia asignada a cada pregunta, con la
  // regla única de nivel (`nivelPorSustancia`). Las preguntas ocultas por el
  // Condicionante no tienen respuesta y no cuentan.
  if (esAssist) {
    final r = evaluarAssist(
        preguntas: preguntasEncuesta, test: test, alertas: alertas);
    return {
      'puntajesPorSustancia': <String, double>{
        for (final e in r.porSustancia.entries)
          e.key: e.value.puntaje.toDouble(),
      },
      'detallesPorSustancia': <String, List<Map<String, dynamic>>>{
        for (final e in r.porSustancia.entries)
          e.key: [
            for (final d in e.value.detalles)
              {
                'pregunta': d.pregunta,
                'respuesta': d.respuesta,
                'valor': d.valor.toDouble(),
              },
          ],
      },
      'nivelRiesgoPorSustancia': <String, String>{
        for (final e in r.porSustancia.entries) e.key: e.value.nivel,
      },
    };
  }

  if (variables.isEmpty) {
    if (esAssist) {
      variables.addAll(kTodasLasSustancias);
    } else {
      variables.add(categoria.isNotEmpty ? categoria : titulo);
    }
  }

  Map<String, double> puntajesPorVariable = {};
  Map<String, List<Map<String, dynamic>>> detallesPorVariable = {};

  for (var v in variables) {
    puntajesPorVariable[v] = 0.0;
    detallesPorVariable[v] = [];
  }

  for (var item in test) {
    if (item is! Map<String, dynamic>) continue;

    final tipo = item['Tipo'] as String?;
    if (tipo == null || !tipo.toLowerCase().contains('tamizaje')) continue;

    final pregunta = item['Pregunta'] as String? ?? '';
    final respuestaTamizaje =
        item['RespuestaTamizaje'] as List<dynamic>? ?? [];

    if (respuestaTamizaje.isEmpty) continue;

    final respuestaSeleccionada =
        respuestaTamizaje[0] as Map<String, dynamic>;
    final etiqueta = respuestaSeleccionada['etiqueta'] as String? ?? '';
    final valor = (respuestaSeleccionada['valor'] as num?)?.toDouble() ?? 0.0;

    String varName = '';
    final nPregunta = item['NPregunta'] as int? ?? 0;
    if (nPregunta > 0 && nPregunta <= preguntasEncuesta.length) {
      final pregData = preguntasEncuesta[nPregunta - 1] as Map<String, dynamic>?;
      varName = pregData?['variable']?.toString().trim() ?? '';
    } else {
      for (var p in preguntasEncuesta) {
        if (p is Map<String, dynamic> &&
          (p['Pregunta'] ?? p['pregunta']) == pregunta) {
          varName = p['variable']?.toString().trim() ?? '';
          break;
        }
      }
    }

    if (varName.isEmpty) {
      if (esAssist) {
        varName = extraerSustancia(pregunta);
      } else if (variables.length == 1) {
        varName = variables.first;
      }
    }

    if (varName.isNotEmpty) {
      if (!variables.contains(varName)) {
        variables.add(varName);
        puntajesPorVariable[varName] = 0.0;
        detallesPorVariable[varName] = [];
      }
      puntajesPorVariable[varName] = (puntajesPorVariable[varName] ?? 0.0) + valor;
      detallesPorVariable[varName]!.add({
        'pregunta': pregunta,
        'respuesta': etiqueta,
        'valor': valor,
      });
    }
  }

  Map<String, String> nivelRiesgoPorVariable = {};
  for (var v in variables) {
    final puntaje = puntajesPorVariable[v] ?? 0.0;
    nivelRiesgoPorVariable[v] = evaluarNivelRiesgo(v, puntaje, alertas);
  }

  return {
    'puntajesPorSustancia': puntajesPorVariable,
    'detallesPorSustancia': detallesPorVariable,
    'nivelRiesgoPorSustancia': nivelRiesgoPorVariable,
  };
}

Map<String, dynamic> completarSustanciasFaltantes(
    Map<String, dynamic> resultados, Set<String> variables) {
  final puntajesPorSustancia =
      Map<String, double>.from(resultados['puntajesPorSustancia'] ?? {});
  final nivelesRiesgoPorSustancia =
      Map<String, String>.from(resultados['nivelRiesgoPorSustancia'] ?? {});
  final detallesPorSustancia = Map<String, List<Map<String, dynamic>>>.from(
      resultados['detallesPorSustancia'] ?? {});

  for (var sustancia in variables) {
    if (!puntajesPorSustancia.containsKey(sustancia)) {
      puntajesPorSustancia[sustancia] = 0.0;
      nivelesRiesgoPorSustancia[sustancia] = 'Sin alarma';

      if (!detallesPorSustancia.containsKey(sustancia)) {
        detallesPorSustancia[sustancia] = [
          {
            'pregunta': 'Consumo o evaluación de $sustancia',
            'respuesta': 'No evaluada',
            'valor': 0.0,
          }
        ];
      }
    }
  }

  return {
    'puntajesPorSustancia': puntajesPorSustancia,
    'detallesPorSustancia': detallesPorSustancia,
    'nivelRiesgoPorSustancia': nivelesRiesgoPorSustancia,
  };
}

String formatFecha(Timestamp? timestamp) {
  if (timestamp == null) return 'Sin fecha';
  final fecha = timestamp.toDate();
  return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
}

Map<String, dynamic> crearRegistroExcel(
  Map<String, dynamic> userData,
  Map<String, dynamic> resultados,
  Map<String, dynamic> respuestaData,
  int numeroRegistro,
  Set<String> variables,
) {
  final puntajes = resultados['puntajesPorSustancia'] as Map<String, double>;
  final niveles =
      resultados['nivelRiesgoPorSustancia'] as Map<String, String>;

  String fechaNacimientoFormateada = 'No registrada';
  String edad = 'No registrada';
  if (userData['fecha_nacimiento'] != null) {
    final fechaNacimiento =
        (userData['fecha_nacimiento'] as Timestamp).toDate();
    final ahora = DateTime.now();
    final edadCalculada = ahora.year - fechaNacimiento.year;
    edad = '$edadCalculada';
    fechaNacimientoFormateada =
        '${fechaNacimiento.day.toString().padLeft(2, '0')}/${fechaNacimiento.month.toString().padLeft(2, '0')}/${fechaNacimiento.year}';
  } else if (userData['edad'] != null && userData['edad'].toString().trim().isNotEmpty) {
    edad = userData['edad'].toString().trim();
  }

  String cursoVida = 'Adolescente';
  if (edad != 'No registrada') {
    final edadNum = int.tryParse(edad) ?? 0;
    if (edadNum < 13) {
      cursoVida = 'Niño';
    } else if (edadNum >= 13 && edadNum <= 19) {
      cursoVida = 'Adolescente';
    } else {
      cursoVida = 'Adulto';
    }
  }

  final registro = {
    'N': numeroRegistro,
    'ANO': DateTime.now().year,
    'FOLIO': 'TZ${numeroRegistro.toString().padLeft(3, '0')}',
    'NOMBRE': userData['display_name'] ?? 'No especificado',
    'COLEGIO': userData['colegio'] ?? 'No registrado',
    'DOCUMENTO': userData['identidad'] ?? 'No registrado',
    'EDAD': edad,
    'FECHA_NACIMIENTO': fechaNacimientoFormateada,
    'GENERO': userData['genero'] ?? 'No especificado',
    'MUNICIPIO': userData['municipio'] ?? 'No registrado',
    'BARRIO': userData['barrio'] ?? 'No registrado',
    'GRADO': userData['grado']?.toString() ?? 'No registrado',
    'EPS': userData['eps'] ?? 'No registrada',
    'CURSO_VIDA': cursoVida,
    'FECHA_RESPUESTA': formatFecha(respuestaData['Fecha'] as Timestamp?),
  };

  for (var v in variables) {
    final valorKey = getSubstanceKey(v, 'VALOR');
    final riesgoKey = getSubstanceKey(v, 'RIESGO');
    registro[valorKey] = puntajes[v] ?? 0.0;
    registro[riesgoKey] = niveles[v] ?? 'Sin alarma';
  }

  return registro;
}
