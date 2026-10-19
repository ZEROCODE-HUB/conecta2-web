import 'package:flutter/material.dart';

import '../helpers/stats_calculator.dart';
import 'chart_card.dart';
import 'grouped_bar_chart.dart';

class ChartPorGenero extends StatelessWidget {
  const ChartPorGenero({super.key, required this.stats});

  final StatsAggregates stats;

  @override
  Widget build(BuildContext context) {
    return ChartCard(
      title: 'Alertas por género',
      subtitle: stats.tipo.label,
      child: stats.total == 0
          ? const ChartEmpty()
          : GroupedBarChart(
              categorias: kGeneros,
              niveles: stats.niveles,
              data: stats.porGenero,
              tooltipCategoryLabel: (c) => c,
            ),
    );
  }
}
