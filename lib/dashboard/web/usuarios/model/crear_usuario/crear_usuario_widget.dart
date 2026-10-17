import 'package:firebase_auth/firebase_auth.dart';
import '/auth/correo_registrado.dart';
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
import '/backend/schema/shared/listas_fijas.dart';
import '../../../../../dashboard/web/usuarios/shared/user_form_fields.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import '/backend/schema/shared/ubicacion_colegio.dart';
import '/components/ubicacion_colegio/ubicacion_colegio_readonly.dart';
import 'crear_usuario_model.dart';
export 'crear_usuario_model.dart';

const List<String> kListaGrados = [
  '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11'
];

class CrearUsuarioWidget extends StatefulWidget {
  const CrearUsuarioWidget({super.key});

  @override
  State<CrearUsuarioWidget> createState() => _CrearUsuarioWidgetState();
}

class _CrearUsuarioWidgetState extends State<CrearUsuarioWidget> {
  late CrearUsuarioModel _model;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// Catálogo de colegios: nombres para el desplegable y municipio/barrio
  /// de cada uno (la ubicación del adolescente sale del colegio).
  List<ColegiosRecord> _colegios = [];
  List<String> _colegiosNombres = [];
  bool _isLoadingColegios = true;

  Future<void> _loadColegios() async {
    try {
      final colegios = await queryColegiosRecordOnce();
      if (mounted) {
        setState(() {
          _colegios = colegios;
          _colegiosNombres = nombresDeColegios(colegios);
          _isLoadingColegios = false;
          _model.colegioDropDownController ??=
              FormFieldController<String>(null);
        });
      }
    } catch (e) {
      print('Error cargando colegios: $e');
      if (mounted) {
        setState(() {
          _isLoadingColegios = false;
        });
      }
    }
  }

  /// Elige el colegio y copia su municipio y barrio (solo lectura).
  void _seleccionarColegio(String? nombre) {
    final ubicacion = ubicacionDeColegio(_colegios, nombre);
    safeSetState(() {
      _model.textFieldcolegioTextController.text = nombre ?? '';
      _model.textFieldmunicipioTextController.text = ubicacion?.municipio ?? '';
      _model.textFieldbarrioTextController.text = ubicacion?.barrio ?? '';
    });
  }

  /// Explica por qué el correo ya está en uso: si pertenece a un perfil
  /// existente o a una cuenta de acceso sin perfil (p. ej. de un usuario
  /// eliminado antes de que Eliminar borrara también la cuenta Auth).
  Future<String> _mensajeCorreoEnUso(String email) async {
    try {
      final existente = await perfilConCorreo(email);
      if (existente != null) return mensajeCorreoRegistrado(email, existente);
    } catch (_) {}
    return 'Existe una cuenta de acceso sin perfil con el correo $email '
        '(posiblemente de un usuario eliminado). Contacta al administrador '
        'técnico para liberarla.';
  }

