import 'package:flutter/material.dart';

import '/tamizajes/shared/assist_utils.dart' show kNivelesAssist, kSinAlerta;

import '../helpers/stats_calculator.dart';
import 'chart_card.dart';
import 'grouped_bar_chart.dart';

/// ASSIST: personas por nivel de riesgo (Bajo/Moderado/Alto) en cada
/// sustancia evaluada. Solo se muestra en la pestaña Sustancias. Si alguna
/// sustancia quedó fuera de todos los rangos configurados se agrega la barra
/// gris "Sin alerta".
class ChartPorSustancia extends StatelessWidget {
  const ChartPorSustancia({super.key, required this.stats});

  final StatsAggregates stats;

  @override
  Widget build(BuildContext context) {
    final sustancias = stats.porSustancia.keys.toList();
    final haySinAlerta =
        stats.porSustancia.values.any((f) => (f[kSinAlerta] ?? 0) > 0);
    return ChartCard(
      title: 'Riesgo por sustancia',
      subtitle: 'Personas evaluadas por nivel en cada sustancia',
      child: sustancias.isEmpty
          ? const ChartEmpty()
          : GroupedBarChart(
              categorias: sustancias,
              niveles: [if (haySinAlerta) kSinAlerta, ...kNivelesAssist],
              data: stats.porSustancia,
              tooltipCategoryLabel: (c) => c,
            ),
    );
  }
}
