import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/footer/footer_widget.dart';
import '/components/header/header_widget.dart';
import '/flutter_flow/flutter_flow_choice_chips.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/index.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'encuestas_and_tamizajes_model.dart';
export 'encuestas_and_tamizajes_model.dart';

class EncuestasAndTamizajesWidget extends StatefulWidget {
  const EncuestasAndTamizajesWidget({super.key});

  static String routeName = 'EncuestasAndTamizajes';
  static String routePath = '/encuestasAndTamizajes';

  @override
  State<EncuestasAndTamizajesWidget> createState() =>
      _EncuestasAndTamizajesWidgetState();
}

class _EncuestasAndTamizajesWidgetState
    extends State<EncuestasAndTamizajesWidget> {
  late EncuestasAndTamizajesModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EncuestasAndTamizajesModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 45.0, 0.0, 0.0),
                child: Container(
                  width: MediaQuery.sizeOf(context).width * 1.0,
                  height: MediaQuery.sizeOf(context).height * 1.0,
                  decoration: BoxDecoration(),
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 74.0),
                    child: SingleChildScrollView(
                      primary: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            decoration: BoxDecoration(),
                            alignment: AlignmentDirectional(-1.0, 0.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 10.0, 0.0, 0.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: FlutterFlowChoiceChips(
                                      options: [
                                        ChipData('Encuestas'),
                                        ChipData('Tamizajes')
                                      ],
                                      onChanged: (val) => safeSetState(() =>
                                          _model.choiceChipsValue =
                                              val?.firstOrNull),
                                      selectedChipStyle: ChipStyle(
                                        backgroundColor: Color(0xFF265294),
                                        textStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.inter(
                                                fontWeight: FontWeight.w500,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryBackground,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w500,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                        iconColor: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        iconSize: 18.0,
                                        elevation: 4.0,
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                      ),
                                      unselectedChipStyle: ChipStyle(
                                        backgroundColor:
                                            FlutterFlowTheme.of(context)
                                                .alternate,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.inter(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                        iconColor: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        iconSize: 18.0,
                                        elevation: 0.0,
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                      ),
                                      chipSpacing: 0.0,
                                      rowSpacing: 12.0,
                                      multiselect: false,
                                      initialized:
                                          _model.choiceChipsValue != null,
                                      alignment: WrapAlignment.spaceEvenly,
                                      controller:
                                          _model.choiceChipsValueController ??=
                                              FormFieldController<List<String>>(
                                        ['Encuestas'],
                                      ),
                                      wrapped: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 24.0, 0.0, 24.0),
                            child: AuthUserStreamWidget(
                              builder: (context) => PagedListView<
                                  DocumentSnapshot<Object?>?,
                                  EncuestasRecord>.separated(
                                pagingController:
                                    _model.setSurveyLists1Controller(
                                  EncuestasRecord.collection
                                      .where(
                                        'Publicado',
                                        isEqualTo: true,
                                      )
                                      .where(
                                        'Roles',
                                        arrayContains: valueOrDefault(
                                            currentUserDocument?.rol, ''),
                                      )
                                      .where(
                                        'tipo',
                                        isEqualTo: valueOrDefault<String>(
                                          _model.choiceChipsValue,
                                          'Encuestas',
                                        ),
                                      )
                                      .orderBy('CreateAt', descending: true),
                                ),
                                padding: EdgeInsets.zero,
                                primary: false,
                                shrinkWrap: true,
                                reverse: false,
                                scrollDirection: Axis.vertical,
                                separatorBuilder: (_, __) =>
                                    SizedBox(height: 8.0),
                                builderDelegate:
                                    PagedChildBuilderDelegate<EncuestasRecord>(
                                  // Customize what your widget looks like when it's loading the first page.
                                  firstPageProgressIndicatorBuilder: (_) =>
                                      Center(
                                    child: SizedBox(
                                      width: 50.0,
                                      height: 50.0,
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          FlutterFlowTheme.of(context).primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Customize what your widget looks like when it's loading another page.
                                  newPageProgressIndicatorBuilder: (_) =>
                                      Center(
                                    child: SizedBox(
                                      width: 50.0,
                                      height: 50.0,
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          FlutterFlowTheme.of(context).primary,
                                        ),
                                      ),
                                    ),
                                  ),

                                  itemBuilder: (context, _, surveyLists1Index) {
                                    final surveyLists1EncuestasRecord = _model
                                        .surveyLists1PagingController!
                                        .itemList![surveyLists1Index];
                                    return InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        _model.exist2 =
                                            await queryRespuestasRecordOnce(
                                          parent: surveyLists1EncuestasRecord
                                              .reference,
                                          queryBuilder: (respuestasRecord) =>
                                              respuestasRecord.where(
                                            'User_respuesta',
                                            isEqualTo: currentUserReference,
                                          ),
                                          singleRecord: true,
                                        ).then((s) => s.firstOrNull);
                                        if (_model.exist2?.reference == null) {
                                          FFAppState().RespuestaEnc = [];
                                          safeSetState(() {});
                                          _model.maxRetries = null;
                                          _model.retryCount = 0;
                                          safeSetState(() {});
                                          _model.maxRetries =
                                              surveyLists1EncuestasRecord
                                                  .preguntas.length;
                                          safeSetState(() {});
                                          while (_model.retryCount! <
                                              _model.maxRetries!) {
                                            FFAppState().addToRespuestaEnc(
                                                RespuestaTestStruct(
                                              pregunta:
                                                  surveyLists1EncuestasRecord
                                                      .preguntas
                                                      .elementAtOrNull(
                                                          _model.retryCount!)
                                                      ?.pregunta,
                                              tipo: surveyLists1EncuestasRecord
                                                  .preguntas
                                                  .elementAtOrNull(
                                                      _model.retryCount!)
                                                  ?.tipo,
                                              nPregunta: _model.retryCount! + 1,
                                              userRef: currentUserReference,
                                              respuestaSelection:
                                                  surveyLists1EncuestasRecord
                                                      .preguntas
                                                      .elementAtOrNull(
                                                          _model.retryCount!)
                                                      ?.respuestaSelection,
                                              rSeleccionUnica:
                                                  surveyLists1EncuestasRecord
                                                      .preguntas
                                                      .elementAtOrNull(
                                                          _model.retryCount!)
                                                      ?.respuestasSeleccionUnica,
                                            ));
                                            safeSetState(() {});
                                            _model.retryCount =
                                                _model.retryCount! + 1;
                                            safeSetState(() {});
                                          }
                                          if (surveyLists1EncuestasRecord
                                                  .tipo ==
                                              'Tamizajes') {
                                            context.pushNamed(
                                              EncuestasAdolescenteOpen2Widget
                                                  .routeName,
                                              queryParameters: {
                                                'choice': serializeParam(
                                                  surveyLists1EncuestasRecord
                                                      .tipo,
                                                  ParamType.String,
                                                ),
                                                'text': serializeParam(
                                                  surveyLists1EncuestasRecord
                                                      .titulo,
                                                  ParamType.String,
                                                ),
                                                'desc': serializeParam(
                                                  surveyLists1EncuestasRecord
                                                      .descripcion,
                                                  ParamType.String,
                                                ),
                                                'encuesta': serializeParam(
                                                  surveyLists1EncuestasRecord
                                                      .reference,
                                                  ParamType.DocumentReference,
                                                ),
                                              }.withoutNulls,
                                              extra: <String, dynamic>{
                                                '__transition_info__':
                                                    TransitionInfo(
                                                  hasTransition: true,
                                                  transitionType:
                                                      PageTransitionType.fade,
                                                  duration:
                                                      Duration(milliseconds: 0),
                                                ),
                                              },
                                            );
                                          } else {
                                            context.pushNamed(
                                              EncuestasAdolescenteOpenWidget
                                                  .routeName,
                                              queryParameters: {
                                                'choice': serializeParam(
                                                  surveyLists1EncuestasRecord
                                                      .tipo,
                                                  ParamType.String,
                                                ),
                                                'encuesta': serializeParam(
                                                  surveyLists1EncuestasRecord
                                                      .reference,
                                                  ParamType.DocumentReference,
                                                ),
                                                'text': serializeParam(
                                                  surveyLists1EncuestasRecord
                                                      .titulo,
                                                  ParamType.String,
                                                ),
                                                'desc': serializeParam(
                                                  surveyLists1EncuestasRecord
                                                      .descripcion,
                                                  ParamType.String,
                                                ),
                                              }.withoutNulls,
                                              extra: <String, dynamic>{
                                                '__transition_info__':
                                                    TransitionInfo(
                                                  hasTransition: true,
                                                  transitionType:
                                                      PageTransitionType.fade,
                                                  duration:
                                                      Duration(milliseconds: 0),
                                                ),
                                              },
                                            );
                                          }
                                        } else {
                                          context.pushNamed(
                                            EncTamRespuestaWidget.routeName,
                                            queryParameters: {
                                              'encuestaRespuesta':
                                                  serializeParam(
                                                _model.exist2,
                                                ParamType.Document,
                                              ),
                                              'choice': serializeParam(
                                                _model.choiceChipsValue,
                                                ParamType.String,
                                              ),
                                            }.withoutNulls,
                                            extra: <String, dynamic>{
                                              'encuestaRespuesta':
                                                  _model.exist2,
                                            },
                                          );
                                        }

                                        safeSetState(() {});
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      14.0, 14.0, 14.0, 0.0),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Container(
                                                    width: 80.0,
                                                    height: 24.0,
                                                    decoration: BoxDecoration(
                                                      color: Color(0xFF265294),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    child: Align(
                                                      alignment:
                                                          AlignmentDirectional(
                                                              0.0, 0.0),
                                                      child: AutoSizeText(
                                                        _model.choiceChipsValue ==
                                                                'Encuestas'
                                                            ? 'Encuesta'
                                                            : 'Tamizaje',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .outfit(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                                  ),
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryBackground,
                                                                  fontSize:
                                                                      12.0,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                                ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      14.0, 8.0, 14.0, 10.0),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      surveyLists1EncuestasRecord
                                                          .titulo
                                                          .maybeHandleOverflow(
                                                        maxChars: 100,
                                                        replacement: '…',
                                                      ),
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            font: GoogleFonts
                                                                .outfit(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                            ),
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                            lineHeight: 1.2,
                                                          ),
                                                    ),
                                                  ),
                                                  Container(
                                                    width: 24.0,
                                                    height: 24.0,
                                                    decoration: BoxDecoration(
                                                      color: Color(0xFF265294),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(
                                                      Icons
                                                          .keyboard_arrow_right,
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .primaryBackground,
                                                      size: 20.0,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              wrapWithModel(
                model: _model.headerModel,
                updateCallback: () => safeSetState(() {}),
                child: HeaderWidget(
                  pageTitle: 'Encuestas',
                  showIconBack: false,
                ),
              ),
              Align(
                alignment: AlignmentDirectional(0.0, 1.0),
                child: wrapWithModel(
                  model: _model.footerModel,
                  updateCallback: () => safeSetState(() {}),
                  child: FooterWidget(
                    active: 4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
