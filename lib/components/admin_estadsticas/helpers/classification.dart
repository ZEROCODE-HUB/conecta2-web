// Pure domain logic for classifying tamizaje responses.
//
// These functions must stay Firestore-free so they can be unit-tested
// in isolation (see `test/components/admin_estadsticas/classification_test.dart`).

/// Minimal view of a tamizaje's configured thresholds. Callers in the app
/// pass a projection of their `EncuestasRecord` so this file stays
/// Firestore-free.
class UmbralesConfig {
  const UmbralesConfig({
    this.bajoMax,
    this.moderadoMax,
    this.beckMinimaMax,
    this.beckLeveMax,
    this.beckModeradaMax,
  });

  /// For 3-level tamizajes (Autoestima/CDI): max value still considered
  /// the lowest level ("Baja" / "Sin sintomatología").
  final int? bajoMax;

  /// For 3-level tamizajes: max value still considered the middle level
  /// ("Media" / "Leve").
  final int? moderadoMax;

  /// For Beck (4 levels): max value of "Mínima".
  final int? beckMinimaMax;

  /// For Beck: max value of "Leve".
  final int? beckLeveMax;

  /// For Beck: max value of "Moderada". Values above are "Grave".
  final int? beckModeradaMax;

  bool get hasThreeLevel => bajoMax != null && moderadoMax != null;
  bool get hasBeck =>
      beckMinimaMax != null &&
      beckLeveMax != null &&
      beckModeradaMax != null;
}

/// Canonical gender buckets used across charts and aggregations.
const List<String> kGeneros = ['Masculino', 'Femenino', 'Otro'];

/// Age buckets shown on charts. 'Otro' holds off-range or missing ages
/// and is kept out of the visible chart axes (shown in the total KPI).
const List<String> kRangosEdad = ['10-12', '13-15', '16-18'];
const String kRangoEdadFallback = 'Otro';

/// Normalizes a tamizaje title into one of the known dimension keys.
/// Returns `'otros'` when nothing matches so the default classifier
/// branch is used.
String tipoKeyFromTitulo(String titulo) {
  final t = titulo.toLowerCase();
  if (t.contains('cdi') || t.contains('depresión infantil')) return 'cdi';
  if (t.contains('rosemberg') ||
      t.contains('rosenberg') ||
      t.contains('autoestima')) return 'autoestima';
  if (t.contains('crq')) return 'crq';
  if (t.contains('srq')) return 'srq';
  if (t.contains('beck') || t.contains('bdi')) return 'bdi';
  if (t.contains('sustancia') ||
      t.contains('assist') ||
      t.contains('consumo')) return 'sustancias';
  return 'otros';
}

/// Normalizes raw gender strings coming from the database into one of
/// [kGeneros]. Accepts Spanish/Portuguese variants commonly seen in
/// production data (e.g. "M", "Masc", "H", "F", "Mujer", "Femenino").
String normalizeGenero(String? raw) {
  final g = (raw ?? '').toLowerCase().trim();
  if (g.startsWith('m') && !g.startsWith('mu')) return 'Masculino';
  if (g.startsWith('h')) return 'Masculino';
  if (g.startsWith('f') || g.startsWith('mu')) return 'Femenino';
  return 'Otro';
}

/// Age → bucket label using [kRangosEdad]. Returns
/// [kRangoEdadFallback] for missing or off-range values.
String rangoEdadFromEdad(int? edad) {
  if (edad == null) return kRangoEdadFallback;
  for (final bucket in kRangosEdad) {
    final parts = bucket.split('-');
    final lo = int.parse(parts[0]);
    final hi = int.parse(parts[1]);
    if (edad >= lo && edad <= hi) return bucket;
  }
  return kRangoEdadFallback;
}

/// Parses a raw response map into a numeric score. Used when a tamizaje
/// doesn't store a pre-computed `puntajeTotal` and we must aggregate
/// answer-level values on the fly.
int numericValue(Map<String, dynamic> m) {
  final tAndF = m['TrueAndFalse'];
  if (tAndF is num && tAndF > 0) return tAndF.toInt();
  final resp = (m['Respuesta'] ?? m['respuesta'] ?? '').toString().trim();
  final asInt = int.tryParse(resp);
  if (asInt != null) return asInt;
  final lowered = resp.toLowerCase();
  const mapa = {
    'nunca': 0,
    'no': 0,
    'pocas veces': 1,
    'rara vez': 1,
    'algunas veces': 2,
    'a veces': 2,
    'frecuentemente': 3,
    'a menudo': 3,
    'siempre': 4,
    'sí': 1,
    'si': 1,
    'mucho': 4,
  };
  for (final entry in mapa.entries) {
    if (lowered.contains(entry.key)) return entry.value;
  }
  return 0;
}

