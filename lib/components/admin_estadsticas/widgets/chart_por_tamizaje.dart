import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '../helpers/stats_calculator.dart';
import 'chart_card.dart';

class ChartPorTamizaje extends StatelessWidget {
  const ChartPorTamizaje({super.key, required this.stats});

  final StatsAggregates stats;

  @override
  Widget build(BuildContext context) {
    if (stats.porTamizaje.isEmpty) {
      return const ChartCard(
        title: 'Alertas por tamizaje',
        child: ChartEmpty(),
      );
    }

    // Sort descending by count
    final entries = stats.porTamizaje.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final maxCount = entries.fold<int>(0, (max, e) => e.value > max ? e.value : max);
    final theme = FlutterFlowTheme.of(context);

    return ChartCard(
      title: 'Alertas por tamizaje',
      subtitle: 'Cantidad de alertas registradas (moderadas o graves) por encuesta',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: entries.map((entry) {
            final double percentage = maxCount > 0 ? entry.value / maxCount : 0.0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      entry.key,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.bodyMedium.override(
                        font: GoogleFonts.inter(
                          fontWeight: FontWeight.w500,
                          fontStyle: theme.bodyMedium.fontStyle,
                        ),
                        color: theme.primaryText,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    flex: 5,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          children: [
                            Container(
                              height: 12.0,
                              decoration: BoxDecoration(
                                color: theme.alternate.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                            ),
                            Container(
                              height: 12.0,
                              width: constraints.maxWidth * percentage,
                              decoration: BoxDecoration(
                                color: const Color(StatsColors.rojo),
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  SizedBox(
                    width: 30,
                    child: Text(
                      entry.value.toString(),
                      textAlign: TextAlign.right,
                      style: theme.bodyMedium.override(
                        font: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontStyle: theme.bodyMedium.fontStyle,
                        ),
                        color: theme.primaryText,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
