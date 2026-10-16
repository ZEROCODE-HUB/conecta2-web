// Lógica compartida del tamizaje "Consumo de SPA" (ASSIST).
//
// Un ASSIST combina:
//  - una pregunta `Condicionante` (selección múltiple; cada opción apunta a una
//    sustancia mediante `sustanciaValor`) que decide qué sustancias se evalúan;
//  - preguntas `Tamizaje (Sustancias)` (o el tipo legacy `Tamizaje` con
//    `sustancia`), una por sustancia, que solo se responden si su sustancia fue
//    marcada en el Condicionante.
//
// El puntaje y el nivel de riesgo se calculan POR SUSTANCIA; el nivel global
// de la persona es el de su peor sustancia. Todas las vistas (wizard, flujo
// del adolescente, detalle, estadísticas, tabla/Excel y PDFs) deben usar estas
// funciones para no divergir.
//
// Funciones puras (sin Flutter ni Firestore) para poder testearlas.

import '/backend/backend.dart';
import '/custom_code/widgets/tamizaje_data_table/data/substance_data.dart'
    show kTodasLasSustancias;
import '/dashboard/web/encuestas/editar/widgets/tamizajes_niveles.dart'
    show kSinAlerta;

export '/dashboard/web/encuestas/editar/widgets/tamizajes_niveles.dart'
    show kSinAlerta;

const String kCategoriaAssist = 'Consumo de SPA';

/// Orden canónico de sustancias (el de la tabla/Excel).
const List<String> kSustanciasOrden = kTodasLasSustancias;

/// Niveles de riesgo por sustancia, en orden clínico (de menor a mayor).
const List<String> kNivelesAssist = ['Bajo', 'Moderado', 'Alto'];

// ---------------------------------------------------------------------------
// Normalización e identificación
// ---------------------------------------------------------------------------

const _conTildes = 'áéíóúüñÁÉÍÓÚÜÑ';
const _sinTildes = 'aeiouunAEIOUUN';

String _sinAcentos(String s) {
  final buffer = StringBuffer();
  for (final ch in s.split('')) {
    final idx = _conTildes.indexOf(ch);
    buffer.write(idx >= 0 ? _sinTildes[idx] : ch);
  }
  return buffer.toString();
}

/// Minúsculas, sin espacios extremos y sin tildes. Hace equivalentes
/// 'Cocaina' (editor) y 'Cocaína' (tabla/Excel).
String normalizarSustancia(String s) => _sinAcentos(s.trim().toLowerCase());

String _normalizarTipo(String tipo) => _sinAcentos(tipo.trim().toLowerCase());

/// Nombre canónico de una sustancia (el de [kTodasLasSustancias]). Si no
/// corresponde a ninguna conocida, devuelve el texto original recortado.
String canonicaSustancia(String s) {
  final n = normalizarSustancia(s);
  if (n.isEmpty) return '';
  for (final canonica in kTodasLasSustancias) {
    if (normalizarSustancia(canonica) == n) return canonica;
  }
  return s.trim();
}

/// Deduce la sustancia a partir de un texto libre (texto de la pregunta).
/// Último recurso cuando la pregunta no tiene `sustancia` asignada.
String sustanciaDesdeTexto(String texto) {
  final t = normalizarSustancia(texto);
  if (t.contains('tabaco') || t.contains('cigarrillo')) return 'Tabaco';
  if (t.contains('alcohol') || t.contains('bebidas')) {
    return 'Bebidas alcohólicas';
  }
  if (t.contains('cannabis') || t.contains('marihuana')) return 'Cannabis';
  if (t.contains('cocaina') || t.contains('coca')) return 'Cocaína';
  if (t.contains('anfetamina') || t.contains('estimulante')) {
    return 'Anfetaminas';
  }
  if (t.contains('inhalante')) return 'Inhalantes';
  if (t.contains('tranquilizante') ||
      t.contains('pastillas') ||
      t.contains('sedante')) {
    return 'Tranquilizantes';
  }
  if (t.contains('alucinogeno')) return 'Alucinógenos';
  if (t.contains('opiaceo') || t.contains('heroina')) return 'Opiáceos';
  return 'Otros';
}

/// `true` si el tamizaje es un ASSIST. Se decide por la categoría y, como
/// respaldo para tamizajes antiguos, por palabras clave del título.
bool esEncuestaAssist(String categoria, String titulo) {
  if (categoria.trim() == kCategoriaAssist) return true;
  if (categoria.trim().isNotEmpty) return false;
  final t = normalizarSustancia(titulo);
  return t.contains('sustancia') || t.contains('assist') || t.contains('consumo');
}

