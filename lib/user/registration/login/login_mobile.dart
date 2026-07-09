part of 'login_widget.dart';

extension _LoginMobile on _LoginWidgetState {
  Widget buildMobileLayout(BuildContext context) {
    return Column(
  mainAxisSize: MainAxisSize.max,
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Iniciar Sesion',
              style: FlutterFlowTheme.of(context)
                  .titleLarge
                  .override(
                    font: GoogleFonts.outfit(
                      fontWeight: FontWeight.w600,
                      fontStyle:
                          FlutterFlowTheme.of(context)
                              .titleLarge
                              .fontStyle,
                    ),
                    fontSize: 24.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                    fontStyle: FlutterFlowTheme.of(context)
                        .titleLarge
                        .fontStyle,
                  ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
              0.0, 40.0, 0.0, 0.0),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                  0.0, 0.0, 0.0, 15.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Correo electrónico',
                          style: FlutterFlowTheme.of(
                                  context)
                              .labelSmall
                              .override(
                                font: GoogleFonts.outfit(
                                  fontWeight:
                                      FontWeight.w500,
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
                          child: TextFormField(
                            controller:
                                _model.emailTextController1,
                            focusNode:
                                _model.textFieldFocusNode1,
                            autofocus: false,
                            obscureText: false,
                            decoration: InputDecoration(
                              alignLabelWithHint: false,
                              hintText:
                                  'Correo electrónico',
                              hintStyle: FlutterFlowTheme
                                      .of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts
                                        .readexPro(
                                      fontWeight:
                                          FontWeight.w500,
                                      fontStyle:
                                          FlutterFlowTheme.of(
                                                  context)
                                              .bodyMedium
                                              .fontStyle,
                                    ),
                                    color:
                                        FlutterFlowTheme.of(
                                                context)
                                            .accent3,
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                    fontWeight:
                                        FontWeight.w500,
                                    fontStyle:
                                        FlutterFlowTheme.of(
                                                context)
                                            .bodyMedium
                                            .fontStyle,
                                  ),
                              enabledBorder:
                                  UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0x00000000),
                                  width: 1.0,
                                ),
                                borderRadius:
                                    BorderRadius.circular(
                                        8.0),
                              ),
                              focusedBorder:
                                  UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0x00000000),
                                  width: 1.0,
                                ),
                                borderRadius:
                                    BorderRadius.circular(
                                        8.0),
                              ),
                              errorBorder:
                                  UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color:
                                      FlutterFlowTheme.of(
                                              context)
                                          .error,
                                  width: 1.0,
                                ),
                                borderRadius:
                                    BorderRadius.circular(
                                        8.0),
                              ),
                              focusedErrorBorder:
                                  UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color:
                                      FlutterFlowTheme.of(
                                              context)
                                          .error,
                                  width: 1.0,
                                ),
                                borderRadius:
                                    BorderRadius.circular(
                                        8.0),
                              ),
                              filled: true,
                              fillColor:
                                  FlutterFlowTheme.of(
                                          context)
                                      .secondaryBackground,
                            ),
                            style: FlutterFlowTheme.of(
                                    context)
                                .bodyMedium
                                .override(
                                  font:
                                      GoogleFonts.readexPro(
                                    fontWeight:
                                        FontWeight.w600,
                                    fontStyle:
                                        FlutterFlowTheme.of(
                                                context)
                                            .bodyMedium
                                            .fontStyle,
                                  ),
                                  color:
                                      FlutterFlowTheme.of(
                                              context)
                                          .primaryText,
                                  fontSize: 16.0,
                                  letterSpacing: 0.0,
                                  fontWeight:
                                      FontWeight.w600,
                                  fontStyle:
                                      FlutterFlowTheme.of(
                                              context)
                                          .bodyMedium
                                          .fontStyle,
                                ),
                            textAlign: TextAlign.start,
                            validator: _model
                                .emailTextController1Validator
                                .asValidator(context),
                          ),
                        ),
                      ].divide(SizedBox(height: 10.0)),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(),
                    child: Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(
                              0.0, 20.0, 0.0, 0.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Contraseña',
                            style: FlutterFlowTheme.of(
                                    context)
                                .labelSmall
                                .override(
                                  font: GoogleFonts.outfit(
                                    fontWeight:
                                        FontWeight.w500,
                                    fontStyle:
                                        FlutterFlowTheme.of(
                                                context)
                                            .labelSmall
                                            .fontStyle,
                                  ),
                                  fontSize: 16.0,
                                  letterSpacing: 0.0,
                                  fontWeight:
                                      FontWeight.w500,
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
                            child: TextFormField(
                              controller: _model
                                  .passwordTextController1,
                              focusNode: _model
                                  .textFieldFocusNode2,
                              autofocus: false,
                              obscureText: !_model
                                  .passwordVisibility1,
                              decoration: InputDecoration(
                                alignLabelWithHint: false,
                                hintText: 'Contraseña',
                                hintStyle: FlutterFlowTheme
                                        .of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts
                                          .readexPro(
                                        fontWeight:
                                            FontWeight.w500,
                                        fontStyle:
                                            FlutterFlowTheme.of(
                                                    context)
                                                .bodyMedium
                                                .fontStyle,
                                      ),
                                      color: FlutterFlowTheme
                                              .of(context)
                                          .accent3,
                                      fontSize: 16.0,
                                      letterSpacing: 0.0,
                                      fontWeight:
                                          FontWeight.w500,
                                      fontStyle:
                                          FlutterFlowTheme.of(
                                                  context)
                                              .bodyMedium
                                              .fontStyle,
                                    ),
                                enabledBorder:
                                    UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color:
                                        Color(0x00000000),
                                    width: 1.0,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(
                                          8.0),
                                ),
                                focusedBorder:
                                    UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color:
                                        Color(0x00000000),
                                    width: 1.0,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(
                                          8.0),
                                ),
                                errorBorder:
                                    UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color:
                                        FlutterFlowTheme.of(
                                                context)
                                            .error,
                                    width: 1.0,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(
                                          8.0),
                                ),
                                focusedErrorBorder:
                                    UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color:
                                        FlutterFlowTheme.of(
                                                context)
                                            .error,
                                    width: 1.0,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(
                                          8.0),
                                ),
                                filled: true,
                                fillColor: FlutterFlowTheme
                                        .of(context)
                                    .secondaryBackground,
                                suffixIcon: InkWell(
                                  onTap: () async {
                                    safeSetState(() => _model
                                            .passwordVisibility1 =
                                        !_model
                                            .passwordVisibility1);
                                  },
                                  focusNode: FocusNode(
                                      skipTraversal: true),
                                  child: Icon(
                                    _model.passwordVisibility1
                                        ? Icons
                                            .visibility_outlined
                                        : Icons
                                            .visibility_off_outlined,
                                    color: FlutterFlowTheme
                                            .of(context)
                                        .lightBlueForMobile,
                                    size: 24.0,
                                  ),
                                ),
                              ),
                              style: FlutterFlowTheme.of(
                                      context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts
                                        .readexPro(
                                      fontWeight:
                                          FontWeight.w600,
                                      fontStyle:
                                          FlutterFlowTheme.of(
                                                  context)
                                              .bodyMedium
                                              .fontStyle,
                                    ),
                                    color:
                                        FlutterFlowTheme.of(
                                                context)
                                            .primaryText,
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                    fontWeight:
                                        FontWeight.w600,
                                    fontStyle:
                                        FlutterFlowTheme.of(
                                                context)
                                            .bodyMedium
                                            .fontStyle,
                                  ),
                              textAlign: TextAlign.start,
                              validator: _model
                                  .passwordTextController1Validator
                                  .asValidator(context),
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
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                        0.0, 40.0, 0.0, 0.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Align(
                          alignment: AlignmentDirectional(
                              0.0, 0.0),
                          child: InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor:
                                Colors.transparent,
                            onTap: () async {
                              context.pushNamed(
                                  ForgotPWWidget.routeName);
                            },
                            child: Text(
                              '¿Te olvidaste tu contraseña?',
                              style: FlutterFlowTheme.of(
                                      context)
                                  .labelSmall
                                  .override(
                                    font:
                                        GoogleFonts.outfit(
                                      fontWeight:
                                          FontWeight.w600,
                                      fontStyle:
                                          FlutterFlowTheme.of(
                                                  context)
                                              .labelSmall
                                              .fontStyle,
                                    ),
                                    color: FlutterFlowTheme
                                            .of(context)
                                        .lightBlueForMobile,
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                    fontWeight:
                                        FontWeight.w600,
                                    fontStyle:
                                        FlutterFlowTheme.of(
                                                context)
                                            .labelSmall
                                            .fontStyle,
                                  ),
                            ),
                          ),
                        ),
                      ].divide(SizedBox(width: 5.0)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
    Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
          0.0, 0.0, 0.0, 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          wrapWithModel(
            model: _model.registartionButtonModel,
            updateCallback: () => safeSetState(() {}),
            child: RegistartionButtonWidget(
              btnText: 'Iniciar Sesion',
              btnAction: () async {
                FFAppState().EmailAdmin =
                    _model.emailTextController1.text;
                FFAppState().PasswordAdmin =
                    _model.passwordTextController1.text;

                GoRouter.of(context).prepareAuthEvent();

                final user =
                    await authManager.signInWithEmail(
                  context,
                  _model.emailTextController1.text,
                  _model.passwordTextController1.text,
                );
                if (user == null) {
                  FFAppState().EmailAdmin = '';
                  FFAppState().PasswordAdmin = '';
                  return;
                }

                if (valueOrDefault(
                        currentUserDocument?.rol, '') ==
                    'Adolescente') {
                  context.goNamedAuth(
                    HomeWidget.routeName,
                    context.mounted,
                    extra: <String, dynamic>{
                      '__transition_info__': TransitionInfo(
                        hasTransition: true,
                        transitionType:
                            PageTransitionType.fade,
                        duration: Duration(milliseconds: 0),
                      ),
                    },
                  );
                } else if (valueOrDefault(
                        currentUserDocument?.rol, '') ==
                    'Acudiente') {
                  context.goNamedAuth(
                    HomeParentsWidget.routeName,
                    context.mounted,
                    extra: <String, dynamic>{
                      '__transition_info__': TransitionInfo(
                        hasTransition: true,
                        transitionType:
                            PageTransitionType.fade,
                        duration: Duration(milliseconds: 0),
                      ),
                    },
                  );
                } else if (valueOrDefault(
                        currentUserDocument?.rol, '') ==
                    'Profesional') {
                  context.goNamedAuth(
                    PacientesWidget.routeName,
                    context.mounted,
                    extra: <String, dynamic>{
                      '__transition_info__': TransitionInfo(
                        hasTransition: true,
                        transitionType:
                            PageTransitionType.fade,
                        duration: Duration(milliseconds: 0),
                      ),
                    },
                  );
                } else if (valueOrDefault(
                        currentUserDocument?.rol, '') ==
                    'Administrador') {
                  context.goNamedAuth(
                    WebWidget.routeName,
                    context.mounted,
                    extra: <String, dynamic>{
                      '__transition_info__': TransitionInfo(
                        hasTransition: true,
                        transitionType:
                            PageTransitionType.fade,
                        duration: Duration(milliseconds: 0),
                      ),
                    },
                  );
                } else if (valueOrDefault(
                        currentUserDocument?.rol, '') ==
                    'Padre') {
                  context.goNamedAuth(
                    HomeWidget.routeName,
                    context.mounted,
                    extra: <String, dynamic>{
                      '__transition_info__': TransitionInfo(
                        hasTransition: true,
                        transitionType:
                            PageTransitionType.fade,
                        duration: Duration(milliseconds: 0),
                      ),
                    },
                  );
                }

                await currentUserReference!
                    .update(createUsersRecordData(
                  lastconnectedday: getCurrentTimestamp,
                  status: 1,
                ));
              },
            ),
          ),
          FFButtonWidget(
            onPressed: () async {
              context.pushNamed(
                RegisterContinueWidget.routeName,
                extra: <String, dynamic>{
                  '__transition_info__': TransitionInfo(
                    hasTransition: true,
                    transitionType: PageTransitionType.fade,
                    duration: Duration(milliseconds: 0),
                  ),
                },
              );
            },
            text: 'Crear cuenta',
            options: FFButtonOptions(
              width: double.infinity,
              height: 57.0,
              padding: EdgeInsetsDirectional.fromSTEB(
                  24.0, 0.0, 24.0, 0.0),
              iconPadding: EdgeInsetsDirectional.fromSTEB(
                  0.0, 0.0, 0.0, 0.0),
              color: FlutterFlowTheme.of(context).info,
              textStyle: FlutterFlowTheme.of(context)
                  .titleLarge
                  .override(
                    font: GoogleFonts.outfit(
                      fontWeight: FontWeight.w600,
                      fontStyle:
                          FlutterFlowTheme.of(context)
                              .titleLarge
                              .fontStyle,
                    ),
                    color: FlutterFlowTheme.of(context)
                        .lightBlueForMobile,
                    fontSize: 18.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                    fontStyle: FlutterFlowTheme.of(context)
                        .titleLarge
                        .fontStyle,
                  ),
              elevation: 0.0,
              borderSide: BorderSide(
                color: FlutterFlowTheme.of(context)
                    .lightBlueForMobile,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(40.0),
            ),
          ),
        ].divide(SizedBox(height: 20.0)),
      ),
    ),
    Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        InkWell(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () async {
            await launchURL(
                ' https://conecta2ips.blogspot.com/2024/07/politica-de-privacidad.html');
          },
          child: Text(
            'Politicas de Privacidad ',
            style: FlutterFlowTheme.of(context)
                .bodyMedium
                .override(
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
                  fontStyle: FlutterFlowTheme.of(context)
                      .bodyMedium
                      .fontStyle,
                ),
          ),
        ),
        InkWell(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () async {
            await launchURL(
                'https://conecta2ips.blogspot.com/2024/07/terminos-y-condiciones.html');
          },
          child: Text(
            'Términos y Condiciones',
            style: FlutterFlowTheme.of(context)
                .bodyMedium
                .override(
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
                  fontStyle: FlutterFlowTheme.of(context)
                      .bodyMedium
                      .fontStyle,
                ),
          ),
        ),
      ],
    ),
  ],
);
  }
}
