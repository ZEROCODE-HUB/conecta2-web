part of 'register_continue2_widget.dart';

extension _RegisterContinue2Form2 on _RegisterContinue2WidgetState {
  List<Widget> buildFormPart2(BuildContext context) {
    return [
      Container(
        decoration: BoxDecoration(),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Grado de escolaridad',
                style: FlutterFlowTheme.of(context).labelSmall.override(
                      font: GoogleFonts.outfit(
                        fontWeight: FontWeight.w500,
                        fontStyle:
                            FlutterFlowTheme.of(context).labelSmall.fontStyle,
                      ),
                      fontSize: 16.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w500,
                      fontStyle:
                          FlutterFlowTheme.of(context).labelSmall.fontStyle,
                    ),
              ),
              Container(
                height: 47.0,
                decoration: BoxDecoration(),
                child: FlutterFlowDropDown<String>(
                  controller: _model.anioValueController ??=
                      FormFieldController<String>(
                    _model.anioValue ??=
                        FFAppState().detalleUsuarioTemp.detalle.grado,
                  ),
                  options: [
                    '1',
                    '2',
                    '3',
                    '4',
                    '5',
                    '6',
                    '7',
                    '8',
                    '9',
                    '10',
                    '11'
                  ],
                  onChanged: (val) =>
                      safeSetState(() => _model.anioValue = val),
                  width: MediaQuery.sizeOf(context).width * 1.0,
                  height: 40.0,
                  textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(
                          fontWeight: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                        letterSpacing: 0.0,
                        fontWeight:
                            FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                  hintText: 'Select...',
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
                  margin: EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
                  hidesUnderline: true,
                  isOverButton: false,
                  isSearchable: false,
                  isMultiSelect: false,
                ),
              ),
            ].divide(SizedBox(height: 10.0)),
          ),
        ),
      ),
      Container(
        decoration: BoxDecoration(),
      ),
      Container(
        decoration: BoxDecoration(),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'EPS',
                style: FlutterFlowTheme.of(context).labelSmall.override(
                      font: GoogleFonts.outfit(
                        fontWeight: FontWeight.w500,
                        fontStyle:
                            FlutterFlowTheme.of(context).labelSmall.fontStyle,
                      ),
                      fontSize: 16.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w500,
                      fontStyle:
                          FlutterFlowTheme.of(context).labelSmall.fontStyle,
                    ),
              ),
              Container(
                height: 47.0,
                decoration: BoxDecoration(),
                child: FlutterFlowDropDown<String>(
                  controller: _model.epsValueController ??=
                      FormFieldController<String>(
                    _model.epsValue ??=
                        FFAppState().detalleUsuarioTemp.detalle.eps,
                  ),
                  options: [
                    'ACOPI',
                    'AMBUQ',
                    'ANAWAYU',
                    'CAJACOPI',
                    'COMFACHOCO',
                    'COMFACOR',
                    'COMFAMILIAR',
                    'COMPENSAR',
                    'COOSALUD',
                    'DUSAKAWI A.R.S.I.',
                    'FAMILIAR',
                    'FAMISANAR',
                    'FERROCARRILES',
                    'MALLAMAS EPSI',
                    'MUTUAL SER',
                    'NUEVA EPS',
                    'SALUD TOTAL',
                    'SAVIA SALUD',
                    'SURA',
                    'NO AFILIADO',
                    'SIN EPS REGISTRADA'
                  ],
                  onChanged: (val) => safeSetState(() => _model.epsValue = val),
                  height: 40.0,
                  textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(
                          fontWeight: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                        letterSpacing: 0.0,
                        fontWeight:
                            FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                  hintText: 'Select...',
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
                  margin: EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
                  hidesUnderline: true,
                  isOverButton: false,
                  isSearchable: false,
                  isMultiSelect: false,
                ),
              ),
            ].divide(SizedBox(height: 10.0)),
          ),
        ),
      ),
      Container(
        decoration: BoxDecoration(),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Documento de identidad',
                style: FlutterFlowTheme.of(context).labelSmall.override(
                      font: GoogleFonts.outfit(
                        fontWeight: FontWeight.w500,
                        fontStyle:
                            FlutterFlowTheme.of(context).labelSmall.fontStyle,
                      ),
                      fontSize: 16.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w500,
                      fontStyle:
                          FlutterFlowTheme.of(context).labelSmall.fontStyle,
                    ),
              ),
              Container(
                height: 47.0,
                decoration: BoxDecoration(),
                child: Container(
                  width: MediaQuery.sizeOf(context).width * 1.0,
                  child: TextFormField(
                    controller: _model.textFieldDocTextController,
                    focusNode: _model.textFieldDocFocusNode,
                    autofocus: false,
                    enabled: true,
                    obscureText: false,
                    decoration: InputDecoration(
                      isDense: true,
                      labelStyle:
                          FlutterFlowTheme.of(context).labelMedium.override(
                                font: GoogleFonts.inter(
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .fontStyle,
                                ),
                                letterSpacing: 0.0,
                                fontWeight: FlutterFlowTheme.of(context)
                                    .labelMedium
                                    .fontWeight,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .labelMedium
                                    .fontStyle,
                              ),
                      hintText: 'Documento de identidad',
                      hintStyle:
                          FlutterFlowTheme.of(context).labelMedium.override(
                                font: GoogleFonts.inter(
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .fontStyle,
                                ),
                                fontSize: 14.0,
                                letterSpacing: 0.0,
                                fontWeight: FlutterFlowTheme.of(context)
                                    .labelMedium
                                    .fontWeight,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .labelMedium
                                    .fontStyle,
                              ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0x00000000),
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0x00000000),
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: FlutterFlowTheme.of(context).error,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: FlutterFlowTheme.of(context).error,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      filled: true,
                      fillColor:
                          FlutterFlowTheme.of(context).secondaryBackground,
                    ),
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.inter(
                            fontWeight: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                          fontSize: 12.0,
                          letterSpacing: 0.0,
                          fontWeight: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                    keyboardType: TextInputType.number,
                    cursorColor: FlutterFlowTheme.of(context).primaryText,
                    enableInteractiveSelection: true,
                    validator: _model.textFieldDocTextControllerValidator
                        .asValidator(context),
                  ),
                ),
              ),
            ].divide(SizedBox(height: 10.0)),
          ),
        ),
      ),
    ];
  }
}
