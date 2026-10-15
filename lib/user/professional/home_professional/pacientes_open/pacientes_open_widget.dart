import '/tamizajes/shared/widgets/seguimientos_lista_movil.dart';
import '/backend/backend.dart';
import '/components/calendario_read/calendario_read_widget.dart';
import '/components/header_prof_back/header_prof_back_widget.dart';
import '/components/show_calender_details/show_calender_details_widget.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'pacientes_open_model.dart';
import 'widgets/paciente_acudiente.dart';
import 'widgets/paciente_header.dart';
import 'widgets/paciente_info.dart';
import 'widgets/paciente_tamizajes.dart';
export 'pacientes_open_model.dart';

class PacientesOpenWidget extends StatefulWidget {
  const PacientesOpenWidget({
    super.key,
    required this.idPacientes,
  });

  final DocumentReference? idPacientes;

  static String routeName = 'pacientesOpen';
  static String routePath = '/pacientesOpen';

  @override
  State<PacientesOpenWidget> createState() => _PacientesOpenWidgetState();
}

class _PacientesOpenWidgetState extends State<PacientesOpenWidget> {
  late PacientesOpenModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PacientesOpenModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UsersRecord>(
      stream: UsersRecord.getDocument(widget.idPacientes!),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: Center(
              child: SizedBox(
                width: 50.0,
                height: 50.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    FlutterFlowTheme.of(context).primary,
                  ),
                ),
              ),
            ),
          );
        }

        final user = snapshot.data!;

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
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        20.0, 60.0, 20.0, 100.0),
                    child: SingleChildScrollView(
                      primary: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PacienteHeader(user: user),
                          if (user.rol == 'Adolescente')
                            EditAcudienteButton(
                              user: user,
                              onSaved: () => safeSetState(() {}),
                            ),
                          _buildSectionSelector(user),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 24.0, 0.0, 0.0),
                            child: _buildSelectedSection(user),
                          ),
                        ],
                      ),
                    ),
                  ),
                  wrapWithModel(
                    model: _model.headerProfBackModel,
                    updateCallback: () => safeSetState(() {}),
                    updateOnChange: true,
                    child: const HeaderProfBackWidget(name: 'Perfil'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionSelector(UsersRecord user) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          if (user.rol == 'Adolescente')
            Flexible(
              child: Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                child: _dropdown(
                  controller: _model.dropDownValueController1 ??=
                      FormFieldController<String>(_model.dropDownValue1 ??= '0'),
                  options: const ['0', '1', '2', '3'],
                  optionLabels: const [
                    'Datos personales',
                    'Registro de emociones',
                    'Respuestas de encuestas',
                    'Seguimientos programados',
                  ],
                  onChanged: (val) =>
                      safeSetState(() => _model.dropDownValue1 = val),
                ),
              ),
            ),
          if (user.rol == 'Acudiente')
            Flexible(
              child: Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                child: _dropdown(
                  controller: _model.dropDownValueController2 ??=
                      FormFieldController<String>(_model.dropDownValue2 ??= '0'),
                  options: const ['0', '2'],
                  optionLabels: const [
                    'Datos personales',
                    'Respuestas de encuestas',
                  ],
                  onChanged: (val) =>
                      safeSetState(() => _model.dropDownValue2 = val),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _dropdown({
    required FormFieldController<String> controller,
    required List<String> options,
    required List<String> optionLabels,
    required ValueChanged<String?> onChanged,
  }) {
    final bodyMedium = FlutterFlowTheme.of(context).bodyMedium;
    return FlutterFlowDropDown<String>(
      controller: controller,
      options: List<String>.from(options),
      optionLabels: optionLabels,
      onChanged: onChanged,
      width: MediaQuery.sizeOf(context).width * 1.0,
      height: 47.0,
      textStyle: bodyMedium.override(
        font: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontStyle: bodyMedium.fontStyle,
        ),
        color: const Color(0xFF265294),
        fontSize: 16.0,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w600,
        fontStyle: bodyMedium.fontStyle,
      ),
      hintText: 'Datos personales',
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Color(0xFF265294),
        size: 24.0,
      ),
      fillColor: FlutterFlowTheme.of(context).alternate,
      elevation: 2.0,
      borderColor: const Color(0xFF265294),
      borderWidth: 1.0,
      borderRadius: 32.0,
      margin: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
      hidesUnderline: true,
      isOverButton: true,
      isSearchable: false,
      isMultiSelect: false,
    );
  }

  Widget _buildSelectedSection(UsersRecord user) {
    if (_model.dropDownValue1 == '3') {
      return SeguimientosListaMovil(
        adolescenteRef: user.reference,
        pacienteNombre: user.displayName,
      );
    }
    if (_model.dropDownValue1 == '0' || _model.dropDownValue2 == '0') {
      return PacienteInfoSection(user: user);
    }
    if (_model.dropDownValue1 == '1') {
      return _buildEmocionesSection(user);
    }
    return PacienteTamizajesSection(
      user: user,
      pacienteRef: user.reference,
      choiceChipsController: _model.choiceChipsValueController ??=
          FormFieldController<List<String>>(['Encuestas']),
      onChipChanged: (val) =>
          safeSetState(() => _model.choiceChipsValue = val),
    );
  }

  Widget _buildEmocionesSection(UsersRecord user) {
    return SingleChildScrollView(
      primary: false,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Builder(
            builder: (context) => wrapWithModel(
              model: _model.calendarioReadModel,
              updateCallback: () => safeSetState(() {}),
              updateOnChange: true,
              child: CalendarioReadWidget(
                inputDate: getCurrentTimestamp,
                initialSelectedDate: getCurrentTimestamp,
                userRef: user.reference,
                onSelectDateAction: (selectedDate) async {
                  await showDialog(
                    context: context,
                    builder: (dialogContext) {
                      return Dialog(
                        elevation: 0,
                        insetPadding: EdgeInsets.zero,
                        backgroundColor: Colors.transparent,
                        alignment: const AlignmentDirectional(0.0, 0.0)
                            .resolve(Directionality.of(context)),
                        child: WebViewAware(
                          child: GestureDetector(
                            onTap: () {
                              FocusScope.of(dialogContext).unfocus();
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                            child: ShowCalenderDetailsWidget(
                              fecha: selectedDate,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
