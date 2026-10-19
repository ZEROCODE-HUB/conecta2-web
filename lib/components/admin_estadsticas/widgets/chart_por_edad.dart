import 'package:flutter/material.dart';

import '../helpers/stats_calculator.dart';
import 'chart_card.dart';
import 'grouped_bar_chart.dart';

class ChartPorEdad extends StatelessWidget {
  const ChartPorEdad({super.key, required this.stats});

  final StatsAggregates stats;

  @override
  Widget build(BuildContext context) {
    return ChartCard(
      title: 'Alertas por rango de edad',
      subtitle: stats.tipo.label,
      child: stats.total == 0
          ? const ChartEmpty()
          : GroupedBarChart(
              categorias: kRangosEdad,
              niveles: stats.niveles,
              data: stats.porEdad,
              tooltipCategoryLabel: (c) => '$c años',
            ),
    );
  }
}
