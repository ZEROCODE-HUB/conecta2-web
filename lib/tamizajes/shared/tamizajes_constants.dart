import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// Constantes compartidas para las secciones de Tamizajes
// ═══════════════════════════════════════════════════════════════════════════════

/// Color principal navy de la plataforma.
const Color kNavy = Color(0xFF265294);

/// Color de éxito (verde).
const Color kSuccess = Color(0xFF34A853);

/// Color de peligro (rojo).
const Color kDanger = Color(0xFFE53935);

/// Color para tamizaje manual (azul).
const Color kManualBlue = Color(0xFF1976D2);

/// Color para tamizaje app (púrpura).
const Color kAppPurple = Color(0xFF673AB7);

/// Tamaño de página para paginación en listas de tamizajes.
const int kPageSize = 10;

/// Categorías de filtro disponibles para tamizajes.
const List<String> kCategoriasTamizaje = [
  'Todas',
  'CDI',
  'Beck',
  'CRQ/SRQ',
  'Autoestima',
  'Ansiedad',
  'Consumo de SPA',
];

/// Estados de filtro disponibles para tamizajes.
const List<String> kEstadosTamizaje = [
  'Todos',
  'Completados',
  'Invalidados',
];
