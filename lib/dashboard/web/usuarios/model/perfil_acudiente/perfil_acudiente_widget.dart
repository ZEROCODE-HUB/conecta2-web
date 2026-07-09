import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'perfil_acudiente_model.dart';
export 'perfil_acudiente_model.dart';

class PerfilAcudienteWidget extends StatefulWidget {
  const PerfilAcudienteWidget({
    super.key,
    required this.documentID,
  });

  final DocumentReference? documentID;

  @override
  State<PerfilAcudienteWidget> createState() => _PerfilAcudienteWidgetState();
}

class _PerfilAcudienteWidgetState extends State<PerfilAcudienteWidget> {
  late PerfilAcudienteModel _model;

  static const _tabs = ['Datos Personales', 'Repuestas de encuestas'];

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PerfilAcudienteModel());
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
                title: 'Perfil Acudiente',
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
                          valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
                        ),
                      ),
                    );
                  }
                  return _buildBody(snapshot.data!);
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: PerfilTabBar(
                    tabs: _tabs,
                    current: _model.slider,
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
      case 'Repuestas de encuestas':
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
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDatosPersonales(UsersRecord user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InfoSection(
          title: 'Datos personales',
          topPadding: 20.0,
          rows: [
            InfoRow(
              left: InfoField(label: 'Tipo de usuario', value: user.rol),
              right: InfoField(label: 'Nombres y Apellidos', value: user.displayName),
            ),
            InfoRow(
              left: InfoField(label: 'Correo electrónico', value: user.email),
              right: InfoField(label: 'Celular', value: user.phoneNumber),
            ),
            InfoRow(
              left: InfoField(label: 'Documento de identidad', value: user.identidad),
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
            InfoRow(
              left: InfoField(label: 'Edad', value: user.edad.isNotEmpty ? user.edad : 'No registrado'),
              right: InfoField(label: 'Género', value: user.genero.isNotEmpty ? user.genero : 'No registrado'),
            ),
            InfoRow(
              left: InfoField(label: 'Fecha de nacimiento', value: user.fechaNacimiento != null ? DateFormat('dd/MM/yyyy').format(user.fechaNacimiento!) : 'No registrado'),
              right: InfoField(label: 'Colegio', value: user.colegio.isNotEmpty ? user.colegio : 'No registrado'),
            ),
            InfoRow(
              left: InfoField(label: 'EPS', value: user.eps.isNotEmpty ? user.eps : 'No registrado'),
              right: InfoField(label: 'Grado Escolar', value: user.grado.isNotEmpty ? user.grado : 'No registrado'),
            ),
            InfoRow(
              left: InfoField(label: 'Municipio', value: user.municipio.isNotEmpty ? user.municipio : 'No registrado'),
              right: InfoField(label: 'Barrio', value: user.barrio.isNotEmpty ? user.barrio : 'No registrado'),
            ),
          ],
        ),
        const SizedBox(height: 24.0),
        _buildAdolescentesVinculados(user),
      ],
    );
  }

  Widget _buildAdolescentesVinculados(UsersRecord user) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 12.0),
            child: Text(
              'Adolescentes vinculados',
              style: theme.titleSmall,
            ),
          ),
          StreamBuilder<List<UsersRecord>>(
            stream: queryUsersRecord(
              queryBuilder: (q) => q.where('Acudiente.correo', isEqualTo: user.email),
            ),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: SizedBox(
                    height: 24.0,
                    width: 24.0,
                    child: CircularProgressIndicator(strokeWidth: 2.0),
                  ),
                );
              }
              final adolescentes = snapshot.data!;
              if (adolescentes.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Este acudiente no tiene adolescentes vinculados.',
                    style: theme.bodyMedium
                        .override(color: theme.secondaryText),
                  ),
                );
              }
              return Column(
                children: adolescentes
                    .map(
                      (a) => Container(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.alternate),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.person, color: theme.primary),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    a.displayName.isEmpty
                                        ? '(sin nombre)'
                                        : a.displayName,
                                    style: theme.bodyMedium.override(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2.0),
                                  Text(a.email,
                                      style: theme.bodySmall.override(
                                          color: theme.secondaryText)),
                                  if (a.phoneNumber.isNotEmpty)
                                    Text(a.phoneNumber,
                                        style: theme.bodySmall.override(
                                            color: theme.secondaryText)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
