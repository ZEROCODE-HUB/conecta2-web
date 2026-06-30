import 'package:flutter/scheduler.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:collection/collection.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/custom_code/actions/evaluar_alertas_especiales.dart';
import '/components/lista_respuestas_cond_widget.dart';
import '/components/lista_respuestas_widget.dart';
import '/components/r_seleccion_unica_radious_tamizaje_widget.dart';
import '/components/r_seleccion_unica_radious_widget.dart';
import '/components/registartion_button/registartion_button_widget.dart';
import '/components/text_respuesta_widget.dart';
import '/components/verdaderofalso_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'encuestas_adolescente_open_model.dart';
export 'encuestas_adolescente_open_model.dart';

class EncuestasAdolescenteOpenWidget extends StatefulWidget {
  const EncuestasAdolescenteOpenWidget({
    super.key,
    this.encuesta,
    required this.choice,
    required this.text,
    required this.desc,
  });

  final DocumentReference? encuesta;
  final String? choice;
  final String? text;
  final String? desc;

  static String routeName = 'EncuestasAdolescenteOpen';
  static String routePath = '/encuestasAdolescenteOpen';

  @override
  State<EncuestasAdolescenteOpenWidget> createState() =>
      _EncuestasAdolescenteOpenWidgetState();
}

class _EncuestasAdolescenteOpenWidgetState
    extends State<EncuestasAdolescenteOpenWidget> {
  late EncuestasAdolescenteOpenModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EncuestasAdolescenteOpenModel());

    // Check for 24h block on this specific encuesta
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      final lastInvalidated = await queryRespuestasRecordOnce(
        parent: widget.encuesta,
        queryBuilder: (q) => q
            .where('User_respuesta', isEqualTo: currentUserReference)
            .where('invalidado', isEqualTo: true)
            .orderBy('fechaInvalidacion', descending: true),
        limit: 1,
      ).then((list) => list.firstOrNull);

      if (lastInvalidated != null && lastInvalidated.hasFechaInvalidacion()) {
        final diff =
            DateTime.now().difference(lastInvalidated.fechaInvalidacion!);
        if (diff.inHours < 24) {
          _model.isBlocked = true;
          final remaining = 24 - diff.inHours;
          _model.blockMessage =
              'Este tamizaje fue invalidado. Podrás intentarlo de nuevo en $remaining horas.';
          safeSetState(() {});
        }
      }
      safeSetState(() {});
    });
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
          child: StreamBuilder<EncuestasRecord>(
            stream: EncuestasRecord.getDocument(widget.encuesta!),
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

              final columnEncuestasRecord = snapshot.data!;

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    if (_model.isBlocked)
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.all(20.0),
                        padding: EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: Color(0xFFFFE5E5),
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(color: Colors.red, width: 1.0),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.lock_clock_outlined,
                                color: Colors.red, size: 48.0),
                            SizedBox(height: 16.0),
                            Text(
                              'PRUEBA BLOQUEADA',
                              style: FlutterFlowTheme.of(context)
                                  .headlineSmall
                                  .override(
                                    font: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold),
                                    color: Colors.red,
                                  ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              _model.blockMessage,
                              textAlign: TextAlign.center,
                              style: FlutterFlowTheme.of(context).bodyMedium,
                            ),
                            SizedBox(height: 24.0),
                            FFButtonWidget(
                              onPressed: () => context.safePop(),
                              text: 'Regresar',
                              options: FFButtonOptions(
                                width: 200.0,
                                height: 40.0,
                                color: Colors.red,
                                textStyle:
                                    FlutterFlowTheme.of(context).titleSmall,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (!_model.isBlocked) ...[
                      Container(
                        width: double.infinity,
                        height: 41.0,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).primary,
                        ),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              20.0, 5.0, 20.0, 5.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  FFAppState().EncuestaRespuesta = [];
                                  FFAppState().RespuestaEnc = [];
                                  safeSetState(() {});
                                  context.safePop();
                                },
                                child: FaIcon(
                                  FontAwesomeIcons.circleChevronLeft,
                                  color: FlutterFlowTheme.of(context)
                                      .lightBlueForMobile,
                                  size: 30.0,
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Icon(
                                    Icons.favorite,
                                    color:
                                        FlutterFlowTheme.of(context).tertiary,
                                    size: 24.0,
                                  ),
                                  Text(
                                    '${functions.emocion(FFAppState().CalenderEmotion.map((e) => e.emocion).toList()).toString()} dias',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight: FontWeight.bold,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.bold,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                  ),
                                ],
                              ),
                              AuthUserStreamWidget(
                                builder: (context) => InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    context.pushNamed(
                                      ProfileWidget.routeName,
                                      extra: <String, dynamic>{
                                        '__transition_info__': TransitionInfo(
                                          hasTransition: true,
                                          transitionType:
                                              PageTransitionType.fade,
                                          duration: Duration(milliseconds: 0),
                                        ),
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 41.0,
                                    height: 41.0,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    child: Image.network(
                                      valueOrDefault<String>(
                                        currentUserPhoto,
                                        'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              12.0, 10.0, 12.0, 10.0),
                          child: SingleChildScrollView(
                            primary: false,
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                            widget.text,
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
                                                    FlutterFlowTheme.of(context)
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
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.outfit(
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
                                    ],
                                  ),
                                ),
                                Builder(
                                  builder: (context) {
                                    final preguntasindeex =
                                        columnEncuestasRecord.preguntas
                                            .toList();

                                    return Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children:
                                          List.generate(preguntasindeex.length,
                                              (preguntasindeexIndex) {
                                        final preguntasindeexItem =
                                            preguntasindeex[
                                                preguntasindeexIndex];
                                        return Column(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            if (preguntasindeexItem.tipo ==
                                                'abiertas')
                                              Column(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 24.0,
                                                                0.0, 0.0),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Flexible(
                                                          child: Text(
                                                            preguntasindeexItem
                                                                .pregunta,
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .outfit(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
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
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  if (preguntasindeexItem
                                                          .ocultarRespuesta ==
                                                      false)
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Flexible(
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0.0,
                                                                        8.0,
                                                                        0.0,
                                                                        0.0),
                                                            child: Container(
                                                              height: 47.0,
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
                                                                      model: _model
                                                                          .textRespuestaModels
                                                                          .getModel(
                                                                        preguntasindeexIndex
                                                                            .toString(),
                                                                        preguntasindeexIndex,
                                                                      ),
                                                                      updateCallback:
                                                                          () =>
                                                                              safeSetState(() {}),
                                                                      updateOnChange:
                                                                          true,
                                                                      child:
                                                                          TextRespuestaWidget(
                                                                        key:
                                                                            Key(
                                                                          'Keypgm_${preguntasindeexIndex.toString()}',
                                                                        ),
                                                                        action:
                                                                            () async {
                                                                          FFAppState()
                                                                              .updateRespuestaEncAtIndex(
                                                                            preguntasindeexIndex,
                                                                            (e) => e
                                                                              ..respuesta = FFAppState().updateText,
                                                                          );
                                                                          safeSetState(
                                                                              () {});
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
                                            if ((preguntasindeexItem.tipo ==
                                                    'Tamizaje') &&
                                                (FFAppState()
                                                        .TamizajeSustanciaPermitidas
                                                        .where((e) =>
                                                            e ==
                                                            preguntasindeexItem
                                                                .sustancia)
                                                        .toList()
                                                        .length !=
                                                    0))
                                              Column(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 24.0,
                                                                0.0, 0.0),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Flexible(
                                                          child: Text(
                                                            preguntasindeexItem
                                                                .pregunta,
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .outfit(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
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
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 12.0,
                                                                0.0, 0.0),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        RSeleccionUnicaRadiousTamizajeWidget(
                                                          key: Key(
                                                              'Key2o5_${preguntasindeexIndex}_of_${preguntasindeex.length}'),
                                                          index:
                                                              preguntasindeexIndex,
                                                          parameter1:
                                                              preguntasindeexItem
                                                                  .respuestaTamizaje,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            if ((preguntasindeexItem.tipo ==
                                                    'Tamizaje autoestima') ||
                                                (preguntasindeexItem.tipo ==
                                                    'Tamizaje CDI') ||
                                                (preguntasindeexItem.tipo ==
                                                    'Tamizajes Depresion Beck') ||
                                                (preguntasindeexItem.tipo ==
                                                    'Tamizaje CRQ / SRQ') ||
                                                (preguntasindeexItem.tipo ==
                                                    'Tamizaje CRQ') ||
                                                (preguntasindeexItem.tipo ==
                                                    'Tamizaje SRQ'))
                                              Column(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 24.0,
                                                                0.0, 0.0),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Flexible(
                                                          child: Text(
                                                            (preguntasindeexItem.tipo == 'Tamizaje CRQ / SRQ' ||
                                                                    preguntasindeexItem
                                                                            .tipo ==
                                                                        'Tamizaje CRQ' ||
                                                                    preguntasindeexItem
                                                                            .tipo ==
                                                                        'Tamizaje SRQ')
                                                                ? '${preguntasindeexItem.numeroPregunta}. ${preguntasindeexItem.pregunta}'
                                                                : preguntasindeexItem
                                                                    .pregunta,
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .outfit(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
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
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 12.0,
                                                                0.0, 0.0),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        RSeleccionUnicaRadiousTamizajeWidget(
                                                          key: Key(
                                                              'KeyTam2_${preguntasindeexIndex}_of_${preguntasindeex.length}'),
                                                          index:
                                                              preguntasindeexIndex,
                                                          parameter1:
                                                              preguntasindeexItem
                                                                  .respuestaTamizaje,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            if (preguntasindeexItem.tipo ==
                                                'Descriptiva')
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        0.0, 24.0, 0.0, 0.0),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Flexible(
                                                      child: Text(
                                                        preguntasindeexItem
                                                            .pregunta,
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .outfit(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
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
                                                                ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            if (preguntasindeexItem.tipo ==
                                                'selección')
                                              Column(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 24.0,
                                                                0.0, 0.0),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Flexible(
                                                          child: Text(
                                                            preguntasindeexItem
                                                                .pregunta,
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .outfit(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
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
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 12.0,
                                                                0.0, 0.0),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Flexible(
                                                          child: wrapWithModel(
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
                                                                'Key078_${preguntasindeexIndex.toString()}',
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
                                            if (preguntasindeexItem.tipo ==
                                                'Selección única')
                                              Column(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 24.0,
                                                                0.0, 0.0),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Flexible(
                                                          child: Text(
                                                            preguntasindeexItem
                                                                .pregunta,
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .outfit(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
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
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 12.0,
                                                                0.0, 0.0),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        RSeleccionUnicaRadiousWidget(
                                                          key: Key(
                                                              'Key7yp_${preguntasindeexIndex}_of_${preguntasindeex.length}'),
                                                          parameter1:
                                                              preguntasindeexItem
                                                                  .respuestasSeleccionUnica,
                                                          index:
                                                              preguntasindeexIndex,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            if (preguntasindeexItem.tipo ==
                                                'Verdadero o falso')
                                              Column(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      Flexible(
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      0.0,
                                                                      20.0,
                                                                      0.0,
                                                                      0.0),
                                                          child: Text(
                                                            preguntasindeexItem
                                                                .pregunta,
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  font:
                                                                      GoogleFonts
                                                                          .inter(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
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
                                                        safeSetState(() {}),
                                                    child: VerdaderofalsoWidget(
                                                      key: Key(
                                                        'Key055_${preguntasindeexIndex.toString()}',
                                                      ),
                                                      parameter1:
                                                          preguntasindeexItem
                                                              .nPregunta,
                                                      parameter2:
                                                          preguntasindeexIndex,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            if (preguntasindeexItem.tipo ==
                                                'Condicionante')
                                              Column(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 24.0,
                                                                0.0, 0.0),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Flexible(
                                                          child: Text(
                                                            preguntasindeexItem
                                                                .pregunta,
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .outfit(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
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
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 12.0,
                                                                0.0, 0.0),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Container(
                                                          child: wrapWithModel(
                                                            model: _model
                                                                .listaRespuestasCondModels
                                                                .getModel(
                                                              preguntasindeexIndex
                                                                  .toString(),
                                                              preguntasindeexIndex,
                                                            ),
                                                            updateCallback: () =>
                                                                safeSetState(
                                                                    () {}),
                                                            child:
                                                                ListaRespuestasCondWidget(
                                                              key: Key(
                                                                'Keyzni_${preguntasindeexIndex.toString()}',
                                                              ),
                                                              parameter2:
                                                                  preguntasindeexIndex,
                                                              parameter3:
                                                                  preguntasindeexItem
                                                                      .respuestaCondicionante,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
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
                                        // B3: Validar que todas las preguntas obligatorias tengan respuesta
                                        final preguntas =
                                            columnEncuestasRecord.preguntas;
                                        for (int i = 0;
                                            i < preguntas.length;
                                            i++) {
                                          final p = preguntas[i];
                                          if (p.nPregunta != 1) continue;
                                          if (p.tipo == 'Descriptiva') continue;

                                          final r = i <
                                                  FFAppState()
                                                      .RespuestaEnc
                                                      .length
                                              ? FFAppState().RespuestaEnc[i]
                                              : null;

                                          bool respondida = false;
                                          if (r != null) {
                                            final tipo = p.tipo;
                                            if (tipo == 'abiertas') {
                                              respondida =
                                                  r.respuesta.trim().isNotEmpty;
                                            } else if (tipo ==
                                                'Verdadero o falso') {
                                              respondida = r.hasTrueAndFalse();
                                            } else if (tipo ==
                                                'Selección única') {
                                              respondida = r
                                                  .respuestaSeleccionUnica
                                                  .isNotEmpty;
                                            } else if (tipo == 'selección' ||
                                                tipo == 'Condicionante') {
                                              respondida = r
                                                  .respuestasSeleccionadas
                                                  .isNotEmpty;
                                            } else if (tipo == 'Tamizaje') {
                                              final visible = FFAppState()
                                                  .TamizajeSustanciaPermitidas
                                                  .contains(p.sustancia);
                                              respondida = !visible ||
                                                  r.respuestaTamizaje
                                                      .isNotEmpty;
                                            } else if (tipo ==
                                                    'Tamizaje autoestima' ||
                                                tipo == 'Tamizaje CDI' ||
                                                tipo ==
                                                    'Tamizajes Depresion Beck' ||
                                                tipo == 'Tamizaje CRQ / SRQ' ||
                                                tipo == 'Tamizaje CRQ' ||
                                                tipo == 'Tamizaje SRQ') {
                                              respondida = r
                                                  .respuestaTamizaje.isNotEmpty;
                                            } else {
                                              respondida = r
                                                  .respuestaTamizaje.isNotEmpty;
                                            }
                                          }

                                          if (!respondida) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Falta responder la pregunta: ${p.pregunta}'),
                                                backgroundColor: Colors.red,
                                                duration:
                                                    const Duration(seconds: 3),
                                              ),
                                            );
                                            return;
                                          }
                                        }

                                        // Logica de Alertas Especiales
                                        List<String> specialAlerts = [];
                                        bool hasSuicidalIdeation = false;

                                        for (var r
                                            in FFAppState().RespuestaEnc) {
                                          // Detectar Ideación Suicida
                                          if (r.respuestaTamizaje
                                              .any((a) => a.ideacionSuicida)) {
                                            hasSuicidalIdeation = true;
                                          }
                                        }

                                        if (hasSuicidalIdeation) {
                                          specialAlerts.add(
                                              'ALERTA: Ideación Suicida detectada');
                                        }

                                        // Evaluate alertas especiales defined on the encuesta
                                        if (columnEncuestasRecord
                                            .alertasEspeciales.isNotEmpty) {
                                          final triggered =
                                              evaluarAlertasEspeciales(
                                            columnEncuestasRecord
                                                .alertasEspeciales,
                                            FFAppState().RespuestaEnc,
                                          );
                                          specialAlerts.addAll(triggered);
                                        }

                                        await RespuestasRecord.createDoc(
                                                widget.encuesta!)
                                            .set({
                                          ...createRespuestasRecordData(
                                            userRespuesta: currentUserReference,
                                            fecha: getCurrentTimestamp,
                                            titlo: widget.text,
                                            desc: widget.desc,
                                            puntajeTotal: FFAppState()
                                                .RespuestaEnc
                                                .fold<int>(
                                                  0,
                                                  (sum, r) =>
                                                      sum +
                                                      (r.respuestaTamizaje
                                                              .isNotEmpty
                                                          ? r.respuestaTamizaje
                                                              .first.valor
                                                          : 0),
                                                ),
                                            alertasEspeciales: specialAlerts,
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
                                              'user_Ref': FieldValue.arrayUnion(
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
                    ], // end if (!_model.isBlocked)
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
