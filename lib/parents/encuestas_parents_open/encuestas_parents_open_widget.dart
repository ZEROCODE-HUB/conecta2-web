import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/footer_parents/footer_parents_widget.dart';
import '/components/header_prof_back/header_prof_back_widget.dart';
import '/components/lista_respuestas_widget.dart';
import '/components/r_seleccion_unica_radious_widget.dart';
import '/components/registartion_button/registartion_button_widget.dart';
import '/components/text_respuesta_widget.dart';
import '/components/verdaderofalso_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'encuestas_parents_open_model.dart';
export 'encuestas_parents_open_model.dart';

class EncuestasParentsOpenWidget extends StatefulWidget {
  const EncuestasParentsOpenWidget({
    super.key,
    this.encuesta,
    required this.choice,
    required this.titulo,
    required this.desc,
  });

  final DocumentReference? encuesta;
  final String? choice;
  final String? titulo;
  final String? desc;

  static String routeName = 'EncuestasParentsOpen';
  static String routePath = '/encuestasParentsOpen';

  @override
  State<EncuestasParentsOpenWidget> createState() =>
      _EncuestasParentsOpenWidgetState();
}

class _EncuestasParentsOpenWidgetState
    extends State<EncuestasParentsOpenWidget> {
  late EncuestasParentsOpenModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EncuestasParentsOpenModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

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
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              wrapWithModel(
                model: _model.headerProfBackModel,
                updateCallback: () => safeSetState(() {}),
                updateOnChange: true,
                child: HeaderProfBackWidget(
                  name: widget.choice,
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 40.0),
                        child: Container(
                          decoration: BoxDecoration(),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                12.0, 10.0, 12.0, 10.0),
                            child: SingleChildScrollView(
                              primary: false,
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Align(
                                    alignment: AlignmentDirectional(-1.0, 0.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Align(
                                          alignment:
                                              AlignmentDirectional(-1.0, 0.0),
                                          child: Text(
                                            valueOrDefault<String>(
                                              widget.titulo,
                                              'Sin título',
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.outfit(
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  fontSize: 18.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                          ),
                                        ),
                                        Align(
                                          alignment:
                                              AlignmentDirectional(-1.0, 0.0),
                                          child: Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0.0, 5.0, 0.0, 0.0),
                                            child: Text(
                                              valueOrDefault<String>(
                                                widget.desc,
                                                'Sin descripción',
                                              ),
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        font:
                                                            GoogleFonts.outfit(
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
                                          ),
                                        ),
                                        Builder(
                                          builder: (context) {
                                            final preguntasindeex = FFAppState()
                                                .RespuestaEnc
                                                .toList();

                                            return Column(
                                              mainAxisSize: MainAxisSize.max,
                                              children: List.generate(
                                                  preguntasindeex.length,
                                                  (preguntasindeexIndex) {
                                                final preguntasindeexItem =
                                                    preguntasindeex[
                                                        preguntasindeexIndex];
                                                return Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    if (preguntasindeexItem
                                                            .tipo ==
                                                        'abiertas')
                                                      Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0.0,
                                                                        24.0,
                                                                        0.0,
                                                                        0.0),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: [
                                                                Flexible(
                                                                  child: Text(
                                                                    preguntasindeexItem
                                                                        .pregunta,
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.outfit(
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                          ),
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                        ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            children: [
                                                              Flexible(
                                                                child: Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          8.0,
                                                                          0.0,
                                                                          0.0),
                                                                  child:
                                                                      Container(
                                                                    height:
                                                                        47.0,
                                                                    decoration:
                                                                        BoxDecoration(),
                                                                    child: Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      children: [
                                                                        Flexible(
                                                                          child:
                                                                              wrapWithModel(
                                                                            model:
                                                                                _model.textRespuestaModels.getModel(
                                                                              preguntasindeexIndex.toString(),
                                                                              preguntasindeexIndex,
                                                                            ),
                                                                            updateCallback: () =>
                                                                                safeSetState(() {}),
                                                                            updateOnChange:
                                                                                true,
                                                                            child:
                                                                                TextRespuestaWidget(
                                                                              key: Key(
                                                                                'Keyo9z_${preguntasindeexIndex.toString()}',
                                                                              ),
                                                                              action: () async {
                                                                                FFAppState().updateRespuestaEncAtIndex(
                                                                                  preguntasindeexIndex,
                                                                                  (e) => e..respuesta = FFAppState().updateText,
                                                                                );
                                                                                safeSetState(() {});
                                                                              },
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    if (preguntasindeexItem
                                                            .tipo ==
                                                        'selección')
                                                      Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0.0,
                                                                        24.0,
                                                                        0.0,
                                                                        0.0),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: [
                                                                Flexible(
                                                                  child: Text(
                                                                    preguntasindeexItem
                                                                        .pregunta,
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.outfit(
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                          ),
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
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
                                                                        0.0,
                                                                        12.0,
                                                                        0.0,
                                                                        0.0),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: [
                                                                Flexible(
                                                                  child:
                                                                      wrapWithModel(
                                                                    model: _model
                                                                        .listaRespuestasModels
                                                                        .getModel(
                                                                      preguntasindeexIndex
                                                                          .toString(),
                                                                      preguntasindeexIndex,
                                                                    ),
                                                                    updateCallback: () =>
                                                                        safeSetState(
                                                                            () {}),
                                                                    child:
                                                                        ListaRespuestasWidget(
                                                                      key: Key(
                                                                        'Key85l_${preguntasindeexIndex.toString()}',
                                                                      ),
                                                                      parameter2:
                                                                          preguntasindeexIndex,
                                                                      parameter3:
                                                                          preguntasindeexItem
                                                                              .respuestaSelection,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    if (preguntasindeexItem
                                                            .tipo ==
                                                        'Selección única')
                                                      Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0.0,
                                                                        24.0,
                                                                        0.0,
                                                                        0.0),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: [
                                                                Flexible(
                                                                  child: Text(
                                                                    preguntasindeexItem
                                                                        .pregunta,
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.outfit(
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                          ),
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
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
                                                                        0.0,
                                                                        12.0,
                                                                        0.0,
                                                                        0.0),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: [
                                                                RSeleccionUnicaRadiousWidget(
                                                                  key: Key(
                                                                      'Keyk1z_${preguntasindeexIndex}_of_${preguntasindeex.length}'),
                                                                  parameter1:
                                                                      preguntasindeexItem
                                                                          .rSeleccionUnica,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    if (preguntasindeexItem
                                                            .tipo ==
                                                        'Verdadero o falso')
                                                      Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            children: [
                                                              Flexible(
                                                                child: Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          20.0,
                                                                          0.0,
                                                                          0.0),
                                                                  child: Text(
                                                                    preguntasindeexItem
                                                                        .pregunta,
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.inter(
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                          ),
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                        ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          wrapWithModel(
                                                            model: _model
                                                                .verdaderofalsoModels
                                                                .getModel(
                                                              preguntasindeexIndex
                                                                  .toString(),
                                                              preguntasindeexIndex,
                                                            ),
                                                            updateCallback: () =>
                                                                safeSetState(
                                                                    () {}),
                                                            child:
                                                                VerdaderofalsoWidget(
                                                              key: Key(
                                                                'Keyfxs_${preguntasindeexIndex.toString()}',
                                                              ),
                                                              parameter1:
                                                                  preguntasindeexItem
                                                                      .trueAndFalse,
                                                              parameter2:
                                                                  preguntasindeexIndex,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                  ],
                                                );
                                              }),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 24.0, 0.0, 0.0),
                                    child: wrapWithModel(
                                      model: _model.registartionButtonModel,
                                      updateCallback: () => safeSetState(() {}),
                                      updateOnChange: true,
                                      child: RegistartionButtonWidget(
                                        btnText: 'Enviar',
                                        btnAction: () async {
                                          if (widget.encuesta != null) {
                                            final encuestaDoc = await EncuestasRecord.getDocumentOnce(widget.encuesta!);
                                            final preguntas = encuestaDoc.preguntas;
                                            for (int i = 0; i < preguntas.length; i++) {
                                              final p = preguntas[i];
                                              if (p.nPregunta != 1) continue;
                                              if (p.tipo == 'Descriptiva') continue;

                                              final r = i < FFAppState().RespuestaEnc.length
                                                  ? FFAppState().RespuestaEnc[i]
                                                  : null;

                                              bool respondida = false;
                                              if (r != null) {
                                                final tipo = p.tipo;
                                                if (tipo == 'abiertas') {
                                                  respondida = r.respuesta.trim().isNotEmpty;
                                                } else if (tipo == 'Verdadero o falso') {
                                                  respondida = r.hasTrueAndFalse();
                                                } else if (tipo == 'Selección única') {
                                                  respondida = r.respuestaSeleccionUnica.isNotEmpty;
                                                } else if (tipo == 'selección' || tipo == 'Condicionante') {
                                                  respondida = r.respuestasSeleccionadas.isNotEmpty;
                                                } else if (tipo == 'Tamizaje') {
                                                  final visible = FFAppState().TamizajeSustanciaPermitidas.contains(p.sustancia);
                                                  respondida = !visible || r.respuestaTamizaje.isNotEmpty;
                                                } else if (tipo == 'Tamizaje autoestima' ||
                                                           tipo == 'Tamizaje CDI' ||
                                                           tipo == 'Tamizajes Depresion Beck' ||
                                                           tipo == 'Tamizaje CRQ / SRQ') {
                                                  respondida = r.respuestaTamizaje.isNotEmpty;
                                                } else {
                                                  respondida = r.respuestaTamizaje.isNotEmpty;
                                                }
                                              }

                                              if (!respondida) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Falta responder la pregunta: ${p.pregunta}'),
                                                    backgroundColor: Colors.red,
                                                    duration: const Duration(seconds: 3),
                                                  ),
                                                );
                                                return;
                                              }
                                            }
                                          }
                                          await RespuestasRecord.createDoc(
                                                  widget.encuesta!)
                                              .set({
                                            ...createRespuestasRecordData(
                                              userRespuesta:
                                                  currentUserReference,
                                              fecha: getCurrentTimestamp,
                                              titlo: widget.titulo,
                                              desc: widget.desc,
                                            ),
                                            ...mapToFirestore(
                                              {
                                                'test':
                                                    getRespuestaTestListFirestoreData(
                                                  FFAppState().RespuestaEnc,
                                                ),
                                              },
                                            ),
                                          });

                                          await widget.encuesta!.update({
                                            ...mapToFirestore(
                                              {
                                                'user_Ref':
                                                    FieldValue.arrayUnion(
                                                        [currentUserReference]),
                                              },
                                            ),
                                          });
                                          FFAppState().RespuestaEnc = [];
                                          FFAppState().select = [];
                                          safeSetState(() {});
                                          context.safePop();
                                        },
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
              Align(
                alignment: AlignmentDirectional(0.0, 1.0),
                child: wrapWithModel(
                  model: _model.footerParentsModel,
                  updateCallback: () => safeSetState(() {}),
                  child: FooterParentsWidget(
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
