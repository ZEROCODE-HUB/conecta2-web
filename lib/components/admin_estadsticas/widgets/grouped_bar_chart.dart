import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../helpers/stats_calculator.dart';
import 'chart_card.dart';

/// Grouped vertical bar chart: one group per category (gender / age range),
/// one rod per nivel. Reusable for both [ChartPorGenero] and [ChartPorEdad]
/// and any future "per-bucket × per-nivel" breakdown.
class GroupedBarChart extends StatelessWidget {
  const GroupedBarChart({
    super.key,
    required this.categorias,
    required this.niveles,
    required this.data,
    required this.tooltipCategoryLabel,
  });

  /// X-axis categories (e.g. ['Masculino', 'Femenino', 'Otro']).
  final List<String> categorias;

  /// Level labels used as the rod dimension and for the legend.
  final List<String> niveles;

  /// `data[categoria][nivel] = count`.
  final Map<String, Map<String, int>> data;

  /// Formatter for the bold tooltip first line, e.g. '10-12 años'.
  final String Function(String categoria) tooltipCategoryLabel;

  @override
  Widget build(BuildContext context) {
    final maxY = _computeMaxY();

    return Column(
      children: [
        Expanded(
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => const Color(0xE6263238),
                  tooltipBorderRadius: BorderRadius.circular(8),
                  tooltipPadding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 8),
                  getTooltipItem: (group, gIdx, rod, rIdx) {
                    final cat = categorias[group.x];
                    final nivel = niveles[rIdx];
                    final count = rod.toY.toInt();
                    return BarTooltipItem(
                      '${tooltipCategoryLabel(cat)}\n',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                      children: [
                        TextSpan(
                          text: '$nivel: $count',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              titlesData: _buildTitles(maxY),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: _interval(maxY),
                getDrawingHorizontalLine: (_) => const FlLine(
                  color: Color(0xFFE8EAED),
                  strokeWidth: 1,
                  dashArray: [4, 4],
                ),
              ),
              barGroups: _buildGroups(),
            ),
            duration: const Duration(milliseconds: 400),
          ),
        ),
        const SizedBox(height: 10),
        NivelLegend(
          niveles: niveles,
          colors: niveles.map(StatsColors.forNivel).toList(),
        ),
      ],
    );
  }

  FlTitlesData _buildTitles(double maxY) => FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            interval: _interval(maxY),
            getTitlesWidget: (v, meta) => Text(
              v.toInt().toString(),
              style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            getTitlesWidget: (v, meta) {
              final idx = v.toInt();
              if (idx < 0 || idx >= categorias.length) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  categorias[idx],
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            },
          ),
        ),
      );

  List<BarChartGroupData> _buildGroups() {
    final groups = <BarChartGroupData>[];
    for (var i = 0; i < categorias.length; i++) {
      final counts = data[categorias[i]] ?? const <String, int>{};
      final rods = niveles
          .map((n) => BarChartRodData(
                toY: (counts[n] ?? 0).toDouble(),
                color: Color(StatsColors.forNivel(n)),
                width: 14,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ))
          .toList();
      groups.add(BarChartGroupData(x: i, barsSpace: 4, barRods: rods));
    }
    return groups;
  }

  double _computeMaxY() {
    var max = 0;
    for (final c in categorias) {
      final row = data[c] ?? const <String, int>{};
      for (final v in row.values) {
        if (v > max) max = v;
      }
    }
    if (max == 0) return 4;
    return (max * 1.2).ceilToDouble();
  }

  double _interval(double maxY) {
    if (maxY <= 5) return 1;
    if (maxY <= 20) return 5;
    if (maxY <= 100) return 10;
    return (maxY / 5).ceilToDouble();
  }
}
