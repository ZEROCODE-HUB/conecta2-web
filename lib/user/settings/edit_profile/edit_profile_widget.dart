import '/components/button_vazado/button_vazado_widget.dart';
import '/components/footer/footer_widget.dart';
import '/components/header/header_widget.dart';
import '/components/registartion_button/registartion_button_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'edit_profile_model.dart';
export 'edit_profile_model.dart';

part 'edit_profile_form_sections.dart';
part 'edit_profile_form_sections2.dart';

class EditProfileWidget extends StatefulWidget {
  const EditProfileWidget({super.key});

  static String routeName = 'EditProfile';
  static String routePath = '/editProfile';

  @override
  State<EditProfileWidget> createState() => _EditProfileWidgetState();
}

class _EditProfileWidgetState extends State<EditProfileWidget> {
  late EditProfileModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EditProfileModel());

    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.textController2 ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();

    _model.textController3 ??= TextEditingController();
    _model.textFieldFocusNode3 ??= FocusNode();

    _model.textController4 ??= TextEditingController();
    _model.textFieldFocusNode4 ??= FocusNode();

    _model.textController5 ??= TextEditingController();
    _model.textFieldFocusNode5 ??= FocusNode();

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
              Container(
                decoration: BoxDecoration(),
                child: Padding(
                  padding:
                      EdgeInsetsDirectional.fromSTEB(20.0, 10.0, 20.0, 10.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 75.0, 0.0, 0.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              ...buildFormSections(context),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 32.0, 0.0, 12.0),
                          child: wrapWithModel(
                            model: _model.buttonVazadoModel,
                            updateCallback: () => safeSetState(() {}),
                            child: ButtonVazadoWidget(
                              btnText: 'Restaurar contraseña',
                              btnAction: () async {},
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
                              btnAction: () async {},
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              wrapWithModel(
                model: _model.headerModel,
                updateCallback: () => safeSetState(() {}),
                child: HeaderWidget(
                  pageTitle: 'Mi Perfil',
                  showIconBack: false,
                ),
              ),
              Positioned(
                top: 50,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF265294),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: const Text(
                    'v.1.1.8',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: AlignmentDirectional(0.0, 1.0),
                child: wrapWithModel(
                  model: _model.footerModel,
                  updateCallback: () => safeSetState(() {}),
                  child: FooterWidget(
                    active: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
