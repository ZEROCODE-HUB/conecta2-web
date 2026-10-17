part of 'register_continue2_widget.dart';

extension _RegisterContinue2Form on _RegisterContinue2WidgetState {
  Widget buildForm(BuildContext context) {
    return Padding(
  padding:
      EdgeInsetsDirectional.fromSTEB(0.0, 40.0, 0.0, 0.0),
  child: Container(
    width: double.infinity,
    decoration: BoxDecoration(),
    child: Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Datos personales',
          style: FlutterFlowTheme.of(context)
              .labelSmall
              .override(
                font: GoogleFonts.outfit(
                  fontWeight: FontWeight.w600,
                  fontStyle: FlutterFlowTheme.of(context)
                      .labelSmall
                      .fontStyle,
                ),
                fontSize: 16.0,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w600,
                fontStyle: FlutterFlowTheme.of(context)
                    .labelSmall
                    .fontStyle,
              ),
        ),
        Container(
          width: MediaQuery.sizeOf(context).width * 1.0,
          decoration: BoxDecoration(),
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
                0.0, 20.0, 0.0, 0.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Fecha de nacimiento',
                  style: FlutterFlowTheme.of(context)
                      .labelSmall
                      .override(
                        font: GoogleFonts.outfit(
                          fontWeight: FontWeight.w500,
                          fontStyle:
                              FlutterFlowTheme.of(context)
                                  .labelSmall
                                  .fontStyle,
                        ),
                        fontSize: 16.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w500,
                        fontStyle:
                            FlutterFlowTheme.of(context)
                                .labelSmall
                                .fontStyle,
                      ),
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    final _datePickedDate =
                        await showDatePicker(
                      context: context,
                      initialDate: getCurrentTimestamp,
                      firstDate: DateTime(1900),
                      lastDate: getCurrentTimestamp,
                      builder: (context, child) {
                        return wrapInMaterialDatePickerTheme(
                          context,
                          child!,
                          headerBackgroundColor:
                              FlutterFlowTheme.of(context)
                                  .primary,
                          headerForegroundColor:
                              FlutterFlowTheme.of(context)
                                  .info,
                          headerTextStyle:
                              FlutterFlowTheme.of(context)
                                  .headlineLarge
                                  .override(
                                    font:
                                        GoogleFonts.inter(
                                      fontWeight:
                                          FontWeight.w600,
                                      fontStyle:
                                          FlutterFlowTheme.of(
                                                  context)
                                              .headlineLarge
                                              .fontStyle,
                                    ),
                                    fontSize: 32.0,
                                    letterSpacing: 0.0,
                                    fontWeight:
                                        FontWeight.w600,
                                    fontStyle:
                                        FlutterFlowTheme.of(
                                                context)
                                            .headlineLarge
                                            .fontStyle,
                                  ),
                          pickerBackgroundColor:
                              FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                          pickerForegroundColor:
                              FlutterFlowTheme.of(context)
                                  .primaryText,
                          selectedDateTimeBackgroundColor:
                              FlutterFlowTheme.of(context)
                                  .secondary,
                          selectedDateTimeForegroundColor:
                              FlutterFlowTheme.of(context)
                                  .info,
                          actionButtonForegroundColor:
                              FlutterFlowTheme.of(context)
                                  .primaryText,
                          iconSize: 24.0,
                        );
                      },
                    );

                    if (_datePickedDate != null) {
                      safeSetState(() {
                        _model.datePicked = DateTime(
                          _datePickedDate.year,
                          _datePickedDate.month,
                          _datePickedDate.day,
                        );
                      });
                    } else if (_model.datePicked !=
                        null) {
                      safeSetState(() {
                        _model.datePicked =
                            getCurrentTimestamp;
                      });
                    }
                  },
                  child: Container(
                    width:
                        MediaQuery.sizeOf(context).width *
                            1.0,
                    height: 47.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context)
                          .secondaryBackground,
                      borderRadius:
                          BorderRadius.circular(10.0),
                    ),
                    child: Align(
                      alignment:
                          AlignmentDirectional(-1.0, 0.0),
                      child: Padding(
                        padding: EdgeInsetsDirectional
                            .fromSTEB(
                                10.0, 0.0, 0.0, 0.0),
                        child: Text(
                          valueOrDefault<String>(
                            dateTimeFormat(
                              "yMd",
                              _model.datePicked,
                              locale: FFLocalizations.of(
                                      context)
                                  .languageCode,
                            ),
                            'Seleccione fecha',
                          ),
                          style:
                              FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font:
                                        GoogleFonts.inter(
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
                                    fontSize: 14.0,
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
                  ),
                ),
              ].divide(SizedBox(height: 10.0)),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(),
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
                0.0, 20.0, 0.0, 0.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Género',
                  style: FlutterFlowTheme.of(context)
                      .labelSmall
                      .override(
                        font: GoogleFonts.outfit(
                          fontWeight: FontWeight.w500,
                          fontStyle:
                              FlutterFlowTheme.of(context)
                                  .labelSmall
                                  .fontStyle,
                        ),
                        fontSize: 16.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w500,
                        fontStyle:
                            FlutterFlowTheme.of(context)
                                .labelSmall
                                .fontStyle,
                      ),
                ),
                FlutterFlowDropDown<String>(
                  controller: _model
                          .dropDownGeneroValueController ??=
                      FormFieldController<String>(
                    _model.dropDownGeneroValue ??=
                        FFAppState()
                            .detalleUsuarioTemp
                            .detalle
                            .genero,
                  ),
                  options: kListaGeneros,
                  onChanged: (val) => safeSetState(() =>
                      _model.dropDownGeneroValue = val),
                  width:
                      MediaQuery.sizeOf(context).width *
                          1.0,
                  height: 40.0,
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
                  hintText: 'Selecciona...',
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: FlutterFlowTheme.of(context)
                        .secondaryText,
                    size: 24.0,
                  ),
                  fillColor: FlutterFlowTheme.of(context)
                      .secondaryBackground,
                  elevation: 2.0,
                  borderColor: Colors.transparent,
                  borderWidth: 0.0,
                  borderRadius: 8.0,
                  margin: EdgeInsetsDirectional.fromSTEB(
                      12.0, 0.0, 12.0, 0.0),
                  hidesUnderline: true,
                  isOverButton: false,
                  isSearchable: false,
                  isMultiSelect: false,
                ),
              ].divide(SizedBox(height: 10.0)),
            ),
          ),
        ),
        StreamBuilder<List<ColegiosRecord>>(
          stream: queryColegiosRecord(),
          builder: (context, snapshot) {
            // Customize what your widget looks like when it's loading.
            if (!snapshot.hasData) {
              return Center(
                child: SizedBox(
                  width: 50.0,
                  height: 50.0,
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(
                      FlutterFlowTheme.of(context)
                          .primary,
                    ),
                  ),
                ),
              );
            }
            List<ColegiosRecord> cardColegiosRecordList =
                snapshot.data!;

            return Container(
              decoration: BoxDecoration(),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(
                    0.0, 20.0, 0.0, 0.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Colegio',
                      style: FlutterFlowTheme.of(context)
                          .labelSmall
                          .override(
                            font: GoogleFonts.outfit(
                              fontWeight: FontWeight.w500,
                              fontStyle:
                                  FlutterFlowTheme.of(
                                          context)
                                      .labelSmall
                                      .fontStyle,
                            ),
                            fontSize: 16.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w500,
                            fontStyle:
                                FlutterFlowTheme.of(
                                        context)
                                    .labelSmall
                                    .fontStyle,
                          ),
                    ),
                    Container(
                      height: 47.0,
                      decoration: BoxDecoration(),
                      child: FlutterFlowDropDown<String>(
                        controller: _model
                                .textFieldColegioValueController ??=
                            FormFieldController<String>(
                          _model.textFieldColegioValue ??=
                              FFAppState()
                                  .detalleUsuarioTemp
                                  .detalle
                                  .colegio,
                        ),
                        options: cardColegiosRecordList
                            .map((e) => e.nombre)
                            .toList(),
                        onChanged: (val) => safeSetState(
                            () => _model
                                    .textFieldColegioValue =
                                val),
                        width: MediaQuery.sizeOf(context)
                                .width *
                            1.0,
                        height: 40.0,
                        searchHintTextStyle:
                            FlutterFlowTheme.of(context)
                                .labelMedium
                                .override(
                                  font: GoogleFonts.inter(
                                    fontWeight:
                                        FlutterFlowTheme.of(
                                                context)
                                            .labelMedium
                                            .fontWeight,
                                    fontStyle:
                                        FlutterFlowTheme.of(
                                                context)
                                            .labelMedium
                                            .fontStyle,
                                  ),
                                  letterSpacing: 0.0,
                                  fontWeight:
                                      FlutterFlowTheme.of(
                                              context)
                                          .labelMedium
                                          .fontWeight,
                                  fontStyle:
                                      FlutterFlowTheme.of(
                                              context)
                                          .labelMedium
                                          .fontStyle,
                                ),
                        searchTextStyle:
                            FlutterFlowTheme.of(context)
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
                        textStyle:
                            FlutterFlowTheme.of(context)
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
                        hintText: 'Selecciona...',
                        searchHintText: 'Buscar...',
                        icon: Icon(
                          Icons
                              .keyboard_arrow_down_rounded,
                          color:
                              FlutterFlowTheme.of(context)
                                  .secondaryText,
                          size: 24.0,
                        ),
                        fillColor:
                            FlutterFlowTheme.of(context)
                                .secondaryBackground,
                        elevation: 2.0,
                        borderColor: Colors.transparent,
                        borderWidth: 0.0,
                        borderRadius: 8.0,
                        margin: EdgeInsetsDirectional
                            .fromSTEB(
                                12.0, 0.0, 12.0, 0.0),
                        hidesUnderline: true,
                        isOverButton: false,
                        isSearchable: true,
                        isMultiSelect: false,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(),
                          child: Padding(
                            padding: EdgeInsetsDirectional
                                .fromSTEB(
                                    0.0, 20.0, 0.0, 0.0),
                            child: Column(
                              mainAxisSize:
                                  MainAxisSize.max,
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Text(
                                  'Municipio',
                                  style: FlutterFlowTheme
                                          .of(context)
                                      .labelSmall
                                      .override(
                                        font: GoogleFonts
                                            .outfit(
                                          fontWeight:
                                              FontWeight
                                                  .w500,
                                          fontStyle: FlutterFlowTheme.of(
                                                  context)
                                              .labelSmall
                                              .fontStyle,
                                        ),
                                        fontSize: 16.0,
                                        letterSpacing:
                                            0.0,
                                        fontWeight:
                                            FontWeight
                                                .w500,
                                        fontStyle:
                                            FlutterFlowTheme.of(
                                                    context)
                                                .labelSmall
                                                .fontStyle,
                                      ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.sizeOf(
                                                  context)
                                              .width *
                                          0.4,
                                  height: 40.0,
                                  decoration:
                                      BoxDecoration(
                                    color: FlutterFlowTheme
                                            .of(context)
                                        .secondaryBackground,
                                  ),
                                  child: Align(
                                    alignment:
                                        AlignmentDirectional(
                                            -1.0, 0.0),
                                    child: Padding(
                                      padding:
                                          EdgeInsetsDirectional
                                              .fromSTEB(
                                                  4.0,
                                                  0.0,
                                                  0.0,
                                                  0.0),
                                      child: Text(
                                        valueOrDefault<
                                            String>(
                                          cardColegiosRecordList
                                              .where((e) =>
                                                  _model
                                                      .textFieldColegioValue ==
                                                  e.nombre)
                                              .toList()
                                              .firstOrNull
                                              ?.municipio,
                                          '-',
                                        ),
                                        style: FlutterFlowTheme
                                                .of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts
                                                  .inter(
                                                fontWeight: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .fontWeight,
                                                fontStyle: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .fontStyle,
                                              ),
                                              letterSpacing:
                                                  0.0,
                                              fontWeight: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .fontWeight,
                                              fontStyle: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .fontStyle,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              ].divide(
                                  SizedBox(height: 10.0)),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(),
                          child: Padding(
                            padding: EdgeInsetsDirectional
                                .fromSTEB(
                                    0.0, 20.0, 0.0, 0.0),
                            child: Column(
                              mainAxisSize:
                                  MainAxisSize.max,
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Text(
                                  'Barrio',
                                  style: FlutterFlowTheme
                                          .of(context)
                                      .labelSmall
                                      .override(
                                        font: GoogleFonts
                                            .outfit(
                                          fontWeight:
                                              FontWeight
                                                  .w500,
                                          fontStyle: FlutterFlowTheme.of(
                                                  context)
                                              .labelSmall
                                              .fontStyle,
                                        ),
                                        fontSize: 16.0,
                                        letterSpacing:
                                            0.0,
                                        fontWeight:
                                            FontWeight
                                                .w500,
                                        fontStyle:
                                            FlutterFlowTheme.of(
                                                    context)
                                                .labelSmall
                                                .fontStyle,
                                      ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.sizeOf(
                                                  context)
                                              .width *
                                          0.4,
                                  height: 40.0,
                                  decoration:
                                      BoxDecoration(
                                    color: FlutterFlowTheme
                                            .of(context)
                                        .secondaryBackground,
                                  ),
                                  child: Align(
                                    alignment:
                                        AlignmentDirectional(
                                            -1.0, 0.0),
                                    child: Padding(
                                      padding:
                                          EdgeInsetsDirectional
                                              .fromSTEB(
                                                  4.0,
                                                  0.0,
                                                  0.0,
                                                  0.0),
                                      child: Text(
                                        valueOrDefault<
                                            String>(
                                          cardColegiosRecordList
                                              .where((e) =>
                                                  _model
                                                      .textFieldColegioValue ==
                                                  e.nombre)
                                              .toList()
                                              .firstOrNull
                                              ?.barrio,
                                          '-',
                                        ),
                                        style: FlutterFlowTheme
                                                .of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts
                                                  .inter(
                                                fontWeight: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .fontWeight,
                                                fontStyle: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .fontStyle,
                                              ),
                                              letterSpacing:
                                                  0.0,
                                              fontWeight: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .fontWeight,
                                              fontStyle: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .fontStyle,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              ].divide(
                                  SizedBox(height: 10.0)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ].divide(SizedBox(height: 10.0)),
                ),
              ),
            );
          },
        ),
        ...buildFormPart2(context),
      ],
    ),
  ),
);
  }
}
