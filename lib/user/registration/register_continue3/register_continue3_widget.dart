import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/index.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'register_continue3_model.dart';
export 'register_continue3_model.dart';

part 'register_continue3_form.dart';
part 'register_continue3_form2.dart';

class RegisterContinue3Widget extends StatefulWidget {
  const RegisterContinue3Widget({super.key});

  static String routeName = 'registerContinue3';
  static String routePath = '/registerContinue3';

  @override
  State<RegisterContinue3Widget> createState() =>
      _RegisterContinue3WidgetState();
}

class _RegisterContinue3WidgetState extends State<RegisterContinue3Widget> {
  late RegisterContinue3Model _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RegisterContinue3Model());

    _model.textFieldNombreParentescoTextController ??= TextEditingController();
    _model.textFieldNombreParentescoFocusNode ??= FocusNode();

    _model.textFieldParentescoTextController ??= TextEditingController();
    _model.textFieldParentescoFocusNode ??= FocusNode();

    _model.correoParentescoTextController ??= TextEditingController();
    _model.correoParentescoFocusNode ??= FocusNode();

    _model.textFieldTelefonoParentescoTextController ??=
        TextEditingController();
    _model.textFieldTelefonoParentescoFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
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
          child: Form(
            key: _model.formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                context.safePop();
                              },
                              child: FaIcon(
                                FontAwesomeIcons.circleChevronLeft,
                                color: FlutterFlowTheme.of(context)
                                    .lightBlueForMobile,
                                size: 24.0,
                              ),
                            ),
                            Text(
                              'Datos del contacto',
                              style: FlutterFlowTheme.of(context)
                                  .titleLarge
                                  .override(
                                    font: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
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
                            Container(
                              width: 20.0,
                              height: 20.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
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
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...buildFormChildren(context),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 20.0),
                      child: FFButtonWidget(
                        onPressed: () async {
                          if (_model.formKey.currentState == null ||
                              !_model.formKey.currentState!.validate()) {
                            return;
                          }
                          GoRouter.of(context).prepareAuthEvent();

                          // B7: Si el correo ya existe (registro previo incompleto), intentar login
                          BaseAuthUser? authUser = await authManager.createAccountWithEmail(
                            context,
                            FFAppState().detalleUsuarioTemp.email,
                            FFAppState().detalleUsuarioTemp.password,
                          );
                          if (authUser == null) {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            authUser = await authManager.signInWithEmail(
                              context,
                              FFAppState().detalleUsuarioTemp.email,
                              FFAppState().detalleUsuarioTemp.password,
                            );
                            if (authUser == null) {
                              return;
                            }
                          }

                          // Fix: Avoid querying by email which fails due to Firestore delay.
                          // Update all fields directly using user.uid in a single call.
                          await UsersRecord.collection
                              .doc(authUser.uid)
                              .set(createUsersRecordData(
                                createdTime: getCurrentTimestamp,
                                email: FFAppState().detalleUsuarioTemp.email,
                                displayName: FFAppState().detalleUsuarioTemp.nombre,
                                phoneNumber: FFAppState().detalleUsuarioTemp.phone,
                                rol: FFAppState().detalleUsuarioTemp.tipo,
                                acudiente: createAcudienteStruct(
                                  nombre: _model.matchedParentUser != null
                                      ? _model.matchedParentUser!.displayName
                                      : (_model.selectParentsValue ?? _model.textFieldNombreParentescoTextController.text),
                                  ref: _model.matchedParentUser?.reference,
                                  parentesco:
                                      _model.textFieldParentescoTextController.text,
                                  correo:
                                      _model.correoParentescoTextController.text,
                                  telefono: _model
                                      .textFieldTelefonoParentescoTextController
                                      .text,
                                  clearUnsetFields: false,
                                ),
                                fechaNacimiento: FFAppState()
                                    .detalleUsuarioTemp
                                    .detalle
                                    .fechaNacimiento,
                                genero:
                                    FFAppState().detalleUsuarioTemp.detalle.genero,
                                municipio: FFAppState()
                                    .detalleUsuarioTemp
                                    .detalle
                                    .municipio,
                                barrio:
                                    FFAppState().detalleUsuarioTemp.detalle.barrio,
                                colegio:
                                    FFAppState().detalleUsuarioTemp.detalle.colegio,
                                eps: FFAppState().detalleUsuarioTemp.detalle.eps,
                                grado:
                                    FFAppState().detalleUsuarioTemp.detalle.grado,
                                identidad: FFAppState()
                                    .detalleUsuarioTemp
                                    .detalle
                                    .documento,
                              ));
                          if (currentUserReference != null) {
                            context.goNamedAuth(
                                SuccessWidget.routeName, context.mounted);

                            FFAppState().description = '';
                            FFAppState().emocion = 0;
                            FFAppState().dateEmocion =
                                DateTime.fromMillisecondsSinceEpoch(
                                    1719194940000);
                            FFAppState().emocionDay = 0;
                            FFAppState().CalenderEmotion = [];
                            safeSetState(() {});
                          }

                          safeSetState(() {});
                        },
                        text: 'Registrar',
                        options: FFButtonOptions(
                          width: MediaQuery.sizeOf(context).width * 1.0,
                          height: 40.0,
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 0.0, 16.0, 0.0),
                          iconPadding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 0.0),
                          color: FlutterFlowTheme.of(context).accent2,
                          textStyle:
                              FlutterFlowTheme.of(context).titleSmall.override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontStyle,
                                    ),
                                    color: Colors.white,
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontStyle,
                                  ),
                          elevation: 0.0,
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
