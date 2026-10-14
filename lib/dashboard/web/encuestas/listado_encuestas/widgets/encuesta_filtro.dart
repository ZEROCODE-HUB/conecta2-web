import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Barra de filtros del Listado de Encuestas: selector de encuesta.
class EncuestaFiltro extends StatelessWidget {
  const EncuestaFiltro({
    super.key,
    required this.encuestas,
    required this.encuestaId,
    required this.onChanged,
  });

  final List<EncuestasRecord> encuestas;

  /// Id de la encuesta seleccionada; null = todas.
  final String? encuestaId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final textStyle = GoogleFonts.inter(
      fontSize: 12.0,
      color: theme.primaryText,
      letterSpacing: 0.0,
    );
    final valor = encuestas.any((e) => e.reference.id == encuestaId)
        ? encuestaId
        : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      color: theme.secondaryBackground,
      child: Wrap(
        spacing: 16.0,
        runSpacing: 8.0,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'Filtros:',
            style: theme.labelMedium.override(
              font: GoogleFonts.inter(fontWeight: FontWeight.w600),
              fontSize: 13.0,
              letterSpacing: 0.0,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Encuesta:',
                style: GoogleFonts.inter(
                  fontSize: 12.0,
                  color: theme.secondaryText,
                  letterSpacing: 0.0,
                ),
              ),
              const SizedBox(width: 6.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                constraints: const BoxConstraints(maxWidth: 360.0),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.alternate),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: DropdownButton<String?>(
                  value: valor,
                  isDense: true,
                  isExpanded: false,
                  underline: const SizedBox(),
                  style: textStyle,
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Todas', style: textStyle),
                    ),
                    for (final e in encuestas)
                      DropdownMenuItem<String?>(
                        value: e.reference.id,
                        child: Text(
                          e.titulo.isNotEmpty ? e.titulo : '(sin título)',
                          overflow: TextOverflow.ellipsis,
                          style: textStyle,
                        ),
                      ),
                  ],
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
