part of 'editarencuesta2_widget.dart';

extension _Editarencuesta2WidgetBuildSections2 on _Editarencuesta2WidgetState {
  Widget _buildTamizajesAlertsPanel(BuildContext context) {
    final categoria = widget.docencuestas2?.categoria ?? '';
    // Consumo de SPA -> per-substance alerts (legacy UI below).
    if (categoria == 'Consumo de SPA') {
      return _buildTamizajesAlertsPanelSustancias(context);
    }
    // Autoestima / CDI / Depresión Beck -> predefined global levels.
    if (usaNivelesGlobales(categoria)) {
      return _buildTamizajesAlertsPanelNiveles(context, categoria);
    }
    // CRQ / SRQ -> condition-based alerts (info card; the actual editor lives
    // in AlertasEspecialesConfig used by the modular editor). For the legacy
    // editor we render the substance-style panel so the user can still edit
    // min/max per level as a fallback.
    if (categoria == 'CRQ / SRQ' ||
        categoria == 'RQC / SRQ' ||
        categoria == 'RQC' ||
        categoria == 'SRQ' ||
        categoria == 'CRQ') {
      return _buildTamizajesAlertsPanelNiveles(context, categoria);
    }
    // Default: keep legacy Sustancias panel to stay backwards compatible.
    return _buildTamizajesAlertsPanelSustancias(context);
  }

