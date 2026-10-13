import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// "Enviar Repuestas" action row at the bottom of the vista previa.
///
/// When pressed it flips the `publicado` flag of the current encuesta to true
/// and clears the selected-user state (returning the admin to the listing).
/// For tamizajes ([esTamizaje]) it becomes "Volver a editar" and only
/// navigates back to the editor, without writing to Firestore.
class PreviewSubmitButton extends StatelessWidget {
  const PreviewSubmitButton({
    super.key,
    required this.encuestaID,
    this.esTamizaje = false,
    this.onSubmitted,
  });

  final DocumentReference encuestaID;
  final bool esTamizaje;
  final VoidCallback? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 40.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FFButtonWidget(
            onPressed: () async {
              if (esTamizaje) {
                FFAppState().selectUser = FFAppState().createEncuesta == true
                    ? 'Crearencuesta'
                    : 'Editar Encuesta';
                FFAppState().update(() {});
                return;
              }
              await encuestaID.update(createEncuestasRecordData(
                publicado: true,
              ));
              FFAppState().selectUser = '';
              onSubmitted?.call();
            },
            text: esTamizaje ? 'Volver a editar' : 'Enviar Repuestas',
            options: FFButtonOptions(
              height: 54.0,
              padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
              iconPadding:
                  EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
              color: FlutterFlowTheme.of(context).secondary,
              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                    font: GoogleFonts.inter(
                      fontWeight:
                          FlutterFlowTheme.of(context).titleSmall.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).titleSmall.fontStyle,
                    ),
                    color: Color(0xFF265294),
                    fontSize: 18.0,
                    letterSpacing: 0.0,
                    fontWeight:
                        FlutterFlowTheme.of(context).titleSmall.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).titleSmall.fontStyle,
                  ),
              elevation: 3.0,
              borderSide: BorderSide(
                color: FlutterFlowTheme.of(context).secondary,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(40.0),
            ),
          ),
        ],
      ),
    );
  }
}
