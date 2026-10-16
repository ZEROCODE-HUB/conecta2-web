import 'package:flutter/material.dart';

import '../nivel_respuesta.dart';
import '../tamizajes_constants.dart';

/// Color del nivel de una respuesta de tamizaje en las tarjetas de resultado
/// (detalle, wizard web y wizard móvil del profesional).
///
/// - Gris: "Sin alerta" porque el puntaje no cayó en ningún rango configurado.
/// - Verde: nivel sano. Amarillo: intermedio. Rojo: el más severo.
/// - Autoestima: "Baja" es el nivel de riesgo y "Elevada" el sano.
Color colorNivelTamizaje(String categoria, String nivel) {
  if (esSinAlertaPorRango(categoria, nivel)) return kGrisSinAlerta;
  final n = nivel.toLowerCase();
  if (categoria == 'Escala autoestima') {
    if (n.contains('baja')) return const Color(0xFFD92D20);
    if (n.contains('elevada')) return kSuccess;
  }
  if (n.contains('baja') ||
      n.contains('bajo') ||
      n.contains('sin ') ||
      n.contains('mínima') ||
      n.contains('minima')) {
    return kSuccess;
  }
  if (n.contains('media') || n.contains('moderad') || n.contains('leve')) {
    return const Color(0xFFF6BD33);
  }
  if (n.contains('elevada') ||
      n.contains('alto') ||
      n.contains('grave') ||
      n.contains('severo')) {
    return const Color(0xFFD92D20);
  }
  return kNavy;
}