  /// Predefined-levels panel (Autoestima / CDI / Beck / CRQ). Renders one
  /// row per level with min/max inputs persisted into
  /// `FFAppState().listaAlertasEnvio`.
  Widget _buildTamizajesAlertsPanelNiveles(
      BuildContext context, String categoria) {
    final tema = FlutterFlowTheme.of(context);
    final niveles = nivelesPorCategoria(categoria);

    // Ensure the app-state list has one entry per nivel for this category.
    final currentList = FFAppState().listaAlertasEnvio.toList();
    final mapByNivel = {for (final a in currentList) a.nivel: a};
    final rebuilt = <AlertaStruct>[];
    for (final nivel in niveles) {
      rebuilt.add(mapByNivel[nivel] ??
          AlertaStruct(min: 0, max: 0, sustancia: categoria, nivel: nivel));
    }
    // Keep any legacy entries not in the predefined set at the end (e.g.
    // per-substance entries from an older save).
    for (final a in currentList) {
      if (!niveles.contains(a.nivel)) rebuilt.add(a);
    }
    if (rebuilt.length != currentList.length ||
        !_sameOrder(rebuilt, currentList)) {
      FFAppState().listaAlertasEnvio = rebuilt;
    }

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(30.0, 20.0, 0.0, 0.0),
      child: Container(
        width: MediaQuery.sizeOf(context).width * 0.2,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              blurRadius: 50.0,
              color: Color(0x26000000),
              offset: Offset(20.0, 20.0),
            ),
          ],
          borderRadius: BorderRadius.circular(20.0),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              categoria == "SRQ"
                  ? "Puntuación psicométrica y subescalas"
                  : categoria == "CRQ" || categoria == "RQC"
                      ? "Escala de valoración"
                      : "Alertas — $categoria",
              style: tema.bodyMedium.override(
                font: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontStyle: tema.bodyMedium.fontStyle,
                ),
                fontSize: 16.0,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w600,
                fontStyle: tema.bodyMedium.fontStyle,
              ),
            ),
            const SizedBox(height: 6.0),
            Text(
              'Define el rango de puntaje para cada nivel.',
              style: tema.bodyMedium.override(
                font: GoogleFonts.inter(
                  fontWeight: FontWeight.w400,
                  fontStyle: tema.bodyMedium.fontStyle,
                ),
                color: const Color(0xFF9E8888),
                fontSize: 12.0,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w400,
                fontStyle: tema.bodyMedium.fontStyle,
              ),
            ),
            const SizedBox(height: 12.0),
            for (int i = 0; i < niveles.length; i++)
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        niveles[i],
                        style: tema.bodyMedium.override(
                          font: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                            fontStyle: tema.bodyMedium.fontStyle,
                          ),
                          color: const Color(0xFF265294),
                          fontSize: 14.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w500,
                          fontStyle: tema.bodyMedium.fontStyle,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Min', style: tema.bodyMedium),
                          TextFieldAlertaWidget(
                            key: Key('nivelAlertaMin_${i}_${niveles.length}'),
                            parameter1: FFAppState().listaAlertasEnvio[i].min,
                            accion: (nuevo) async {
                              FFAppState().updateListaAlertasEnvioAtIndex(
                                i,
                                (e) => e..min = nuevo,
                              );
                              safeSetState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Max', style: tema.bodyMedium),
                          TextFieldAlertaWidget(
                            key: Key('nivelAlertaMax_${i}_${niveles.length}'),
                            parameter1: FFAppState().listaAlertasEnvio[i].max,
                            accion: (nuevo) async {
                              FFAppState().updateListaAlertasEnvioAtIndex(
                                i,
                                (e) => e..max = nuevo,
                              );
                              safeSetState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            if (categoria == 'CRQ / SRQ' ||
                categoria == 'RQC / SRQ' ||
                categoria == 'CRQ' ||
                categoria == 'SRQ' ||
                categoria == 'RQC') ...[
              const SizedBox(height: 8.0),
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF4FB),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        size: 16.0, color: Color(0xFF265294)),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        'Las alertas especiales RQC/SRQ (Todas Sí, Al menos una Sí, etc.) '
                        'se configuran desde el editor modular.',
                        style: tema.bodyMedium.override(
                          font: GoogleFonts.inter(
                            fontWeight: FontWeight.w400,
                            fontStyle: tema.bodyMedium.fontStyle,
                          ),
                          color: const Color(0xFF265294),
                          fontSize: 11.5,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w400,
                          fontStyle: tema.bodyMedium.fontStyle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _sameOrder(List<AlertaStruct> a, List<AlertaStruct> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].nivel != b[i].nivel) return false;
    }
    return true;
  }

  /// Legacy per-substance alerts panel (Consumo de SPA).
  Widget _buildTamizajesAlertsPanelSustancias(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(30.0, 20.0, 0.0, 0.0),
      child: Container(
        width: MediaQuery.sizeOf(context).width * 0.2,
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
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Align(
              alignment: AlignmentDirectional(-1.0, 0.0),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 20.0, 0.0, 0.0),
                child: Text(
                  'Alertas',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                        fontSize: 16.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(4.0, 8.0, 0.0, 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    'Sustancia: ',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.inter(
                            fontWeight: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                          letterSpacing: 0.0,
                          fontWeight: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                  ),
                  FlutterFlowDropDown<String>(
                    controller: _model.dropDownSustancia2ValueController ??=
                        FormFieldController<String>(null),
                    options: [
                      'Tabaco',
                      'Bebidas alcohólicas',
                      'Cannabis',
                      'Anfetaminas',
                      'Inhalantes',
                      'Tranquilizantes',
                      'Alucinógenos',
                      'Opiáceos',
                      'Otros',
                      'Cocaina'
                    ],
                    onChanged: (val) => safeSetState(
                        () => _model.dropDownSustancia2Value = val),
                    width: 200.0,
                    height: 40.0,
                    textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.inter(
                            fontWeight: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                          letterSpacing: 0.0,
                          fontWeight: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                    hintText: 'Seleccione',
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: FlutterFlowTheme.of(context).secondaryText,
                      size: 24.0,
                    ),
                    fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                    elevation: 2.0,
                    borderColor: Colors.transparent,
                    borderWidth: 0.0,
                    borderRadius: 8.0,
                    margin:
                        EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
                    hidesUnderline: true,
                    isOverButton: false,
                    isSearchable: false,
                    isMultiSelect: false,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 16.0, 0.0),
              child: Text(
                'Configure los rangos de cada sustancia. Las sustancias '
                'que deje en 0 usarán los cortes ASSIST de la OMS '
                '(Alcohol: Bajo 0–10, Moderado 11–26, Alto 27+; resto: '
                'Bajo 0–3, Moderado 4–26, Alto 27+). En el nivel Alto, '
                'Max = 0 significa "sin tope".',
                style: FlutterFlowTheme.of(context).bodySmall.override(
                      font: GoogleFonts.inter(),
                      color: FlutterFlowTheme.of(context).secondaryText,
                      letterSpacing: 0.0,
                    ),
              ),
            ),
            Builder(
              builder: (context) {
                final listaAlertasSustancias =
                    FFAppState().listaAlertasEnvio.toList();

                return Column(
                  mainAxisSize: MainAxisSize.max,
                  children: List.generate(listaAlertasSustancias.length,
                      (listaAlertasSustanciasIndex) {
                    final listaAlertasSustanciasItem =
                        listaAlertasSustancias[listaAlertasSustanciasIndex];
                    return Visibility(
                      visible: listaAlertasSustanciasItem.sustancia ==
                          _model.dropDownSustancia2Value,
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            8.0, 20.0, 8.0, 16.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    listaAlertasSustanciasItem.nivel,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight: FontWeight.w500,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          fontSize: 18.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w500,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Min',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight: FontWeight.w500,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          fontSize: 18.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w500,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                  ),
                                  TextFieldAlertaWidget(
                                    key: Key(
                                        'Keyzdv_${listaAlertasSustanciasIndex}_of_${listaAlertasSustancias.length}'),
                                    parameter1: listaAlertasSustanciasItem.min,
                                    accion: (nuevoTexto) async {
                                      FFAppState()
                                          .updateListaAlertasEnvioAtIndex(
                                        listaAlertasSustanciasIndex,
                                        (e) => e..min = nuevoTexto,
                                      );
                                      safeSetState(() {});
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Max',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight: FontWeight.w500,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          fontSize: 18.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w500,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                  ),
                                  TextFieldAlertaWidget(
                                    key: Key(
                                        'Keyny2_${listaAlertasSustanciasIndex}_of_${listaAlertasSustancias.length}'),
                                    parameter1: listaAlertasSustanciasItem.max,
                                    accion: (nuevoTexto) async {
                                      FFAppState()
                                          .updateListaAlertasEnvioAtIndex(
                                        listaAlertasSustanciasIndex,
                                        (e) => e..max = nuevoTexto,
                                      );
                                      safeSetState(() {});
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ].divide(SizedBox(width: 8.0)),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ],
        ),
      ),
    );
  }


  bool get _esAssist =>
      (widget.docencuestas2?.categoria ?? '') == 'Consumo de SPA';

  /// ASSIST: valida los rangos por sustancia antes de guardar.
  bool _alertasAssistValidas(BuildContext context) {
    if (!_esAssist) return true;
    final errores = validarAlertasAssist(FFAppState().listaAlertasEnvio);
    if (errores.isEmpty) return true;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errores.length == 1
            ? 'Revise las alertas: ${errores.first}'
            : 'Revise las alertas: ${errores.first} '
                '(y ${errores.length - 1} más)'),
        backgroundColor: FlutterFlowTheme.of(context).error,
        duration: const Duration(seconds: 5),
      ),
    );
    return false;
  }

  List<AlertaStruct> _alertasParaGuardar() => _esAssist
      ? limpiarAlertasAssist(FFAppState().listaAlertasEnvio)
      : FFAppState().listaAlertasEnvio;

  List<Widget> _buildActionButtons(BuildContext context) {
    return [
      Padding(
        padding: EdgeInsetsDirectional.fromSTEB(0.0, 40.0, 0.0, 0.0),
        child: FFButtonWidget(
          onPressed: () async {
            final okTitulo = await _validarTituloUnico();
            if (!okTitulo) {
              return;
            }
            if (!_alertasAssistValidas(context)) {
              return;
            }
            await widget.encuestaID!.update({
              ..._payloadEncuestaRecord(
                publicado: true,
                titulo: _model.textController1.text,
                descripcion: _model.descTextController.text,
              ),
              ...mapToFirestore(
                {
                  'alertas': getAlertaListFirestoreData(
                    _alertasParaGuardar(),
                  ),
                  'alertasEspeciales': _model.alertasEspeciales
                      .map((a) => getAlertaEspecialFirestoreData(a, true))
                      .toList(),
                },
              ),
            });
            FFAppState().selectUser = 'VistaPrevia';
            FFAppState().createEncuesta = false;
            _model.updatePage(() {});
          },
          text: 'Vista Previa',
          options: FFButtonOptions(
            width: MediaQuery.sizeOf(context).width * 1.0,
            height: 54.0,
            padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
            iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
            color: FlutterFlowTheme.of(context).secondaryBackground,
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
                  fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                ),
            elevation: 3.0,
            borderSide: BorderSide(
              color: Color(0xFFF6BD33),
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(40.0),
          ),
        ),
      ),
      Padding(
        padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
        child: FFButtonWidget(
          onPressed: () async {
            final okTitulo = await _validarTituloUnico();
            if (!okTitulo) {
              return;
            }
            if (!_alertasAssistValidas(context)) {
              return;
            }
            await widget.encuestaID!.update({
              ..._payloadEncuestaRecord(
                publicado: true,
                titulo: _model.textController1.text,
                descripcion: _model.descTextController.text,
              ),
              ...mapToFirestore(
                {
                  'alertas': getAlertaListFirestoreData(
                    _alertasParaGuardar(),
                  ),
                  'alertasEspeciales': _model.alertasEspeciales
                      .map((a) => getAlertaEspecialFirestoreData(a, true))
                      .toList(),
                },
              ),
            });
            FFAppState().selectUser = '';
            safeSetState(() {});
          },
          text: 'Guardar como borrador',
          options: FFButtonOptions(
            width: MediaQuery.sizeOf(context).width * 1.0,
            height: 54.0,
            padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
            iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
            color: FlutterFlowTheme.of(context).secondaryBackground,
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
                  fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                ),
            elevation: 3.0,
            borderSide: BorderSide(
              color: Color(0xFFF6BD33),
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(40.0),
          ),
        ),
      ),
      Builder(
        builder: (context) => Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
          child: FFButtonWidget(
            onPressed: () async {
              final okTitulo = await _validarTituloUnico();
              if (!okTitulo) {
                return;
              }
              FFAppState().selectUser = '';
              safeSetState(() {
                widget.encuestaID!.update({
                  ..._payloadEncuestaRecord(
                    publicado: true,
                    titulo: _model.textController1.text,
                    descripcion: _model.descTextController.text,
                  ),
                  ...mapToFirestore({
                    'Preguntas': _model.preguntas
                        .map((p) => getPreguntasEncuestaFirestoreData(p, true))
                        .toList(),
                    'Roles': _model.roleValue,
                    'alertas': getAlertaListFirestoreData(
                        FFAppState().listaAlertasEnvio),
                    'alertasEspeciales': _model.alertasEspeciales
                        .map((a) => getAlertaEspecialFirestoreData(a, true))
                        .toList(),
                  }),
                });
              });

              await showDialog(
                context: context,
                builder: (dialogContext) {
                  return Dialog(
                    elevation: 0,
                    insetPadding: EdgeInsets.zero,
                    backgroundColor: Colors.transparent,
                    alignment: AlignmentDirectional(0.0, 0.0)
                        .resolve(Directionality.of(context)),
                    child: WebViewAware(
                      child: SuccesspopupWidget(),
                    ),
                  );
                },
              );
            },
            text: 'Publicar encuesta',
            options: FFButtonOptions(
              width: MediaQuery.sizeOf(context).width * 1.0,
              height: 54.0,
              padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
              iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
              color: Color(0xFFF6BD33),
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
                color: Color(0xFFF6BD33),
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(40.0),
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildAgregarPreguntasButton(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 40.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FFButtonWidget(
            onPressed: () async {
              bool isCRQ = _model.tipoValue == 'Tamizaje CRQ' ||
                  _model.tipoValue == 'Tamizaje RQC' ||
                  _model.tipoValue == 'Tamizaje SRQ' ||
                  _model.tipoValue == 'Tamizaje CRQ / SRQ' ||
                  _model.tipoValue == 'Tamizaje RQC / SRQ';
              int? finalNumPregunta;
              if (isCRQ) {
                int? numPregunta = int.tryParse(
                    _model.crqNumeroPreguntaTextController?.text ?? '');
                if (numPregunta == null || numPregunta <= 0) {
                  int maxNum = 0;
                  for (var p in _model.preguntas) {
                    if (p.numeroPregunta > maxNum) maxNum = p.numeroPregunta;
                  }
                  numPregunta = maxNum + 1;
                }
                if (_model.preguntas
                    .any((p) => p.numeroPregunta == numPregunta)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'El número de pregunta $numPregunta ya existe. Debe ser único.')),
                  );
                  return;
                }
                finalNumPregunta = numPregunta;
              }

              final esCDIoBeck = _model.tipoValue == 'Tamizaje CDI' ||
                  _model.tipoValue == 'Tamizajes Depresion Beck';
              List<AtributosStruct> finalRespuestaTamizaje = esCDIoBeck
                  ? List.from(_model.respuestaCDI)
                  : List.from(_model.respuestaTamizaje);
              if (isCRQ) {
                finalRespuestaTamizaje = [
                  createAtributosStruct(
                    etiqueta: 'Sí',
                    valor: int.tryParse(
                            _model.crqSiScoreTextController?.text ?? '') ??
                        0,
                    clearUnsetFields: false,
                  ),
                  createAtributosStruct(
                    etiqueta: 'No',
                    valor: int.tryParse(
                            _model.crqNoScoreTextController?.text ?? '') ??
                        0,
                    clearUnsetFields: false,
                  ),
                ];
              }

              final nuevaPregunta = createPreguntasEncuestaStruct(
                pregunta: _model.preguntaTextController?.text,
                tipo: _model.tipoValue,
                respuestaLarga: _model.abiertaTextController?.text,
                respuestaSUnicaCorrecta: _model.sunicarespValue,
                sustancia: _model.dropDownSustanciaValue,
                ocultarRespuesta: _model.ocultarRespuestaValue,
                nPregunta: _model.checkboxNPValue1 == true ? 1 : 0,
                numeroPregunta: isCRQ ? (finalNumPregunta ?? 0) : 0,
                variable: isCRQ ? 'CRQ' : (_model.variableCDIValue ?? ''),
                fieldValues: {
                  'RespuestaSelection': _model.respuestaSelection,
                  'RespuestasSeleccionUnica': _model.seleccionunica,
                  'RespuestaCondicionante':
                      getValorCondicionanteListFirestoreData(
                          _model.respuestaCondicionante),
                  'RespuestaTamizaje':
                      getAtributosListFirestoreData(finalRespuestaTamizaje),
                },
                clearUnsetFields: false,
              );
              nuevaPregunta.respuestaTamizaje = finalRespuestaTamizaje;
              nuevaPregunta.respuestaSelection = List.from(_model.respuestaSelection);
              nuevaPregunta.respuestasSeleccionUnica = List.from(_model.seleccionunica);
              nuevaPregunta.respuestaCondicionante = List.from(_model.respuestaCondicionante);

              safeSetState(() {
                _model.addToPreguntas(nuevaPregunta);
              });
              _model.respuestaSelection = [];
              _model.seleccionunicarespuesta = null;
              _model.seleccionunica = [];
              _model.respuestaTamizaje = [];
              _model.respuestaCondicionante = [];
              _model.respuestaCDI = [];
              _model.variableCDI = null;
              _model.variableCDIValue = null;
              _model.ideacionSuicidaValue = false;
              safeSetState(() {});
              safeSetState(() {
                _model.dropDownSustanciaValueController?.value = null;
                _model.dropDownSustanciaValue = null;
                _model.variableCDIValueController?.value = null;
              });
              safeSetState(() {
                _model.ocultarRespuestaValue = false;
                _model.checkboxNPValue1 = false;
              });
              safeSetState(() {
                _model.preguntaTextController?.clear();
                _model.abiertaTextController?.clear();
                _model.cdiTextController?.clear();
                _model.cdiValorTextController?.clear();
                _model.crqNumeroPreguntaTextController?.clear();
                _model.crqSiScoreTextController?.clear();
                _model.crqNoScoreTextController?.clear();
                _model.autoestimaEtiquetaTextController?.clear();
                _model.autoestimaValorTextController?.clear();
                _model.tipoValue = null;
                _model.tipoValueController?.value = null;
              });
            },
            text: 'Agregar preguntas',
            options: FFButtonOptions(
              height: 40.0,
              padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
              iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
              color: FlutterFlowTheme.of(context).secondaryBackground,
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
                color: Color(0xFFF6BD33),
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(40.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTamizajesAlertsEspecialesPanel(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(30.0, 16.0, 0.0, 0.0),
      child: Container(
        width: MediaQuery.sizeOf(context).width * 0.2,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              blurRadius: 50.0,
              color: Color(0x26000000),
              offset: Offset(20.0, 20.0),
            )
          ],
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 15.0),
                child: Text(
                  'Alertas Especiales RQC/SRQ',
                  style: tema.bodyMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontStyle: tema.bodyMedium.fontStyle,
                    ),
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextFormField(
                controller: _model.alertaEspecialNombreTextController ??=
                    TextEditingController(),
                focusNode: _model.alertaEspecialNombreFocusNode ??= FocusNode(),
                autofocus: false,
                obscureText: false,
                decoration: InputDecoration(
                  hintText: 'Nombre de la alerta',
                  hintStyle: tema.labelMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight: tema.labelMedium.fontWeight,
                      fontStyle: tema.labelMedium.fontStyle,
                    ),
                    color: const Color(0xFF9E8888),
                    fontSize: 14.0,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: tema.alternate,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: tema.primary,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: tema.error,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: tema.error,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  filled: true,
                  fillColor: tema.primaryBackground,
                ),
                style: tema.bodyMedium.override(
                  font: GoogleFonts.inter(
                    fontWeight: tema.bodyMedium.fontWeight,
                    fontStyle: tema.bodyMedium.fontStyle,
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
                child: FlutterFlowDropDown<String>(
                  controller: _model.alertaEspecialCondicionValueController ??=
                      FormFieldController<String>(null),
                  options: const [
                    'Todas en Sí',
                    'Al menos una en Sí',
                    'Al menos dos en Sí',
                    'Todas en No',
                    'Al menos una en No',
                    'Al menos dos en No',
                    'Puntaje igual a'
                  ],
                  onChanged: (val) {
                    _model.alertaEspecialCondicionValue = val;
                    safeSetState(() {});
                  },
                  width: double.infinity,
                  height: 44.0,
                  textStyle: tema.bodyMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight: tema.bodyMedium.fontWeight,
                      fontStyle: tema.bodyMedium.fontStyle,
                    ),
                  ),
                  hintText: 'Condición...',
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: tema.secondaryText,
                    size: 24.0,
                  ),
                  fillColor: tema.secondaryBackground,
                  elevation: 2.0,
                  borderColor: Colors.transparent,
                  borderWidth: 0.0,
                  borderRadius: 8.0,
                  margin: const EdgeInsetsDirectional.fromSTEB(
                      12.0, 0.0, 12.0, 0.0),
                  hidesUnderline: true,
                  isOverButton: false,
                  isSearchable: false,
                  isMultiSelect: false,
                ),
              ),
              if (_model.alertaEspecialCondicionValue == 'Puntaje igual a')
                Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
                  child: TextFormField(
                    controller: _model.alertaEspecialPuntajeTextController ??=
                        TextEditingController(),
                    focusNode: _model.alertaEspecialPuntajeFocusNode ??=
                        FocusNode(),
                    autofocus: false,
                    keyboardType: TextInputType.number,
                    obscureText: false,
                    decoration: InputDecoration(
                      hintText: 'Puntaje',
                      hintStyle: tema.labelMedium.override(
                        font: GoogleFonts.inter(
                          fontWeight: tema.labelMedium.fontWeight,
                          fontStyle: tema.labelMedium.fontStyle,
                        ),
                        color: const Color(0xFF9E8888),
                        fontSize: 14.0,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: tema.alternate,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: tema.primary,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: tema.error,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: tema.error,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      filled: true,
                      fillColor: tema.primaryBackground,
                    ),
                    style: tema.bodyMedium.override(
                      font: GoogleFonts.inter(
                        fontWeight: tema.bodyMedium.fontWeight,
                        fontStyle: tema.bodyMedium.fontStyle,
                      ),
                    ),
                  ),
                ),
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
                child: TextFormField(
                  controller: _model.alertaEspecialPreguntasTextController ??=
                      TextEditingController(),
                  focusNode: _model.alertaEspecialPreguntasFocusNode ??=
                      FocusNode(),
                  autofocus: false,
                  obscureText: false,
                  decoration: InputDecoration(
                    hintText: 'Números de pregunta (ej: 1, 2, 11)',
                    hintStyle: tema.labelMedium.override(
                      font: GoogleFonts.inter(
                        fontWeight: tema.labelMedium.fontWeight,
                        fontStyle: tema.labelMedium.fontStyle,
                      ),
                      color: const Color(0xFF9E8888),
                      fontSize: 14.0,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: tema.alternate,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: tema.primary,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: tema.error,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: tema.error,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    filled: true,
                    fillColor: tema.primaryBackground,
                  ),
                  style: tema.bodyMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight: tema.bodyMedium.fontWeight,
                      fontStyle: tema.bodyMedium.fontStyle,
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: FFButtonWidget(
                    onPressed: () async {
                      if (_model.alertaEspecialNombreTextController?.text
                                  .isNotEmpty ==
                              true &&
                          _model.alertaEspecialCondicionValue != null) {
                        final preguntasRaw = _model
                                .alertaEspecialPreguntasTextController?.text ??
                            '';
                        final List<int> preguntasParsed = preguntasRaw
                            .split(',')
                            .map((s) => int.tryParse(s.trim()))
                            .where((v) => v != null)
                            .cast<int>()
                            .toList();
                        final nuevaAlerta = createAlertaEspecialStruct(
                          nombre:
                              _model.alertaEspecialNombreTextController?.text ??
                                  '',
                          condicion: _model.alertaEspecialCondicionValue ?? '',
                          puntaje: int.tryParse(_model
                                      .alertaEspecialPuntajeTextController
                                      ?.text ??
                                  '') ??
                              0,
                          clearUnsetFields: false,
                        );
                        nuevaAlerta.preguntas = preguntasParsed;
                        _model.addToAlertasEspeciales(nuevaAlerta);
                        _model.alertaEspecialNombreTextController?.clear();
                        _model.alertaEspecialCondicionValueController?.value =
                            null;
                        _model.alertaEspecialCondicionValue = null;
                        _model.alertaEspecialPuntajeTextController?.clear();
                        _model.alertaEspecialPreguntasTextController?.clear();
                        safeSetState(() {});
                      }
                    },
                    text: 'Agregar alerta especial',
                    options: FFButtonOptions(
                      height: 34.0,
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          14.0, 0.0, 14.0, 0.0),
                      color: const Color(0xFF265294),
                      textStyle: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
              if (_model.alertasEspeciales.isNotEmpty)
                Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alertas especiales guardadas',
                        style: tema.bodyMedium.override(
                          font: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                            fontStyle: tema.bodyMedium.fontStyle,
                          ),
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      ...List.generate(_model.alertasEspeciales.length, (idx) {
                        final alerta = _model.alertasEspeciales[idx];
                        return Container(
                          margin: const EdgeInsets.only(top: 8.0),
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: tema.primaryBackground,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      alerta.nombre,
                                      style: tema.bodyMedium.override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                          fontStyle: tema.bodyMedium.fontStyle,
                                        ),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      alerta.condicion +
                                          (alerta.condicion == 'Puntaje igual a'
                                              ? ': ${alerta.puntaje}'
                                              : ''),
                                      style: tema.bodyMedium.override(
                                        font: GoogleFonts.inter(
                                          fontWeight:
                                              tema.bodyMedium.fontWeight,
                                          fontStyle: tema.bodyMedium.fontStyle,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                  size: 20.0,
                                ),
                                onPressed: () {
                                  _model
                                      .removeAtIndexFromAlertasEspeciales(idx);
                                  safeSetState(() {});
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
