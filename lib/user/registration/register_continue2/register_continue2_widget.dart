import '/backend/backend.dart';
import '/backend/schema/shared/listas_fijas.dart';
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
import 'register_continue2_model.dart';
export 'register_continue2_model.dart';

part 'register_continue2_form.dart';
part 'register_continue2_form2.dart';

class RegisterContinue2Widget extends StatefulWidget {
  const RegisterContinue2Widget({super.key});

  static String routeName = 'registerContinue2';
  static String routePath = '/registerContinue2';

  @override
  State<RegisterContinue2Widget> createState() =>
      _RegisterContinue2WidgetState();
}

class _RegisterContinue2WidgetState extends State<RegisterContinue2Widget> {
  late RegisterContinue2Model _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RegisterContinue2Model());

    _model.textFieldDocTextController ??= TextEditingController();
    _model.textFieldDocFocusNode ??= FocusNode();

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
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            'Registro',
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
                      buildForm(context),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            0.0, 20.0, 0.0, 10.0),
                        child: FFButtonWidget(
                          onPressed: () async {
                            if (_model.formKey.currentState == null ||
                                !_model.formKey.currentState!.validate()) {
                              return;
                            }
                            _model.colegioelegido =
                                await queryColegiosRecordOnce(
                              queryBuilder: (colegiosRecord) =>
                                  colegiosRecord.where(
                                'nombre',
                                isEqualTo: _model.textFieldColegioValue,
                              ),
                              singleRecord: true,
                            ).then((s) => s.firstOrNull);
                            FFAppState().updateDetalleUsuarioTempStruct(
                              (e) => e
                                ..detalle = DetalleUsuarioStruct(
                                  fechaNacimiento: _model.datePicked,
                                  genero: _model.dropDownGeneroValue,
                                  municipio: _model.colegioelegido?.municipio,
                                  barrio: _model.colegioelegido?.barrio,
                                  colegio: _model.textFieldColegioValue,
                                  eps: _model.epsValue,
                                  grado: _model.anioValue,
                                  documento:
                                      _model.textFieldDocTextController.text,
                                ),
                            );
                            FFAppState().update(() {});

                            context
                                .pushNamed(RegisterContinue3Widget.routeName);

                            safeSetState(() {});
                          },
                          text: 'Siguiente',
                          options: FFButtonOptions(
                            width: MediaQuery.sizeOf(context).width * 1.0,
                            height: 40.0,
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 0.0, 16.0, 0.0),
                            iconPadding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            color: FlutterFlowTheme.of(context).accent2,
                            textStyle: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
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
      ),
    );
  }
}
