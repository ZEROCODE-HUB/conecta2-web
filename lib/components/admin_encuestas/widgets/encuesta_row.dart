import '/backend/backend.dart';
import '/components/empty_resultados_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '../admin_encuestas_model.dart';
import 'encuesta_actions_menu.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

/// A single row in the encuestas table.
class EncuestaRow extends StatelessWidget {
  const EncuestaRow({
    super.key,
    required this.model,
    required this.encuesta,
    required this.onStateChanged,
  });

  final AdminEncuestasModel model;
  final EncuestasRecord encuesta;
  final VoidCallback onStateChanged;

  Future<void> _handleResultados(BuildContext context) async {
    model.check1 = await queryRespuestasRecordOnce(
      parent: encuesta.reference,
      singleRecord: true,
    ).then((s) => s.firstOrNull);

    if (model.check1?.reference != null) {
      // Decide por tipo: las encuestas también llevan categoría ("Encuesta").
      FFAppState().selectUser = encuesta.tipo == 'Tamizajes'
          ? 'ResultadosTamizaje'
          : 'Resultados';
      model.documentID = encuesta.reference;
      onStateChanged();
    } else {
      if (!context.mounted) return;
      await showDialog(
        context: context,
        builder: (dialogContext) {
          return Dialog(
            elevation: 0,
            insetPadding: EdgeInsets.zero,
            backgroundColor: Colors.transparent,
            alignment: AlignmentDirectional(0.0, 0.0)
                .resolve(Directionality.of(context)),
            child: const WebViewAware(child: EmptyResultadosWidget()),
          );
        },
      );
    }
    onStateChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Title
            Expanded(
              flex: 35,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  const FaIcon(
                    FontAwesomeIcons.solidFileLines,
                    color: Color(0xFF265294),
                    size: 24.0,
                  ),
                  const SizedBox(width: 5.0),
                  Expanded(
                    child: Text(
                      encuesta.titulo,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(),
                            fontSize: 14.0,
                            letterSpacing: 0.0,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            // Dirigido para (roles)
            Expanded(
              flex: 14,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: encuesta.roles
                    .map<Widget>(
                      (roleItem) => Align(
                        alignment: AlignmentDirectional.center,
                        child: Text(
                          roleItem,
                          overflow: TextOverflow.ellipsis,
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                                font: GoogleFonts.inter(),
                                fontSize: 14.0,
                                letterSpacing: 0.0,
                              ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            // Estado pill
            Expanded(
              flex: 16,
              child: Container(
                height: 38.0,
                decoration: BoxDecoration(
                  color: encuesta.publicado
                      ? const Color(0xFF88FFDB)
                      : const Color(0xFFFFCB9B),
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: Align(
                  alignment: AlignmentDirectional.center,
                  child: Text(
                    encuesta.publicado ? 'Publicado' : 'Borrador',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.inter(),
                          fontSize: 14.0,
                          letterSpacing: 0.0,
                        ),
                  ),
                ),
              ),
            ),
            // Creación date
            Expanded(
              flex: 15,
              child: Align(
                alignment: AlignmentDirectional.center,
                child: Text(
                  encuesta.createAt == null
                      ? '-'
                      : dateTimeFormat(
                          'yMMMd',
                          encuesta.createAt!,
                          locale: FFLocalizations.of(context).languageCode,
                        ),
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(),
                        fontSize: 14.0,
                        letterSpacing: 0.0,
                      ),
                ),
              ),
            ),
            // Resultados button
            Expanded(
              flex: 12,
              child: Align(
                alignment: AlignmentDirectional.center,
                child: FFButtonWidget(
                  onPressed: () => _handleResultados(context),
                  text: 'Resultados',
                  options: FFButtonOptions(
                    height: 35.0,
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        20.0, 0.0, 20.0, 0.0),
                    iconPadding: EdgeInsetsDirectional.zero,
                    color: const Color(0xFF265294),
                    textStyle:
                        FlutterFlowTheme.of(context).titleSmall.override(
                              font: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600),
                              color: Colors.white,
                              fontSize: 14.0,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w600,
                            ),
                    elevation: 0.0,
                    borderSide: const BorderSide(
                      color: Colors.transparent,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
            ),
            // Actions menu (3 dots)
            Expanded(
              flex: 10,
              child: Align(
                alignment: AlignmentDirectional.center,
                child: EncuestaActionsMenu(
                  model: model,
                  encuesta: encuesta,
                  onStateChanged: onStateChanged,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