bool esTipoCondicionante(String tipo) =>
    _normalizarTipo(tipo) == 'condicionante';

/// `true` si una pregunta con este [tipo] y [sustancia] es una pregunta de
/// sustancia: el tipo actual `Tamizaje (Sustancias)` o el legacy `Tamizaje`
/// con una sustancia asignada.
bool esTipoSustancia(String tipo, String sustancia) {
  final n = _normalizarTipo(tipo);
  if (n == 'tamizaje (sustancias)' || n == 'tamizaje sustancias') return true;
  return n == 'tamizaje' && sustancia.trim().isNotEmpty;
}

bool esPreguntaSustancia(PreguntasEncuestaStruct p) =>
    esTipoSustancia(p.tipo, p.sustancia);

bool esPreguntaCondicionante(PreguntasEncuestaStruct p) =>
    esTipoCondicionante(p.tipo);

// ---------------------------------------------------------------------------
// Visibilidad por Condicionante
// ---------------------------------------------------------------------------

bool hayCondicionante(Iterable<PreguntasEncuestaStruct> preguntas) =>
    preguntas.any(esPreguntaCondicionante);

/// Conjunto normalizado de sustancias habilitadas a partir de los
/// `sustanciaValor` marcados en los Condicionantes.
Set<String> sustanciasPermitidasDesde(Iterable<String> sustanciaValores) => {
      for (final s in sustanciaValores)
        if (s.trim().isNotEmpty) normalizarSustancia(s),
    };

/// Una pregunta que no es de sustancia siempre es visible. Una de sustancia
/// es visible si su sustancia fue marcada; si el tamizaje no tiene
/// Condicionante, todas son visibles (compatibilidad).
bool esPreguntaVisible({
  required String tipo,
  required String sustancia,
  required Set<String> permitidas,
  required bool conCondicionante,
}) {
  if (!esTipoSustancia(tipo, sustancia)) return true;
  if (!conCondicionante) return true;
  return permitidas.contains(normalizarSustancia(sustancia));
}

/// Atajo para los flujos que guardan las sustancias marcadas en una lista
/// (p. ej. `FFAppState().TamizajeSustanciaPermitidas` del adolescente).
bool preguntaSustanciaVisible({
  required PreguntasEncuestaStruct pregunta,
  required Iterable<String> sustanciasMarcadas,
  required Iterable<PreguntasEncuestaStruct> preguntas,
}) =>
    esPreguntaVisible(
      tipo: pregunta.tipo,
      sustancia: pregunta.sustancia,
      permitidas: sustanciasPermitidasDesde(sustanciasMarcadas),
      conCondicionante: hayCondicionante(preguntas),
    );

// ---------------------------------------------------------------------------
// Nivel de riesgo por sustancia
// ---------------------------------------------------------------------------

/// Origen de los rangos usados para clasificar una sustancia.
enum OrigenNivel { configurado, global, oms }

class NivelSustancia {
  const NivelSustancia(this.nivel, this.origen);
  final String nivel;
  final OrigenNivel origen;
}

class _Rango {
  const _Rango(this.nivel, this.min, this.max);
  final String nivel;
  final int min;
  final int max;
}

String? _nivelCanonico(String raw) {
  final n = normalizarSustancia(raw);
  for (final nivel in kNivelesAssist) {
    if (normalizarSustancia(nivel) == n) return nivel;
  }
  return null;
}

int _toInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v.trim()) ?? 0;
  return 0;
}

/// Lee una alerta venga como [AlertaStruct] o como mapa de Firestore.
({String sustancia, String nivel, int min, int max})? _leerAlerta(dynamic a) {
  if (a is AlertaStruct) {
    return (sustancia: a.sustancia, nivel: a.nivel, min: a.min, max: a.max);
  }
  if (a is Map) {
    return (
      sustancia: (a['sustancia'] ?? '').toString(),
      nivel: (a['nivel'] ?? '').toString(),
      min: _toInt(a['min']),
      max: _toInt(a['max']),
    );
  }
  return null;
}

/// Rangos (solo niveles Bajo/Moderado/Alto) de una sustancia normalizada,
/// en orden clínico. Descarta entradas basura como "Hello World".
List<_Rango> _rangosDe(String sustanciaNorm, List<dynamic> alertas) {
  final porNivel = <String, _Rango>{};
  for (final raw in alertas) {
    final a = _leerAlerta(raw);
    if (a == null) continue;
    if (normalizarSustancia(a.sustancia) != sustanciaNorm) continue;
    final nivel = _nivelCanonico(a.nivel);
    if (nivel == null) continue;
    porNivel[nivel] = _Rango(nivel, a.min, a.max);
  }
  return [
    for (final nivel in kNivelesAssist)
      if (porNivel.containsKey(nivel)) porNivel[nivel]!,
  ];
}

