import '/backend/backend.dart';
import '/components/dias/dias_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'calendario_read_model.dart';
export 'calendario_read_model.dart';

class CalendarioReadWidget extends StatefulWidget {
  const CalendarioReadWidget({
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
  State<CalendarioReadWidget> createState() => _CalendarioReadWidgetState();
}

class _CalendarioReadWidgetState extends State<CalendarioReadWidget> {
  late CalendarioReadModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CalendarioReadModel());

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
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 10.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Align(
                  alignment: AlignmentDirectional(-1.0, 0.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        dateTimeFormat(
                          "MMMM",
                          dateTimeFromSecondsSinceEpoch(valueOrDefault<int>(
                            _model.inputDate?.secondsSinceEpoch,
                            0,
                          )),
                          locale: FFLocalizations.of(context).languageCode,
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
                              color: Color(0xFF265294),
                              fontSize: 16.0,
                              letterSpacing: 0.0,
                              fontWeight: FlutterFlowTheme.of(context)
                                  .labelLarge
                                  .fontWeight,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .labelLarge
                                  .fontStyle,
                            ),
                      ),
                      Text(
                        valueOrDefault<String>(
                          dateTimeFormat(
                            "y",
                            dateTimeFromSecondsSinceEpoch(valueOrDefault<int>(
                              _model.inputDate?.secondsSinceEpoch,
                              0,
                            )),
                            locale: FFLocalizations.of(context).languageCode,
                          ),
                          '0',
                        ),
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.outfit(
                                fontWeight: FontWeight.w600,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                              color: Color(0xFF265294),
                              fontSize: 16.0,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w600,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                      ),
                    ].divide(SizedBox(width: 4.0)),
                  ),
                ),
              ),
              Container(
                height: 40.0,
                decoration: BoxDecoration(),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FlutterFlowIconButton(
                        borderColor: Colors.transparent,
                        borderRadius: 26.0,
                        buttonSize: 40.0,
                        icon: Icon(
                          Icons.chevron_left,
                          color: FlutterFlowTheme.of(context).accent3,
                          size: 25.0,
                        ),
                        onPressed: () async {
                          _model.inputDate =
                              functions.getLastMonthDateTime(_model.inputDate!);
                          safeSetState(() {});
                        },
                      ),
                      Transform.rotate(
                        angle: 180.0 * (math.pi / 180),
                        child: FlutterFlowIconButton(
                          borderColor: Colors.transparent,
                          borderRadius: 26.0,
                          buttonSize: 40.0,
                          icon: Icon(
                            Icons.chevron_left,
                            color: FlutterFlowTheme.of(context).accent3,
                            size: 25.0,
                          ),
                          onPressed: () async {
                            _model.inputDate = functions
                                .getNextMonthDateTime(_model.inputDate!);
                            safeSetState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ].addToStart(SizedBox(width: 24.0)),
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
                padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                child: Builder(
                  builder: (context) {
                    final calendar = functions
                        .getCalendarForMonth(_model.inputDate!)
                        .toList();

                    return GridView.builder(
                      padding: EdgeInsets.zero,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                              _model.leerreaccion =
                                  await queryEmocionesRegistroRecordOnce(
                                parent: widget.userRef,
                                queryBuilder: (emocionesRegistroRecord) =>
                                    emocionesRegistroRecord.where(
                                  'fecha',
                                  isEqualTo: functions
                                      .formatdate(calendarItem.calendarDate!),
                                ),
                                singleRecord: true,
                              ).then((s) => s.firstOrNull);
                              if (_model.leerreaccion?.emocion != null) {
                                FFAppState().description =
                                    _model.leerreaccion!.descripcion;
                                FFAppState().emocion = valueOrDefault<int>(
                                  _model.leerreaccion?.emocion,
                                  0,
                                );
                                safeSetState(() {});
                              } else {
                                FFAppState().description = '';
                                FFAppState().emocion = 0;
                                safeSetState(() {});
                              }

                              await widget.onSelectDateAction?.call(
                                getCurrentTimestamp,
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        dateTimeFormat(
                                          "d",
                                          dateTimeFromSecondsSinceEpoch(
                                              valueOrDefault<int>(
                                            calendarItem.calendarDate
                                                ?.secondsSinceEpoch,
                                            0,
                                          )),
                                          locale: FFLocalizations.of(context)
                                              .languageCode,
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .labelLarge
                                            .override(
                                              font: GoogleFonts.outfit(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .labelLarge
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelLarge
                                                        .fontStyle,
                                              ),
                                              fontSize: 14.0,
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .labelLarge
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelLarge
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
    );
  }
}
