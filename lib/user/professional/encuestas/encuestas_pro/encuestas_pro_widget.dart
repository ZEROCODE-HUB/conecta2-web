import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/footer_professionals/footer_professionals_widget.dart';
import '/components/profesional_header/profesional_header_widget.dart';
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
import 'encuestas_pro_model.dart';
export 'encuestas_pro_model.dart';

class EncuestasProWidget extends StatefulWidget {
  const EncuestasProWidget({super.key});

  static String routeName = 'EncuestasPro';
  static String routePath = '/encuestasPro';

  @override
  State<EncuestasProWidget> createState() => _EncuestasProWidgetState();
}

class _EncuestasProWidgetState extends State<EncuestasProWidget> {
  late EncuestasProModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EncuestasProModel());

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
              Container(
                decoration: BoxDecoration(),
                child: Padding(
                  padding:
                      EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 100.0),
                  child: SingleChildScrollView(
                    primary: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 80.0, 0.0, 0.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Responde estas encuestas desarrolladas por nuestros profesionales.',
                                  textAlign: TextAlign.justify,
                                  style: FlutterFlowTheme.of(context)
                                      .labelSmall
                                      .override(
                                        font: GoogleFonts.outfit(
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelSmall
                                                  .fontStyle,
                                        ),
                                        fontSize: 18.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelSmall
                                            .fontStyle,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 20.0, 0.0, 0.0),
                          child: Container(
                            decoration: BoxDecoration(),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  20.0, 0.0, 20.0, 100.0),
                              child: SingleChildScrollView(
                                primary: false,
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(),
                                      alignment:
                                          AlignmentDirectional(-1.0, 0.0),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0.0, 10.0, 0.0, 0.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: FlutterFlowChoiceChips(
                                                options: [
                                                  ChipData('Encuestas'),
                                                  ChipData('Tamizajes')
                                                ],
                                                onChanged: (val) =>
                                                    safeSetState(() => _model
                                                            .choiceChipsValue =
                                                        val?.firstOrNull),
                                                selectedChipStyle: ChipStyle(
                                                  backgroundColor:
                                                      Color(0xFF265294),
                                                  textStyle: FlutterFlowTheme
                                                          .of(context)
                                                      .bodyMedium
                                                      .override(
                                                        font: GoogleFonts.inter(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .primaryBackground,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                  iconColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .primaryText,
                                                  iconSize: 18.0,
                                                  elevation: 4.0,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16.0),
                                                ),
                                                unselectedChipStyle: ChipStyle(
                                                  backgroundColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .alternate,
                                                  textStyle: FlutterFlowTheme
                                                          .of(context)
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
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .secondaryText,
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
                                                  iconColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .secondaryText,
                                                  iconSize: 18.0,
                                                  elevation: 0.0,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16.0),
                                                ),
                                                chipSpacing: 0.0,
                                                rowSpacing: 12.0,
                                                multiselect: false,
                                                initialized:
                                                    _model.choiceChipsValue !=
                                                        null,
                                                alignment:
                                                    WrapAlignment.spaceEvenly,
                                                controller: _model
                                                        .choiceChipsValueController ??=
                                                    FormFieldController<
                                                        List<String>>(
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
                                          0.0, 24.0, 0.0, 0.0),
                                      child: AuthUserStreamWidget(
                                        builder: (context) => PagedListView<
                                            DocumentSnapshot<Object?>?,
                                            EncuestasRecord>.separated(
                                          pagingController:
                                              _model.setSurveyListsController(
                                            EncuestasRecord.collection
                                                .where(
                                                  'Publicado',
                                                  isEqualTo: true,
                                                )
                                                .where(
                                                  'Roles',
                                                  arrayContains: valueOrDefault(
                                                      currentUserDocument?.rol,
                                                      ''),
                                                )
                                                .where(
                                                  'tipo',
                                                  isEqualTo:
                                                      _model.choiceChipsValue,
                                                )
                                                .orderBy('CreateAt',
                                                    descending: true),
                                          ),
                                          padding: EdgeInsets.zero,
                                          shrinkWrap: true,
                                          reverse: false,
                                          scrollDirection: Axis.vertical,
                                          separatorBuilder: (_, __) =>
                                              SizedBox(height: 8.0),
                                          builderDelegate:
                                              PagedChildBuilderDelegate<
                                                  EncuestasRecord>(
                                            // Customize what your widget looks like when it's loading the first page.
                                            firstPageProgressIndicatorBuilder:
                                                (_) => Center(
                                              child: SizedBox(
                                                width: 50.0,
                                                height: 50.0,
                                                child:
                                                    CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // Customize what your widget looks like when it's loading another page.
                                            newPageProgressIndicatorBuilder:
                                                (_) => Center(
                                              child: SizedBox(
                                                width: 50.0,
                                                height: 50.0,
                                                child:
                                                    CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                  ),
                                                ),
                                              ),
                                            ),

                                            itemBuilder:
                                                (context, _, surveyListsIndex) {
                                              final surveyListsEncuestasRecord =
                                                  _model.surveyListsPagingController!
                                                          .itemList![
                                                      surveyListsIndex];
                                              return InkWell(
                                                splashColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onTap: () async {
                                                  _model.exist =
                                                      await queryRespuestasRecordOnce(
                                                    parent:
                                                        surveyListsEncuestasRecord
                                                            .reference,
                                                    queryBuilder:
                                                        (respuestasRecord) =>
                                                            respuestasRecord
                                                                .where(
                                                      'User_respuesta',
                                                      isEqualTo:
                                                          currentUserReference,
                                                    ),
                                                    singleRecord: true,
                                                  ).then((s) => s.firstOrNull);
                                                  if (_model.exist?.reference ==
                                                      null) {
                                                    FFAppState().RespuestaEnc =
                                                        [];
                                                    safeSetState(() {});
                                                    _model.maxRetries = null;
                                                    _model.retryCount = 0;
                                                    safeSetState(() {});
                                                    _model.maxRetries =
                                                        surveyListsEncuestasRecord
                                                            .preguntas.length;
                                                    safeSetState(() {});
                                                    while (_model.retryCount! <
                                                        _model.maxRetries!) {
                                                      FFAppState()
                                                          .addToRespuestaEnc(
                                                              RespuestaTestStruct(
                                                        pregunta:
                                                            surveyListsEncuestasRecord
                                                                .preguntas
                                                                .elementAtOrNull(
                                                                    _model
                                                                        .retryCount!)
                                                                ?.pregunta,
                                                        tipo: surveyListsEncuestasRecord
                                                            .preguntas
                                                            .elementAtOrNull(
                                                                _model
                                                                    .retryCount!)
                                                            ?.tipo,
                                                        nPregunta: _model.retryCount! + 1,
                                                        userRef:
                                                            currentUserReference,
                                                        respuestaSelection:
                                                            surveyListsEncuestasRecord
                                                                .preguntas
                                                                .elementAtOrNull(
                                                                    _model
                                                                        .retryCount!)
                                                                ?.respuestaSelection,
                                                      ));
                                                      safeSetState(() {});
                                                      _model.retryCount =
                                                          _model.retryCount! +
                                                              1;
                                                      safeSetState(() {});
                                                    }

                                                    context.pushNamed(
                                                      EncuestasParentsOpenWidget
                                                          .routeName,
                                                      queryParameters: {
                                                        'encuesta':
                                                            serializeParam(
                                                          surveyListsEncuestasRecord
                                                              .reference,
                                                          ParamType
                                                              .DocumentReference,
                                                        ),
                                                        'choice':
                                                            serializeParam(
                                                          _model
                                                              .choiceChipsValue,
                                                          ParamType.String,
                                                        ),
                                                        'titulo':
                                                            serializeParam(
                                                          surveyListsEncuestasRecord
                                                              .titulo,
                                                          ParamType.String,
                                                        ),
                                                        'desc': serializeParam(
                                                          surveyListsEncuestasRecord
                                                              .descripcion,
                                                          ParamType.String,
                                                        ),
                                                      }.withoutNulls,
                                                      extra: <String, dynamic>{
                                                        '__transition_info__':
                                                            TransitionInfo(
                                                          hasTransition: true,
                                                          transitionType:
                                                              PageTransitionType
                                                                  .fade,
                                                          duration: Duration(
                                                              milliseconds: 0),
                                                        ),
                                                      },
                                                    );
                                                  } else {
                                                    context.pushNamed(
                                                      EncuestasOpenRespuestaWidget
                                                          .routeName,
                                                      queryParameters: {
                                                        'encuestaRespuesta':
                                                            serializeParam(
                                                          _model.exist,
                                                          ParamType.Document,
                                                        ),
                                                        'choice':
                                                            serializeParam(
                                                          _model
                                                              .choiceChipsValue,
                                                          ParamType.String,
                                                        ),
                                                      }.withoutNulls,
                                                      extra: <String, dynamic>{
                                                        'encuestaRespuesta':
                                                            _model.exist,
                                                      },
                                                    );
                                                  }

                                                  safeSetState(() {});
                                                },
                                                child: Container(
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryBackground,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16.0),
                                                  ),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    14.0,
                                                                    14.0,
                                                                    14.0,
                                                                    0.0),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          children: [
                                                            Container(
                                                              width: 80.0,
                                                              height: 24.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Color(
                                                                    0xFF265294),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8.0),
                                                              ),
                                                              child: Align(
                                                                alignment:
                                                                    AlignmentDirectional(
                                                                        0.0,
                                                                        0.0),
                                                                child:
                                                                    AutoSizeText(
                                                                  valueOrDefault<
                                                                      String>(
                                                                    _model
                                                                        .choiceChipsValue,
                                                                    'Encuestas',
                                                                  ),
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        font: GoogleFonts
                                                                            .outfit(
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                        ),
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .primaryBackground,
                                                                        fontSize:
                                                                            12.0,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                        fontStyle: FlutterFlowTheme.of(context)
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
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    14.0,
                                                                    8.0,
                                                                    14.0,
                                                                    10.0),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Flexible(
                                                              child: Text(
                                                                surveyListsEncuestasRecord
                                                                    .titulo
                                                                    .maybeHandleOverflow(
                                                                  maxChars: 100,
                                                                  replacement:
                                                                      '…',
                                                                ),
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      font: GoogleFonts
                                                                          .outfit(
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontStyle,
                                                                      ),
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontStyle,
                                                                      lineHeight:
                                                                          1.2,
                                                                    ),
                                                              ),
                                                            ),
                                                            Container(
                                                              width: 24.0,
                                                              height: 24.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Color(
                                                                    0xFF265294),
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                              child: Icon(
                                                                Icons
                                                                    .keyboard_arrow_right,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
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
                      ],
                    ),
                  ),
                ),
              ),
              wrapWithModel(
                model: _model.profesionalHeaderModel,
                updateCallback: () => safeSetState(() {}),
                updateOnChange: true,
                child: ProfesionalHeaderWidget(
                  name: _model.choiceChipsValue!,
                ),
              ),
              Align(
                alignment: AlignmentDirectional(0.0, 1.0),
                child: wrapWithModel(
                  model: _model.footerProfessionalsModel,
                  updateCallback: () => safeSetState(() {}),
                  updateOnChange: true,
                  child: FooterProfessionalsWidget(
                    active: 0, // fuera del menú desde 2026-10-15
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
