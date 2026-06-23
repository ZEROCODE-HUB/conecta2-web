import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/backend/backend.dart';
import '/dashboard/web/usuarios/model/perfil_adolescente_repuesta/perfil_adolescente_repuesta_widget.dart';
import '/dashboard/web/usuarios/perfiles/shared/encuestas_respuestas_section.dart';
import '/dashboard/web/usuarios/perfiles/shared/info_row.dart';
import '/dashboard/web/usuarios/perfiles/shared/info_section.dart';
import '/dashboard/web/usuarios/perfiles/shared/perfil_actions_menu.dart';
import '/dashboard/web/usuarios/perfiles/shared/perfil_header.dart';
import '/dashboard/web/usuarios/perfiles/shared/perfil_page_header.dart';
import '/dashboard/web/usuarios/perfiles/shared/perfil_tab_bar.dart';
import '/dashboard/web/usuarios/perfiles/shared/registro_emociones_section.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'perfil_adolescente_model.dart';
export 'perfil_adolescente_model.dart';

class PerfilAdolescenteWidget extends StatefulWidget {
  const PerfilAdolescenteWidget({
    super.key,
    required this.documentID,
  });

  final DocumentReference? documentID;

  @override
  State<PerfilAdolescenteWidget> createState() =>
      _PerfilAdolescenteWidgetState();
}

class _PerfilAdolescenteWidgetState extends State<PerfilAdolescenteWidget> {
  late PerfilAdolescenteModel _model;

  static const _tabs = [
    'Datos Personales',
    'Registro de emociones',
    //'Repuestas de encuestas',
  ];

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PerfilAdolescenteModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  String _formatDate(DateTime? value) {
    if (value == null) return '';
    return dateTimeFormat(
      'yMMMd',
      value,
      locale: FFLocalizations.of(context).languageCode,
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final theme = FlutterFlowTheme.of(context);

    return Container(
      decoration: BoxDecoration(color: theme.secondaryBackground),
      child: SingleChildScrollView(
        primary: false,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(40.0, 20.0, 40.0, 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PerfilPageHeader(
                title: 'Perfil Adolescente',
                onBack: () {
                  FFAppState().selectUser = '';
                  safeSetState(() {});
                },
              ),
              const SizedBox(height: 45.0),
              StreamBuilder<UsersRecord>(
                stream: UsersRecord.getDocument(widget.documentID!),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: SizedBox(
                        width: 50.0,
                        height: 50.0,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(theme.primary),
                        ),
                      ),
                    );
                  }
                  final user = snapshot.data!;
                  return _buildBody(user);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(UsersRecord user) {
    return LayoutBuilder(builder: (context, constraints) {
      final compact = constraints.maxWidth < 900.0;
      final header = PerfilHeader(
        user: user,
        width: compact ? double.infinity : null,
        badges: [
          PerfilBadge(
            label: 'Acudiente',
            value: user.acudiente.nombre,
            fallbackValue: 'Acudiente no asignado',
          ),
          PerfilBadge(
            label: 'Profesional',
            value: user.profesionales.nombre,
            fallbackValue: 'Profesional no asignado',
          ),
        ],
      );
      final content = _buildContentCard(user);
      if (compact) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [header, const SizedBox(height: 24.0), content],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          const SizedBox(width: 30.0),
          Expanded(child: content),
        ],
      );
    });
  }

  Widget _buildContentCard(UsersRecord user) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            blurRadius: 50.0,
            color: Color(0x26000000),
            offset: Offset(20.0, 20.0),
          ),
        ],
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: PerfilTabBar(
                    tabs: _tabs,
                    current: _model.slider,
                    mainAxisAlignment: MainAxisAlignment.center,
                    onSelected: (value) {
                      _model.slider = value;
                      FFAppState().showEncuesta = false;
                      safeSetState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 12.0),
                if (widget.documentID != null)
                  PerfilActionsMenu(
                    userRef: widget.documentID!,
                    onStateChanged: () => safeSetState(() {}),
                  ),
              ],
            ),
            const SizedBox(height: 20.0),
            _buildTabContent(user),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(UsersRecord user) {
    switch (_model.slider) {
      case 'Datos Personales':
        return _buildDatosPersonales(user);
      case 'Registro de emociones':
        return RegistroEmocionesSection(
          userRef: widget.documentID!,
          calendarioModel: _model.calendarioReadModel,
          onStateChanged: () => safeSetState(() {}),
        );
      /*case 'Repuestas de encuestas':
        if (FFAppState().showEncuesta == true && _model.refEncuestas != null) {
          return Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 40.0, 0.0, 0.0),
            child: wrapWithModel(
              model: _model.perfilAdolescenteRepuestaModel,
              updateCallback: () => safeSetState(() {}),
              updateOnChange: true,
              child: PerfilAdolescenteRepuestaWidget(
                refencuestas: _model.refEncuestas,
                userRef: user,
              ),
            ),
          );
        }
        return EncuestasRespuestasSection(
          userRef: user.reference,
          selected: _model.choiceChipsValue,
          controller: _model.choiceChipsValueController ??=
              FormFieldController<List<String>>(['Encuestas']),
          onChanged: (value) {
            _model.choiceChipsValue = value;
            safeSetState(() {});
          },
          onOpenEncuesta: (ref) {
            _model.refEncuestas = ref;
            FFAppState().showEncuesta = true;
            safeSetState(() {});
          },
        ); */
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDatosPersonales(UsersRecord user) {
    return InfoSection(
      title: 'Datos personales',
      topPadding: 20.0,
      rows: [
        InfoRow(
          left: InfoField(label: 'Tipo de usuario', value: user.rol),
          right:
              InfoField(label: 'Nombres y Apellidos', value: user.displayName),
        ),
        InfoRow(
          left: InfoField(label: 'Correo electrónico', value: user.email),
          right: InfoField(label: 'Celular', value: user.phoneNumber),
        ),
        InfoRow(
          left:
              InfoField(label: 'Documento de identidad', value: user.identidad),
          right: InfoField(label: 'Dirección', value: user.address),
        ),
        InfoRow(
          left: InfoField(
            label: 'Último día conectado',
            value: _formatDate(user.lastconnectedday),
          ),
          right: InfoField(
            label: 'Fecha de registro',
            value: _formatDate(user.createdTime),
          ),
        ),
      ],
    );
  }
}
