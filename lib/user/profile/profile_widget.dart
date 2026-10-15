import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/user/registration/sesion_app.dart';
import '/components/button_vazado/button_vazado_widget.dart';
import '/components/registartion_button/registartion_button_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'profile_model.dart';
import 'widgets/profile_actions.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_stats.dart';
export 'profile_model.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  static String routeName = 'profile';
  static String routePath = '/profile';

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  late ProfileModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  String? _generoSeleccionado;
  DateTime? _fechaNacimiento;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ProfileModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (loggedIn) {
        await currentUserReference!
            .update(createUsersRecordData(status: 1));
      } else {
        await currentUserReference!
            .update(createUsersRecordData(status: 0));
      }
    });

    _model.textFieldnameTextController ??=
        TextEditingController(text: currentUserDisplayName);
    _model.textFieldnameFocusNode ??= FocusNode();

    _model.textFieldemailTextController ??=
        TextEditingController(text: correoDeAcceso);
    _model.textFieldemailFocusNode ??= FocusNode();

    _model.textFieldphoneTextController ??=
        TextEditingController(text: currentPhoneNumber);
    _model.textFieldphoneFocusNode ??= FocusNode();

    _model.textFielddniTextController ??= TextEditingController(
        text: valueOrDefault(currentUserDocument?.identidad, ''));
    _model.textFielddniFocusNode ??= FocusNode();

    _model.textFieldaddressTextController ??= TextEditingController(
        text: valueOrDefault(currentUserDocument?.address, ''));
    _model.textFieldaddressFocusNode ??= FocusNode();

    final userDoc = currentUserDocument;
    if (userDoc != null) {
      _generoSeleccionado = userDoc.genero.isEmpty ? null : userDoc.genero;
      _fechaNacimiento = userDoc.fechaNacimiento;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  String get _resolvedPhotoUrl {
    if (_model.uploadedFileUrl_uploadDataB3e369.isNotEmpty) {
      return _model.uploadedFileUrl_uploadDataB3e369;
    }
    return valueOrDefault<String>(currentUserPhoto, kDefaultProfileAvatar);
  }

  Future<void> _onSubmit() async {
    // El correo no se edita aquí: es el de acceso (Firebase Auth).
    await currentUserReference!.update(createUsersRecordData(
      displayName: _model.textFieldnameTextController.text,
      photoUrl: valueOrDefault<String>(_resolvedPhotoUrl, kDefaultProfileAvatar),
      phoneNumber: _model.textFieldphoneTextController.text,
      address: _model.textFieldaddressTextController.text,
      identidad: _model.textFielddniTextController.text,
      genero: _generoSeleccionado ?? '',
      fechaNacimiento: _fechaNacimiento,
    ));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Datos actualizados con éxito',
          style: TextStyle(
            color: FlutterFlowTheme.of(context).primaryBackground,
          ),
        ),
        duration: const Duration(milliseconds: 4000),
        backgroundColor: FlutterFlowTheme.of(context).menuWeb,
      ),
    );
  }

  Future<void> _onResetPassword() async {
    if (correoDeAcceso.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontró tu correo de acceso.')),
      );
      return;
    }
    await authManager.resetPassword(
      email: correoDeAcceso,
      context: context,
    );
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
          child: Stack(
            children: [
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(0.0, 40.0, 0.0, 0.0),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                      20.0, 10.0, 20.0, 10.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            ProfileHeader(
                              uploadedFileUrl:
                                  _model.uploadedFileUrl_uploadDataB3e369,
                              onUploading: (uploading) => safeSetState(() {
                                _model.isDataUploading_uploadDataB3e369 =
                                    uploading;
                              }),
                              onUploaded: (file, url) => safeSetState(() {
                                _model.uploadedLocalFile_uploadDataB3e369 =
                                    file;
                                _model.uploadedFileUrl_uploadDataB3e369 = url;
                              }),
                            ),
                            ProfileFormField(
                              label: 'Nombres y apelidos',
                              hintText: 'Nombres y apelidos',
                              controller:
                                  _model.textFieldnameTextController!,
                              focusNode: _model.textFieldnameFocusNode!,
                              validator:
                                  _model.textFieldnameTextControllerValidator,
                            ),
                            ProfileFormField(
                              label: 'Correo electrónico',
                              hintText: 'Correo electrónico',
                              controller:
                                  _model.textFieldemailTextController!,
                              focusNode: _model.textFieldemailFocusNode!,
                              validator:
                                  _model.textFieldemailTextControllerValidator,
                              wrapInAuthStream: false,
                              readOnly: true,
                              nota: 'Es tu correo de acceso. Para cambiarlo, '
                                  'contacta al administrador.',
                            ),
                            ProfileFormField(
                              label: 'Celular',
                              hintText: 'Celular',
                              controller:
                                  _model.textFieldphoneTextController!,
                              focusNode: _model.textFieldphoneFocusNode!,
                              validator:
                                  _model.textFieldphoneTextControllerValidator,
                            ),
                            ProfileFormField(
                              label: 'Documento de identidad',
                              hintText: 'Documento de identidad',
                              controller: _model.textFielddniTextController!,
                              focusNode: _model.textFielddniFocusNode!,
                              validator:
                                  _model.textFielddniTextControllerValidator,
                            ),
                            ProfileFormField(
                              label: 'Dirección',
                              hintText: 'Dirección',
                              controller:
                                  _model.textFieldaddressTextController!,
                              focusNode: _model.textFieldaddressFocusNode!,
                              validator: _model
                                  .textFieldaddressTextControllerValidator,
                            ),
                            _buildGeneroYFecha(context),
                            const ProfileLogoutButton(),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 32.0, 0.0, 12.0),
                          child: wrapWithModel(
                            model: _model.buttonVazadoModel,
                            updateCallback: () => safeSetState(() {}),
                            child: ButtonVazadoWidget(
                              btnText: 'Restaurar contrasena',
                              btnAction: _onResetPassword,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 5.0, 0.0, 20.0),
                          child: wrapWithModel(
                            model: _model.registartionButtonModel,
                            updateCallback: () => safeSetState(() {}),
                            child: RegistartionButtonWidget(
                              btnText: 'Enviar',
                              btnAction: _onSubmit,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ProfileBottomBar(profileRouteName: ProfileWidget.routeName),
              Positioned(
                top: 8,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGeneroYFecha(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Género',
              style: GoogleFonts.outfit(
                  fontSize: 14, color: theme.primaryText)),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final selected = await showModalBottomSheet<String>(
                context: context,
                builder: (ctx) => SafeArea(
                  child: Wrap(
                    children: const [
                      'Masculino',
                      'Femenino',
                      'Otro',
                      'Prefiero no decirlo',
                    ]
                        .map((g) => ListTile(
                              title: Text(g),
                              onTap: () => Navigator.of(ctx).pop(g),
                            ))
                        .toList(),
                  ),
                ),
              );
              if (selected != null) {
                safeSetState(() => _generoSeleccionado = selected);
              }
            },
            child: Container(
              height: 47,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: theme.alternate, width: 2),
                borderRadius: BorderRadius.circular(8),
                color: theme.secondaryBackground,
              ),
              child: Row(children: [
                Expanded(
                  child: Text(
                    _generoSeleccionado ?? 'Selecciona género',
                    style: GoogleFonts.inter(
                      color: _generoSeleccionado == null
                          ? const Color(0x7C1F2129)
                          : theme.primaryText,
                      fontSize: 14,
                    ),
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: theme.secondaryText),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          Text('Fecha de nacimiento',
              style: GoogleFonts.outfit(
                  fontSize: 14, color: theme.primaryText)),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: _fechaNacimiento ??
                    DateTime(now.year - 30, now.month, now.day),
                firstDate: DateTime(1940),
                lastDate: now,
              );
              if (picked != null) {
                safeSetState(() => _fechaNacimiento = picked);
              }
            },
            child: Container(
              height: 47,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: theme.alternate, width: 2),
                borderRadius: BorderRadius.circular(8),
                color: theme.secondaryBackground,
              ),
              child: Row(children: [
                Expanded(
                  child: Text(
                    _fechaNacimiento == null
                        ? 'Selecciona fecha'
                        : '${_fechaNacimiento!.day.toString().padLeft(2, '0')}/'
                            '${_fechaNacimiento!.month.toString().padLeft(2, '0')}/'
                            '${_fechaNacimiento!.year}',
                    style: GoogleFonts.inter(
                      color: _fechaNacimiento == null
                          ? const Color(0x7C1F2129)
                          : theme.primaryText,
                      fontSize: 14,
                    ),
                  ),
                ),
                Icon(Icons.calendar_today,
                    size: 18, color: theme.secondaryText),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
