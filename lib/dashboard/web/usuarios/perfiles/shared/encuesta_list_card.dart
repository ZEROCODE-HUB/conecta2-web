import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Single row in the encuestas/tamizajes list.
class EncuestaListCard extends StatelessWidget {
  const EncuestaListCard({
    super.key,
    required this.encuesta,
    this.onTap,
    this.etiquetas = const [],
  });

  final EncuestasRecord encuesta;

  /// Abre el detalle; null = fila solo informativa.
  final VoidCallback? onTap;

  /// Chips opcionales bajo la fecha (p. ej. "Publicado", "CDI").
  final List<String> etiquetas;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 10.0),
      child: Container(
        width: 350.0,
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.solidFileLines,
                      color: Color(0xFF265294),
                      size: 24.0,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            15.0, 0.0, 15.0, 0.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              encuesta.titulo,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: theme.bodyMedium.override(
                                font: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  fontStyle: theme.bodyMedium.fontStyle,
                                ),
                                fontSize: 18.0,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (encuesta.createAt != null)
                              Text(
                                dateTimeFormat(
                                  'yMMMd',
                                  encuesta.createAt,
                                  locale: FFLocalizations.of(context).languageCode,
                                ),
                                style: theme.bodyMedium.override(
                                  font: GoogleFonts.inter(
                                    fontWeight: FontWeight.w500,
                                    fontStyle: theme.bodyMedium.fontStyle,
                                  ),
                                  fontSize: 14.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            if (etiquetas.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Wrap(
                                  spacing: 6.0,
                                  runSpacing: 4.0,
                                  children: [
                                    for (final e in etiquetas)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0, vertical: 2.0),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF265294)
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        child: Text(
                                          e,
                                          style: GoogleFonts.inter(
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF265294),
                                          ),
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
              // Sin onTap es solo informativa: sin flecha.
              if (onTap != null)
                IconButton(
                  onPressed: onTap,
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFF265294),
                    size: 24.0,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
