part of 'edit_profile_proff_widget.dart';

extension _EditProfileProffFormSections on _EditProfileProffWidgetState {
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
                              child: AuthUserStreamWidget(
                                builder: (context) =>
                                    TextFormField(
                                  controller: _model
                                      .textFieldnameTextController,
                                  focusNode: _model
                                      .textFieldnameFocusNode,
                                  autofocus: false,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    labelStyle: FlutterFlowTheme
                                            .of(context)
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
                                    hintText:
                                        'Nombres y apelidos',
                                    hintStyle: FlutterFlowTheme
                                            .of(context)
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
                                              Color(0x7C1F2129),
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
                                        color:
                                            FlutterFlowTheme.of(
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
                                        color:
                                            FlutterFlowTheme.of(
                                                    context)
                                                .primary,
                                        width: 2.0,
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(
                                              8.0),
                                    ),
                                    errorBorder:
                                        OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            FlutterFlowTheme.of(
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
                                        color:
                                            FlutterFlowTheme.of(
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
                                  validator: _model
                                      .textFieldnameTextControllerValidator
                                      .asValidator(context),
                                ),
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
                                readOnly: true,
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
                              child: AuthUserStreamWidget(
                                builder: (context) =>
                                    TextFormField(
                                  controller: _model
                                      .textFieldphoneTextController,
                                  focusNode: _model
                                      .textFieldphoneFocusNode,
                                  autofocus: false,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    labelStyle: FlutterFlowTheme
                                            .of(context)
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
                                    hintStyle: FlutterFlowTheme
                                            .of(context)
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
                                              Color(0x7C1F2129),
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
                                        color:
                                            FlutterFlowTheme.of(
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
                                        color:
                                            FlutterFlowTheme.of(
                                                    context)
                                                .primary,
                                        width: 2.0,
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(
                                              8.0),
                                    ),
                                    errorBorder:
                                        OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            FlutterFlowTheme.of(
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
                                        color:
                                            FlutterFlowTheme.of(
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
                                  validator: _model
                                      .textFieldphoneTextControllerValidator
                                      .asValidator(context),
                                ),
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
}
