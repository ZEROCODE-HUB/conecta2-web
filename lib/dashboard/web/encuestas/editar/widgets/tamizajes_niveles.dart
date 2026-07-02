// Helpers for alert-level configuration and evaluation by test category.
//
// Each published tamizaje (Autoestima, CDI, Depresión Beck, CRQ/SRQ, Consumo
// de SPA) has a set of predefined alert levels. This file centralises:
//   * `nivelesPorCategoria` -> labels shown in the editor's "Alertas" panel.
//   * `calcularNivelAlerta` -> given a score + saved AlertaStruct list,
//     returns the matching level label for display in the results screen.
//
// It is pure Dart (no Flutter widgets) so it can be reused by the wizard
// results views (web + mobile) and the PDF builder without pulling in
// Material dependencies.

import '/backend/schema/encuestas_record.dart';
import '/backend/schema/structs/index.dart';
import '/components/admin_estadsticas/helpers/classification.dart'
    show UmbralesConfig;

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
    'Moderada',
    'Severo',
  ],
  'SRQ': [
    'Sin alerta',
    'Moderada',
    'Severo',
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

/// Umbrales para [classifyNivel] en **CDI** y **Escala autoestima** (primer y
/// segundo tramo; el tercero es el resto).
///
/// Prioriza los campos anidados `bajo` y `moderado` del documento. Si no tienen
/// `max` persistido (p. ej. primer guardado incompleto), reconstruye desde el
/// array `alertas` buscando por etiqueta en [nivelesPorCategoria].
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

UmbralesConfig? umbralesTripleteDesdeEncuesta(EncuestasRecord e) {
  final cat = e.categoria;

  // ── Escala ansiedad (4 niveles) ──────────────────────────────────────────
  if (cat == 'Escala ansiedad') {
    final orden = nivelesPorCategoria(cat);
    if (orden.length < 4) return null;
    final byNombre = <String, AlertaStruct>{};
    for (final a in e.alertas) {
      if (a.nivel.isNotEmpty) byNombre[a.nivel] = a;
    }
    final a0 = byNombre[orden[0]];
    final a1 = byNombre[orden[1]];
    final a2 = byNombre[orden[2]];
    if (a0 != null &&
        a1 != null &&
        a2 != null &&
        a0.hasMax() &&
        a1.hasMax() &&
        a2.hasMax() &&
        a0.max < a1.max &&
        a1.max < a2.max) {
      return UmbralesConfig(
        ansiedad1Max: a0.max,
        ansiedad2Max: a1.max,
        ansiedad3Max: a2.max,
      );
    }
    return null;
  }

  // ── 3-level (Autoestima / CDI) ────────────────────────────────────────────
  if (cat != 'Escala autoestima' && cat != 'CDI') return null;

  final orden = nivelesPorCategoria(cat);
  if (orden.length < 2) return null;
  final byNombre = <String, AlertaStruct>{};
  for (final a in e.alertas) {
    if (a.nivel.isNotEmpty) byNombre[a.nivel] = a;
  }
  final a0 = byNombre[orden[0]];
  final a1 = byNombre[orden[1]];

  // Umbrales coherentes: el segundo tramo debe terminar después del primero.
  bool tripleteValido(int bajoMax, int moderadoMax) => bajoMax < moderadoMax;

  // 1) Preferir `alertas`: AlertasConfig (editor clásico) solo persiste este
  //    array; `bajo`/`moderado` pueden quedar desactualizados y forzar nivel
  //    erróneo aunque el listado de alertas esté bien.
  if (a0 != null &&
      a1 != null &&
      a0.hasMax() &&
      a1.hasMax() &&
      tripleteValido(a0.max, a1.max)) {
    return UmbralesConfig(
      bajoMax: a0.max,
      moderadoMax: a1.max,
    );
  }

  if (e.bajo.hasMax() &&
      e.moderado.hasMax() &&
      tripleteValido(e.bajo.max, e.moderado.max)) {
    return UmbralesConfig(
      bajoMax: e.bajo.max,
      moderadoMax: e.moderado.max,
    );
  }

  return null;
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
