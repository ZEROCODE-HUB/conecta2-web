part of 'edit_profile_parents_widget.dart';

extension _EditProfileParentsFormSections on _EditProfileParentsWidgetState {
  List<Widget> buildFormSections(BuildContext context) {
    return [
                Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                          0.0, 24.0, 0.0, 0.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            'Nombres y apelidos',
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
                                      FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                  fontStyle:
                                      FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(
                                    0.0, 8.0, 0.0, 0.0),
                            child: Container(
                              height: 47.0,
                              decoration: BoxDecoration(),
                              child: TextFormField(
                                controller: _model
                                    .textFieldnameTextController,
                                focusNode:
                                    _model.textFieldnameFocusNode,
                                autofocus: false,
                                obscureText: false,
                                decoration: InputDecoration(
                                  labelStyle: FlutterFlowTheme.of(
                                          context)
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
                                        color:
                                            FlutterFlowTheme.of(
                                                    context)
                                                .primaryText,
                                        fontSize: 14.0,
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
                                  hintText: 'Nombres y Apellidos',
                                  hintStyle: FlutterFlowTheme.of(
                                          context)
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
                                        color: Color(0x7C1F2129),
                                        fontSize: 16.0,
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
                                  enabledBorder:
                                      OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(
                                              context)
                                          .alternate,
                                      width: 2.0,
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(
                                            8.0),
                                  ),
                                  focusedBorder:
                                      OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(
                                              context)
                                          .primary,
                                      width: 2.0,
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(
                                            8.0),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(
                                              context)
                                          .error,
                                      width: 2.0,
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(
                                            8.0),
                                  ),
                                  focusedErrorBorder:
                                      OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(
                                              context)
                                          .error,
                                      width: 2.0,
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(
                                            8.0),
                                  ),
                                  filled: true,
                                ),
                                style:
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
                                validator: _model
                                    .textFieldnameTextControllerValidator
                                    .asValidator(context),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                          0.0, 24.0, 0.0, 0.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            'Correo electrónico',
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
                                      FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                  fontStyle:
                                      FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(
                                    0.0, 8.0, 0.0, 0.0),
                            child: Container(
                              height: 47.0,
                              decoration: BoxDecoration(),
                              child: TextFormField(
                                controller: _model
                                    .textFieldemailTextController,
                                focusNode: _model
                                    .textFieldemailFocusNode,
                                autofocus: false,
                                obscureText: false,
                                decoration: InputDecoration(
                                  labelStyle: FlutterFlowTheme.of(
                                          context)
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
                                        color:
                                            FlutterFlowTheme.of(
                                                    context)
                                                .primaryText,
                                        fontSize: 14.0,
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
                                  hintText: 'Correo electrónico',
                                  hintStyle: FlutterFlowTheme.of(
                                          context)
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
                                        color: Color(0x7C1F2129),
                                        fontSize: 16.0,
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
                                  enabledBorder:
                                      OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(
                                              context)
                                          .alternate,
                                      width: 2.0,
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(
                                            8.0),
                                  ),
                                  focusedBorder:
                                      OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(
                                              context)
                                          .primary,
                                      width: 2.0,
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(
                                            8.0),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(
                                              context)
                                          .error,
                                      width: 2.0,
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(
                                            8.0),
                                  ),
                                  focusedErrorBorder:
                                      OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(
                                              context)
                                          .error,
                                      width: 2.0,
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(
                                            8.0),
                                  ),
                                  filled: true,
                                ),
                                style:
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
                                validator: _model
                                    .textFieldemailTextControllerValidator
                                    .asValidator(context),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                          0.0, 24.0, 0.0, 0.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            'Celular',
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
                                      FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                  fontStyle:
                                      FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(
                                    0.0, 8.0, 0.0, 0.0),
                            child: Container(
                              height: 47.0,
                              decoration: BoxDecoration(),
                              child: TextFormField(
                                controller: _model
                                    .textFieldcelularTextController,
                                focusNode: _model
                                    .textFieldcelularFocusNode,
                                autofocus: false,
                                obscureText: false,
                                decoration: InputDecoration(
                                  labelStyle: FlutterFlowTheme.of(
                                          context)
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
                                        color:
                                            FlutterFlowTheme.of(
                                                    context)
                                                .primaryText,
                                        fontSize: 14.0,
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
                                  hintText: 'Celular',
                                  hintStyle: FlutterFlowTheme.of(
                                          context)
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
                                        color: Color(0x7C1F2129),
                                        fontSize: 16.0,
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
                                  enabledBorder:
                                      OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(
                                              context)
                                          .alternate,
                                      width: 2.0,
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(
                                            8.0),
                                  ),
                                  focusedBorder:
                                      OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(
                                              context)
                                          .primary,
                                      width: 2.0,
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(
                                            8.0),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(
                                              context)
                                          .error,
                                      width: 2.0,
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(
                                            8.0),
                                  ),
                                  focusedErrorBorder:
                                      OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(
                                              context)
                                          .error,
                                      width: 2.0,
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(
                                            8.0),
                                  ),
                                  filled: true,
                                ),
                                style:
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
                                validator: _model
                                    .textFieldcelularTextControllerValidator
                                    .asValidator(context),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
      _buildGeneroYFecha(context),
      ...buildFormSections2(context),
    ];
  }

  Widget _buildGeneroYFecha(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
          child: Row(mainAxisSize: MainAxisSize.max, children: [
            Text('Género',
                style: theme.bodyMedium.override(
                    font: GoogleFonts.outfit(), letterSpacing: 0.0)),
          ]),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
          child: Row(mainAxisSize: MainAxisSize.max, children: [
            Expanded(
              child: InkWell(
                onTap: () async {
                  final selected = await showModalBottomSheet<String>(
                    context: context,
                    builder: (ctx) => SafeArea(
                      child: Wrap(
                        children: const [
                          'Masculino',
                          'Femenino',
                          'Otro',
                          'Prefiero no decirlo',
                        ]
                            .map((g) => ListTile(
                                  title: Text(g),
                                  onTap: () => Navigator.of(ctx).pop(g),
                                ))
                            .toList(),
                      ),
                    ),
                  );
                  if (selected != null) {
                    safeSetState(() => _generoSeleccionado = selected);
                  }
                },
                child: Container(
                  height: 47.0,
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: theme.alternate, width: 2.0),
                    borderRadius: BorderRadius.circular(8.0),
                    color: theme.secondaryBackground,
                  ),
                  child: Row(children: [
                    Expanded(
                      child: Text(
                        _generoSeleccionado ?? 'Selecciona género',
                        style: theme.bodyMedium.override(
                          color: _generoSeleccionado == null
                              ? const Color(0x7C1F2129)
                              : null,
                          fontSize: 14.0,
                          letterSpacing: 0.0,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_drop_down,
                        color: theme.secondaryText),
                  ]),
                ),
              ),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
          child: Row(mainAxisSize: MainAxisSize.max, children: [
            Text('Fecha de nacimiento',
                style: theme.bodyMedium.override(
                    font: GoogleFonts.outfit(), letterSpacing: 0.0)),
          ]),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
          child: Row(mainAxisSize: MainAxisSize.max, children: [
            Expanded(
              child: InkWell(
                onTap: () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _fechaNacimiento ??
                        DateTime(now.year - 30, now.month, now.day),
                    firstDate: DateTime(1940),
                    lastDate: now,
                  );
                  if (picked != null) {
                    safeSetState(() => _fechaNacimiento = picked);
                  }
                },
                child: Container(
                  height: 47.0,
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: theme.alternate, width: 2.0),
                    borderRadius: BorderRadius.circular(8.0),
                    color: theme.secondaryBackground,
                  ),
                  child: Row(children: [
                    Expanded(
                      child: Text(
                        _fechaNacimiento == null
                            ? 'Selecciona fecha'
                            : '${_fechaNacimiento!.day.toString().padLeft(2, '0')}/'
                                '${_fechaNacimiento!.month.toString().padLeft(2, '0')}/'
                                '${_fechaNacimiento!.year}',
                        style: theme.bodyMedium.override(
                          color: _fechaNacimiento == null
                              ? const Color(0x7C1F2129)
                              : null,
                          fontSize: 14.0,
                          letterSpacing: 0.0,
                        ),
                      ),
                    ),
                    Icon(Icons.calendar_today,
                        size: 18.0, color: theme.secondaryText),
                  ]),
                ),
              ),
            ),
          ]),
        ),
      ],
    );
  }
}