/// Classifies a tamizaje response into its nivel label. Prefers a stored
/// `puntajeTotal` when present; otherwise sums the per-item scores via
/// [numericValue].
///
/// If [umbrales] is provided AND the categoria has configurable levels,
/// thresholds stored in the tamizaje doc take precedence over the
/// clinical-default thresholds hardcoded here. Callers should pass the
/// corresponding labels so the result matches what the admin configured
/// (e.g. Rosemberg defaults to Baja/Media/Elevada).
String classifyNivel(
  String titulo,
  List<Map<String, dynamic>> items, {
  num? puntajeTotal,
  UmbralesConfig? umbrales,
}) {
  final key = tipoKeyFromTitulo(titulo);
  int total = 0;
  // Incluye puntaje 0 (válido en CDI/Beck); antes `> 0` forzaba total=0 y
  // devolvía siempre el tramo más bajo aunque el doc tuviera umbrales.
  if (puntajeTotal != null) {
    total = puntajeTotal!.round();
  } else {
    for (final m in items) {
      total += numericValue(m);
    }
  }

  switch (key) {
    case 'autoestima':
      // Rosemberg: thresholds invert — higher score = healthier.
      if (umbrales?.hasThreeLevel == true) {
        if (total <= umbrales!.bajoMax!) return 'Baja';
        if (total <= umbrales.moderadoMax!) return 'Media';
        return 'Elevada';
      }
      if (total >= 30) return 'Elevada';
      if (total >= 26) return 'Media';
      return 'Baja';
    case 'cdi':
      if (umbrales?.hasThreeLevel == true) {
        if (total <= umbrales!.bajoMax!) return 'Sin sintomatología';
        if (total <= umbrales.moderadoMax!) return 'Leve';
        return 'Severo';
      }
      // CDI: umbrales según percentiles publicados para población colombiana
      // Pc<65 (G≤10) = Sin sintomatología; Pc 65-84 (11-16) = Leve; Pc≥85 (≥17) = Severo
      if (total >= 17) return 'Severo';
      if (total >= 11) return 'Leve';
      return 'Sin sintomatología';
    case 'bdi':
      if (umbrales?.hasBeck == true) {
        if (total <= umbrales!.beckMinimaMax!) return 'Mínima';
        if (total <= umbrales.beckLeveMax!) return 'Leve';
        if (total <= umbrales.beckModeradaMax!) return 'Moderada';
        return 'Grave';
      }
      if (total >= 29) return 'Grave';
      if (total >= 20) return 'Moderada';
      if (total >= 14) return 'Leve';
      return 'Mínima';
    case 'crq':
    case 'srq':
      if (total >= 11) return 'Severo';
      if (total >= 4) return 'Moderada';
      return 'Sin alerta';
    case 'sustancias':
      if (total >= 27) return 'Severo';
      if (total >= 4) return 'Moderada';
      return 'Sin alerta';
    default:
      if (total >= 20) return 'Grave';
      if (total >= 10) return 'Severo';
      if (total >= 4) return 'Moderada';
      return 'Sin alerta';
  }
}

/// Maps a specific level label (e.g. 'Leve', 'Mínima', 'Baja') into the
/// generic bucket list shown by the chart. Needed so the 'Todas' view,
/// which aggregates mixed-type responses, collapses levels sensibly
/// instead of defaulting everything to the first bucket.
String mapNivelToBucket(String nivel, List<String> buckets) {
  if (buckets.contains(nivel)) return nivel;
  final n = nivel.toLowerCase();
  String? firstMatching(List<String> candidates) {
    for (final b in buckets) {
      if (candidates.contains(b.toLowerCase())) return b;
    }
    return null;
  }

  if (n.contains('grave')) {
    return firstMatching(['grave']) ??
        firstMatching(['severo']) ??
        buckets.last;
  }
  if (n.contains('severo') ||
      n.contains('severa') ||
      n.contains('baja') ||
      n.contains('alto') ||
      n.contains('alta')) {
    return firstMatching(['severo', 'severa']) ?? buckets.last;
  }
  if (n.contains('moderad') || n.contains('leve') || n.contains('media')) {
    return firstMatching(['moderada', 'moderado', 'leve', 'media']) ??
        buckets[buckets.length ~/ 2];
  }
  // 'sin sintomatología', 'mínima', 'sin alerta', 'elevada' → healthy
  return firstMatching(
          ['sin alerta', 'sin sintomatología', 'mínima', 'elevada']) ??
      buckets.first;
}
