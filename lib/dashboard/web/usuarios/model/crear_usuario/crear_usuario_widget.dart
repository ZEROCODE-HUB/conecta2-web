import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/firebase_storage/storage.dart';
import '/components/successpopup_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/flutter_flow/upload_data.dart';
import '/index.dart';
import '../../../../../dashboard/web/usuarios/shared/form_acudiente_fields.dart';
import '../../../../../dashboard/web/usuarios/shared/form_adolescente_fields.dart';
import '../../../../../dashboard/web/usuarios/shared/user_form_fields.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'crear_usuario_model.dart';
export 'crear_usuario_model.dart';

class CrearUsuarioWidget extends StatefulWidget {
  const CrearUsuarioWidget({super.key});

  @override
  State<CrearUsuarioWidget> createState() => _CrearUsuarioWidgetState();
}

class _CrearUsuarioWidgetState extends State<CrearUsuarioWidget> {
  late CrearUsuarioModel _model;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CrearUsuarioModel());

    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.emailTextController ??= TextEditingController();
    _model.emailFocusNode ??= FocusNode();

    _model.textController2 ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();

    _model.textController3 ??= TextEditingController();
    _model.textFieldFocusNode3 ??= FocusNode();

    _model.textController4 ??= TextEditingController();
    _model.textFieldFocusNode4 ??= FocusNode();

    _model.passwordTextController ??= TextEditingController();
    _model.passwordFocusNode ??= FocusNode();

    _model.repeatepasswordTextController ??= TextEditingController();
    _model.repeatepasswordFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Container(
                      height: MediaQuery.sizeOf(context).height * 1.0,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            40.0, 20.0, 40.0, 20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildHeaderRow(context),
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 45.0, 0.0, 0.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildSidebarCard(context),
                                    Flexible(child: _buildFormCard(context)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------- Header --------
  Widget _buildHeaderRow(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        InkWell(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () async {
            FFAppState().selectUser = '';
            safeSetState(() {});
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: safeAssetImage(
              'assets/images/Down.png',
              width: 26.0,
              height: 26.0,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 0.0, 0.0),
            child: Text(
              'Crear Usuario',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
                    fontSize: 36.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 10.0, 0.0),
                  child: AuthUserStreamWidget(
                    builder: (context) => ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: CachedNetworkImage(
                        fadeInDuration: const Duration(milliseconds: 500),
                        fadeOutDuration: const Duration(milliseconds: 500),
                        imageUrl: valueOrDefault<String>(
                          currentUserPhoto,
                          kDefaultAvatarUrl,
                        ),
                        width: 30.0,
                        height: 30.0,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => const Icon(
                          Icons.person,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                AuthUserStreamWidget(
                  builder: (context) => Text(
                    currentUserDisplayName,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                          fontSize: 18.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // -------- Sidebar card (avatar + role-specific dropdowns) --------
  Widget _buildSidebarCard(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width * 0.2,
      height: MediaQuery.sizeOf(context).height * 1.0,
      decoration: sharedCardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatarStack(context),
            if (_model.tipoValue == 'Adolescente')
              AdolescenteSidebarFields(
                acudienteController: () => _model.dropDownValueController1 ??=
                    FormFieldController<String>(_model.dropDownValue1 ??= ''),
                profesionalController: () => _model.dropDownValueController2 ??=
                    FormFieldController<String>(null),
                onAcudienteChanged: (val) =>
                    safeSetState(() => _model.dropDownValue1 = val),
                onProfesionalChanged: (val) =>
                    safeSetState(() => _model.dropDownValue2 = val),
              )
            else if (_model.tipoValue == 'Acudiente')
              AcudienteSidebarFields(
                adolescenteController: () => _model.dropDownValueController1 ??=
                    FormFieldController<String>(_model.dropDownValue1 ??= ''),
                profesionalController: () => _model.dropDownValueController2 ??=
                    FormFieldController<String>(null),
                onAdolescenteChanged: (val) =>
                    safeSetState(() => _model.dropDownValue1 = val),
                onProfesionalChanged: (val) =>
                    safeSetState(() => _model.dropDownValue2 = val),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarStack(BuildContext context) {
    return Stack(
      alignment: const AlignmentDirectional(1.0, 1.0),
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 40.0, 0.0, 0.0),
          child: Container(
            width: 106.0,
            height: 106.0,
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(
                  _model.uploadedFileUrl_uploadImage != ''
                      ? _model.uploadedFileUrl_uploadImage
                      : kDefaultAvatarUrl,
                ),
                onError: (exception, stackTrace) {},
              ),
              shape: BoxShape.circle,
            ),
          ),
        ),
        InkWell(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: _pickAndUploadAvatar,
          child: Container(
            width: 35.0,
            height: 35.0,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: safeAssetImage('assets/images/Group_273.png'),
          ),
        ),
      ],
    );
  }

  Future<void> _pickAndUploadAvatar() async {
    final selectedMedia = await selectMediaWithSourceBottomSheet(
      context: context,
      allowPhoto: true,
    );
    if (selectedMedia == null ||
        !selectedMedia
            .every((m) => validateFileFormat(m.storagePath, context))) {
      return;
    }
    safeSetState(() => _model.isDataUploading_uploadImage = true);

    var selectedUploadedFiles = <FFUploadedFile>[];
    var downloadUrls = <String>[];
    try {
      selectedUploadedFiles = selectedMedia
          .map((m) => FFUploadedFile(
                name: m.storagePath.split('/').last,
                bytes: m.bytes,
                height: m.dimensions?.height,
                width: m.dimensions?.width,
                blurHash: m.blurHash,
                originalFilename: m.originalFilename,
              ))
          .toList();

      downloadUrls = (await Future.wait(
        selectedMedia
            .map((m) async => await uploadData(m.storagePath, m.bytes)),
      ))
          .where((u) => u != null)
          .map((u) => u!)
          .toList();
    } finally {
      _model.isDataUploading_uploadImage = false;
    }
    if (selectedUploadedFiles.length == selectedMedia.length &&
        downloadUrls.length == selectedMedia.length) {
      safeSetState(() {
        _model.uploadedLocalFile_uploadImage = selectedUploadedFiles.first;
        _model.uploadedFileUrl_uploadImage = downloadUrls.first;
      });
    } else {
      safeSetState(() {});
    }
  }

  // -------- Main form card --------
  Widget _buildFormCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(30.0, 0.0, 0.0, 0.0),
      child: Container(
        height: MediaQuery.sizeOf(context).height * 1.0,
        decoration: sharedCardDecoration(),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.disabled,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 20.0, 0.0, 0.0),
                      child: buildSectionTitle(context, 'Datos personales'),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 20.0, 0.0, 0.0),
                      child: _buildTipoAndNombreRow(context),
                    ),
                    _buildEmailPhoneRow(context),
                    _buildIdentityAddressRow(context),
                    _buildPasswordRow(context),
                  ],
                ),
              ),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipoAndNombreRow(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildFieldLabel(context, 'Tipo de usuario'),
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                child: buildStyledDropDown(
                  context: context,
                  controller: _model.tipoValueController ??=
                      FormFieldController<String>(null),
                  options: kUserRoles,
                  onChanged: (val) =>
                      safeSetState(() => _model.tipoValue = val),
                  hintText: 'Elige el tipo de usuario',
                  width: double.infinity,
                  height: 47.0,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: LabeledTextField(
            label: 'Nombres y Apellidos *',
            controller: _model.textController1,
            focusNode: _model.textFieldFocusNode1,
            autofocus: true,
            validator: _model.textController1Validator.asValidator(context),
          ),
        ),
      ].divide(const SizedBox(width: 25.0)),
    );
  }

  Widget _buildEmailPhoneRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: LabeledTextField(
              label: 'Correo electrónico *',
              controller: _model.emailTextController,
              focusNode: _model.emailFocusNode,
              autofocus: true,
              fontWeight: FontWeight.w500,
              validator:
                  _model.emailTextControllerValidator.asValidator(context),
            ),
          ),
          Expanded(
            child: LabeledTextField(
              label: 'Celular',
              controller: _model.textController2,
              focusNode: _model.textFieldFocusNode2,
              autofocus: true,
              maxLength: 12,
              fontWeight: FontWeight.w500,
              validator: _model.textController2Validator.asValidator(context),
            ),
          ),
        ].divide(const SizedBox(width: 25.0)),
      ),
    );
  }

  Widget _buildIdentityAddressRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: LabeledTextField(
              label: 'Documento de identidad *',
              controller: _model.textController3,
              focusNode: _model.textFieldFocusNode3,
              useErrorColor: false,
              validator: _model.textController3Validator.asValidator(context),
            ),
          ),
          Expanded(
            child: LabeledTextField(
              label: 'Dirección',
              controller: _model.textController4,
              focusNode: _model.textFieldFocusNode4,
              autofocus: true,
              validator: _model.textController4Validator.asValidator(context),
            ),
          ),
        ].divide(const SizedBox(width: 25.0)),
      ),
    );
  }

  Widget _buildPasswordRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: LabeledTextField(
              label: 'Contraseña *',
              controller: _model.passwordTextController,
              focusNode: _model.passwordFocusNode,
              obscureText: !_model.passwordVisibility,
              useErrorColor: false,
              suffixIcon: InkWell(
                onTap: () => safeSetState(() =>
                    _model.passwordVisibility = !_model.passwordVisibility),
                focusNode: FocusNode(skipTraversal: true),
                child: Icon(
                  _model.passwordVisibility
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 22,
                ),
              ),
              validator:
                  _model.passwordTextControllerValidator.asValidator(context),
            ),
          ),
          Expanded(
            child: LabeledTextField(
              label: 'Repetir contraseña *',
              controller: _model.repeatepasswordTextController,
              focusNode: _model.repeatepasswordFocusNode,
              obscureText: !_model.repeatepasswordVisibility,
              suffixIcon: InkWell(
                onTap: () => safeSetState(() =>
                    _model.repeatepasswordVisibility =
                        !_model.repeatepasswordVisibility),
                focusNode: FocusNode(skipTraversal: true),
                child: Icon(
                  _model.repeatepasswordVisibility
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 22,
                ),
              ),
              validator: _model.repeatepasswordTextControllerValidator
                  .asValidator(context),
            ),
          ),
        ].divide(const SizedBox(width: 25.0)),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 40.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildSecondaryButton(
            context: context,
            text: 'Cancelar',
            onPressed: () async {
              FFAppState().selectUser = '';
              safeSetState(() {});
            },
          ),
          Builder(
            builder: (context) => buildPrimaryButton(
              context: context,
              text: 'Crear nuevo usuario',
              onPressed: _onCreatePressed,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onCreatePressed() async {
    if (_model.tipoValue == null ||
        _model.tipoValue!.isEmpty ||
        _model.textController1.text.trim().isEmpty ||
        _model.textController3.text.trim().isEmpty) {
      await showDialog(
        context: context,
        builder: (alertDialogContext) => WebViewAware(
          child: AlertDialog(
            title: const Text('Campos obligatorios incompletos',
                style: TextStyle(fontWeight: FontWeight.bold)),
            content: const Text(
                'Por favor, asegúrate de seleccionar el "Tipo de usuario", e ingresar los "Nombres y Apellidos" y el "Documento de identidad" para registrar al usuario.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(alertDialogContext),
                child: const Text('Entendido'),
              ),
            ],
          ),
        ),
      );
      safeSetState(() {});
      return;
    }

    if (_model.passwordTextController.text !=
        _model.repeatepasswordTextController.text) {
      await showDialog(
        context: context,
        builder: (alertDialogContext) => WebViewAware(
          child: AlertDialog(
            title: const Text('Error en la contraseña',
                style: TextStyle(fontWeight: FontWeight.bold)),
            content: const Text(
                'Las contraseñas ingresadas no coinciden. Por favor, verifícalas e inténtalo nuevamente.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(alertDialogContext),
                child: const Text('Entendido'),
              ),
            ],
          ),
        ),
      );
      safeSetState(() {});
      return;
    }

    // B8: Realizar queries mientras el admin sigue autenticado (antes de crear el usuario)
    _model.getRefAcud = await queryUsersRecordOnce(
      queryBuilder: (usersRecord) => usersRecord.where(
        'display_name',
        isEqualTo: _model.dropDownValue1,
      ),
      singleRecord: true,
    ).then((s) => s.firstOrNull);
    _model.getRefProf = await queryUsersRecordOnce(
      queryBuilder: (usersRecord) => usersRecord.where(
        'display_name',
        isEqualTo: _model.dropDownValue2,
      ),
      singleRecord: true,
    ).then((s) => s.firstOrNull);

    GoRouter.of(context).prepareAuthEvent();
    final user = await authManager.createAccountWithEmail(
      context,
      _model.emailTextController.text,
      _model.passwordTextController.text,
    );
    if (user == null) return;

    // Actualizar todo en un solo paso usando user.uid (no requiere query adicional)
    await UsersRecord.collection.doc(user.uid).update(createUsersRecordData(
          createdTime: getCurrentTimestamp,
          email: _model.emailTextController.text,
          displayName: _model.textController1.text,
          photoUrl: '',
          rol: _model.tipoValue,
          phoneNumber: _model.textController2.text,
          address: _model.textController4.text,
          acudiente: updateAcudienteStruct(
            AcudienteStruct(
              nombre: _model.dropDownValue1,
              ref: _model.getRefAcud?.reference,
              correo: _model.getRefAcud?.email,
            ),
            clearUnsetFields: false,
          ),
          profesionales: updateProfesionalesStruct(
            ProfesionalesStruct(
              nombre: _model.dropDownValue2,
              ref: _model.getRefProf?.reference,
            ),
            clearUnsetFields: false,
          ),
          identidad: _model.textController3.text,
        ));

    await showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        elevation: 0,
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        alignment: const AlignmentDirectional(0.0, 0.0)
            .resolve(Directionality.of(context)),
        child: WebViewAware(child: SuccesspopupWidget()),
      ),
    );

    FFAppState().selectUser = '';
    safeSetState(() {});

    context.goNamedAuth(
      SplashadminWidget.routeName,
      context.mounted,
      extra: <String, dynamic>{
        '__transition_info__': TransitionInfo(
          hasTransition: true,
          transitionType: PageTransitionType.fade,
          duration: Duration(milliseconds: 0),
        ),
      },
    );
  }
}
