import '/backend/backend.dart';
import '/user/calendar/emociones_service.dart'
    show emocionesDelDia, registroDelDia;
import '/components/dias/dias_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'calendario_read2_model.dart';
export 'calendario_read2_model.dart';

class CalendarioRead2Widget extends StatefulWidget {
  const CalendarioRead2Widget({
    super.key,
    required this.inputDate,
    this.onSelectDateAction,
    this.initialSelectedDate,
    this.placeofmanagement,
    required this.userRef,
  });

  final DateTime? inputDate;
  final Future Function(DateTime? selectedDate)? onSelectDateAction;
  final DateTime? initialSelectedDate;
  final String? placeofmanagement;
  final DocumentReference? userRef;

  @override
  State<CalendarioRead2Widget> createState() => _CalendarioRead2WidgetState();
}

class _CalendarioRead2WidgetState extends State<CalendarioRead2Widget> {
  late CalendarioRead2Model _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CalendarioRead2Model());

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.inputDate = widget.inputDate;
      safeSetState(() {});
      if (widget.initialSelectedDate != null) {
        _model.selectedDate = widget.initialSelectedDate;
        safeSetState(() {});
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primary,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 40.0,
              decoration: BoxDecoration(),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FFButtonWidget(
                    onPressed: () async {
                      _model.inputDate =
                          functions.getLastMonthDateTime(_model.inputDate!);
                      safeSetState(() {});
                    },
                    text: 'Atrás',
                    options: FFButtonOptions(
                      height: 40.0,
                      padding:
                          EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                      iconPadding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      color: Color(0xFFE3E3E3),
                      textStyle:
                          FlutterFlowTheme.of(context).titleSmall.override(
                                font: GoogleFonts.inter(
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .fontStyle,
                                ),
                                color: FlutterFlowTheme.of(context).primaryText,
                                fontSize: 18.0,
                                letterSpacing: 0.0,
                                fontWeight: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .fontWeight,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .fontStyle,
                              ),
                      elevation: 3.0,
                      borderSide: BorderSide(
                        color: Colors.transparent,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                  ),
                  FFButtonWidget(
                    onPressed: () async {
                      _model.inputDate =
                          functions.getNextMonthDateTime(_model.inputDate!);
                      safeSetState(() {});
                    },
                    text: 'Siguiente',
                    options: FFButtonOptions(
                      height: 40.0,
                      padding:
                          EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                      iconPadding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      color: FlutterFlowTheme.of(context).accent2,
                      textStyle:
                          FlutterFlowTheme.of(context).titleSmall.override(
                                font: GoogleFonts.inter(
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .fontStyle,
                                ),
                                color: Colors.white,
                                fontSize: 18.0,
                                letterSpacing: 0.0,
                                fontWeight: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .fontWeight,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .fontStyle,
                              ),
                      elevation: 3.0,
                      borderSide: BorderSide(
                        color: Colors.transparent,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 10.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    valueOrDefault<String>(
                      dateTimeFormat(
                        "MMMM",
                        dateTimeFromSecondsSinceEpoch(valueOrDefault<int>(
                          _model.inputDate?.secondsSinceEpoch,
                          0,
                        )),
                        locale: FFLocalizations.of(context).languageCode,
                      ),
                      'null',
                    ),
                    style: FlutterFlowTheme.of(context).labelLarge.override(
                          font: GoogleFonts.outfit(
                            fontWeight: FlutterFlowTheme.of(context)
                                .labelLarge
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .labelLarge
                                .fontStyle,
                          ),
                          fontSize: 16.0,
                          letterSpacing: 0.0,
                          fontWeight: FlutterFlowTheme.of(context)
                              .labelLarge
                              .fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).labelLarge.fontStyle,
                        ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 5.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  wrapWithModel(
                    model: _model.diasModel1,
                    updateCallback: () => safeSetState(() {}),
                    child: DiasWidget(
                      dia: 'Lun',
                    ),
                  ),
                  wrapWithModel(
                    model: _model.diasModel2,
                    updateCallback: () => safeSetState(() {}),
                    child: DiasWidget(
                      dia: 'Mar',
                    ),
                  ),
                  wrapWithModel(
                    model: _model.diasModel3,
                    updateCallback: () => safeSetState(() {}),
                    child: DiasWidget(
                      dia: 'Mie',
                    ),
                  ),
                  wrapWithModel(
                    model: _model.diasModel4,
                    updateCallback: () => safeSetState(() {}),
                    child: DiasWidget(
                      dia: 'Jue',
                    ),
                  ),
                  wrapWithModel(
                    model: _model.diasModel5,
                    updateCallback: () => safeSetState(() {}),
                    child: DiasWidget(
                      dia: 'Vie',
                    ),
                  ),
                  wrapWithModel(
                    model: _model.diasModel6,
                    updateCallback: () => safeSetState(() {}),
                    child: DiasWidget(
                      dia: 'Sa',
                    ),
                  ),
                  wrapWithModel(
                    model: _model.diasModel7,
                    updateCallback: () => safeSetState(() {}),
                    child: DiasWidget(
                      dia: 'Do',
                    ),
                  ),
                ],
              ),
            ),
            FutureBuilder<List<EmocionesRegistroRecord>>(
              future: queryEmocionesRegistroRecordOnce(
                parent: widget.userRef,
              ),
              builder: (context, snapshot) {
                // Customize what your widget looks like when it's loading.
                if (!snapshot.hasData) {
                  return Center(
                    child: SizedBox(
                      width: 50.0,
                      height: 50.0,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          FlutterFlowTheme.of(context).primary,
                        ),
                      ),
                    ),
                  );
                }
                List<EmocionesRegistroRecord>
                    calendarDaysContainerEmocionesRegistroRecordList =
                    snapshot.data!;

                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 20.0),
                    child: Builder(
                      builder: (context) {
                        final calendar = functions
                            .getCalendarForMonth(_model.inputDate!)
                            .toList();

                        return GridView.builder(
                          padding: EdgeInsets.zero,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            crossAxisSpacing: 0.0,
                            mainAxisSpacing: 12.0,
                            childAspectRatio: 0.8,
                          ),
                          primary: false,
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: calendar.length,
                          itemBuilder: (context, calendarIndex) {
                            final calendarItem = calendar[calendarIndex];
                            return Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 2.0, 0.0),
                              child: InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  // Mismo registro que pinta el icono del día (si hay varios,
                                  // el de menor valor); consulta por rango del día.
                                  _model.leerreaccion = registroDelDia(
                                      await emocionesDelDia(
                                          widget.userRef!, calendarItem.calendarDate!));
                                  if (_model.leerreaccion?.emocion != null) {
                                    FFAppState().description =
                                        _model.leerreaccion!.descripcion;
                                    FFAppState().emocion =
                                        _model.leerreaccion!.emocion;
                                    safeSetState(() {});
                                  } else {
                                    FFAppState().description = '';
                                    FFAppState().emocion = 0;
                                    safeSetState(() {});
                                  }

                                  await widget.onSelectDateAction?.call(
                                    calendarItem.calendarDate,
                                  );

                                  safeSetState(() {});
                                },
                                child: Material(
                                  color: Colors.transparent,
                                  elevation: 0.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Container(
                                    width: 24.0,
                                    height: 24.0,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: Align(
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            dateTimeFormat(
                                              "d",
                                              calendarItem.calendarDate!,
                                              locale:
                                                  FFLocalizations.of(context)
                                                      .languageCode,
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontWeight,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  fontSize: 10.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                          ),
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                            child: CachedNetworkImage(
                                              fadeInDuration:
                                                  Duration(milliseconds: 500),
                                              fadeOutDuration:
                                                  Duration(milliseconds: 500),
                                              imageUrl: valueOrDefault<String>(
                                                () {
                                                  if (calendarDaysContainerEmocionesRegistroRecordList
                                                          .where((e) =>
                                                              (dateTimeFormat(
                                                                    "d/M/y",
                                                                    e.fecha,
                                                                    locale: FFLocalizations.of(
                                                                            context)
                                                                        .languageCode,
                                                                  ) ==
                                                                  dateTimeFormat(
                                                                    "d/M/y",
                                                                    calendarItem
                                                                        .calendarDate,
                                                                    locale: FFLocalizations.of(
                                                                            context)
                                                                        .languageCode,
                                                                  )) &&
                                                              (e.emocion == 1))
                                                          .toList()
                                                          .length >
                                                      0) {
                                                    return 'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/conecta2-wtnr9n/assets/94v45qugvs2r/caritasRecurso_6Plantilla.png';
                                                  } else if (calendarDaysContainerEmocionesRegistroRecordList
                                                          .where((e) =>
                                                              (dateTimeFormat(
                                                                    "d/M/y",
                                                                    e.fecha,
                                                                    locale: FFLocalizations.of(
                                                                            context)
                                                                        .languageCode,
                                                                  ) ==
                                                                  dateTimeFormat(
                                                                    "d/M/y",
                                                                    calendarItem
                                                                        .calendarDate,
                                                                    locale: FFLocalizations.of(
                                                                            context)
                                                                        .languageCode,
                                                                  )) &&
                                                              (e.emocion == 2))
                                                          .toList()
                                                          .length >
                                                      0) {
                                                    return 'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/conecta2-wtnr9n/assets/mivazz3vocqw/caritasRecurso_5Plantilla.png';
                                                  } else if (calendarDaysContainerEmocionesRegistroRecordList
                                                          .where((e) =>
                                                              (dateTimeFormat(
                                                                    "d/M/y",
                                                                    e.fecha,
                                                                    locale: FFLocalizations.of(
                                                                            context)
                                                                        .languageCode,
                                                                  ) ==
                                                                  dateTimeFormat(
                                                                    "d/M/y",
                                                                    calendarItem
                                                                        .calendarDate,
                                                                    locale: FFLocalizations.of(
                                                                            context)
                                                                        .languageCode,
                                                                  )) &&
                                                              (e.emocion == 3))
                                                          .toList()
                                                          .length >
                                                      0) {
                                                    return 'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/conecta2-wtnr9n/assets/kxhn0imof79s/caritasRecurso_4Plantilla.png';
                                                  } else if (calendarDaysContainerEmocionesRegistroRecordList
                                                          .where((e) =>
                                                              (dateTimeFormat(
                                                                    "d/M/y",
                                                                    e.fecha,
                                                                    locale: FFLocalizations.of(
                                                                            context)
                                                                        .languageCode,
                                                                  ) ==
                                                                  dateTimeFormat(
                                                                    "d/M/y",
                                                                    calendarItem
                                                                        .calendarDate,
                                                                    locale: FFLocalizations.of(
                                                                            context)
                                                                        .languageCode,
                                                                  )) &&
                                                              (e.emocion == 4))
                                                          .toList()
                                                          .length >
                                                      0) {
                                                    return 'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/conecta2-wtnr9n/assets/l5bc1vpqz2vm/caritasRecurso_3Plantilla.png';
                                                  } else if (calendarDaysContainerEmocionesRegistroRecordList
                                                          .where((e) =>
                                                              (dateTimeFormat(
                                                                    "d/M/y",
                                                                    e.fecha,
                                                                    locale: FFLocalizations.of(
                                                                            context)
                                                                        .languageCode,
                                                                  ) ==
                                                                  dateTimeFormat(
                                                                    "d/M/y",
                                                                    calendarItem
                                                                        .calendarDate,
                                                                    locale: FFLocalizations.of(
                                                                            context)
                                                                        .languageCode,
                                                                  )) &&
                                                              (e.emocion == 5))
                                                          .toList()
                                                          .length >
                                                      0) {
                                                    return 'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/conecta2-wtnr9n/assets/diaqw394jcgs/caritasRecurso_2Plantilla.png';
                                                  } else {
                                                    return FFAppConstants
                                                        .emocionvacia;
                                                  }
                                                }(),
                                                'https://i.postimg.cc/nLX7K1tW/Group-223.png',
                                              ),
                                              width: 20.0,
                                              height: 20.0,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ].divide(SizedBox(height: 2.0)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ].addToStart(SizedBox(height: 16.0)),
        ),
      ),
    );
  }
}