/// Una sustancia está configurada si alguna fila salió de la plantilla 0/0.
bool _configurados(List<_Rango> rangos) =>
    rangos.any((r) => r.min > 0 || r.max > 0);

String _clasificar(List<_Rango> rangos, num puntaje) {
  // Coincidencia exacta; en el último nivel max == 0 significa "sin tope".
  for (var i = 0; i < rangos.length; i++) {
    final r = rangos[i];
    final esUltimo = i == rangos.length - 1;
    if (esUltimo && r.max == 0) {
      if (puntaje >= r.min) return r.nivel;
    } else if (puntaje >= r.min && puntaje <= r.max) {
      return r.nivel;
    }
  }
  // Fuera de todos los rangos (hueco, por debajo o por encima): no es alerta.
  return kSinAlerta;
}

/// Rangos estándar ASSIST OMS v3.1 (Alcohol 0–10 / 11–26 / 27+; resto
/// 0–3 / 4–26 / 27+). Se usan cuando la encuesta no configuró la sustancia.
List<({String nivel, int min, int max})> rangosOms(String sustancia) {
  final esAlcohol = normalizarSustancia(canonicaSustancia(sustancia)) ==
          normalizarSustancia('Bebidas alcohólicas') ||
      normalizarSustancia(sustancia).contains('alcohol');
  return esAlcohol
      ? const [
          (nivel: 'Bajo', min: 0, max: 10),
          (nivel: 'Moderado', min: 11, max: 26),
          (nivel: 'Alto', min: 27, max: 0),
        ]
      : const [
          (nivel: 'Bajo', min: 0, max: 3),
          (nivel: 'Moderado', min: 4, max: 26),
          (nivel: 'Alto', min: 27, max: 0),
        ];
}

/// Única regla de nivel por sustancia:
///  1. Rangos configurados para la sustancia en `Encuesta.alertas`.
///  2. Si no hay, rangos globales (alertas con `sustancia` vacía).
///  3. Si tampoco hay, cortes estándar ASSIST OMS.
/// Una sustancia con la plantilla en 0/0 cuenta como NO configurada (antes
/// se clasificaba como "Alto" con cualquier puntaje).
NivelSustancia nivelPorSustancia(
    String sustancia, num puntaje, List<dynamic> alertas) {
  final propios = _rangosDe(normalizarSustancia(sustancia), alertas);
  if (_configurados(propios)) {
    return NivelSustancia(_clasificar(propios, puntaje), OrigenNivel.configurado);
  }
  final globales = _rangosDe('', alertas);
  if (_configurados(globales)) {
    return NivelSustancia(_clasificar(globales, puntaje), OrigenNivel.global);
  }
  final oms = [
    for (final r in rangosOms(sustancia)) _Rango(r.nivel, r.min, r.max),
  ];
  return NivelSustancia(_clasificar(oms, puntaje), OrigenNivel.oms);
}

int _indiceNivel(String nivel) {
  final canonico = _nivelCanonico(nivel);
  return canonico == null ? -1 : kNivelesAssist.indexOf(canonico);
}

/// El peor nivel de la lista ('' si no hay ninguno válido).
String peorNivel(Iterable<String> niveles) {
  var peor = -1;
  for (final n in niveles) {
    final i = _indiceNivel(n);
    if (i > peor) peor = i;
  }
  return peor < 0 ? '' : kNivelesAssist[peor];
}

/// Traduce el nivel ASSIST al eje del panel de estadísticas.
String bucketStats(String nivel) {
  switch (_nivelCanonico(nivel)) {
    case 'Bajo':
      return 'Sin alerta';
    case 'Moderado':
      return 'Moderada';
    case 'Alto':
      return 'Severo';
    default:
      return nivel;
  }
}

