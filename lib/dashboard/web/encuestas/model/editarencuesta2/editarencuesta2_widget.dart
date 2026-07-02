import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/successpopup_widget.dart';
import '/components/text_field_alerta_widget.dart';
import '/dashboard/web/encuestas/crearencuesta/pregunta_card_widget.dart';
import '/dashboard/web/encuestas/model/emptytest/emptytest_widget.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'editarencuesta2_model.dart';
import '../../encuesta_form_helpers.dart';
import '../../editar/widgets/tamizajes_niveles.dart';
export 'editarencuesta2_model.dart';

part 'editarencuesta2_widget.form_sections.dart';
part 'editarencuesta2_widget.action_sections.dart';

class Editarencuesta2Widget extends StatefulWidget {
  const Editarencuesta2Widget({
    super.key,
    required this.encuestaID,
    required this.docencuestas2,
    required this.tipo,
  });

  final DocumentReference? encuestaID;
  final EncuestasRecord? docencuestas2;
  final String? tipo;

  @override
  State<Editarencuesta2Widget> createState() => _Editarencuesta2WidgetState();
}

class _Editarencuesta2WidgetState extends State<Editarencuesta2Widget> {
  late Editarencuesta2Model _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => Editarencuesta2Model());

    final doc = widget.docencuestas2;
    if (doc != null) {
      final cat = doc.categoria;
      if (cat == 'CDI' ||
          cat == 'Escala autoestima' ||
          cat == 'Escala ansiedad') {
        // Ansiedad tiene 4 niveles, los demás 3. alertasTripletePorDefecto maneja ambos.
        final minAlerts = cat == 'Escala ansiedad' ? 4 : 3;
        if (doc.alertas.length >= minAlerts) {
          FFAppState().listaAlertasEnvio =
              doc.alertas.toList().cast<AlertaStruct>();
        } else if (cat != 'Escala ansiedad' &&
            doc.bajo.hasMax() &&
            doc.moderado.hasMax() &&
            doc.alto.hasMax()) {
          FFAppState().listaAlertasEnvio = [
            doc.bajo,
            doc.moderado,
            doc.alto,
          ];
        } else {
          FFAppState().listaAlertasEnvio = alertasTripletePorDefecto(cat);
        }
      } else if (doc.alertas.length > 2) {
        FFAppState().listaAlertasEnvio =
            doc.alertas.toList().cast<AlertaStruct>();
      } else {
        FFAppState().listaAlertasEnvio =
            FFAppState().listaAlertas.toList().cast<AlertaStruct>();
      }

      _model.textController1 = TextEditingController(text: doc.titulo);
      _model.descTextController = TextEditingController(text: doc.descripcion);
      _model.roleValue = List.from(doc.roles);
      _model.roleValueController =
          FormFieldController<List<String>>(_model.roleValue);
      _model.categoriaValue = doc.categoria;
      _model.categoriaValueController =
          FormFieldController<String>(_model.categoriaValue);
      _model.alertasEspeciales =
          List<AlertaEspecialStruct>.from(doc.alertasEspeciales);
      _model.preguntas = List<PreguntasEncuestaStruct>.from(doc.preguntas);
    }

    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    _model.descTextController ??= TextEditingController();
    _model.descFocusNode ??= FocusNode();

    _model.preguntaTextController ??= TextEditingController();
    _model.preguntaFocusNode ??= FocusNode();

    _model.abiertaTextController ??= TextEditingController();
    _model.abiertaFocusNode ??= FocusNode();

    _model.selection1TextController1 ??= TextEditingController();
    _model.selection1FocusNode1 ??= FocusNode();

    _model.selectionPuntajeTextController ??= TextEditingController();
    _model.selectionPuntajeFocusNode ??= FocusNode();

    _model.selection1TextController2 ??= TextEditingController();
    _model.selection1FocusNode2 ??= FocusNode();

    _model.selectionunica1TextController ??= TextEditingController();
    _model.selectionunica1FocusNode ??= FocusNode();

    _model.selection1CondicionTextController ??= TextEditingController();
    _model.selection1CondicionFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  /// Evita que un `.update()` del editor modular deje `bajo`/`moderado`/`alto`
  /// sin escribir (Firestore conservaba valores viejos; en creación quedaban vacíos).
  Map<String, dynamic> _payloadEncuestaRecord({
    required bool publicado,
    String? titulo,
    String? descripcion,
  }) {
    final cat = _model.categoriaValue ?? widget.docencuestas2?.categoria;
    AlertaStruct? bajo;
    AlertaStruct? moderado;
    AlertaStruct? alto;
    if ((cat == 'Escala autoestima' || cat == 'CDI') &&
        FFAppState().listaAlertasEnvio.length >= 3) {
      bajo = FFAppState().listaAlertasEnvio[0];
      moderado = FFAppState().listaAlertasEnvio[1];
      alto = FFAppState().listaAlertasEnvio[2];
    }
    return createEncuestasRecordData(
      publicado: publicado,
      titulo: titulo,
      descripcion: descripcion,
      bajo: bajo,
      moderado: moderado,
      alto: alto,
      categoria: cat,
    );
  }

  String _normalizeTitulo(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  Future<bool> _tituloYaExiste(String titulo) async {
    final encuestaRef = widget.encuestaID;
    final normalizado = _normalizeTitulo(titulo);
    final encuestas = await queryEncuestasRecordOnce();
    for (final e in encuestas) {
      if (encuestaRef != null && e.reference == encuestaRef) continue;
      if (_normalizeTitulo(e.titulo) == normalizado) return true;
    }
    return false;
  }

  Future<bool> _validarTituloUnico() async {
    final titulo = _model.textController1.text.trim();
    if (titulo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('El nombre del tamizaje es obligatorio.'),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
      return false;
    }
    final duplicado = await _tituloYaExiste(titulo);
    if (duplicado) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Ya existe un tamizaje con ese nombre. Usa un nombre diferente.',
          ),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
      ),
      child: SingleChildScrollView(
        primary: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Container(
                      height: MediaQuery.sizeOf(context).height * 1.0,
                      decoration: BoxDecoration(),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            40.0, 20.0, 40.0, 20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildHeaderRow(context),
                            Flexible(
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 45.0, 0.0, 0.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: Container(
                                        height:
                                            MediaQuery.sizeOf(context).height *
                                                1.0,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              blurRadius: 50.0,
                                              color: Color(0x26000000),
                                              offset: Offset(
                                                20.0,
                                                20.0,
                                              ),
                                            )
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(10.0),
                                          child: SingleChildScrollView(
                                            primary: false,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                _buildDatosPrincipalesSection(
                                                    context),
                                                _buildAgregarPreguntasButton(
                                                    context),
                                                Padding(
                                                  padding: EdgeInsets.all(20.0),
                                                  child: StreamBuilder<
                                                      EncuestasRecord>(
                                                    stream: EncuestasRecord
                                                        .getDocument(
                                                            widget.encuestaID!),
                                                    builder:
                                                        (context, snapshot) {
                                                      // Customize what your widget looks like when it's loading.
                                                      if (!snapshot.hasData) {
                                                        return Center(
                                                          child: SizedBox(
                                                            width: 50.0,
                                                            height: 50.0,
                                                            child:
                                                                CircularProgressIndicator(
                                                              valueColor:
                                                                  AlwaysStoppedAnimation<
                                                                      Color>(
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .primary,
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      }

                                                      final containerEncuestasRecord =
                                                          snapshot.data!;

                                                      return Container(
                                                        width:
                                                            MediaQuery.sizeOf(
                                                                        context)
                                                                    .width *
                                                                1.0,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      20.0),
                                                        ),
                                                        child:
                                                            SingleChildScrollView(
                                                          primary: false,
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            children: [
                                                              _buildPreguntasList(
                                                                  containerEncuestasRecord),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SingleChildScrollView(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    30.0, 0.0, 0.0, 0.0),
                                            child: Container(
                                              width: MediaQuery.sizeOf(context)
                                                      .width *
                                                  0.2,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                boxShadow: [
                                                  BoxShadow(
                                                    blurRadius: 50.0,
                                                    color: Color(0x26000000),
                                                    offset: Offset(
                                                      20.0,
                                                      20.0,
                                                    ),
                                                  )
                                                ],
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Flexible(
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.all(20.0),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                children: [
                                                                  Padding(
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            0.0,
                                                                            12.0,
                                                                            0.0,
                                                                            15.0),
                                                                    child: Text(
                                                                      'Dirigido a:',
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.inter(
                                                                              fontWeight: FontWeight.w600,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                            fontSize:
                                                                                18.0,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              FlutterFlowDropDown<
                                                                  String>(
                                                                multiSelectController: _model
                                                                        .roleValueController ??=
                                                                    FormListFieldController<
                                                                        String>(_model
                                                                            .roleValue ??=
                                                                        List<
                                                                            String>.from(
                                                                  widget.docencuestas2
                                                                          ?.roles ??
                                                                      [],
                                                                )),
                                                                options:
                                                                    FFAppConstants
                                                                        .Role,
                                                                width: 276.0,
                                                                height: 56.0,
                                                                textStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      font: GoogleFonts
                                                                          .inter(
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontStyle,
                                                                      ),
                                                                      color: Color(
                                                                          0xFF9E8888),
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
                                                                hintText:
                                                                    'Seleccionar',
                                                                icon: Icon(
                                                                  Icons
                                                                      .keyboard_arrow_down_rounded,
                                                                  color: Color(
                                                                      0xFF265294),
                                                                  size: 35.0,
                                                                ),
                                                                fillColor: Color(
                                                                    0xFFF5F5F5),
                                                                elevation: 2.0,
                                                                borderColor:
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .alternate,
                                                                borderWidth:
                                                                    2.0,
                                                                borderRadius:
                                                                    8.0,
                                                                margin: EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        16.0,
                                                                        4.0,
                                                                        16.0,
                                                                        4.0),
                                                                hidesUnderline:
                                                                    true,
                                                                isOverButton:
                                                                    false,
                                                                isSearchable:
                                                                    false,
                                                                isMultiSelect:
                                                                    true,
                                                                onMultiSelectChanged:
                                                                    (val) async {
                                                                  safeSetState(() =>
                                                                      _model.roleValue =
                                                                          val);
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                          ..._buildActionButtons(
                                                              context),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          if (widget.tipo == 'Tamizajes') ...[
                                            _buildTamizajesAlertsPanel(context),
                                            if (_model.categoriaValue ==
                                                    'CRQ / SRQ' ||
                                                _model.categoriaValue ==
                                                    'CRQ' ||
                                                _model.categoriaValue == 'SRQ')
                                              _buildTamizajesAlertsEspecialesPanel(
                                                  context),
                                          ],
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
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreguntasList(EncuestasRecord encuestasRecord) {
    final preguntaList = _model.preguntas;
    if (preguntaList.isEmpty) {
      return Center(child: EmptytestWidget());
    }
    return ListView.builder(
      padding: EdgeInsets.zero,
      primary: false,
      shrinkWrap: true,
      itemCount: preguntaList.length,
      itemBuilder: (context, index) {
        return PreguntaCard(
          pregunta: preguntaList[index],
          encuestasRecord: encuestasRecord,
          index: index,
          onDelete: () {
            setState(() {
              _model.preguntas.removeAt(index);
            });
          },
        );
      },
    );
  }
}
