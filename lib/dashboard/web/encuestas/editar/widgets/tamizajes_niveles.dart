// Helpers for alert-level configuration and evaluation by test category.
//
// Each published tamizaje (Autoestima, CDI, Depresión Beck, CRQ/SRQ, Consumo
// de SPA) has a set of predefined alert levels. This file centralises:
//   * `nivelesPorCategoria` -> labels shown in the editor's "Alertas" panel.
//   * `nivelPorRangos` -> CDI / autoestima / ansiedad / Beck: level whose
//     configured [min, max] contains the score, or 'Sin alerta' (kSinAlerta)
//     when no range contains it.
//   * `calcularNivelAlerta` -> CRQ/SRQ/RQC: given a score + saved AlertaStruct
//     list, returns the matching level label for display in the results screen.
//
// It is pure Dart (no Flutter widgets) so it can be reused by the wizard
// results views (web + mobile) and the PDF builder without pulling in
// Material dependencies.

import '/backend/schema/encuestas_record.dart';
import '/backend/schema/structs/index.dart';

/// Alert level names per tamizaje category (from the requirements doc).
/// The keys match the `categoria` field used in [EncuestasRecord].
const Map<String, List<String>> kNivelesPorCategoria = {
  'Escala autoestima': [
    'Autoestima Baja',
    'Autoestima Media',
    'Autoestima Elevada',
  ],
  'CDI': [
    'Sin sintomatología',
    'Leve',
    'Severo',
  ],
  'Depresión Beck': [
    'Mínima',
    'Leve',
    'Moderada',
    'Grave',
  ],
  'CRQ / SRQ': [
    'Sin alerta',
    'Moderada',
    'Severo',
  ],
  'CRQ': [
    'Sin alerta',
    'Subescala 1',
    'Subescala 2',
  ],
  'RQC': [
    'Sin alerta',
    'Subescala 1',
    'Subescala 2',
  ],
  'SRQ': [
    'Sin alerta',
    'Subescala 1',
    'Subescala 2',
  ],
  // Consumo de SPA uses per-substance levels (Bajo/Moderado/Alto) handled
  // separately in the sustancias panel.
  'Consumo de SPA': [
    'Bajo',
    'Moderado',
    'Alto',
  ],
  'Escala ansiedad': [
    'Sin sintomatología',
    'Leve',
    'Moderado',
    'Severo',
  ],
};

/// Returns the list of level labels configured for [categoria]. Empty list
/// for unknown categories.
List<String> nivelesPorCategoria(String? categoria) {
  if (categoria == null || categoria.isEmpty) return const [];
  return kNivelesPorCategoria[categoria] ?? const [];
}

/// Returns true when this category uses the "niveles globales" model
/// (single score compared against min/max ranges) instead of per-substance
/// or special condition-based alerts.
bool usaNivelesGlobales(String? categoria) {
  switch (categoria) {
    case 'Escala autoestima':
    case 'CDI':
    case 'Depresión Beck':
    case 'Escala ansiedad':
      return true;
    default:
      return false;
  }
}

/// Nivel de un puntaje que no cae en ningún rango configurado: no es alerta.
const kSinAlerta = 'Sin alerta';

/// Nivel de [puntaje] según los rangos `[min, max]` configurados en [alertas]
/// para los tamizajes de niveles globales (CDI, autoestima, ansiedad, Beck).
///
/// - `null` si la categoría no es de niveles globales ([usaNivelesGlobales])
///   o la encuesta no tiene rangos de esa categoría (el llamador usa los
///   cortes clínicos por defecto).
/// - El primer rango de la lista que contiene el puntaje (si se cruzan, gana
///   el primero).
/// - [kSinAlerta] si el puntaje no está en ningún rango: no se cataloga como
///   alerta.
///
/// En autoestima devuelve 'Baja'/'Media'/'Elevada' (sin el prefijo
/// "Autoestima"), como los cortes por defecto.
String? nivelPorRangos({
  required String? categoria,
  required num puntaje,
  required Iterable<AlertaStruct> alertas,
}) {
  if (!usaNivelesGlobales(categoria)) return null;
  final niveles = nivelesPorCategoria(categoria);
  final rangos = [
    for (final a in alertas)
      if (niveles.contains(a.nivel) && a.hasMax()) a,
  ];
  if (rangos.isEmpty) return null;
  for (final a in rangos) {
    if (puntaje >= a.min && puntaje <= a.max) {
      return a.nivel.replaceFirst(RegExp(r'^Autoestima\s+'), '');
    }
  }
  return kSinAlerta;
}

/// Tres niveles por defecto (mismos valores que al crear encuesta en memoria).
List<AlertaStruct> alertasTripletePorDefecto(String? categoria) {
  switch (categoria) {
    case 'Escala autoestima':
      return [
        AlertaStruct(nivel: 'Autoestima Baja', min: 0, max: 25),
        AlertaStruct(nivel: 'Autoestima Media', min: 26, max: 29),
        AlertaStruct(nivel: 'Autoestima Elevada', min: 30, max: 999),
      ];
    case 'CDI':
      return [
        AlertaStruct(nivel: 'Sin sintomatología', min: 0, max: 6),
        AlertaStruct(nivel: 'Leve', min: 7, max: 19),
        AlertaStruct(nivel: 'Severo', min: 20, max: 999),
      ];
    case 'Escala ansiedad':
      return [
        AlertaStruct(nivel: 'Sin sintomatología', min: 0, max: 7),
        AlertaStruct(nivel: 'Leve', min: 8, max: 15),
        AlertaStruct(nivel: 'Moderado', min: 16, max: 21),
        AlertaStruct(nivel: 'Severo', min: 22, max: 999),
      ];
    default:
      return [];
  }
}

/// Given a [puntaje] and the saved [alertas] list from the encuesta,
/// returns the label of the matching level for [categoria].
///
/// The match uses the `nivel` field on each [AlertaStruct] and checks
/// `min <= puntaje <= max`. When no range matches, the level whose
/// `min` is the highest `<= puntaje` is returned as a fallback.
/// Returns an empty string when nothing can be determined.
String calcularNivelAlerta({
  required String? categoria,
  required int puntaje,
  required List<AlertaStruct> alertas,
}) {
  final niveles = nivelesPorCategoria(categoria);
  if (niveles.isEmpty) return '';

  // Filter alerts that belong to this category (sustancia left empty for
  // global-level tamizajes).
  final relevantes =
      alertas.where((a) => niveles.contains(a.nivel)).toList(growable: false);

  if (relevantes.isEmpty) {
    // No persisted ranges -> cannot classify.
    return '';
  }

  // Exact range match.
  for (final a in relevantes) {
    if (puntaje >= a.min && puntaje <= a.max && a.max > 0) {
      return a.nivel;
    }
  }

  // Fallback: highest "min" that the puntaje reaches.
  AlertaStruct? best;
  for (final a in relevantes) {
    if (puntaje >= a.min) {
      if (best == null || a.min > best.min) best = a;
    }
  }
  return best?.nivel ?? relevantes.first.nivel;
}
