// Lógica pura del mapa de intervención (Estadísticas → Mapa), separada del
// widget para poder probarla sin Firestore ni Google Maps.

/// Rango aproximado de Colombia.
bool latitudEnColombia(double v) => v >= -4.0 && v <= 13.0;
bool longitudEnColombia(double v) => v >= -79.0 && v <= -67.0;

/// Convierte la latitud o longitud guardada en `colegios` a número.
///
/// Además del decimal normal acepta coma decimal (`10,39`) y los textos con
/// puntos de miles que quedaron de la carga inicial (`1.038.489.798`,
/// `-7.545.956.605`, `10.421.933`): se quitan los puntos y se pone el decimal
/// después de 2 o 1 dígitos enteros, el primero que caiga dentro de Colombia.
/// Devuelve null si no hay un valor válido para ese eje.
double? parseCoordenada(dynamic value, {required bool esLatitud}) {
  final enRango = esLatitud ? latitudEnColombia : longitudEnColombia;
  if (value == null) return null;
  if (value is num) {
    final v = value.toDouble();
    return enRango(v) ? v : null;
  }
  var texto = value.toString().trim().replaceAll(' ', '');
  if (texto.isEmpty) return null;
  if (!texto.contains('.') && texto.contains(',')) {
    texto = texto.replaceAll(',', '.');
  }
  if ('.'.allMatches(texto).length <= 1) {
    final v = double.tryParse(texto);
    return v != null && enRango(v) ? v : null;
  }
  final negativo = texto.startsWith('-');
  final digitos = texto.replaceAll('-', '').replaceAll('.', '');
  if (!RegExp(r'^\d+$').hasMatch(digitos)) return null;
  for (final enteros in [2, 1]) {
    if (digitos.length <= enteros) continue;
    final v = double.parse(
        '${digitos.substring(0, enteros)}.${digitos.substring(enteros)}');
    final firmado = negativo ? -v : v;
    if (enRango(firmado)) return firmado;
  }
  return null;
}

/// Clave para comparar nombres de colegio, municipio o barrio: sin tildes,
/// en minúsculas, sin espacios extremos ni repetidos.
String normalizarTexto(String? texto) {
  const conTilde = 'áàäâéèëêíìïîóòöôúùüûñ';
  const sinTilde = 'aaaaeeeeiiiioooouuuun';
  final buffer = StringBuffer();
  for (final c in (texto ?? '').toLowerCase().trim().split('')) {
    final i = conTilde.indexOf(c);
    buffer.write(i >= 0 ? sinTilde[i] : c);
  }
  return buffer.toString().replaceAll(RegExp(r'\s+'), ' ');
}

/// "CARTAGENA" → "Cartagena", "san juan" → "San Juan".
String enFormatoTitulo(String texto) => texto
    .trim()
    .toLowerCase()
    .split(RegExp(r'\s+'))
    .where((p) => p.isNotEmpty)
    .map((p) => p[0].toUpperCase() + p.substring(1))
    .join(' ');

/// Una respuesta válida de tamizaje, reducida a lo que usa el mapa.
class RespuestaMapa {
  const RespuestaMapa({
    required this.usuario,
    required this.colegio,
    required this.tamizaje,
    this.fecha,
  });

  /// Ruta del adolescente (`users/{id}`).
  final String usuario;

  /// Colegio del adolescente, normalizado con [normalizarTexto].
  final String colegio;

  /// Título del tamizaje.
  final String tamizaje;
  final DateTime? fecha;
}

/// Respuestas del [ano] indicado (todas si es null).
Iterable<RespuestaMapa> respuestasDelAno(
  Iterable<RespuestaMapa> respuestas,
  int? ano,
) =>
    ano == null ? respuestas : respuestas.where((r) => r.fecha?.year == ano);

/// Colegios (normalizados) con al menos una respuesta en el [ano].
Set<String> colegiosIntervenidos(
  Iterable<RespuestaMapa> respuestas,
  int? ano,
) =>
    respuestasDelAno(respuestas, ano).map((r) => r.colegio).toSet();

/// Años con respuestas, del más reciente al más antiguo.
List<int> anosConRespuestas(Iterable<RespuestaMapa> respuestas) =>
    respuestas.map((r) => r.fecha?.year).whereType<int>().toSet().toList()
      ..sort((a, b) => b.compareTo(a));

/// Estudiantes distintos por tamizaje en un colegio (normalizado) y año,
/// ordenado por cantidad descendente y luego por nombre.
List<MapEntry<String, int>> estudiantesPorTamizaje(
  Iterable<RespuestaMapa> respuestas,
  String colegio,
  int? ano,
) {
  final porTamizaje = <String, Set<String>>{};
  for (final r in respuestasDelAno(respuestas, ano)) {
    if (r.colegio != colegio) continue;
    porTamizaje.putIfAbsent(r.tamizaje, () => {}).add(r.usuario);
  }
  return porTamizaje.entries
      .map((e) => MapEntry(e.key, e.value.length))
      .toList()
    ..sort((a, b) {
      final c = b.value.compareTo(a.value);
      return c != 0 ? c : a.key.compareTo(b.key);
    });
}
