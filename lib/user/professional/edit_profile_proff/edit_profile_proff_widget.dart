import '/auth/firebase_auth/auth_util.dart';
import '/user/registration/sesion_app.dart';
import '/backend/backend.dart';
import '/backend/firebase_storage/storage.dart';
import '/components/button_vazado/button_vazado_widget.dart';
import '/components/header_prof_back/header_prof_back_widget.dart';
import '/components/registartion_button/registartion_button_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/upload_data.dart';
import '/index.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'edit_profile_proff_model.dart';
export 'edit_profile_proff_model.dart';

part 'edit_profile_proff_form_sections.dart';
part 'edit_profile_proff_form_sections2.dart';

class EditProfileProffWidget extends StatefulWidget {
  const EditProfileProffWidget({super.key});

  static String routeName = 'EditProfileProff';
  static String routePath = '/editProfileProff';

  @override
  State<EditProfileProffWidget> createState() => _EditProfileProffWidgetState();
}

class _EditProfileProffWidgetState extends State<EditProfileProffWidget> {
  late EditProfileProffModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  String? _generoSeleccionado;
  DateTime? _fechaNacimiento;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EditProfileProffModel());

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
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 40.0, 0.0, 0.0),
                child: Container(
                  decoration: BoxDecoration(),
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(20.0, 10.0, 20.0, 10.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Stack(
                                    alignment: AlignmentDirectional(1.0, 1.0),
                                    children: [
                                      AuthUserStreamWidget(
                                        builder: (context) => Container(
                                          width: 120.0,
                                          height: 120.0,
                                          clipBehavior: Clip.antiAlias,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                          ),
                                          child: CachedNetworkImage(
                                            fadeInDuration:
                                                Duration(milliseconds: 500),
                                            fadeOutDuration:
                                                Duration(milliseconds: 500),
                                            imageUrl: valueOrDefault<String>(
                                              _model.uploadedFileUrl_uploadDataB3e !=
                                                          ''
                                                  ? _model
                                                      .uploadedFileUrl_uploadDataB3e
                                                  : valueOrDefault<String>(
                                                      currentUserPhoto,
                                                      'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/conecta2-wtnr9n/assets/9yllj3p8hz5o/User.png',
                                                    ),
                                              'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/conecta2-wtnr9n/assets/9yllj3p8hz5o/User.png',
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          final selectedMedia =
                                              await selectMediaWithSourceBottomSheet(
                                            context: context,
                                            allowPhoto: true,
                                          );
                                          if (selectedMedia != null &&
                                              selectedMedia.every((m) =>
                                                  validateFileFormat(
                                                      m.storagePath,
                                                      context))) {
                                            safeSetState(() => _model
                                                    .isDataUploading_uploadDataB3e =
                                                true);
                                            var selectedUploadedFiles =
                                                <FFUploadedFile>[];

                                            var downloadUrls = <String>[];
                                            try {
                                              selectedUploadedFiles =
                                                  selectedMedia
                                                      .map(
                                                          (m) => FFUploadedFile(
                                                                name: m
                                                                    .storagePath
                                                                    .split('/')
                                                                    .last,
                                                                bytes: m.bytes,
                                                                height: m
                                                                    .dimensions
                                                                    ?.height,
                                                                width: m
                                                                    .dimensions
                                                                    ?.width,
                                                                blurHash:
                                                                    m.blurHash,
                                                                originalFilename:
                                                                    m.originalFilename,
                                                              ))
                                                      .toList();

                                              downloadUrls = (await Future.wait(
                                                selectedMedia.map(
                                                  (m) async => await uploadData(
                                                      m.storagePath, m.bytes),
                                                ),
                                              ))
                                                  .where((u) => u != null)
                                                  .map((u) => u!)
                                                  .toList();
                                            } finally {
                                              _model.isDataUploading_uploadDataB3e =
                                                  false;
                                            }
                                            if (selectedUploadedFiles.length ==
                                                    selectedMedia.length &&
                                                downloadUrls.length ==
                                                    selectedMedia.length) {
                                              safeSetState(() {
                                                _model.uploadedLocalFile_uploadDataB3e =
                                                    selectedUploadedFiles.first;
                                                _model.uploadedFileUrl_uploadDataB3e =
                                                    downloadUrls.first;
                                              });
                                            } else {
                                              safeSetState(() {});
                                              return;
                                            }
                                          }
                                        },
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          child: Image.asset(
                                            'assets/images/Group_274.png',
                                            width: 35.0,
                                            height: 35.0,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
                                btnText: 'Restaurar contrasena',
                                btnAction: () async {
                                  if (correoDeAcceso.isEmpty) {
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
                                    email: correoDeAcceso,
                                    context: context,
                                  );
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 5.0, 0.0, 20.0),
                            child: wrapWithModel(
                              model: _model.registartionButtonModel,
                              updateCallback: () => safeSetState(() {}),
                              child: RegistartionButtonWidget(
                                btnText: 'Enviar',
                                btnAction: () async {
                                  await currentUserReference!
                                      .update(createUsersRecordData(
                                    // El correo no se edita: es el de acceso.
                                    displayName:
                                        _model.textFieldnameTextController.text,
                                    address: _model
                                        .textFieldaddressTextController.text,
                                    phoneNumber: _model
                                        .textFieldphoneTextController.text,
                                    genero: _generoSeleccionado ?? '',
                                    fechaNacimiento: _fechaNacimiento,
                                    photoUrl: valueOrDefault<String>(
                                      _model.uploadedFileUrl_uploadDataB3e !=
                                                  ''
                                          ? _model.uploadedFileUrl_uploadDataB3e
                                          : valueOrDefault<String>(
                                              currentUserPhoto,
                                              'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/conecta2-wtnr9n/assets/9yllj3p8hz5o/User.png',
                                            ),
                                      'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/conecta2-wtnr9n/assets/9yllj3p8hz5o/User.png',
                                    ),
                                  ));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Datos guardados con éxito',
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
                  name: 'Mi Perfil',
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Género', style: GoogleFonts.outfit(fontSize: 14, color: theme.primaryText)),
          const SizedBox(height: 8),
          Row(mainAxisSize: MainAxisSize.max, children: [
            Expanded(
              child: InkWell(
                onTap: () async {
                  final selected = await showModalBottomSheet<String>(
                    context: context,
                    builder: (ctx) => SafeArea(
                      child: Wrap(
                        children: const ['Masculino', 'Femenino', 'Otro', 'Prefiero no decirlo']
                            .map((g) => ListTile(title: Text(g), onTap: () => Navigator.of(ctx).pop(g)))
                            .toList(),
                      ),
                    ),
                  );
                  if (selected != null) safeSetState(() => _generoSeleccionado = selected);
                },
                child: Container(
                  height: 47,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.alternate, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(children: [
                    Expanded(
                      child: Text(
                        _generoSeleccionado ?? 'Selecciona género',
                        style: GoogleFonts.inter(
                          color: _generoSeleccionado == null ? const Color(0x7C1F2129) : theme.primaryText,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_drop_down, color: theme.secondaryText),
                  ]),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 16),
          Text('Fecha de nacimiento', style: GoogleFonts.outfit(fontSize: 14, color: theme.primaryText)),
          const SizedBox(height: 8),
          Row(mainAxisSize: MainAxisSize.max, children: [
            Expanded(
              child: InkWell(
                onTap: () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _fechaNacimiento ?? DateTime(now.year - 30, now.month, now.day),
                    firstDate: DateTime(1940),
                    lastDate: now,
                  );
                  if (picked != null) safeSetState(() => _fechaNacimiento = picked);
                },
                child: Container(
                  height: 47,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.alternate, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(children: [
                    Expanded(
                      child: Text(
                        _fechaNacimiento == null
                            ? 'Selecciona fecha'
                            : '${_fechaNacimiento!.day.toString().padLeft(2, '0')}/${_fechaNacimiento!.month.toString().padLeft(2, '0')}/${_fechaNacimiento!.year}',
                        style: GoogleFonts.inter(
                          color: _fechaNacimiento == null ? const Color(0x7C1F2129) : theme.primaryText,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Icon(Icons.calendar_today, size: 18, color: theme.secondaryText),
                  ]),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
