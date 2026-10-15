import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/button_vazado/button_vazado_widget.dart';
import '/components/header_prof_back/header_prof_back_widget.dart';
import '/components/registartion_button/registartion_button_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'edit_profile_parents_model.dart';
export 'edit_profile_parents_model.dart';

part 'edit_profile_parents_form_sections.dart';
part 'edit_profile_parents_form_sections2.dart';

class EditProfileParentsWidget extends StatefulWidget {
  const EditProfileParentsWidget({super.key});

  static String routeName = 'EditProfileParents';
  static String routePath = '/editProfileParents';

  @override
  State<EditProfileParentsWidget> createState() =>
      _EditProfileParentsWidgetState();
}

class _EditProfileParentsWidgetState extends State<EditProfileParentsWidget> {
  late EditProfileParentsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  String? _generoSeleccionado;
  DateTime? _fechaNacimiento;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EditProfileParentsModel());

    _model.textFieldnameTextController ??= TextEditingController();
    _model.textFieldnameFocusNode ??= FocusNode();

    _model.textFieldemailTextController ??= TextEditingController();
    _model.textFieldemailFocusNode ??= FocusNode();

    _model.textFieldcelularTextController ??= TextEditingController();
    _model.textFieldcelularFocusNode ??= FocusNode();

    _model.textFielddniTextController ??= TextEditingController();
    _model.textFielddniFocusNode ??= FocusNode();

    _model.textFieldaddressTextController ??= TextEditingController();
    _model.textFieldaddressFocusNode ??= FocusNode();

    final userDoc = currentUserDocument;
    if (userDoc != null) {
      _generoSeleccionado =
          userDoc.genero.isEmpty ? null : userDoc.genero;
      _fechaNacimiento = userDoc.fechaNacimiento;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 45.0, 0.0, 0.0),
                child: Container(
                  decoration: BoxDecoration(),
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 10.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              ...buildFormSections(context),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 32.0, 0.0, 12.0),
                            child: wrapWithModel(
                              model: _model.buttonVazadoModel,
                              updateCallback: () => safeSetState(() {}),
                              child: ButtonVazadoWidget(
                                btnText: 'Restaurar contraseña',
                                btnAction: () async {
                                  if (_model.textFieldemailTextController.text
                                      .isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'No se encontró tu correo de acceso.',
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  await authManager.resetPassword(
                                    email: _model
                                        .textFieldemailTextController.text,
                                    context: context,
                                  );
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 5.0, 0.0, 90.0),
                            child: wrapWithModel(
                              model: _model.registartionButtonModel,
                              updateCallback: () => safeSetState(() {}),
                              child: RegistartionButtonWidget(
                                btnText: 'Enviar',
                                btnAction: () async {
                                  await currentUserReference!
                                      .update(createUsersRecordData(
                                    email: _model
                                        .textFieldemailTextController.text,
                                    displayName:
                                        _model.textFieldnameTextController.text,
                                    address: _model
                                        .textFieldaddressTextController.text,
                                    phoneNumber: _model
                                        .textFieldcelularTextController.text,
                                    genero: _generoSeleccionado ?? '',
                                    fechaNacimiento: _fechaNacimiento,
                                  ));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Datos actualizados con éxito',
                                        style: TextStyle(
                                          color: FlutterFlowTheme.of(context)
                                              .primaryBackground,
                                        ),
                                      ),
                                      duration: Duration(milliseconds: 4000),
                                      backgroundColor:
                                          FlutterFlowTheme.of(context).menuWeb,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              wrapWithModel(
                model: _model.headerProfBackModel,
                updateCallback: () => safeSetState(() {}),
                child: HeaderProfBackWidget(
                  name: 'Mi Perfil  ·  v.1.1.8',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
