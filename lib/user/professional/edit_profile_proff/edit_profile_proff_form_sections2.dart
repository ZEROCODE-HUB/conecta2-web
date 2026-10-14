part of 'edit_profile_proff_widget.dart';

extension _EditProfileProffFormSections2 on _EditProfileProffWidgetState {
  List<Widget> buildFormSections2(BuildContext context) {
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
                            'Documento de identidad',
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
                                      .textFielddniTextController,
                                  focusNode: _model
                                      .textFielddniFocusNode,
                                  autofocus: true,
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
                                        'Documento de identidad',
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
                                      .textFielddniTextControllerValidator
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
                            'Dirección',
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
                                      .textFieldaddressTextController,
                                  focusNode: _model
                                      .textFieldaddressFocusNode,
                                  autofocus: true,
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
                                    hintText: 'Dirección',
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
                                      .textFieldaddressTextControllerValidator
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
                          0.0, 12.0, 0.0, 0.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(
                                      0.0, 24.0, 0.0, 0.0),
                              child: InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor:
                                    Colors.transparent,
                                onTap: () async {
                                  GoRouter.of(context)
                                      .prepareAuthEvent();
                                  await authManager.signOut();
                                  limpiarSesionApp();
                                  GoRouter.of(context)
                                      .clearRedirectLocation();

                                  context.goNamedAuth(
                                      SplashWidget.routeName,
                                      context.mounted);
                                },
                                child: Container(
                                  height: 47.0,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF5F5F5),
                                    borderRadius:
                                        BorderRadius.circular(
                                            12.0),
                                  ),
                                  child: Row(
                                    mainAxisSize:
                                        MainAxisSize.max,
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsetsDirectional
                                                .fromSTEB(
                                                    24.0,
                                                    0.0,
                                                    0.0,
                                                    0.0),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius
                                                  .circular(8.0),
                                          child: SvgPicture.asset(
                                            'assets/images/Logout.svg',
                                            width: 24.0,
                                            height: 24.0,
                                            fit: BoxFit.none,
                                            alignment: Alignment(
                                                -1.0, 0.0),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            EdgeInsetsDirectional
                                                .fromSTEB(
                                                    12.0,
                                                    0.0,
                                                    0.0,
                                                    0.0),
                                        child: Text(
                                          'Cerrar Sesión',
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
                                                fontSize: 14.0,
                                                letterSpacing:
                                                    0.0,
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
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    ];
  }
}
