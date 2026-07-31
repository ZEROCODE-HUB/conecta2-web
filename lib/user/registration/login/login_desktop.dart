part of 'login_widget.dart';

extension _LoginDesktop on _LoginWidgetState {
  Widget buildDesktopLayout(BuildContext context) {
    return Container(
  width: MediaQuery.sizeOf(context).width * 0.35,
  decoration: BoxDecoration(
    color: Color(0xFF265294),
    borderRadius: BorderRadius.circular(20.0),
  ),
  child: Padding(
    padding: EdgeInsetsDirectional.fromSTEB(
        40.0, 20.0, 40.0, 20.0),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.asset(
            'assets/images/Group_1.png',
            width: 300.0,
            height: 60.77,
            fit: BoxFit.cover,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                  0.0, 20.0, 0.0, 10.0),
              child: Text(
                'Iniciar Sesion',
                style: FlutterFlowTheme.of(context)
                    .titleLarge
                    .override(
                      font: GoogleFonts.outfit(
                        fontWeight: FontWeight.w500,
                        fontStyle:
                            FlutterFlowTheme.of(context)
                                .titleLarge
                                .fontStyle,
                      ),
                      color: FlutterFlowTheme.of(context)
                          .primaryBackground,
                      fontSize: 30.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w500,
                      fontStyle:
                          FlutterFlowTheme.of(context)
                              .titleLarge
                              .fontStyle,
                    ),
              ),
            ),
          ],
        ),
        Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
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
                              color: FlutterFlowTheme.of(
                                      context)
                                  .primaryBackground,
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
                              _model.emailTextController,
                          focusNode: _model.emailFocusNode,
                          autofocus: false,
                          obscureText: false,
                          decoration: InputDecoration(
                            alignLabelWithHint: false,
                            hintText: 'Correo electrónico',
                            hintStyle: FlutterFlowTheme.of(
                                    context)
                                .bodyMedium
                                .override(
                                  font:
                                      GoogleFonts.readexPro(
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
                                color: FlutterFlowTheme.of(
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
                                color: FlutterFlowTheme.of(
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
                                FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                          ),
                          style: FlutterFlowTheme.of(
                                  context)
                              .bodyMedium
                              .override(
                                font: GoogleFonts.readexPro(
                                  fontWeight:
                                      FontWeight.w500,
                                  fontStyle:
                                      FlutterFlowTheme.of(
                                              context)
                                          .bodyMedium
                                          .fontStyle,
                                ),
                                color: FlutterFlowTheme.of(
                                        context)
                                    .primaryText,
                                fontSize: 16.0,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w500,
                                fontStyle:
                                    FlutterFlowTheme.of(
                                            context)
                                        .bodyMedium
                                        .fontStyle,
                              ),
                          textAlign: TextAlign.start,
                          validator: _model
                              .emailTextControllerValidator
                              .asValidator(context),
                        ),
                      ),
                    ].divide(SizedBox(height: 10.0)),
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
                                color: FlutterFlowTheme.of(
                                        context)
                                    .primaryBackground,
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
                            controller: _model
                                .passwordTextController,
                            focusNode:
                                _model.passwordFocusNode,
                            autofocus: false,
                            obscureText:
                                !_model.passwordVisibility2,
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
                              suffixIcon: InkWell(
                                onTap: () async {
                                  safeSetState(() => _model
                                          .passwordVisibility2 =
                                      !_model
                                          .passwordVisibility2);
                                },
                                focusNode: FocusNode(
                                    skipTraversal: true),
                                child: Icon(
                                  _model.passwordVisibility2
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
                                  font:
                                      GoogleFonts.readexPro(
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
                                          .primaryText,
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
                            textAlign: TextAlign.start,
                            validator: _model
                                .passwordTextControllerValidator
                                .asValidator(context),
                          ),
                        ),
                      ].divide(SizedBox(height: 10.0)),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                  0.0, 20.0, 0.0, 0.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  FFButtonWidget(
                    onPressed: () async {
                      if (_model.emailTextController.text
                          .isEmpty) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          SnackBar(
                            content: Text(
                              'Email required!',
                            ),
                          ),
                        );
                        return;
                      }
                      await authManager.resetPassword(
                        email:
                            _model.emailTextController.text,
                        context: context,
                      );
                    },
                    text: '¿Olvidaste tu contraseña?',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 57.0,
                      padding:
                          EdgeInsetsDirectional.fromSTEB(
                              24.0, 0.0, 24.0, 0.0),
                      iconPadding:
                          EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 0.0),
                      color: Color(0xFF265294),
                      textStyle: FlutterFlowTheme.of(
                              context)
                          .titleLarge
                          .override(
                            font: GoogleFonts.outfit(
                              fontWeight: FontWeight.w600,
                              fontStyle:
                                  FlutterFlowTheme.of(
                                          context)
                                      .titleLarge
                                      .fontStyle,
                            ),
                            color: Color(0xFFF6BD33),
                            fontSize: 18.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w600,
                            fontStyle:
                                FlutterFlowTheme.of(context)
                                    .titleLarge
                                    .fontStyle,
                          ),
                      elevation: 0.0,
                      borderSide: BorderSide(
                        color: Color(0xFFF6BD33),
                        width: 1.0,
                      ),
                      borderRadius:
                          BorderRadius.circular(40.0),
                    ),
                  ),
                  FFButtonWidget(
                    onPressed: () async {
                      FFAppState().EmailAdmin =
                          _model.emailTextController.text;
                      FFAppState().PasswordAdmin = _model
                          .passwordTextController.text;

                      GoRouter.of(context)
                          .prepareAuthEvent();

                      final user =
                          await authManager.signInWithEmail(
                        context,
                        _model.emailTextController.text,
                        _model.passwordTextController.text,
                      );
                      if (user == null) {
                        FFAppState().EmailAdmin = '';
                        FFAppState().PasswordAdmin = '';
                        return;
                      }

                      safeSetState(() {});
                      if (valueOrDefault(
                              currentUserDocument?.rol,
                              '') ==
                          'Adolescente') {
                        context.goNamedAuth(
                          HomeWidget.routeName,
                          context.mounted,
                          extra: <String, dynamic>{
                            '__transition_info__':
                                TransitionInfo(
                              hasTransition: true,
                              transitionType:
                                  PageTransitionType.fade,
                              duration:
                                  Duration(milliseconds: 0),
                            ),
                          },
                        );
                      } else if (valueOrDefault(
                              currentUserDocument?.rol,
                              '') ==
                          'Acudiente') {
                        context.goNamedAuth(
                          HomeParentsWidget.routeName,
                          context.mounted,
                          extra: <String, dynamic>{
                            '__transition_info__':
                                TransitionInfo(
                              hasTransition: true,
                              transitionType:
                                  PageTransitionType.fade,
                              duration:
                                  Duration(milliseconds: 0),
                            ),
                          },
                        );
                      } else if ((valueOrDefault(
                                  currentUserDocument?.rol,
                                  '') ==
                              'Administrador') ||
                          (valueOrDefault(
                                  currentUserDocument?.rol,
                                  '') ==
                              'Profesional')) {
                        context.goNamedAuth(
                          WebWidget.routeName,
                          context.mounted,
                          extra: <String, dynamic>{
                            '__transition_info__':
                                TransitionInfo(
                              hasTransition: true,
                              transitionType:
                                  PageTransitionType.fade,
                              duration:
                                  Duration(milliseconds: 0),
                            ),
                          },
                        );
                      }

                      await UsersRecord.collection
                          .doc(user.uid)
                          .update(createUsersRecordData(
                        lastconnectedday:
                            getCurrentTimestamp,
                      ));
                    },
                    text: 'Iniciar Sesión',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 57.0,
                      padding:
                          EdgeInsetsDirectional.fromSTEB(
                              24.0, 0.0, 24.0, 0.0),
                      iconPadding:
                          EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 0.0),
                      color: Color(0xFFF6BD33),
                      textStyle: FlutterFlowTheme.of(
                              context)
                          .titleLarge
                          .override(
                            font: GoogleFonts.outfit(
                              fontWeight: FontWeight.w600,
                              fontStyle:
                                  FlutterFlowTheme.of(
                                          context)
                                      .titleLarge
                                      .fontStyle,
                            ),
                            color:
                                FlutterFlowTheme.of(context)
                                    .lightBlueForMobile,
                            fontSize: 18.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w600,
                            fontStyle:
                                FlutterFlowTheme.of(context)
                                    .titleLarge
                                    .fontStyle,
                          ),
                      elevation: 0.0,
                      borderRadius:
                          BorderRadius.circular(40.0),
                    ),
                  ),
                ].divide(SizedBox(height: 20.0)),
              ),
            ),
          ],
        ),
      ],
    ),
  ),
);
  }
}
