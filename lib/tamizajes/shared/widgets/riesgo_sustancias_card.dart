import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../assist_utils.dart';
import '../tamizajes_constants.dart';

/// Color de un nivel ASSIST (Bajo / Moderado / Alto; gris si "Sin alerta").
Color colorNivelAssist(String nivel) {
  switch (nivel) {
    case kSinAlerta:
      return kGrisSinAlerta;
    case 'Alto':
      return const Color(0xFFD92D20);
    case 'Moderado':
      return const Color(0xFFF6BD33);
    case 'Bajo':
      return kSuccess;
    default:
      return kNavy;
  }
}

/// Tarjeta "Riesgo por sustancia" de un ASSIST: una fila por sustancia
/// evaluada con su puntaje y nivel, más las sustancias marcadas en el
/// Condicionante. La usan los resultados del wizard (móvil y web) y el
/// detalle de un tamizaje.
class RiesgoSustanciasCard extends StatelessWidget {
  const RiesgoSustanciasCard({super.key, required this.resultado});

  final ResultadoAssist resultado;

  @override
  Widget build(BuildContext context) {
    final filas = resultado.porSustancia.values.toList();
    final usaOms = filas.any((s) => s.origen == OrigenNivel.oms);
    final global = resultado.nivelGlobal;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E3E7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.science_outlined, size: 18, color: kNavy),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Riesgo por sustancia',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: kNavy,
                  ),
                ),
              ),
              if (global.isNotEmpty) _NivelChip(nivel: 'Global: $global', color: colorNivelAssist(global)),
            ],
          ),
          if (resultado.sustanciasMarcadas.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Marcadas en el condicionante: '
              '${resultado.sustanciasMarcadas.join(', ')}',
              style: GoogleFonts.inter(fontSize: 12, color: Colors.black54),
            ),
          ],
          const SizedBox(height: 10),
          if (filas.isEmpty)
            Text(
              'No se evaluó ninguna sustancia (no se marcó consumo en el '
              'condicionante).',
              style: GoogleFonts.inter(fontSize: 13, color: Colors.black54),
            )
          else
            ...filas.map(
              (s) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        s.sustancia,
                        style: GoogleFonts.inter(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                    SizedBox(
                      width: 72,
                      child: Text(
                        'Puntaje ${s.puntaje}',
                        textAlign: TextAlign.right,
                        style: GoogleFonts.inter(
                            fontSize: 12, color: Colors.black54),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _NivelChip(
                      nivel: s.origen == OrigenNivel.oms
                          ? '${s.nivel} *'
                          : s.nivel,
                      color: colorNivelAssist(s.nivel),
                    ),
                  ],
                ),
              ),
            ),
          if (usaOms) ...[
            const SizedBox(height: 8),
            Text(
              '* Sin rangos configurados para la sustancia: se usan los cortes '
              'ASSIST de la OMS.',
              style: GoogleFonts.inter(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: Colors.black45),
            ),
          ],
        ],
      ),
    );
  }
}

class _NivelChip extends StatelessWidget {
  const _NivelChip({required this.nivel, required this.color});

  final String nivel;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Text(
        nivel,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color == kSuccess ? const Color(0xFF1E7B34) : color,
        ),
      ),
    );
  }
}