/// Valida los rangos configurados por sustancia. Devuelve mensajes de error
/// legibles (lista vacía = válido). Las sustancias sin configurar (todo 0/0)
/// son válidas: usarán los cortes OMS.
List<String> validarAlertasAssist(List<dynamic> alertas) {
  final sustancias = <String, String>{}; // normalizada -> nombre mostrado
  for (final raw in alertas) {
    final a = _leerAlerta(raw);
    if (a == null || _nivelCanonico(a.nivel) == null) continue;
    sustancias.putIfAbsent(normalizarSustancia(a.sustancia), () => a.sustancia);
  }
  final errores = <String>[];
  sustancias.forEach((norm, nombre) {
    final rangos = _rangosDe(norm, alertas);
    if (!_configurados(rangos)) return;
    final etiqueta = nombre.trim().isEmpty ? 'General' : nombre;
    for (var i = 0; i < rangos.length; i++) {
      final r = rangos[i];
      final esUltimo = i == rangos.length - 1;
      if (r.min < 0 || r.max < 0) {
        errores.add('$etiqueta – ${r.nivel}: los valores no pueden ser negativos.');
      } else if (!(esUltimo && r.max == 0) && r.min > r.max) {
        errores.add('$etiqueta – ${r.nivel}: el mínimo (${r.min}) es mayor que el máximo (${r.max}).');
      }
      if (i > 0) {
        final prev = rangos[i - 1];
        if (r.min <= prev.max) {
          errores.add('$etiqueta – ${r.nivel}: empieza en ${r.min} y se solapa con ${prev.nivel} (hasta ${prev.max}).');
        }
      }
    }
  });
  return errores;
}

/// Alertas con los cortes OMS para prellenar una sustancia en el editor.
List<AlertaStruct> alertasOmsPara(String sustancia) => [
      for (final r in rangosOms(sustancia))
        AlertaStruct(sustancia: sustancia, nivel: r.nivel, min: r.min, max: r.max),
    ];

/// Elimina de una lista de alertas las entradas que no son niveles ASSIST
/// válidos (p. ej. el placeholder "Hello World" de la plantilla).
List<AlertaStruct> limpiarAlertasAssist(Iterable<AlertaStruct> alertas) => [
      for (final a in alertas)
        if (_nivelCanonico(a.nivel) != null) a,
    ];

// ---------------------------------------------------------------------------
// Evaluación de una respuesta ASSIST
// ---------------------------------------------------------------------------

class DetalleItemAssist {
  const DetalleItemAssist(this.pregunta, this.respuesta, this.valor);
  final String pregunta;
  final String respuesta;
  final num valor;
}

class SustanciaAssist {
  SustanciaAssist(this.sustancia);
  final String sustancia;
  num puntaje = 0;
  String nivel = '';
  OrigenNivel origen = OrigenNivel.oms;
  final List<DetalleItemAssist> detalles = [];
}

class ResultadoAssist {
  ResultadoAssist({
    required this.porSustancia,
    required this.sustanciasMarcadas,
  });

  /// Solo sustancias evaluadas (con al menos una respuesta), en el orden de
  /// [kTodasLasSustancias].
  final Map<String, SustanciaAssist> porSustancia;

  /// Sustancias marcadas en el Condicionante (nombres canónicos).
  final List<String> sustanciasMarcadas;

  /// Peor nivel ASSIST de las sustancias evaluadas; [kSinAlerta] si ninguna
  /// cayó en un rango configurado; '' si no hay sustancias evaluadas.
  String get nivelGlobal {
    final peor = peorNivel(porSustancia.values.map((s) => s.nivel));
    if (peor.isEmpty && porSustancia.isNotEmpty) return kSinAlerta;
    return peor;
  }

  bool get tieneEvaluaciones => porSustancia.isNotEmpty;
}

const _kSeparadorSustancia = ': ';

/// Resuelve a qué sustancia pertenece un ítem respondido, en este orden:
/// `sustancia` de la pregunta → `variable` de la pregunta → prefijo
/// "<Sustancia>: " de la etiqueta → texto de la pregunta.
String _sustanciaDeAtributo({
  required Map<String, dynamic>? pregunta,
  required String etiqueta,
  required String textoPregunta,
}) {
  final asignada = (pregunta?['sustancia'] ?? '').toString().trim();
  if (asignada.isNotEmpty) return canonicaSustancia(asignada);
  final variable = (pregunta?['variable'] ?? '').toString().trim();
  if (variable.isNotEmpty) return canonicaSustancia(variable);
  final idx = etiqueta.indexOf(_kSeparadorSustancia);
  if (idx > 0) {
    final prefijo = canonicaSustancia(etiqueta.substring(0, idx));
    if (kTodasLasSustancias.contains(prefijo)) return prefijo;
  }
  return sustanciaDesdeTexto(textoPregunta);
}

Map<String, dynamic>? _preguntaDeItem(
    Map<String, dynamic> item, List<dynamic> preguntas) {
  final n = _toInt(item['NPregunta']);
  if (n > 0 && n <= preguntas.length && preguntas[n - 1] is Map) {
    return Map<String, dynamic>.from(preguntas[n - 1] as Map);
  }
  final texto = (item['Pregunta'] ?? '').toString();
  for (final p in preguntas) {
    if (p is Map && (p['Pregunta'] ?? '').toString() == texto) {
      return Map<String, dynamic>.from(p);
    }
  }
  return null;
}