  // Avisa al padre (AdminUsuariosWidget) para que Cancelar y la flecha
  // vuelvan al listado al cambiar FFAppState().selectUser.
  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CrearUsuarioModel());
    // Cada vez que se abre, el formulario empieza vacío (al cancelar o
    // volver atrás el modelo conserva lo escrito).
    _model.limpiarFormulario();
    _loadColegios();

    _model.epsDropDownController ??= FormFieldController<String>(null);
    _model.gradoDropDownController ??= FormFieldController<String>(null);

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

    _model.textFieldedadTextController ??= TextEditingController();
    _model.textFieldedadFocusNode ??= FocusNode();

    _model.textFieldfechaNacimientoTextController ??= TextEditingController();
    _model.textFieldfechaNacimientoFocusNode ??= FocusNode();
    _model.textFieldcolegioTextController ??= TextEditingController();
    _model.textFieldcolegioFocusNode ??= FocusNode();
    _model.textFieldepsTextController ??= TextEditingController();
    _model.textFieldepsFocusNode ??= FocusNode();
    _model.textFieldgradoTextController ??= TextEditingController();
    _model.textFieldgradoFocusNode ??= FocusNode();
    _model.textFieldmunicipioTextController ??= TextEditingController();
    _model.textFieldmunicipioFocusNode ??= FocusNode();
    _model.textFieldbarrioTextController ??= TextEditingController();
    _model.textFieldbarrioFocusNode ??= FocusNode();

    _model.passwordTextController ??= TextEditingController();
    _model.passwordFocusNode ??= FocusNode();

    _model.repeatepasswordTextController ??= TextEditingController();
    _model.repeatepasswordFocusNode ??= FocusNode();

    _model.textFieldfechaNacimientoTextControllerValidator = (context, val) {
      if (val == null || val.isEmpty) {
        return null;
      }
      final parts = val.split('/');
      if (parts.length != 3) {
        return 'Formato inválido (DD/MM/YYYY)';
      }
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      if (day == null || month == null || year == null) {
        return 'Formato inválido (DD/MM/YYYY)';
      }
      if (month < 1 || month > 12) {
        return 'Mes inválido (1-12)';
      }
      if (day < 1 || day > 31) {
        return 'Día inválido (1-31)';
      }
      final daysInMonth = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
      if (day > daysInMonth[month - 1]) {
        return 'Día inválido para el mes';
      }
      if (month == 2 && day == 29) {
        final isLeap = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
        if (!isLeap) {
          return 'No es año bisiesto';
        }
      }
      if (year < 1900 || year > DateTime.now().year) {
        return 'Año inválido';
      }
      return null;
    };

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
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
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
                        _buildEdadGeneroRow(context),
                        if (_model.tipoValue == 'Adolescente') ...[
                          _buildNacimientoRow(context),
                          // El municipio y el barrio salen del colegio.
                          _buildColegioRow(context),
                          _buildUbicacionRow(context),
                          _buildEpsGradoRow(context),
                        ],
                        _buildPasswordRow(context),
                      ],
                    ),
                  ),
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

  Widget _buildEdadGeneroRow(BuildContext context) {
    final isAdolescente = _model.tipoValue == 'Adolescente';
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          if (isAdolescente)
            Expanded(
              child: LabeledTextField(
                label: 'Edad',
                controller: _model.textFieldedadTextController,
                focusNode: _model.textFieldedadFocusNode,
                useErrorColor: false,
                validator: _model.textFieldedadTextControllerValidator
                    .asValidator(context),
              ),
            ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildFieldLabel(context, 'Género'),
                Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
                  child: buildStyledDropDown(
                    context: context,
                    controller: _model.dropDownGeneroValueController ??=
                        FormFieldController<String>(null),
                    options: ['Masculino', 'Femenino', 'Otro'],
                    onChanged: (val) =>
                        safeSetState(() => _model.dropDownGeneroValue = val),
                    hintText: 'Seleccionar género',
                    width: double.infinity,
                    height: 47.0,
                  ),
                ),
              ],
            ),
          ),
        ].divide(const SizedBox(width: 25.0)),
      ),
    );
  }

  Widget _buildNacimientoRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: LabeledTextField(
              label: 'Fecha de nacimiento',
              hintText: '(DD/MM/YYYY)',
              controller: _model.textFieldfechaNacimientoTextController,
              focusNode: _model.textFieldfechaNacimientoFocusNode,
              useErrorColor: false,
              keyboardType: TextInputType.datetime,
              inputFormatters: [
                DateInputFormatter(),
              ],
              validator: _model.textFieldfechaNacimientoTextControllerValidator
                  .asValidator(context),
              maxLength: 10,
            ),
          ),
          Expanded(child: const SizedBox()),
        ].divide(const SizedBox(width: 25.0)),
      ),
    );
  }

  Widget _buildColegioRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildFieldLabel(context, 'Colegio *'),
                Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                  child: _isLoadingColegios
                      ? Container(
                          height: 47.0,
                          decoration: BoxDecoration(
                            color: kFormFieldFillColor,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: const SizedBox(
                            width: 20.0,
                            height: 20.0,
                            child: CircularProgressIndicator(strokeWidth: 2.0),
                          ),
                        )
                      : buildSearchableDropDown(
                          context: context,
                          controller: _model.colegioDropDownController ??=
                              FormFieldController<String>(
                            _colegiosNombres.contains(
                                    _model.textFieldcolegioTextController.text)
                                ? _model.textFieldcolegioTextController.text
                                : null,
                          ),
                          options: _colegiosNombres,
                          onChanged: _seleccionarColegio,
                          hintText: 'Seleccionar colegio',
                          searchHintText: 'Buscar colegio',
                          width: double.infinity,
                          height: 47.0,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUbicacionRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
      child: UbicacionColegioReadonly(
        municipio: _model.textFieldmunicipioTextController.text,
        barrio: _model.textFieldbarrioTextController.text,
        colegioElegido:
            _model.textFieldcolegioTextController.text.trim().isNotEmpty,
      ),
    );
  }

  Widget _buildEpsGradoRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildFieldLabel(context, 'EPS'),
                Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                  child: buildSearchableDropDown(
                    context: context,
                    controller: _model.epsDropDownController ??=
                        FormFieldController<String>(
                      kListaEPS.contains(_model.textFieldepsTextController.text)
                          ? _model.textFieldepsTextController.text
                          : null,
                    ),
                    options: kListaEPS,
                    onChanged: (val) {
                      safeSetState(() {
                        _model.textFieldepsTextController.text = val ?? '';
                      });
                    },
                    hintText: 'Seleccionar EPS',
                    searchHintText: 'Buscar EPS',
                    width: double.infinity,
                    height: 47.0,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildFieldLabel(context, 'Grado Escolar'),
                Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                  child: buildSearchableDropDown(
                    context: context,
                    controller: _model.gradoDropDownController ??=
                        FormFieldController<String>(
                      kListaGrados.contains(_model.textFieldgradoTextController.text)
                          ? _model.textFieldgradoTextController.text
                          : null,
                    ),
                    options: kListaGrados,
                    onChanged: (val) {
                      safeSetState(() {
                        _model.textFieldgradoTextController.text = val ?? '';
                      });
                    },
                    hintText: 'Seleccionar grado',
                    searchHintText: 'Buscar grado',
                    width: double.infinity,
                    height: 47.0,
                  ),
                ),
              ],
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
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }
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

    // Mismo formato que Firebase Auth, para que coincida con Acudiente.correo.
    final emailVal = normalizarCorreo(_model.emailTextController.text);
    if (emailVal.isEmpty || !emailVal.contains('@') || !emailVal.contains('.')) {
      await showDialog(
        context: context,
        builder: (alertDialogContext) => WebViewAware(
          child: AlertDialog(
            title: const Text('Correo electrónico inválido',
                style: TextStyle(fontWeight: FontWeight.bold)),
            content: const Text(
                'Por favor, ingresa un correo electrónico válido para registrar al usuario.'),
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

    final passwordVal = _model.passwordTextController.text;
    final repeatPasswordVal = _model.repeatepasswordTextController.text;
    if (passwordVal.isEmpty || passwordVal.length < 6) {
      await showDialog(
        context: context,
        builder: (alertDialogContext) => WebViewAware(
          child: AlertDialog(
            title: const Text('Contraseña requerida',
                style: TextStyle(fontWeight: FontWeight.bold)),
            content: const Text(
                'La contraseña es obligatoria y debe tener al menos 6 caracteres.'),
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

    if (passwordVal != repeatPasswordVal) {
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

    if (_model.tipoValue == 'Adolescente' &&
        _model.textFieldcolegioTextController.text.trim().isEmpty) {
      await showDialog(
        context: context,
        builder: (alertDialogContext) => WebViewAware(
          child: AlertDialog(
            title: const Text('Institución requerida',
                style: TextStyle(fontWeight: FontWeight.bold)),
            content: const Text(
                'Por favor, selecciona una institución de la lista.'),
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

    // Auth solo rechaza correos de cuentas de acceso; los adolescentes
    // registrados por un profesional no tienen cuenta y solo se ven aquí.
    UsersRecord? perfilExistente;
    try {
      perfilExistente = await perfilConCorreo(emailVal);
    } catch (_) {}
    if (perfilExistente != null) {
      final mensaje = mensajeCorreoRegistrado(emailVal, perfilExistente);
      await showDialog(
        context: context,
        builder: (alertDialogContext) => WebViewAware(
          child: AlertDialog(
            title: const Text('Correo ya registrado',
                style: TextStyle(fontWeight: FontWeight.bold)),
            content: Text(mensaje),
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

    final isCreatingAcudiente =
        _model.tipoValue == 'Acudiente' || _model.tipoValue == 'Padre';
    final isAdolescente = _model.tipoValue == 'Adolescente';

    // B8: Realizar queries mientras el admin sigue autenticado (antes de crear el usuario)
    UsersRecord? selectedAdolescenteDoc;
    if (isCreatingAcudiente &&
        _model.dropDownValue1 != null &&
        _model.dropDownValue1!.isNotEmpty) {
      selectedAdolescenteDoc = await queryUsersRecordOnce(
        queryBuilder: (usersRecord) => usersRecord.where(
          'display_name',
          isEqualTo: _model.dropDownValue1,
        ),
        singleRecord: true,
      ).then((s) => s.firstOrNull);
    } else if (!isCreatingAcudiente &&
        _model.dropDownValue1 != null &&
        _model.dropDownValue1!.isNotEmpty) {
      _model.getRefAcud = await queryUsersRecordOnce(
        queryBuilder: (usersRecord) => usersRecord.where(
          'display_name',
          isEqualTo: _model.dropDownValue1,
        ),
        singleRecord: true,
      ).then((s) => s.firstOrNull);
    }

    if (_model.dropDownValue2 != null &&
        _model.dropDownValue2!.isNotEmpty) {
      // El desplegable guarda el id del perfil del profesional.
      _model.getRefProf = await UsersRecord.getDocumentOnce(
          UsersRecord.collection.doc(_model.dropDownValue2));
    }

    final fechaNac = () {
      final text = _model.textFieldfechaNacimientoTextController.text.trim();
      if (text.isEmpty) return null;
      final parts = text.split('/');
      if (parts.length == 3) {
        final day = int.tryParse(parts[0]);
        final month = int.tryParse(parts[1]);
        final year = int.tryParse(parts[2]);
        if (day != null && month != null && year != null) {
          return DateTime(year, month, day);
        }
      }
      return DateTime.tryParse(text);
    }();

    FirebaseApp secondaryApp;
    try {
      secondaryApp = Firebase.app('secondary');
    } catch (_) {
      secondaryApp = await Firebase.initializeApp(
        name: 'secondary',
        options: Firebase.app().options,
      );
    }
    FirebaseAuth secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

    User? authUser;
    try {
      final userCredential = await secondaryAuth.createUserWithEmailAndPassword(
        email: emailVal,
        password: passwordVal,
      );
      authUser = userCredential.user;
    } on FirebaseAuthException catch (e) {
      String errMsg = 'Error al registrar el usuario.';
      if (e.code == 'email-already-in-use') {
        errMsg = await _mensajeCorreoEnUso(emailVal);
      } else if (e.code == 'invalid-email') {
        errMsg = 'El correo electrónico no es válido.';
      } else if (e.code == 'weak-password') {
        errMsg = 'La contraseña es muy débil (debe tener al menos 6 caracteres).';
      }
      await showDialog(
        context: context,
        builder: (alertDialogContext) => WebViewAware(
          child: AlertDialog(
            title: const Text('Error de registro',
                style: TextStyle(fontWeight: FontWeight.bold)),
            content: Text(errMsg),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(alertDialogContext),
                child: const Text('Entendido'),
              ),
            ],
          ),
        ),
      );
      return;
    } catch (e) {
      await showDialog(
        context: context,
        builder: (alertDialogContext) => WebViewAware(
          child: AlertDialog(
            title: const Text('Error inesperado',
                style: TextStyle(fontWeight: FontWeight.bold)),
            content: Text('Ha ocurrido un error inesperado: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(alertDialogContext),
                child: const Text('Entendido'),
              ),
            ],
          ),
        ),
      );
      return;
    }

    if (authUser == null) return;

    // Crear todo usando set() en un solo paso usando el UID obtenido (no requiere query adicional)
    final newAcudienteRef = UsersRecord.collection.doc(authUser.uid);
    try {
      await newAcudienteRef.set(createUsersRecordData(
            createdTime: getCurrentTimestamp,
            email: emailVal,
            displayName: _model.textController1.text,
            photoUrl: '',
            rol: _model.tipoValue,
            phoneNumber: _model.textController2.text,
            address: _model.textController4.text,
            acudiente: (isCreatingAcudiente ||
                    _model.dropDownValue1 == null ||
                    _model.dropDownValue1!.isEmpty)
                ? null
                : updateAcudienteStruct(
                    AcudienteStruct(
                      nombre: _model.dropDownValue1,
                      ref: _model.getRefAcud?.reference,
                      correo: _model.getRefAcud?.email,
                    ),
                    clearUnsetFields: false,
                  ),
            profesionales: (_model.dropDownValue2 == null ||
                    _model.dropDownValue2!.isEmpty ||
                    _model.getRefProf == null)
                ? null
                : updateProfesionalesStruct(
                    ProfesionalesStruct(
                      nombre: _model.getRefProf!.displayName,
                      ref: _model.getRefProf!.reference,
                    ),
                    clearUnsetFields: false,
                  ),
            identidad: _model.textController3.text,
            edad: isAdolescente ? _model.textFieldedadTextController.text : null,
            genero: _model.dropDownGeneroValue,
            fechaNacimiento: isAdolescente ? fechaNac : null,
            colegio: isAdolescente ? _model.textFieldcolegioTextController.text : null,
            eps: isAdolescente ? _model.textFieldepsTextController.text : null,
            grado: isAdolescente ? _model.textFieldgradoTextController.text : null,
            municipio: isAdolescente ? _model.textFieldmunicipioTextController.text : null,
            barrio: isAdolescente ? _model.textFieldbarrioTextController.text : null,
          ));
    } catch (e) {
      // Alta a medias: la cuenta Auth existe pero el perfil no se guardó.
      // Se borra la cuenta para no dejar el correo bloqueado.
      try {
        await authUser.delete();
      } catch (_) {}
      await secondaryAuth.signOut();
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (alertDialogContext) => WebViewAware(
          child: AlertDialog(
            title: const Text('Error de registro',
                style: TextStyle(fontWeight: FontWeight.bold)),
            content: Text(
                'No se pudo guardar el perfil del usuario, así que no se '
                'creó la cuenta. Intenta de nuevo.\n\nDetalle: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(alertDialogContext),
                child: const Text('Entendido'),
              ),
            ],
          ),
        ),
      );
      return;
    }

    // Si es Acudiente, vincular la relación en el documento del Adolescente seleccionado
    if (isCreatingAcudiente && selectedAdolescenteDoc != null) {
      await selectedAdolescenteDoc.reference.update(createUsersRecordData(
        acudiente: updateAcudienteStruct(
          AcudienteStruct(
            nombre: _model.textController1.text.trim(),
            correo: emailVal,
            telefono: _model.textController2.text.trim(),
            ref: newAcudienteRef,
          ),
          clearUnsetFields: false,
        ),
      ));
    }

    // Cerrar sesión en la instancia de Firebase Auth secundaria para limpiar recursos
    await secondaryAuth.signOut();

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

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.length > 8) return oldValue;

    // Auto-pad day if first digit > 3
    if (text.length == 1) {
      if (int.parse(text) > 3) {
        text = '0$text';
      }
    }
    
    // Auto-pad month if first digit of month > 1
    if (text.length == 3) {
      if (int.parse(text[2]) > 1) {
        text = '${text.substring(0, 2)}0${text[2]}';
      }
    }

    if (text.length >= 2) {
      final day = int.tryParse(text.substring(0, 2));
      if (day != null && (day < 1 || day > 31)) {
        return oldValue;
      }
    }
    if (text.length >= 4) {
      final month = int.tryParse(text.substring(2, 4));
      if (month != null && (month < 1 || month > 12)) {
        return oldValue;
      }
    }

    String formatted = '';
    for (int i = 0; i < text.length; i++) {
      if (i == 2 || i == 4) formatted += '/';
      formatted += text[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
