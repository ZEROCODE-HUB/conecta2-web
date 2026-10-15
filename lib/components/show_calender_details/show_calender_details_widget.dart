import '/flutter_flow/flutter_flow_theme.dart';
import '/user/calendar/emociones_service.dart' show cuandoEmocion;
import '/flutter_flow/flutter_flow_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'show_calender_details_model.dart';
export 'show_calender_details_model.dart';

class ShowCalenderDetailsWidget extends StatefulWidget {
  const ShowCalenderDetailsWidget({super.key, this.fecha});

  /// Día seleccionado en el calendario (null = hoy).
  final DateTime? fecha;

  @override
  State<ShowCalenderDetailsWidget> createState() =>
      _ShowCalenderDetailsWidgetState();
}

class _ShowCalenderDetailsWidgetState extends State<ShowCalenderDetailsWidget> {
  late ShowCalenderDetailsModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ShowCalenderDetailsModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Container(
      width: 350.0,
      height: 411.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 20.0),
              child: Text(
                FFAppState().emocion == 0
                    ? '${cuandoEmocion(widget.fecha)}: sin registro'
                    : '${cuandoEmocion(widget.fecha)} me sentí',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                      color: Color(0xFF1F2129),
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 20.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 15.0, 0.0),
                    child: Container(
                      width: 31.0,
                      height: 31.0,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: CachedNetworkImage(
                        fadeInDuration: Duration(milliseconds: 500),
                        fadeOutDuration: Duration(milliseconds: 500),
                        imageUrl: valueOrDefault<String>(
                          () {
                            if (FFAppState().emocion == 1) {
                              return 'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/conecta2-wtnr9n/assets/94v45qugvs2r/caritasRecurso_6Plantilla.png';
                            } else if (FFAppState().emocion == 2) {
                              return 'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/conecta2-wtnr9n/assets/mivazz3vocqw/caritasRecurso_5Plantilla.png';
                            } else if (FFAppState().emocion == 3) {
                              return 'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/conecta2-wtnr9n/assets/kxhn0imof79s/caritasRecurso_4Plantilla.png';
                            } else if (FFAppState().emocion == 4) {
                              return 'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/conecta2-wtnr9n/assets/l5bc1vpqz2vm/caritasRecurso_3Plantilla.png';
                            } else if (FFAppState().emocion == 5) {
                              return 'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/conecta2-wtnr9n/assets/diaqw394jcgs/caritasRecurso_2Plantilla.png';
                            } else {
                              return FFAppConstants.emocionvacia;
                            }
                          }(),
                          'https://i.postimg.cc/nLX7K1tW/Group-223.png',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Text(
                    () {
                      if (FFAppState().emocion == 1) {
                        return 'Con Enojo';
                      } else if (FFAppState().emocion == 2) {
                        return 'Con Miedo';
                      } else if (FFAppState().emocion == 3) {
                        return 'Triste';
                      } else if (FFAppState().emocion == 4) {
                        return 'Indiferente';
                      } else if (FFAppState().emocion == 5) {
                        return 'Muy Alegre';
                      } else {
                        return 'No llenado';
                      }
                    }(),
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w600,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                  ),
                ],
              ),
            ),
            Text(
              FFAppState().description,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                    fontStyle:
                        FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                  ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
              child: Text(
                () {
                  if (valueOrDefault<int>(
                        FFAppState().emocion,
                        0,
                      ) ==
                      1) {
                    return FFAppConstants.Enojo;
                  } else if (valueOrDefault<int>(
                        FFAppState().emocion,
                        0,
                      ) ==
                      2) {
                    return FFAppConstants.Miedo;
                  } else if (valueOrDefault<int>(
                        FFAppState().emocion,
                        0,
                      ) ==
                      3) {
                    return FFAppConstants.Tristeza;
                  } else if (valueOrDefault<int>(
                        FFAppState().emocion,
                        0,
                      ) ==
                      4) {
                    return FFAppConstants.Indiferencia;
                  } else if (valueOrDefault<int>(
                        FFAppState().emocion,
                        0,
                      ) ==
                      5) {
                    return FFAppConstants.Alegra;
                  } else {
                    return 'No llenado';
                  }
                }(),
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                      fontSize: 14.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w500,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