/// Evalúa una respuesta ASSIST a partir de los mapas de Firestore:
/// [preguntas] = `Encuesta.Preguntas`, [test] = `Respuesta.test`,
/// [alertas] = `Encuesta.alertas`.
ResultadoAssist evaluarAssist({
  required List<dynamic> preguntas,
  required List<dynamic> test,
  required List<dynamic> alertas,
}) {
  final acumulado = <String, SustanciaAssist>{};
  final marcadas = <String>{};

  for (final raw in test) {
    if (raw is! Map) continue;
    final item = Map<String, dynamic>.from(raw);
    final pregunta = _preguntaDeItem(item, preguntas);
    final tipo = (pregunta?['Tipo'] ?? item['Tipo'] ?? '').toString();
    final sustanciaPregunta = (pregunta?['sustancia'] ?? '').toString();

    if (esTipoCondicionante(tipo)) {
      final sel = item['RespuestasSeleccionadas'];
      if (sel is List) {
        for (final s in sel) {
          final c = canonicaSustancia(s.toString());
          if (c.isNotEmpty) marcadas.add(c);
        }
      }
      continue;
    }

    final atributos = item['RespuestaTamizaje'];
    if (atributos is! List || atributos.isEmpty) continue;

    // Solo cuentan las preguntas de sustancia (o cualquier tamizaje cuyas
    // etiquetas traigan el prefijo de sustancia del wizard antiguo).
    final textoPregunta = (item['Pregunta'] ?? '').toString();
    final esSustancia = esTipoSustancia(tipo, sustanciaPregunta) ||
        _normalizarTipo(tipo).startsWith('tamizaje');
    if (!esSustancia) continue;

    for (final a in atributos) {
      if (a is! Map) continue;
      final etiqueta = (a['etiqueta'] ?? '').toString();
      final valor = (a['valor'] as num?) ?? 0;
      final sustancia = _sustanciaDeAtributo(
        pregunta: pregunta,
        etiqueta: etiqueta,
        textoPregunta: textoPregunta,
      );
      final s = acumulado.putIfAbsent(sustancia, () => SustanciaAssist(sustancia));
      s.puntaje += valor;
      final idx = etiqueta.indexOf(_kSeparadorSustancia);
      s.detalles.add(DetalleItemAssist(
        textoPregunta,
        idx > 0 ? etiqueta.substring(idx + _kSeparadorSustancia.length) : etiqueta,
        valor,
      ));
      // En el formato actual hay un atributo por pregunta; en registros
      // antiguos del wizard puede haber uno por sustancia.
      if (sustanciaPregunta.trim().isNotEmpty) break;
    }
  }

  for (final s in acumulado.values) {
    final n = nivelPorSustancia(s.sustancia, s.puntaje, alertas);
    s.nivel = n.nivel;
    s.origen = n.origen;
  }

  final ordenadas = <String, SustanciaAssist>{
    for (final nombre in kTodasLasSustancias)
      if (acumulado.containsKey(nombre)) nombre: acumulado[nombre]!,
    for (final e in acumulado.entries)
      if (!kTodasLasSustancias.contains(e.key)) e.key: e.value,
  };

  return ResultadoAssist(
    porSustancia: ordenadas,
    sustanciasMarcadas: [
      for (final nombre in kTodasLasSustancias)
        if (marcadas.contains(nombre)) nombre,
      for (final m in marcadas)
        if (!kTodasLasSustancias.contains(m)) m,
    ],
  );
}

/// Variante tipada para usar con los records de la app.
ResultadoAssist evaluarAssistDesdeStructs({
  required List<PreguntasEncuestaStruct> preguntas,
  required List<RespuestaTestStruct> test,
  required List<AlertaStruct> alertas,
}) =>
    evaluarAssist(
      preguntas: preguntas.map((p) => p.toMap()).toList(),
      test: test.map((t) => t.toMap()).toList(),
      alertas: alertas.map((a) => a.toMap()).toList(),
    );

/// `true` si el ítem es una pregunta de sustancia que no aplicó (su sustancia
/// no se marcó en el Condicionante): se guarda sin respuesta y las vistas no
/// deben mostrarla como "sin respuesta".
bool itemSustanciaNoAplica(
    RespuestaTestStruct item, List<PreguntasEncuestaStruct> preguntas) {
  if (item.respuestaTamizaje.isNotEmpty) return false;
  final n = item.nPregunta;
  final sustancia =
      (n > 0 && n <= preguntas.length) ? preguntas[n - 1].sustancia : '';
  return esTipoSustancia(item.tipo, sustancia);
}
