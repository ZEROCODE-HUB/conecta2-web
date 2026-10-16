import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '../helpers/stats_calculator.dart';
import 'chart_card.dart';

class ChartDistribucionNiveles extends StatefulWidget {
  const ChartDistribucionNiveles({super.key, required this.stats});

  final StatsAggregates stats;

  @override
  State<ChartDistribucionNiveles> createState() =>
      _ChartDistribucionNivelesState();
}

class _ChartDistribucionNivelesState extends State<ChartDistribucionNiveles> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return ChartCard(
      title: _titulo(),
      subtitle: 'Total clasificado: ${widget.stats.total}',
      child: widget.stats.total == 0
          ? const ChartEmpty()
          : Row(
              children: [
                Expanded(
                  flex: 3,
                  child: PieChart(
                    PieChartData(
                      sections: _buildSections(),
                      centerSpaceRadius: 52,
                      sectionsSpace: 2,
                      pieTouchData: PieTouchData(
                        touchCallback: (event, response) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                response == null ||
                                response.touchedSection == null) {
                              _touchedIndex = -1;
                              return;
                            }
                            _touchedIndex =
                                response.touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                    ),
                    duration: const Duration(milliseconds: 500),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: _Legend(stats: widget.stats),
                ),
              ],
            ),
    );
  }

  String _titulo() {
    switch (widget.stats.tipo) {
      case TamizajeTipo.autoestima:
        return 'Nivel de autoestima';
      case TamizajeTipo.ansiedad:
        return 'Nivel de ansiedad';
      case TamizajeTipo.cdi:
        return 'Nivel de depresión (CDI)';
      case TamizajeTipo.beck:
        return 'Nivel de depresión (Beck)';
      case TamizajeTipo.rqc:
        return 'Escala de valoración';
      case TamizajeTipo.srq:
        return 'Puntuación psicométrica y subescalas';
      case TamizajeTipo.sustancias:
        return 'Nivel de consumo (Sustancias)';
      case TamizajeTipo.todas:
        return 'Distribución global de alertas';
    }
  }

  List<PieChartSectionData> _buildSections() {
    final sections = <PieChartSectionData>[];
    final niveles = widget.stats.niveles;
    for (var i = 0; i < niveles.length; i++) {
      final nivel = niveles[i];
      final value = (widget.stats.distribucion[nivel] ?? 0).toDouble();
      if (value == 0) continue;
      final pct = value / widget.stats.total * 100;
      final isTouched = i == _touchedIndex;
      sections.add(PieChartSectionData(
        value: value,
        color: Color(StatsColors.forNivel(nivel,
            sinAlertaGris: widget.stats.tipo.sinAlertaFueraDeRango)),
        title: '${pct.toStringAsFixed(0)}%',
        titleStyle: TextStyle(
          color: Colors.white,
          fontSize: isTouched ? 13 : 12,
          fontWeight: FontWeight.w700,
          shadows: const [Shadow(color: Colors.black26, blurRadius: 2)],
        ),
        radius: isTouched ? 90 : 80,
        titlePositionPercentageOffset: 0.58,
      ));
    }
    return sections;
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.stats});
  final StatsAggregates stats;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: stats.niveles.map((n) {
        final count = stats.distribucion[n] ?? 0;
        final pct = stats.total == 0 ? 0 : (count / stats.total * 100);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Color(StatsColors.forNivel(n,
                      sinAlertaGris: stats.tipo.sinAlertaFueraDeRango)),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      n,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.primaryText,
                      ),
                    ),
                    Text(
                      '$count · ${pct.toStringAsFixed(0)}%',
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
        );
      }).toList(),
    );
  }
}
