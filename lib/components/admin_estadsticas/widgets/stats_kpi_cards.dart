import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '../helpers/stats_calculator.dart';

class StatsKpiCards extends StatelessWidget {
  const StatsKpiCards({super.key, required this.stats});

  final StatsAggregates stats;

  @override
  Widget build(BuildContext context) {
    final total = stats.total;
    final severos = _countsByCriticality(_criticoNiveles);
    final moderados = _countsByCriticality(_moderadoNiveles);
    final sanos = total - severos - moderados;
    final isSRQ = stats.categoria == 'SRQ';
    final isRQC = stats.categoria == 'RQC';
    final isSubescala = isSRQ || isRQC;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cards = [
          _KpiCard(
            label: 'Evaluados',
            value: stats.usuariosEvaluados.toString(),
            color: FlutterFlowTheme.of(context).accent2,
            icon: Icons.people_outline,
          ),
          _KpiCard(
            label: isSubescala ? 'Subescala 2' : 'Alertas severas',
            value: _percentLabel(severos, total),
            color: const Color(StatsColors.rojo),
            icon: Icons.warning_amber_rounded,
            subtitle: '$severos casos',
          ),
          _KpiCard(
            label: isSubescala ? 'Subescala 1' : 'Alertas moderadas',
            value: _percentLabel(moderados, total),
            color: const Color(StatsColors.amarillo),
            icon: Icons.info_outline,
            subtitle: '$moderados casos',
          ),
          _KpiCard(
            label: 'Sin alertas',
            value: _percentLabel(sanos, total),
            color: const Color(StatsColors.verde),
            icon: Icons.check_circle_outline,
            subtitle: '$sanos casos',
          ),
        ];

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: cards
              .map((c) => SizedBox(
                    width: _cardWidth(constraints.maxWidth, cards.length),
                    height: 88,
                    child: c,
                  ))
              .toList(),
        );
      },
    );
  }

  int _countsByCriticality(Set<String> keys) {
    var sum = 0;
    stats.distribucion.forEach((nivel, count) {
      if (keys.contains(nivel.toLowerCase())) sum += count;
    });
    return sum;
  }

  static const _criticoNiveles = <String>{
    'grave',
    'severo',
    'severa',
    'baja',
    'subescala 2',
  };

  static const _moderadoNiveles = <String>{
    'moderada',
    'moderado',
    'leve',
    'media',
    'subescala 1',
  };

  String _percentLabel(int count, int total) {
    if (total == 0) return '0%';
    final pct = (count / total * 100).toStringAsFixed(0);
    return '$pct%';
  }

  double _cardWidth(double maxWidth, int count) {
    const spacing = 12.0;
    if (maxWidth >= 900) {
      return (maxWidth - spacing * (count - 1)) / count;
    }
    if (maxWidth >= 520) {
      return (maxWidth - spacing) / 2;
    }
    return maxWidth;
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    this.subtitle,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(11),
                  bottomLeft: Radius.circular(11),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: color, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            label,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: theme.secondaryText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            value,
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: theme.primaryText,
                            ),
                          ),
                          if (subtitle != null)
                            Text(
                              subtitle!,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: theme.secondaryText,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
