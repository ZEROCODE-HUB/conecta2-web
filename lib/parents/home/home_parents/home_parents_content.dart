part of 'home_parents_widget.dart';

extension _HomeParentsContent on _HomeParentsWidgetState {
  Widget buildMainContent(BuildContext context) {
    return Padding(
  padding:
      EdgeInsetsDirectional.fromSTEB(0.0, 40.0, 0.0, 100.0),
  child: Container(
    decoration: BoxDecoration(),
    child: Padding(
      padding:
          EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 0.0),
      child: SingleChildScrollView(
        primary: false,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            0.0, 0.0, 0.0, 20.0),
                        child: Text(
                          'Bienvenidos al Módulo de Acudientes ',
                          style: FlutterFlowTheme.of(context)
                              .labelSmall
                              .override(
                                font: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontStyle:
                                      FlutterFlowTheme.of(
                                              context)
                                          .labelSmall
                                          .fontStyle,
                                ),
                                fontSize: 18.0,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.bold,
                                fontStyle:
                                    FlutterFlowTheme.of(context)
                                        .labelSmall
                                        .fontStyle,
                              ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            0.0, 0.0, 0.0, 20.0),
                        child: Text(
                          '¡Hola a todos los acudientes y cuidadores! Este módulo está diseñado especialmente para ustedes, con el fin de brindarles herramientas, consejos y recursos útiles para apoyar el bienestar emocional y el desarrollo de sus hijos. ',
                          style: FlutterFlowTheme.of(context)
                              .labelSmall
                              .override(
                                font: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w600,
                                  fontStyle:
                                      FlutterFlowTheme.of(
                                              context)
                                          .labelSmall
                                          .fontStyle,
                                ),
                                fontSize: 18.0,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w600,
                                fontStyle:
                                    FlutterFlowTheme.of(context)
                                        .labelSmall
                                        .fontStyle,
                              ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Último contenido',
                    style: FlutterFlowTheme.of(context)
                        .bodyMedium
                        .override(
                          font: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontStyle:
                                FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                          ),
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w600,
                          fontStyle:
                              FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                        ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                        0.0, 15.0, 0.0, 0.0),
                    child: Container(
                      height: 200.0,
                      decoration: BoxDecoration(),
                      child: AuthUserStreamWidget(
                        builder: (context) => StreamBuilder<
                            List<ContenidoRecord>>(
                          stream: queryContenidoRecord(
                            // Solo publicados (como adolescente y profesional).
                            queryBuilder: (contenidoRecord) => contenidoRecord
                                .where('Publicado', isEqualTo: true)
                                .where(
                              'Roles',
                              arrayContains: valueOrDefault(
                                  currentUserDocument?.rol, ''),
                            ),
                          ),
                          builder: (context, snapshot) {
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
                            List<ContenidoRecord>
                                pageViewContenidoRecordList =
                                snapshot.data!;

                            return Container(
                              width: double.infinity,
                              height: 500.0,
                              child: Stack(
                                children: [
                                  Padding(
                                    padding:
                                        EdgeInsetsDirectional
                                            .fromSTEB(0.0, 0.0,
                                                0.0, 40.0),
                                    child: PageView.builder(
                                      controller: _model
                                              .pageViewController1 ??=
                                          PageController(
                                              initialPage: max(
                                                  0,
                                                  min(
                                                      0,
                                                      pageViewContenidoRecordList
                                                              .length -
                                                          1))),
                                      scrollDirection:
                                          Axis.horizontal,
                                      itemCount:
                                          pageViewContenidoRecordList
                                              .length,
                                      itemBuilder: (context,
                                          pageViewIndex) {
                                        final pageViewContenidoRecord =
                                            pageViewContenidoRecordList[
                                                pageViewIndex];
                                        return Row(
                                          mainAxisSize:
                                              MainAxisSize.max,
                                          children: [
                                            Expanded(
                                              child: InkWell(
                                                splashColor: Colors
                                                    .transparent,
                                                focusColor: Colors
                                                    .transparent,
                                                hoverColor: Colors
                                                    .transparent,
                                                highlightColor:
                                                    Colors
                                                        .transparent,
                                                onTap:
                                                    () async {
                                                  context
                                                      .pushNamed(
                                                    AprendizajeParentsOpenWidget
                                                        .routeName,
                                                    queryParameters:
                                                        {
                                                      'contenido':
                                                          serializeParam(
                                                        pageViewContenidoRecord
                                                            .reference,
                                                        ParamType
                                                            .DocumentReference,
                                                      ),
                                                    }.withoutNulls,
                                                  );
                                                },
                                                child:
                                                    ListCardWidget(
                                                  key: Key(
                                                      'Key2tc_${pageViewIndex}_of_${pageViewContenidoRecordList.length}'),
                                                  showImage:
                                                      true,
                                                  titulo:
                                                      pageViewContenidoRecord
                                                          .titulo,
                                                  imagen: pageViewContenidoRecord
                                                      .imageProfile,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                  Align(
                                    alignment:
                                        AlignmentDirectional(
                                            0.0, 1.0),
                                    child: Padding(
                                      padding:
                                          EdgeInsetsDirectional
                                              .fromSTEB(
                                                  16.0,
                                                  0.0,
                                                  0.0,
                                                  16.0),
                                      child: smooth_page_indicator
                                          .SmoothPageIndicator(
                                        controller: _model
                                                .pageViewController1 ??=
                                            PageController(
                                                initialPage: max(
                                                    0,
                                                    min(
                                                        0,
                                                        pageViewContenidoRecordList.length -
                                                            1))),
                                        count:
                                            pageViewContenidoRecordList
                                                .length,
                                        axisDirection:
                                            Axis.horizontal,
                                        onDotClicked:
                                            (i) async {
                                          await _model
                                              .pageViewController1!
                                              .animateToPage(
                                            i,
                                            duration: Duration(
                                                milliseconds:
                                                    500),
                                            curve: Curves.ease,
                                          );
                                          safeSetState(() {});
                                        },
                                        effect: smooth_page_indicator
                                            .ExpandingDotsEffect(
                                          expansionFactor: 2.0,
                                          spacing: 8.0,
                                          radius: 16.0,
                                          dotWidth: 7.0,
                                          dotHeight: 8.0,
                                          dotColor:
                                              Color(0xFFD9D9D9),
                                          activeDotColor:
                                              Color(0xFF265294),
                                          paintStyle:
                                              PaintingStyle
                                                  .fill,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Text(
                    'Cuestionario',
                    style: FlutterFlowTheme.of(context)
                        .bodyMedium
                        .override(
                          font: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontStyle:
                                FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                          ),
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w600,
                          fontStyle:
                              FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                        ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                        0.0, 15.0, 0.0, 0.0),
                    child: Container(
                      height: 200.0,
                      decoration: BoxDecoration(),
                      child: AuthUserStreamWidget(
                        builder: (context) => StreamBuilder<
                            List<EncuestasRecord>>(
                          stream: queryEncuestasRecord(
                            queryBuilder: (encuestasRecord) =>
                                encuestasRecord.where(
                              'Roles',
                              arrayContains: valueOrDefault(
                                  currentUserDocument?.rol, ''),
                            ),
                          ),
                          builder: (context, snapshot) {
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
                            List<EncuestasRecord>
                                pageViewEncuestasRecordList =
                                snapshot.data!;

                            return Container(
                              width: double.infinity,
                              height: 500.0,
                              child: Stack(
                                children: [
                                  Padding(
                                    padding:
                                        EdgeInsetsDirectional
                                            .fromSTEB(0.0, 0.0,
                                                0.0, 40.0),
                                    child: PageView.builder(
                                      controller: _model
                                              .pageViewController2 ??=
                                          PageController(
                                              initialPage: max(
                                                  0,
                                                  min(
                                                      0,
                                                      pageViewEncuestasRecordList
                                                              .length -
                                                          1))),
                                      scrollDirection:
                                          Axis.horizontal,
                                      itemCount:
                                          pageViewEncuestasRecordList
                                              .length,
                                      itemBuilder: (context,
                                          pageViewIndex) {
                                        final pageViewEncuestasRecord =
                                            pageViewEncuestasRecordList[
                                                pageViewIndex];
                                        return Row(
                                          mainAxisSize:
                                              MainAxisSize.max,
                                          children: [
                                            Expanded(
                                              child: InkWell(
                                                splashColor: Colors
                                                    .transparent,
                                                focusColor: Colors
                                                    .transparent,
                                                hoverColor: Colors
                                                    .transparent,
                                                highlightColor:
                                                    Colors
                                                        .transparent,
                                                onTap:
                                                    () async {
                                                  _model.exist5 =
                                                      await queryRespuestasRecordOnce(
                                                    parent: pageViewEncuestasRecord
                                                        .reference,
                                                    queryBuilder:
                                                        (respuestasRecord) =>
                                                            respuestasRecord.where(
                                                      'User_respuesta',
                                                      isEqualTo:
                                                          currentUserReference,
                                                    ),
                                                    singleRecord:
                                                        true,
                                                  ).then((s) =>
                                                          s.firstOrNull);
                                                  if (_model
                                                          .exist5
                                                          ?.reference ==
                                                      null) {
                                                    context
                                                        .pushNamed(
                                                      EncuestasParentsOpenWidget
                                                          .routeName,
                                                      queryParameters:
                                                          {
                                                        'encuesta':
                                                            serializeParam(
                                                          pageViewEncuestasRecord
                                                              .reference,
                                                          ParamType
                                                              .DocumentReference,
                                                        ),
                                                        'choice':
                                                            serializeParam(
                                                          'Encuestas',
                                                          ParamType
                                                              .String,
                                                        ),
                                                        'titulo':
                                                            serializeParam(
                                                          pageViewEncuestasRecord
                                                              .titulo,
                                                          ParamType
                                                              .String,
                                                        ),
                                                        'desc':
                                                            serializeParam(
                                                          pageViewEncuestasRecord
                                                              .descripcion,
                                                          ParamType
                                                              .String,
                                                        ),
                                                      }.withoutNulls,
                                                      extra: <String,
                                                          dynamic>{
                                                        '__transition_info__':
                                                            TransitionInfo(
                                                          hasTransition:
                                                              true,
                                                          transitionType:
                                                              PageTransitionType.fade,
                                                          duration:
                                                              Duration(milliseconds: 0),
                                                        ),
                                                      },
                                                    );
                                                  } else {
                                                    context
                                                        .pushNamed(
                                                      RespuestaParentsOpenWidget
                                                          .routeName,
                                                      queryParameters:
                                                          {
                                                        'encuestaRespuesta':
                                                            serializeParam(
                                                          _model
                                                              .exist5,
                                                          ParamType
                                                              .Document,
                                                        ),
                                                        'choice':
                                                            serializeParam(
                                                          'Respuesta',
                                                          ParamType
                                                              .String,
                                                        ),
                                                      }.withoutNulls,
                                                      extra: <String,
                                                          dynamic>{
                                                        'encuestaRespuesta':
                                                            _model.exist5,
                                                      },
                                                    );
                                                  }

                                                  safeSetState(
                                                      () {});
                                                },
                                                child:
                                                    Container(
                                                  width: double
                                                      .infinity,
                                                  decoration:
                                                      BoxDecoration(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryBackground,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16.0),
                                                  ),
                                                  child:
                                                      Padding(
                                                    padding:
                                                        EdgeInsets.all(
                                                            15.0),
                                                    child:
                                                        Column(
                                                      mainAxisSize:
                                                          MainAxisSize
                                                              .min,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                          height:
                                                              24.0,
                                                          decoration:
                                                              BoxDecoration(
                                                            color:
                                                                Color(0xFF265294),
                                                            borderRadius:
                                                                BorderRadius.circular(5.0),
                                                          ),
                                                          child:
                                                              Padding(
                                                            padding:
                                                                EdgeInsets.all(2.0),
                                                            child:
                                                                Text(
                                                              'Depresión',
                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                    font: GoogleFonts.inter(
                                                                      fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                    ),
                                                                    color: FlutterFlowTheme.of(context).primaryBackground,
                                                                    fontSize: 14.0,
                                                                    letterSpacing: 0.0,
                                                                    fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                  ),
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: EdgeInsetsDirectional.fromSTEB(
                                                              0.0,
                                                              8.0,
                                                              0.0,
                                                              8.0),
                                                          child:
                                                              Row(
                                                            mainAxisSize:
                                                                MainAxisSize.max,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Flexible(
                                                                child: Padding(
                                                                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 20.0, 0.0),
                                                                  child: Text(
                                                                    pageViewEncuestasRecord.descripcion,
                                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                          font: GoogleFonts.outfit(
                                                                            fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                          ),
                                                                          letterSpacing: 0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                          lineHeight: 1.2,
                                                                        ),
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
                                                                  Icons.keyboard_arrow_right,
                                                                  color: FlutterFlowTheme.of(context).primaryBackground,
                                                                  size: 20.0,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                  Align(
                                    alignment:
                                        AlignmentDirectional(
                                            0.0, 1.0),
                                    child: Padding(
                                      padding:
                                          EdgeInsetsDirectional
                                              .fromSTEB(
                                                  16.0,
                                                  0.0,
                                                  0.0,
                                                  16.0),
                                      child: smooth_page_indicator
                                          .SmoothPageIndicator(
                                        controller: _model
                                                .pageViewController2 ??=
                                            PageController(
                                                initialPage: max(
                                                    0,
                                                    min(
                                                        0,
                                                        pageViewEncuestasRecordList.length -
                                                            1))),
                                        count:
                                            pageViewEncuestasRecordList
                                                .length,
                                        axisDirection:
                                            Axis.horizontal,
                                        onDotClicked:
                                            (i) async {
                                          await _model
                                              .pageViewController2!
                                              .animateToPage(
                                            i,
                                            duration: Duration(
                                                milliseconds:
                                                    500),
                                            curve: Curves.ease,
                                          );
                                          safeSetState(() {});
                                        },
                                        effect: smooth_page_indicator
                                            .ExpandingDotsEffect(
                                          expansionFactor: 2.0,
                                          spacing: 8.0,
                                          radius: 16.0,
                                          dotWidth: 7.0,
                                          dotHeight: 8.0,
                                          dotColor:
                                              Color(0xFFD9D9D9),
                                          activeDotColor:
                                              Color(0xFF265294),
                                          paintStyle:
                                              PaintingStyle
                                                  .fill,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
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
            ...buildMainContentPart2(context),
          ],
        ),
      ),
    ),
  ),
);
  }
}
