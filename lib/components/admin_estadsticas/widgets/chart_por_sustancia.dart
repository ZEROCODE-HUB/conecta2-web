import 'package:flutter/material.dart';

import '/tamizajes/shared/assist_utils.dart' show kNivelesAssist;

import '../helpers/stats_calculator.dart';
import 'chart_card.dart';
import 'grouped_bar_chart.dart';

/// ASSIST: personas por nivel de riesgo (Bajo/Moderado/Alto) en cada
/// sustancia evaluada. Solo se muestra en la pestaña Sustancias.
class ChartPorSustancia extends StatelessWidget {
  const ChartPorSustancia({super.key, required this.stats});

  final StatsAggregates stats;

  @override
  Widget build(BuildContext context) {
    final sustancias = stats.porSustancia.keys.toList();
    return ChartCard(
      title: 'Riesgo por sustancia',
      subtitle: 'Personas evaluadas por nivel en cada sustancia',
      child: sustancias.isEmpty
          ? const ChartEmpty()
          : GroupedBarChart(
              categorias: sustancias,
              niveles: kNivelesAssist,
              data: stats.porSustancia,
              tooltipCategoryLabel: (c) => c,
            ),
    );
  }
}
